const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// POST save job
router.post("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const { job_id } = req.body;

    if (!job_id) {
      return res.status(400).json({ message: "job_id requis" });
    }

    await db.query(
      "INSERT INTO saved_jobs (user_id, job_id) VALUES (?, ?)",
      [req.user.id, job_id]
    );

    res.status(201).json({ message: "Job sauvegardé" });
  } catch (err) {
    if (err.code === "ER_DUP_ENTRY") {
      return res.status(400).json({ message: "Job déjà sauvegardé" });
    }
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// GET saved jobs
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT jobs.* 
       FROM saved_jobs 
       JOIN jobs ON saved_jobs.job_id = jobs.id
       WHERE saved_jobs.user_id = ?`,
      [req.user.id]
    );

    res.status(200).json({
      count: rows.length,
      jobs: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// DELETE saved job
router.delete("/:jobId", protect, authorize("candidate"), async (req, res) => {
  try {
    const { jobId } = req.params;

    await db.query(
      "DELETE FROM saved_jobs WHERE user_id = ? AND job_id = ?",
      [req.user.id, jobId]
    );

    res.status(200).json({ message: "Job supprimé des favoris" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;