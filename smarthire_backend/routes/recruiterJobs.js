const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// CREATE JOB (avec nouvelle DB)
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
      employment_type,
      work_mode,
      skills // ["react", "node"]
    } = req.body;

    // 🔍 récupérer company du recruiter
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

    // 📝 insertion job
    const [result] = await db.query(
      `INSERT INTO jobs 
      (title, description, location, salary_min, salary_max, category, employment_type, work_mode, company_id, created_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        title,
        description,
        location,
        salary_min,
        salary_max,
        category,
        employment_type,
        work_mode,
        companyId,
        req.user.id
      ]
    );

    const jobId = result.insertId;

    // 🔥 insertion skills
    if (skills && skills.length > 0) {
      for (let skill of skills) {
        await db.query(
          "INSERT INTO job_skills (job_id, skill_name) VALUES (?, ?)",
          [jobId, skill]
        );
      }
    }

    res.status(201).json({
      message: "Job créé avec succès",
      jobId
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
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
      employment_type,
      work_mode,
      skills
    } = req.body;

    // 🔄 update job
    await db.query(
      `UPDATE jobs 
       SET title=?, description=?, location=?, salary_min=?, salary_max=?, category=?, employment_type=?, work_mode=?
       WHERE id=? AND created_by=?`,
      [
        title,
        description,
        location,
        salary_min,
        salary_max,
        category,
        employment_type,
        work_mode,
        jobId,
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
      message: "Job mis à jour"
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
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

module.exports = router;