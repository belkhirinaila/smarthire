const express = require("express");
const router = express.Router();
const db = require("../config/db");
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
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
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

    if (existing.length === 0) {
      return res.status(404).json({ message: "Profil non trouvé" });
    }

    await db.query(
      `UPDATE candidate_profiles
       SET professional_headline = ?, location = ?, bio = ?, github_link = ?, behance_link = ?, personal_website = ?, profile_photo = ?, phone_number = ?, email = ?
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
        req.user.id
      ]
    );

    res.status(200).json({ message: "Profil mis à jour avec succès" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;