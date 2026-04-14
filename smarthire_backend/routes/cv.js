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

        const updatedUrl = `${req.protocol}://${req.get('host')}/${filePath.replace(/\\/g, '/')}`;
        return res.json({
          message: "CV mis à jour avec succès",
          file: fileName,
          file_url: updatedUrl,
        });
      }

      // insert
      await db.query(
        "INSERT INTO cv_files (user_id, file_name, file_path) VALUES (?, ?, ?)",
        [req.user.id, fileName, filePath]
      );

      const fileUrl = `${req.protocol}://${req.get('host')}/${filePath.replace(/\\/g, '/')}`;
      res.status(201).json({
        message: "CV uploadé avec succès",
        file: fileName,
        file_url: fileUrl,
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

    const filePath = rows[0].file_path?.toString().replace(/\\/g, '/');
    const fileUrl = filePath
      ? `${req.protocol}://${req.get('host')}/${filePath}`
      : null;

    res.json({
      cv: {
        ...rows[0],
        file_url: fileUrl,
      }
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;