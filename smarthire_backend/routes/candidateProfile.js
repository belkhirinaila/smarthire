const express = require("express");
const router = express.Router();
const db = require("../config/db");
const bcrypt = require("bcryptjs");
const { protect, authorize } = require("../middleware/authMiddleware");

// GET /api/candidate-profile/me
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM candidate_profiles WHERE user_id = ?",
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(200).json({ message: "Profil non encore créé", profile: null });
    }

    res.status(200).json({ profile: rows[0] });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// POST /api/candidate-profile
router.post("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const {
      professional_headline,
      location,
      bio,
      github_link,
      behance_link,
      personal_website,
      profile_photo,
      phone_number,
      email

    } = req.body;

    const [existing] = await db.query(
      "SELECT id FROM candidate_profiles WHERE user_id = ?",
      [req.user.id]
    );

    if (existing.length > 0) {
      return res.status(409).json({ message: "Profil déjà existant" });
    }

    const [result] = await db.query(
      `INSERT INTO candidate_profiles 
      (user_id, professional_headline, location, bio, github_link, behance_link, personal_website, profile_photo, phone_number, email)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        req.user.id,
        professional_headline,
        location,
        bio,
        github_link,
        behance_link,
        personal_website,
        profile_photo,
        phone_number,
        email
      ]
    );

    res.status(201).json({
      message: "Profil créé avec succès",
      profileId: result.insertId
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// PUT /api/candidate-profile
router.put("/", protect, authorize("candidate"), async (req, res) => {
  try {
    const [existing] = await db.query(
      "SELECT * FROM candidate_profiles WHERE user_id = ?",
      [req.user.id]
    );

    if (existing.length === 0) {
      return res.status(404).json({ message: "Profil non trouvé" });
    }

    const oldProfile = existing[0];

    const professional_headline =
      req.body.professional_headline ?? oldProfile.professional_headline;

    const location =
      req.body.location ?? oldProfile.location;

    const bio =
      req.body.bio ?? oldProfile.bio;

    const github_link =
      req.body.github_link ?? oldProfile.github_link;

    const behance_link =
      req.body.behance_link ?? oldProfile.behance_link;

    const personal_website =
      req.body.personal_website ?? oldProfile.personal_website;

    const profile_photo =
      req.body.profile_photo ?? oldProfile.profile_photo;

    const phone_number =
      req.body.phone_number ?? oldProfile.phone_number;

    const email =
      req.body.email ?? oldProfile.email;

    await db.query(
      `UPDATE candidate_profiles
       SET professional_headline = ?,
           location = ?,
           bio = ?,
           github_link = ?,
           behance_link = ?,
           personal_website = ?,
           profile_photo = ?,
           phone_number = ?,
           email = ?
       WHERE user_id = ?`,
      [
        professional_headline,
        location,
        bio,
        github_link,
        behance_link,
        personal_website,
        profile_photo,
        phone_number,
        email,
        req.user.id,
      ]
    );

    res.status(200).json({
      message: "Profil mis à jour avec succès",
      profile_photo,
    });
  } catch (err) {
    console.error("UPDATE CANDIDATE PROFILE ERROR:", err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
});
//1778548825022


// ==============================
// CHANGE PASSWORD
// ==============================
router.put("/change-password", protect, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({
        message: "Tous les champs sont obligatoires",
      });
    }

    const [users] = await db.query(
      "SELECT * FROM users WHERE id = ?",
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        message: "Utilisateur introuvable",
      });
    }

    const user = users[0];

    const isMatch = await bcrypt.compare(
      oldPassword,
      user.password
    );

    if (!isMatch) {
      return res.status(400).json({
        message: "Ancien mot de passe incorrect",
      });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await db.query(
      `
      UPDATE users
      SET password = ?
      WHERE id = ?
      `,
      [hashedPassword, req.user.id]
    );

    res.status(200).json({
      success: true,
      message: "Mot de passe modifié avec succès",
    });

  } catch (error) {
    console.error("CHANGE PASSWORD ERROR:", error);

    res.status(500).json({
      message: "Erreur serveur",
      error: error.message,
    });
  }
});

module.exports = router;