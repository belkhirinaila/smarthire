const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// GET APPLICANTS WITH FILTER
// ==============================
router.get("/:jobId", protect, authorize("recruiter"), async (req, res) => {
  try {
    const jobId = req.params.jobId;
    const { status } = req.query; // 🔥 filter

    // 🔍 Vérifier que le job appartient au recruiter
    const [job] = await db.query(
      "SELECT id FROM jobs WHERE id=? AND created_by=?",
      [jobId, req.user.id]
    );

    if (job.length === 0) {
      return res.status(403).json({
        message: "Accès refusé"
      });
    }

    // 🧱 Query de base
    let query = `
      SELECT 
        applications.id AS application_id,
        applications.status,
        applications.score,
        applications.created_at,
        users.id,
        users.full_name,
        candidate_profiles.location,
        candidate_profiles.professional_headline
      FROM applications
      JOIN users ON users.id = applications.candidate_id
      LEFT JOIN candidate_profiles 
        ON candidate_profiles.user_id = users.id
      WHERE applications.job_id = ?
    `;

    let params = [jobId];

    // 🔥 Filtrer par status (pending / shortlisted / rejected)
    if (status) {
      query += " AND applications.status = ?";
      params.push(status);
    }

    // 🔽 Trier les plus récents en premier
    query += " ORDER BY applications.created_at DESC";

    const [applicants] = await db.query(query, params);

    res.status(200).json({ applicants });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// UPDATE APPLICATION (shortlist / reject / score)
// ==============================
router.put("/:applicationId", protect, authorize("recruiter"), async (req, res) => {
  try {
    const applicationId = req.params.applicationId;
    const { status, score } = req.body;

    // 🔍 Vérifier ownership (sécurité)
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

    // 🔄 Update application
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

    // 🔍 vérifier ownership
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

    // 🔄 update status
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
// ADD NOTE TO APPLICATION
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
// GET NOTES FOR APPLICATION
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

    res.status(200).json({ notes });

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
// COUNT APPLICANTS PER STATUS (tabs)
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

    res.status(200).json({ counts });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});

module.exports = router;