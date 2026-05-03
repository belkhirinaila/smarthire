const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect } = require("../middleware/authMiddleware");

// GET my notifications
router.get("/me", protect, async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC",
      [req.user.id]
    );

    res.status(200).json({
      count: rows.length,
      notifications: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});


// ==============================
// 🔢 COUNT UNREAD
// ==============================
router.get("/unread-count", protect, async (req, res) => {
  try {
    const [rows] = await db.query(
      `
      SELECT COUNT(*) as total
      FROM notifications
      WHERE user_id = ? AND is_read = 0
      `,
      [req.user.id]
    );

    res.status(200).json({
      count: rows[0].total
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// MARK ONE AS READ
router.put("/:id/read", protect, async (req, res) => {
  try {
    const { id } = req.params;

    await db.query(
      "UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?",
      [id, req.user.id]
    );

    res.status(200).json({ message: "Notification marquée comme lue" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// MARK ALL AS READ
router.put("/read-all/me", protect, async (req, res) => {
  try {
    await db.query(
      "UPDATE notifications SET is_read = TRUE WHERE user_id = ?",
      [req.user.id]
    );

    res.status(200).json({ message: "Toutes les notifications sont lues" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;