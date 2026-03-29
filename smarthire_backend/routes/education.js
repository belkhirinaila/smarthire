const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// GET /api/education/me
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM education WHERE user_id = ? ORDER BY start_date DESC",
      [req.user.id]
    );

    res.status(200).json({
      count: rows.length,
      education: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// POST /api/education
router.post("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const { school, degree, field, start_date, end_date } = req.body;

    const [result] = await db.query(
      `INSERT INTO education (user_id, school, degree, field, start_date, end_date)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [req.user.id, school, degree, field, start_date, end_date]
    );

    res.status(201).json({
      message: "Education ajoutée avec succès",
      educationId: result.insertId
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// PUT /api/education/:id
router.put("/:id", protect, authorize("candidate"), async (req, res) => {
  try {
    const { id } = req.params;
    const { school, degree, field, start_date, end_date } = req.body;

    const [existing] = await db.query(
      "SELECT * FROM education WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    if (existing.length === 0) {
      return res.status(404).json({ message: "Education non trouvée" });
    }

    await db.query(
      `UPDATE education
       SET school = ?, degree = ?, field = ?, start_date = ?, end_date = ?
       WHERE id = ? AND user_id = ?`,
      [school, degree, field, start_date, end_date, id, req.user.id]
    );

    res.status(200).json({ message: "Education mise à jour avec succès" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// DELETE /api/education/:id
router.delete("/:id", protect, authorize("candidate"), async (req, res) => {
  try {
    const { id } = req.params;

    const [existing] = await db.query(
      "SELECT * FROM education WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    if (existing.length === 0) {
      return res.status(404).json({ message: "Education non trouvée" });
    }

    await db.query(
      "DELETE FROM education WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    res.status(200).json({ message: "Education supprimée avec succès" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;