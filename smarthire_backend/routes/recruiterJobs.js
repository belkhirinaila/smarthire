const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// CREATE JOB FINAL
// ==============================
router.post("/", protect, authorize("recruiter"), async (req, res) => {
  try {
    const {
      title,
      description,
      location,
      salary_min,
      salary_max,
      category,
      type,
      work_mode,
      skills,
      status
    } = req.body;

    // 🔍 validation
    if (!title || !description) {
      return res.status(400).json({
        message: "Champs obligatoires manquants"
      });
    }

    // 🔍 récupérer company
    const [company] = await db.query(
      "SELECT id FROM company_profiles WHERE user_id = ?",
      [req.user.id]
    );

    if (company.length === 0) {
      return res.status(400).json({
        message: "Créer une company d'abord"
      });
    }

    const companyId = company[0].id;

    // 📝 insert job
    const [result] = await db.query(
      `INSERT INTO jobs 
      (title, description, location, salary_min, salary_max, category,type, work_mode,status, company_id, created_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)`,
      [
        title,
        description,
        location,
        salary_min,
        salary_max,
        category,
        type,
        work_mode,
        status || "active",
        companyId,
        req.user.id
      ]
    );

    const jobId = result.insertId;

    // 🔥 skills
    if (Array.isArray(skills) && skills.length > 0) {
      for (let skill of skills) {
        await db.query(
          "INSERT INTO job_skills (job_id, skill_name) VALUES (?, ?)",
          [jobId, skill]
        );
      }
    }

    res.status(201).json({
      success: true,
      message: "Job created successfully",
      jobId
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// DELETE JOB
// ==============================
router.delete("/:id", protect, authorize("recruiter"), async (req, res) => {
  try {
    const jobId = req.params.id;

    await db.query(
      "DELETE FROM jobs WHERE id = ? AND created_by = ?",
      [jobId, req.user.id]
    );

    res.status(200).json({
      message: "Job supprimé"
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});

// ==============================
// GET MY JOBS
// ==============================
router.get("/my", protect, authorize("recruiter"), async (req, res) => {
  try {
    const [jobs] = await db.query(
      "SELECT * FROM jobs WHERE created_by = ?",
      [req.user.id]
    );

    res.status(200).json({ jobs });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// GET JOB DETAILS + SKILLS
// ==============================
router.get("/:id", protect, async (req, res) => {
  try {
    const jobId = req.params.id;

    const [job] = await db.query(
      "SELECT * FROM jobs WHERE id = ?",
      [jobId]
    );

    const [skills] = await db.query(
      "SELECT skill_name FROM job_skills WHERE job_id = ?",
      [jobId]
    );

    res.status(200).json({
      job: job[0],
      skills
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// UPDATE JOB + SKILLS
// ==============================
router.put("/:id", protect, authorize("recruiter"), async (req, res) => {
  try {
    const jobId = req.params.id;

    const {
      title,
      description,
      location,
      salary_min,
      salary_max,
      category,
      type,
      work_mode,
      skills,
      status
    } = req.body;

    // 🔄 update job
    await db.query(
  `UPDATE jobs 
   SET 
     title=?,
     description=?,
     location=?,
     salary_min=?,
     salary_max=?,
     category=?,
     type=?,
     work_mode=?,
     status=?
   WHERE id=? AND created_by=?`,
  [
    title,
    description,
    location,
    salary_min,
    salary_max,
    category,
    type,
    work_mode,
    status || "active", // 🔥 هنا

    jobId,              // 🔥 مهم الترتيب
    req.user.id
  ]
);

    // 🔥 supprimer anciens skills
    await db.query(
      "DELETE FROM job_skills WHERE job_id = ?",
      [jobId]
    );

    // 🔥 ajouter nouveaux skills
    if (skills && skills.length > 0) {
      for (let skill of skills) {
        await db.query(
          "INSERT INTO job_skills (job_id, skill_name) VALUES (?, ?)",
          [jobId, skill]
        );
      }
    }

    res.status(200).json({
      message: "Job updated successfully"
    });

  }
  catch (err) {
  console.log("🔥 ERROR UPDATE JOB:", err); // 👈 هذا مهم
  res.status(500).json({
    message: "Erreur serveur",
    error: err.message
  });
}
});


// ==============================
// CLOSE JOB
// ==============================
router.put("/:id/close", protect, authorize("recruiter"), async (req, res) => {
  try {
    const jobId = req.params.id;

    await db.query(
      "UPDATE jobs SET status='closed', closed_at=NOW() WHERE id=? AND created_by=?",
      [jobId, req.user.id]
    );

    res.status(200).json({
      message: "Job fermé"
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// INCREMENT VIEWS (bonus 🔥)
// ==============================
router.put("/:id/view", async (req, res) => {
  try {
    const jobId = req.params.id;

    await db.query(
      "UPDATE jobs SET views_count = views_count + 1 WHERE id=?",
      [jobId]
    );

    res.status(200).json({
      message: "View ajoutée"
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});

// ==============================
// GET APPLICANTS FOR JOB
// ==============================
router.get("/:id/applicants", protect, authorize("recruiter"), async (req, res) => {
  try {
    const jobId = req.params.id;

    const [rows] = await db.query(`
      SELECT 
  u.id as user_id,
  u.full_name,
  cp.professional_headline as title,
  cp.location,
  cp.profile_photo as profile_image,
  cp.is_public,
  a.status
FROM applications a
JOIN users u ON a.candidate_id = u.id
LEFT JOIN candidate_profiles cp ON cp.user_id = u.id
WHERE a.job_id = ?
ORDER BY a.created_at DESC
    `, [jobId]);

    res.json({ applicants: rows });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});



// GET CANDIDATE PROFILE
router.get("/candidate-full/:id", protect, async (req, res) => {
  try {
    const userId = req.params.id;

    // PROFILE
    const [profile] = await db.query(`
      SELECT 
        u.full_name as name,
        u.phone,
        cp.professional_headline as title,
        cp.location,
        cp.profile_photo as profile_image,
        cp.is_public
      FROM users u
      LEFT JOIN candidate_profiles cp ON cp.user_id = u.id
      WHERE u.id = ?
    `, [userId]);

    // SKILLS
    const [skills] = await db.query(
      "SELECT skill_name FROM skills WHERE user_id = ?",
      [userId]
    );

    // EXPERIENCE
    const [experiences] = await db.query(
      "SELECT * FROM experiences WHERE user_id = ? ORDER BY start_date DESC",
      [userId]
    );

    // EDUCATION
    const [education] = await db.query(
      "SELECT * FROM education WHERE user_id = ? ORDER BY start_date DESC",
      [userId]
    );

    res.json({
      profile: profile[0],
      skills,
      experiences,
      education
    });

  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;