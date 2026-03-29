const express = require("express");
const router = express.Router();
const db = require("../config/db");
const upload = require("../config/upload");
const { protect, authorize } = require("../middleware/authMiddleware");

// POST /api/cv/upload
router.post(
  "/upload",
  protect,
  authorize("candidate"),
  upload.single("cv"),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ message: "Aucun fichier envoyé" });
      }

      const fileName = req.file.filename;
      const filePath = req.file.path;

      // check if CV already exists
      const [existing] = await db.query(
        "SELECT * FROM cv_files WHERE user_id = ?",
        [req.user.id]
      );

      if (existing.length > 0) {
        // update
        await db.query(
          "UPDATE cv_files SET file_name = ?, file_path = ? WHERE user_id = ?",
          [fileName, filePath, req.user.id]
        );

        return res.json({ message: "CV mis à jour avec succès" });
      }

      // insert
      await db.query(
        "INSERT INTO cv_files (user_id, file_name, file_path) VALUES (?, ?, ?)",
        [req.user.id, fileName, filePath]
      );

      res.status(201).json({
        message: "CV uploadé avec succès",
        file: fileName
      });
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  }
);

// GET /api/cv/me
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM cv_files WHERE user_id = ?",
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Aucun CV trouvé" });
    }

    res.json({
      cv: rows[0]
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;