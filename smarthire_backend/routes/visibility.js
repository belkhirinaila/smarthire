const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// GET /api/visibility/me
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM cv_visibility WHERE user_id = ?",
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(200).json({
        visibility: {
          user_id: req.user.id,
          visibility: "public"
        }
      });
    }

    res.status(200).json({ visibility: rows[0] });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// POST /api/visibility
router.post("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const { visibility } = req.body;

    if (!["public", "private", "selective"].includes(visibility)) {
      return res.status(400).json({ message: "Valeur de visibilité invalide" });
    }

    const [existing] = await db.query(
      "SELECT * FROM cv_visibility WHERE user_id = ?",
      [req.user.id]
    );

    if (existing.length > 0) {
      return res.status(409).json({ message: "Visibility déjà définie" });
    }

    const [result] = await db.query(
      "INSERT INTO cv_visibility (user_id, visibility) VALUES (?, ?)",
      [req.user.id, visibility]
    );

    res.status(201).json({
      message: "Visibility créée avec succès",
      visibilityId: result.insertId
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// PUT /api/visibility
router.put("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const { visibility } = req.body;

    if (!["public", "private", "selective"].includes(visibility)) {
      return res.status(400).json({ message: "Valeur de visibilité invalide" });
    }

    const [existing] = await db.query(
      "SELECT * FROM cv_visibility WHERE user_id = ?",
      [req.user.id]
    );

    if (existing.length === 0) {
      await db.query(
        "INSERT INTO cv_visibility (user_id, visibility) VALUES (?, ?)",
        [req.user.id, visibility]
      );

      return res.status(201).json({ message: "Visibility créée avec succès" });
    }

    await db.query(
      "UPDATE cv_visibility SET visibility = ? WHERE user_id = ?",
      [visibility, req.user.id]
    );

    res.status(200).json({ message: "Visibility mise à jour avec succès" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;