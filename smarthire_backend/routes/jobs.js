const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// CREATE JOB (recruiter)
router.post("/", protect, authorize("recruiter"), async (req, res) => {
  try {
    const { title, description, location, salary, company_name } = req.body;

    const [result] = await db.query(
      "INSERT INTO jobs (title, description, location, salary, company_name, recruiter_id) VALUES (?, ?, ?, ?, ?, ?)",
      [title, description, location, salary, company_name, req.user.id]
    );

    res.status(201).json({
      message: "Job créé avec succès",
      jobId: result.insertId
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// GET ALL JOBS
router.get("/", async (req, res) => {
  try {
    const [jobs] = await db.query("SELECT * FROM jobs");
    res.json({ jobs });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});
// GET ONE JOB BY ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      "SELECT * FROM jobs WHERE id = ?",
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Job non trouvé" });
    }

    res.status(200).json({
      job: rows[0]
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});
module.exports = router;