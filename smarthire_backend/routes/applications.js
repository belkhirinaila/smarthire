const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// APPLY TO A JOB
router.post("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const { job_id } = req.body;
    if (req.user.role !== "candidate") {
  return res.status(403).json({ message: "Seuls les candidats peuvent postuler" });
}
    const candidate_id = req.user.id;

    const [result] = await db.execute(
      "INSERT INTO applications (job_id, candidate_id) VALUES (?, ?)",
      [job_id, candidate_id]
    );

    res.status(201).json({
      message: "Application submitted successfully",
      application_id: result.insertId
    });
  } catch (error) {
    console.error("APPLY ERROR:", error);
    res.status(500).json({
      message: "Server error",
      error: error.message
    });
  }
});

// GET /api/applications/me -> get my applications
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  try {
    const [applications] = await db.query(
      `
      SELECT 
        applications.id,
        applications.status,
        applications.created_at,
        jobs.title,
        jobs.company_name,
        jobs.location,
        jobs.salary
      FROM applications
      JOIN jobs ON applications.job_id = jobs.id
      WHERE applications.candidate_id = ?
      ORDER BY applications.created_at DESC
      `,
      [req.user.id]
    );

    res.json({
      count: applications.length,
      applications
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});
// GET /api/applications/job/:jobId -> recruiter sees applicants for one job
router.get("/job/:jobId", protect, authorize("recruiter"), async (req, res) => {
  try {
    const { jobId } = req.params;

    // vérifier que le job existe et appartient au recruiter connecté
const [jobs] = await db.query(
  "SELECT id, recruiter_id FROM jobs WHERE id = ?",
  [jobId]
);

if (jobs.length === 0) {
  return res.status(404).json({ message: "Job non trouvé" });
}

if (jobs[0].recruiter_id !== req.user.id) {
  return res.status(403).json({ message: "Accès interdit à ce job" });
}

    const [applicants] = await db.query(
   `
   SELECT 
    applications.id,
    applications.status,
    applications.created_at,
    users.id AS candidate_id,
    users.full_name,
    users.email,
    candidate_profiles.professional_headline,
    candidate_profiles.location,
    candidate_profiles.bio,
    candidate_profiles.github_link,
    candidate_profiles.behance_link,
    candidate_profiles.personal_website,
    candidate_profiles.profile_photo
  FROM applications
  JOIN users ON applications.candidate_id = users.id
  LEFT JOIN candidate_profiles ON users.id = candidate_profiles.user_id
  WHERE applications.job_id = ?
  ORDER BY applications.created_at DESC
  `,
  [jobId]
);

    res.status(200).json({
      count: applicants.length,
      applicants
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});
// PATCH /api/applications/:id/status -> recruiter updates application status
router.patch("/:id/status", protect, authorize("recruiter"), async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!["pending", "accepted", "rejected"].includes(status)) {
      return res.status(400).json({ message: "Statut invalide" });
    }

    // récupérer application + job
    const [rows] = await db.query(
      `
      SELECT applications.id, applications.job_id, jobs.recruiter_id
      FROM applications
      JOIN jobs ON applications.job_id = jobs.id
      WHERE applications.id = ?
      `,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Application non trouvée" });
    }

    if (rows[0].recruiter_id !== req.user.id) {
      return res.status(403).json({ message: "Accès interdit" });
    }

    await db.query(
      "UPDATE applications SET status = ? WHERE id = ?",
      [status, id]
    );

    res.status(200).json({ message: "Statut mis à jour avec succès" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});
// GET APPLICATION BY ID
router.get("/:id", protect, authorize("candidate"), async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      "SELECT * FROM applications WHERE id = ? AND candidate_id = ?",
      [id, req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Application non trouvée" });
    }

    res.status(200).json({
      application: rows[0]
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});
module.exports = router;