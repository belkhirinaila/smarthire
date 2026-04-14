const express = require("express");
const router = express.Router();
const upload = require("../config/upload"); // 🔥 هنا نستعمل config تاعك

// ==============================
// UPLOAD LOGO
// ==============================
router.post("/logo", upload.single("image"), (req, res) => {
  res.status(200).json({
    logo: "uploads/" + req.file.filename
  });
});


// ==============================
// UPLOAD COVER
// ==============================
router.post("/cover", upload.single("image"), (req, res) => {
  res.status(200).json({
    cover: "uploads/" + req.file.filename
  });
});

// ==============================
// UPLOAD PROFILE PHOTO 🔥
// ==============================
router.post("/profile", upload.single("image"), (req, res) => {
  res.status(200).json({
    profile_photo: "uploads/" + req.file.filename
  });
});


// ==============================
// UPLOAD CV
// ==============================
router.post("/cv", upload.single("file"), (req, res) => {
  res.status(200).json({
    cv: "uploads/" + req.file.filename
  });
});

module.exports = router;