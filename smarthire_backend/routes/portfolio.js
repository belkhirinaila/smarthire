const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// GET /api/portfolio/me
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM portfolio_links WHERE user_id = ? ORDER BY created_at DESC",
      [req.user.id]
    );

    res.status(200).json({
      count: rows.length,
      portfolio: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// POST /api/portfolio
router.post("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const { title, url } = req.body;

    if (!url) {
      return res.status(400).json({ message: "URL obligatoire" });
    }

    const [result] = await db.query(
      "INSERT INTO portfolio_links (user_id, title, url) VALUES (?, ?, ?)",
      [req.user.id, title, url]
    );

    res.status(201).json({
      message: "Lien portfolio ajouté avec succès",
      portfolioId: result.insertId
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// PUT /api/portfolio/:id
router.put("/:id", protect, authorize("candidate"), async (req, res) => {
  try {
    const { id } = req.params;
    const { title, url } = req.body;

    const [existing] = await db.query(
      "SELECT * FROM portfolio_links WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    if (existing.length === 0) {
      return res.status(404).json({ message: "Lien portfolio non trouvé" });
    }

    await db.query(
      "UPDATE portfolio_links SET title = ?, url = ? WHERE id = ? AND user_id = ?",
      [title, url, id, req.user.id]
    );

    res.status(200).json({ message: "Lien portfolio mis à jour avec succès" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// DELETE /api/portfolio/:id
router.delete("/:id", protect, authorize("candidate"), async (req, res) => {
  try {
    const { id } = req.params;

    const [existing] = await db.query(
      "SELECT * FROM portfolio_links WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    if (existing.length === 0) {
      return res.status(404).json({ message: "Lien portfolio non trouvé" });
    }

    await db.query(
      "DELETE FROM portfolio_links WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    res.status(200).json({ message: "Lien portfolio supprimé avec succès" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;