const express = require("express");
const router = express.Router();
const db = require("../config/db");
const bcrypt = require("bcryptjs");
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// 🔐 CHANGE PASSWORD
// ==============================
router.put("/password", protect, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    const [users] = await db.query(
      "SELECT * FROM users WHERE id = ?",
      [req.user.id]
    );

    const user = users[0];

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({
        message: "Ancien mot de passe incorrect"
      });
    }

    const hashed = await bcrypt.hash(newPassword, 10);

    await db.query(
      "UPDATE users SET password=? WHERE id=?",
      [hashed, req.user.id]
    );

    res.status(200).json({
      message: "Mot de passe mis à jour"
    });

  } catch (err) {
    res.status(500).json({ message: "Erreur serveur" });
  }
});


// ==============================
// 👥 ADD TEAM MEMBER
// ==============================
router.post("/team", protect, authorize("recruiter"), async (req, res) => {
  try {
    const { user_id } = req.body;

    // 🔍 get company
    const [company] = await db.query(
      "SELECT id FROM company_profiles WHERE user_id = ?",
      [req.user.id]
    );

    if (company.length === 0) {
      return res.status(400).json({ message: "Company introuvable" });
    }

    await db.query(
      "INSERT INTO company_users (company_id, user_id) VALUES (?, ?)",
      [company[0].id, user_id]
    );

    res.status(201).json({
      message: "Membre ajouté"
    });

  } catch (err) {
    res.status(500).json({ message: "Erreur serveur" });
  }
});


// ==============================
// 👥 GET TEAM
// ==============================
router.get("/team", protect, authorize("recruiter"), async (req, res) => {
  try {
    const [company] = await db.query(
      "SELECT id FROM company_profiles WHERE user_id = ?",
      [req.user.id]
    );

    const [team] = await db.query(
      `
      SELECT users.id, users.full_name, users.email
      FROM company_users
      JOIN users ON users.id = company_users.user_id
      WHERE company_users.company_id = ?
      `,
      [company[0].id]
    );

    res.status(200).json({ team });

  } catch (err) {
    res.status(500).json({ message: "Erreur serveur" });
  }
});


// ==============================
// ❌ REMOVE TEAM MEMBER
// ==============================
router.delete("/team/:id", protect, authorize("recruiter"), async (req, res) => {
  try {
    const userId = req.params.id;

    await db.query(
      "DELETE FROM company_users WHERE user_id = ?",
      [userId]
    );

    res.status(200).json({
      message: "Membre supprimé"
    });

  } catch (err) {
    res.status(500).json({ message: "Erreur serveur" });
  }
});


// ==============================
// 🔔 TOGGLE NOTIFICATIONS
// ==============================
router.put("/notifications", protect, async (req, res) => {
  try {
    const { enabled } = req.body;

    await db.query(
      `
      INSERT INTO user_settings (user_id, notifications_enabled)
      VALUES (?, ?)
      ON DUPLICATE KEY UPDATE notifications_enabled=?
      `,
      [req.user.id, enabled, enabled]
    );

    res.status(200).json({
      message: "Notifications mises à jour"
    });

  } catch (err) {
    res.status(500).json({ message: "Erreur serveur" });
  }
});


// ==============================
// 🚫 DEACTIVATE ACCOUNT
// ==============================
router.put("/deactivate", protect, async (req, res) => {
  try {
    await db.query(
      "UPDATE users SET is_active = 0 WHERE id = ?",
      [req.user.id]
    );

    res.status(200).json({
      message: "Compte désactivé"
    });

  } catch (err) {
    res.status(500).json({ message: "Erreur serveur" });
  }
});

module.exports = router;