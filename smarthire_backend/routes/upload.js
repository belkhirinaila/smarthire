const express = require("express");
const router = express.Router();

const upload = require("../config/upload");
const { protect } = require("../middleware/authMiddleware");

router.post("/profile", protect, upload.single("image"), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        message: "No image uploaded",
      });
    }

    const filePath =
      "/uploads/profile/" + req.file.filename;

    res.status(200).json({
      message: "Image uploaded successfully",
      profile_photo: filePath,
    });
  } catch (error) {
    console.error("UPLOAD PROFILE ERROR:", error);

    res.status(500).json({
      message: "Erreur serveur",
      error: error.message,
    });
  }
});

module.exports = router;