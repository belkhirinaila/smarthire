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

      requirements,
      experience,
      education,
      languages,
      team,

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
      (title, description, location, salary_min, salary_max, category,type, requirements,experience,education,languages,team, work_mode,status, company_id, created_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        title,
        description,
        location,
        salary_min,
        salary_max,
        category,
        type,
        requirements,
        experience,
        education,
        languages,
        team,
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

    // =========================
    // GET JOB
    // =========================
    const [jobRows] = await db.query(
      "SELECT * FROM jobs WHERE id = ?",
      [jobId]
    );

    if (jobRows.length === 0) {
      return res.status(404).json({
        message: "Job introuvable"
      });
    }

    const job = jobRows[0];

    // =========================
    // JOB DATA
    // =========================
    const jobSkills = job.requirements
      ? job.requirements
          .split(",")
          .map(s => s.trim().toLowerCase())
      : [];

    const jobLocation = job.location || "";

    const requiredExp = job.experience || 0;

    // =========================
    // GET APPLICANTS
    // =========================
    const [rows] = await db.query(
      `
      SELECT
        a.id as application_id,
        a.candidate_id,
        a.status,

        u.id as user_id,
        u.full_name,

        cp.professional_headline as title,
        cp.location,
        cp.profile_photo as profile_image,
        cp.is_public

      FROM applications a

      JOIN users u
        ON a.candidate_id = u.id

      LEFT JOIN candidate_profiles cp
        ON cp.user_id = u.id

      WHERE a.job_id = ?

      ORDER BY a.created_at DESC
      `,
      [jobId]
    );

    let results = [];

    // =========================
    // LOOP APPLICANTS
    // =========================
    for (let app of rows) {

      const userId = app.user_id;

      // =========================
      // GET SKILLS
      // =========================
      const [skillsRows] = await db.query(
        "SELECT skill_name FROM skills WHERE user_id = ?",
        [userId]
      );

      const candidateSkills = skillsRows.map(skill =>
        skill.skill_name.toLowerCase()
      );

      // =========================
// SMART SKILLS MATCH
// =========================

let matchCount = 0;

for (let jobSkill of jobSkills) {

  for (let candidateSkill of candidateSkills) {

    const j = jobSkill.toLowerCase().trim();
    const c = candidateSkill.toLowerCase().trim();

    // exact match
    if (j === c) {
      matchCount += 1;
      break;
    }

    // partial match
    if (
      j.includes(c) ||
      c.includes(j)
    ) {
      matchCount += 0.8;
      break;
    }

    // AI-like keyword similarity
    const jobWords = j.split(" ");
    const candidateWords = c.split(" ");

    const commonWords = jobWords.filter(word =>
      candidateWords.includes(word)
    );

    if (commonWords.length > 0) {
      matchCount += 0.5;
      break;
    }
  }
}

let skillScore = 0;

if (jobSkills.length > 0) {
  skillScore = Math.min(matchCount / jobSkills.length, 1);
}

      // =========================
      // EXPERIENCE SCORE
      // =========================
      const [expRows] = await db.query(
        "SELECT COUNT(*) as total FROM experiences WHERE user_id = ?",
        [userId]
      );

      const candidateExp = expRows[0]?.total || 0;

      let expScore = 0;

      if (requiredExp > 0) {
        expScore = Math.min(candidateExp / requiredExp, 1);
      }

      // =========================
// ALGERIA REGIONS
// =========================

const regions = {

  centre: [
    "alger",
    "blida",
    "boumerdes",
    "tipaza",
    "medea",
    "ain defla",
    "tizi ouzou",
    "bouira",
    "chlef",
    "djelfa"
  ],

  est: [
    "constantine",
    "annaba",
    "setif",
    "bejaia",
    "jijel",
    "skikda",
    "guelma",
    "mila",
    "batna",
    "khenchela",
    "tebessa",
    "souk ahras",
    "el taref",
    "oum el bouaghi",
    "bordj bou arreridj"
  ],

  ouest: [
    "oran",
    "tlemcen",
    "sidi bel abbes",
    "ain temouchent",
    "mostaganem",
    "mascara",
    "relizane",
    "tiaret",
    "saida",
    "naama",
    "tissemsilt"
  ],

  sud: [
    "adrar",
    "tamanrasset",
    "illizi",
    "bechar",
    "ouargla",
    "ghardaia",
    "laghouat",
    "biskra",
    "el oued",
    "timimoun",
    "bordj badji mokhtar",
    "beni abbes",
    "in salah",
    "in guezzam",
    "touggourt",
    "djanet",
    "el mghair",
    "el meniaa"
  ]

};


// =========================
// SMART LOCATION SCORE
// =========================

let locationScore = 0;

const candidateLocation =
  (app.location || "").toLowerCase().trim();

const companyLocation =
  (jobLocation || "").toLowerCase().trim();


// 🔥 SAME WILAYA
if (candidateLocation === companyLocation) {

  locationScore = 1;

}

else {

  let sameRegion = false;

  // 🔥 CHECK SAME REGION
  for (const region in regions) {

    const wilayas = regions[region];

    if (
      wilayas.includes(candidateLocation) &&
      wilayas.includes(companyLocation)
    ) {

      sameRegion = true;
      break;

    }
  }

  // 🔥 SAME REGION
  if (sameRegion) {

    locationScore = 0.7;

  }

  // 🔥 DIFFERENT REGION
  else {

    locationScore = 0.3;

  }
}

      // =========================
// EDUCATION MATCH
// =========================

const [eduRows] = await db.query(
  "SELECT degree FROM education WHERE user_id = ?",
  [userId]
);

let educationScore = 0;

const degrees = eduRows.map(e =>
  (e.degree || "").toLowerCase()
);

if (
  degrees.some(d =>
    d.includes("master") ||
    d.includes("engineer") ||
    d.includes("ingénieur")
  )
) {
  educationScore = 1;
}
else if (
  degrees.some(d =>
    d.includes("licence") ||
    d.includes("bachelor")
  )
) {
  educationScore = 0.7;
}
else {
  educationScore = 0.4;
}

      // =========================
// DYNAMIC AI SCORE
// =========================

let totalWeight = 0;
let weightedScore = 0;


// =========================
// SKILLS
// =========================

if (jobSkills.length > 0) {

  weightedScore += skillScore * 0.50;
  totalWeight += 0.50;

}


// =========================
// EXPERIENCE
// =========================

if (requiredExp > 0) {

  weightedScore += expScore * 0.20;
  totalWeight += 0.20;

}


// =========================
// EDUCATION
// =========================

weightedScore += educationScore * 0.15;
totalWeight += 0.15;


// =========================
// LOCATION
// =========================

weightedScore += locationScore * 0.15;
totalWeight += 0.15;


// =========================
// FINAL SCORE
// =========================

let finalScore = 0;

if (totalWeight > 0) {

  finalScore = Math.round(
    (weightedScore / totalWeight) * 100
  );

}


// 🔥 anti NaN
if (isNaN(finalScore)) {
  finalScore = 0;
}

      // =========================
      // SAVE SCORE IN DATABASE
      // =========================
      await db.query(
        `
        UPDATE applications
        SET score = ?
        WHERE id = ?
        `,
        [finalScore, app.application_id]
      );

      // =========================
      // PUSH RESULT
      // =========================
      results.push({
        ...app,
        score: finalScore
      });
    }

    // =========================
    // SORT BY SCORE
    // =========================
    results.sort((a, b) => b.score - a.score);

    // =========================
    // RESPONSE
    // =========================
    res.json({
      applicants: results
    });

  } catch (err) {

    console.log(err);

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
    u.id,
    u.full_name as name,
    u.email,

    cp.professional_headline as title,
    cp.location,
    cp.profile_photo,
    cp.profile_photo as profile_image,
    cp.phone_number,
    cp.email as profile_email,
    cp.bio,
    cp.github_link,
    cp.behance_link,
    cp.personal_website,
    cp.is_public,
    cp.cv_generated as cv_file

  FROM users u

  LEFT JOIN candidate_profiles cp 
    ON cp.user_id = u.id

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