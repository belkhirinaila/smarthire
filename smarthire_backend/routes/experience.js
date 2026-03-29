const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// GET /api/experience/me
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM experiences WHERE user_id = ? ORDER BY start_date DESC",
      [req.user.id]
    );

    res.status(200).json({
      count: rows.length,
      experiences: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// POST /api/experience
router.post("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const { job_title, company, start_date, end_date, description } = req.body;

    const [result] = await db.query(
      `INSERT INTO experiences (user_id, job_title, company, start_date, end_date, description)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [req.user.id, job_title, company, start_date, end_date, description]
    );

    res.status(201).json({
      message: "Experience ajoutée avec succès",
      experienceId: result.insertId
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// PUT /api/experience/:id
router.put("/:id", protect, authorize("candidate"), async (req, res) => {
  try {
    const { id } = req.params;
    const { job_title, company, start_date, end_date, description } = req.body;

    const [existing] = await db.query(
      "SELECT * FROM experiences WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    if (existing.length === 0) {
      return res.status(404).json({ message: "Experience non trouvée" });
    }

    await db.query(
      `UPDATE experiences
       SET job_title = ?, company = ?, start_date = ?, end_date = ?, description = ?
       WHERE id = ? AND user_id = ?`,
      [job_title, company, start_date, end_date, description, id, req.user.id]
    );

    res.status(200).json({ message: "Experience mise à jour avec succès" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// DELETE /api/experience/:id
router.delete("/:id", protect, authorize("candidate"), async (req, res) => {
  try {
    const { id } = req.params;

    const [existing] = await db.query(
      "SELECT * FROM experiences WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    if (existing.length === 0) {
      return res.status(404).json({ message: "Experience non trouvée" });
    }

    await db.query(
      "DELETE FROM experiences WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    res.status(200).json({ message: "Experience supprimée avec succès" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;