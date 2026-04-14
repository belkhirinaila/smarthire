const multer = require("multer");
const path = require("path");

// ==============================
// STORAGE
// ==============================
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

// ==============================
// FILE FILTER (PDF + IMAGES)
// ==============================
const fileFilter = (req, file, cb) => {
  if (
    file.mimetype.startsWith("image/") ||
    file.mimetype === "application/pdf"
  ) {
    cb(null, true); // ✅ قبول
  } else {
    cb(new Error("Only PDF and images are allowed"), false);
  }
};

// ==============================
// UPLOAD
// ==============================
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
});

module.exports = upload;