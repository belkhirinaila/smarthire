const express = require("express");
console.log("🔥🔥🔥 NEW FILE WORKING 🔥🔥🔥");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// GET APPLICANTS WITH FILTER
// ==============================
router.get("/:jobId", protect, authorize("recruiter"), async (req, res) => {
  console.log("🔥 APPLICANTS ROUTE HIT");

  try {
    const jobId = req.params.jobId;
    const { status } = req.query;

    // 🔍 Vérifier ownership du job
    const [job] = await db.query(
      "SELECT id FROM jobs WHERE id=? AND created_by=?",
      [jobId, req.user.id]
    );

    if (job.length === 0) {
      return res.status(403).json({
        message: "Accès refusé"
      });
    }

    // ==============================
    // GET APPLICATIONS
    // ==============================
    let query = `
      SELECT 
        applications.id AS application_id,
        applications.candidate_id,
        applications.status,
        applications.created_at,

        users.id AS user_id,
        users.full_name,

        candidate_profiles.location,
        candidate_profiles.professional_headline,
        candidate_profiles.profile_photo

      FROM applications

      JOIN users 
        ON users.id = applications.candidate_id

      LEFT JOIN candidate_profiles 
        ON candidate_profiles.user_id = users.id

      WHERE applications.job_id = ?
    `;

    let params = [jobId];

    // 🔥 filter status
    if (status) {
      query += " AND applications.status = ?";
      params.push(status);
    }

    // 🔽 sort by recent
    query += " ORDER BY applications.created_at DESC";

    const [apps] = await db.query(query, params);

    console.log("🔥 APPS FOUND:", apps.length);

    // ==============================
    // GET JOB
    // ==============================
    const [jobRows] = await db.query(
      "SELECT * FROM jobs WHERE id = ?",
      [jobId]
    );

    if (jobRows.length === 0) {
      return res.status(404).json({
        message: "Job introuvable"
      });
    }

    const jobData = jobRows[0];

    // ==============================
    // JOB SKILLS
    // ==============================
    const jobSkills = jobData.requirements
      ? jobData.requirements
          .split(",")
          .map(s => s.trim().toLowerCase())
      : [];

    const jobWilaya = jobData.location || "";
    const requiredExp = jobData.experience || 0;

    let results = [];

    // ==============================
    // LOOP APPLICANTS
    // ==============================
    for (let app of apps) {

      const userId = app.user_id;

      // ==============================
      // GET CANDIDATE SKILLS
      // ==============================
      const [skillsRows] = await db.query(
        "SELECT skill_name FROM skills WHERE user_id = ?",
        [userId]
      );

      const candidateSkills = skillsRows.map(skill =>
        skill.skill_name.toLowerCase()
      );

      // ==============================
      // SKILL MATCH
      // ==============================
      let matchCount = jobSkills.filter(jobSkill =>
        candidateSkills.some(candidateSkill =>
          candidateSkill.includes(jobSkill) ||
          jobSkill.includes(candidateSkill)
        )
      ).length;

      let skillScore = 0;

      if (jobSkills.length > 0) {
        skillScore = matchCount / jobSkills.length;
      }

      // ==============================
      // EXPERIENCE MATCH
      // ==============================
      const [expRows] = await db.query(
        "SELECT COUNT(*) as total FROM experiences WHERE user_id = ?",
        [userId]
      );

      const candidateExp = expRows[0]?.total || 0;

      let expScore = 0;

      if (requiredExp > 0) {
        expScore = Math.min(candidateExp / requiredExp, 1);
      }

      // ==============================
      // LOCATION MATCH
      // ==============================
      let wilayaScore = 0;

      if (
        app.location &&
        jobWilaya &&
        app.location.toLowerCase() === jobWilaya.toLowerCase()
      ) {
        wilayaScore = 1;
      }

      // ==============================
      // FINAL SCORE
      // ==============================
      let totalScore =
        (skillScore * 0.6) +
        (expScore * 0.25) +
        (wilayaScore * 0.15);

      let finalScore = Math.round(totalScore * 100);

      // 🔥 sécurité anti NaN
      if (isNaN(finalScore)) {
        finalScore = 0;
      }

      console.log("APPLICATION ID:", app.application_id);
console.log("FINAL SCORE:", finalScore);

      // 🔥 save score in database
await db.query(
  `
  UPDATE applications
  SET score = ?
  WHERE id = ?
  `,
  [finalScore, app.application_id]
);


console.log("UPDATE RESULT:", updateResult);

      // ==============================
      // PUSH RESULT
      // ==============================
      results.push({
        ...app,
        score: finalScore
      });
    }

    // ==============================
    // SORT BY SCORE
    // ==============================
    results.sort((a, b) => b.score - a.score);

    console.log("🔥 FINAL RESULTS:", results);

    // ==============================
    // RESPONSE
    // ==============================
    res.status(200).json({
      applicants: results
    });

  } catch (err) {

    console.log("❌ ERROR:", err);

    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// UPDATE APPLICATION
// ==============================
router.put("/:applicationId", protect, authorize("recruiter"), async (req, res) => {
  try {

    const applicationId = req.params.applicationId;
    const { status, score } = req.body;

    // 🔍 Vérifier ownership
    const [check] = await db.query(
      `
      SELECT applications.id 
      FROM applications
      JOIN jobs ON jobs.id = applications.job_id
      WHERE applications.id = ? AND jobs.created_by = ?
      `,
      [applicationId, req.user.id]
    );

    if (check.length === 0) {
      return res.status(403).json({
        message: "Accès refusé"
      });
    }

    // 🔄 Update
    await db.query(
      `
      UPDATE applications 
      SET status = ?, score = ?, updated_at = NOW()
      WHERE id = ?
      `,
      [status, score, applicationId]
    );

    res.status(200).json({
      message: "Application mise à jour avec succès"
    });

  } catch (err) {

    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// HIRE CANDIDATE
// ==============================
router.put("/:id/hire", protect, authorize("recruiter"), async (req, res) => {
  try {

    const appId = req.params.id;

    // 🔍 ownership
    const [check] = await db.query(
      `
      SELECT applications.id 
      FROM applications
      JOIN jobs ON jobs.id = applications.job_id
      WHERE applications.id = ? AND jobs.created_by = ?
      `,
      [appId, req.user.id]
    );

    if (check.length === 0) {
      return res.status(403).json({
        message: "Accès refusé"
      });
    }

    // 🔄 update
    await db.query(
      "UPDATE applications SET status='hired', updated_at=NOW() WHERE id=?",
      [appId]
    );

    res.status(200).json({
      message: "Candidat recruté avec succès 🎉"
    });

  } catch (err) {

    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// ADD NOTE
// ==============================
router.post("/:id/note", protect, authorize("recruiter"), async (req, res) => {
  try {

    const appId = req.params.id;
    const { note } = req.body;

    await db.query(
      `
      INSERT INTO application_notes (application_id, recruiter_id, note)
      VALUES (?, ?, ?)
      `,
      [appId, req.user.id, note]
    );

    res.status(201).json({
      message: "Note ajoutée"
    });

  } catch (err) {

    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// GET NOTES
// ==============================
router.get("/:id/notes", protect, authorize("recruiter"), async (req, res) => {
  try {

    const appId = req.params.id;

    const [notes] = await db.query(
      `
      SELECT * FROM application_notes
      WHERE application_id = ?
      ORDER BY created_at DESC
      `,
      [appId]
    );

    res.status(200).json({
      notes
    });

  } catch (err) {

    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// GET CV FILE
// ==============================
router.get("/:id/cv", protect, authorize("recruiter"), async (req, res) => {
  try {

    const appId = req.params.id;

    const [result] = await db.query(
      `
      SELECT cv_files.file_path
      FROM applications
      JOIN cv_files ON cv_files.id = applications.cv_file_id
      WHERE applications.id = ?
      `,
      [appId]
    );

    if (result.length === 0) {
      return res.status(404).json({
        message: "CV non trouvé"
      });
    }

    const filePath = result[0].file_path;

    res.download(filePath);

  } catch (err) {

    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// GET APPLICATION DETAILS
// ==============================
router.get("/details/:id", protect, authorize("recruiter"), async (req, res) => {
  try {

    const appId = req.params.id;

    const [application] = await db.query(
      `
      SELECT 
        applications.*,
        users.full_name,
        users.email
      FROM applications
      JOIN users ON users.id = applications.candidate_id
      WHERE applications.id = ?
      `,
      [appId]
    );

    res.status(200).json({
      application: application[0]
    });

  } catch (err) {

    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// COUNT APPLICANTS
// ==============================
router.get("/counts/:jobId", protect, authorize("recruiter"), async (req, res) => {
  try {

    const jobId = req.params.jobId;

    const [counts] = await db.query(
      `
      SELECT 
        status,
        COUNT(*) as total
      FROM applications
      WHERE job_id = ?
      GROUP BY status
      `,
      [jobId]
    );

    res.status(200).json({
      counts
    });

  } catch (err) {

    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// TEST ROUTE
// ==============================
router.get("/test", (req, res) => {
  res.send("OK WORKING");
});


module.exports = router;