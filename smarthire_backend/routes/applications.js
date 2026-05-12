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

    const [jobRows] = await db.query(
      `SELECT j.recruiter_id, j.title AS job_title, u.full_name AS candidate_name
       FROM jobs j
       JOIN users u ON u.id = ?
       WHERE j.id = ?`,
      [candidate_id, job_id]
    );

    if (jobRows.length > 0) {
      const recruiterId = jobRows[0].recruiter_id;
      const jobTitle = jobRows[0].job_title || "this job";
      const candidateName = jobRows[0].candidate_name || "A candidate";
      const message = `${candidateName} applied to ${jobTitle}.`;

      await db.query(
        `INSERT INTO notifications (user_id, title, message, type, related_id)
         VALUES (?, ?, ?, ?, ?)`,
        [
          recruiterId,
          "New application",
          message,
          "application",
          candidate_id,
        ]
      );

      const io = req.app.get("io");
      if (io) {
        io.to(`user_${recruiterId}`).emit("newNotification", {
          user_id: recruiterId,
          title: "New application",
          message,
          type: "application",
          related_id: candidate_id,
          is_read: 0,
        });
      }
    }

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
        a.*,
        u.id AS candidate_id,
        u.full_name,
        u.email,
        cp.professional_headline,
        cp.location,
        cp.phone_number,
        cp.profile_photo,
        cp.cv_generated,
        CASE 
          WHEN fa.id IS NULL THEN 0
          ELSE 1
        END AS is_favorite
      FROM applications a
      JOIN users u ON u.id = a.candidate_id
      LEFT JOIN candidate_profiles cp ON cp.user_id = u.id
      LEFT JOIN favorite_applicants fa
        ON fa.candidate_id = u.id
        AND fa.job_id = a.job_id
        AND fa.recruiter_id = ?
      WHERE a.job_id = ?
      ORDER BY a.created_at DESC
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




//favorite applicants
router.post("/favorites/applicant", protect, async (req, res) => {
  try {
    const { candidate_id, job_id } = req.body;
    const recruiterId = req.user.id;

    if (!candidate_id || !job_id) {
      return res.status(400).json({
        message: "candidate_id et job_id sont obligatoires",
      });
    }

    await db.query(
      `
      INSERT IGNORE INTO favorite_applicants
      (recruiter_id, candidate_id, job_id)
      VALUES (?, ?, ?)
      `,
      [recruiterId, candidate_id, job_id]
    );

    res.status(200).json({
      success: true,
      message: "Applicant added to favorites",
    });
  } catch (err) {
    console.error("ADD FAVORITE ERROR:", err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
});

router.delete("/favorites/applicant", protect, async (req, res) => {
  try {
    const { candidate_id, job_id } = req.body;
    const recruiterId = req.user.id;

    if (!candidate_id || !job_id) {
      return res.status(400).json({
        message: "candidate_id et job_id sont obligatoires",
      });
    }

    await db.query(
      `
      DELETE FROM favorite_applicants
      WHERE recruiter_id = ?
      AND candidate_id = ?
      AND job_id = ?
      `,
      [recruiterId, candidate_id, job_id]
    );

    res.status(200).json({
      success: true,
      message: "Applicant removed from favorites",
    });
  } catch (err) {
    console.error("REMOVE FAVORITE ERROR:", err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
});
module.exports = router;