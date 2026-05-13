const multer = require("multer");
const path = require("path");
const fs = require("fs");

// ==============================
// CREATE FOLDER IF NOT EXISTS
// ==============================
const uploadPath = "uploads/profile";

fs.mkdirSync(uploadPath, { recursive: true });

// ==============================
// STORAGE
// ==============================
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadPath);
  },

  filename: (req, file, cb) => {
    cb(
      null,
      Date.now() + path.extname(file.originalname)
    );
  },
});

// ==============================
// MULTER
// ==============================
const upload = multer({
  storage: storage,
});

module.exports = upload;