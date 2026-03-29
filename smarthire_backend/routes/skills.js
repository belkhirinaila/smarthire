const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// GET /api/skills/me
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM skills WHERE user_id = ?",
      [req.user.id]
    );

    res.status(200).json({
      count: rows.length,
      skills: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// POST /api/skills
router.post("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const { skill_name } = req.body;

    const [result] = await db.query(
      "INSERT INTO skills (user_id, skill_name) VALUES (?, ?)",
      [req.user.id, skill_name]
    );

    res.status(201).json({
      message: "Skill ajoutée avec succès",
      skillId: result.insertId
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// DELETE /api/skills/:id
router.delete("/:id", protect, authorize("candidate"), async (req, res) => {
  try {
    const { id } = req.params;

    await db.query(
      "DELETE FROM skills WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    res.status(200).json({
      message: "Skill supprimée avec succès"
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;