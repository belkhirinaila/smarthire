const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

router.get("/all", protect, async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        u.id,
        u.full_name,
        cp.professional_headline,
        cp.location,
        cp.profile_photo,
        cp.is_public
      FROM users u
      LEFT JOIN candidate_profiles cp ON cp.user_id = u.id
      WHERE u.role = 'candidate'
    `);

    console.log(rows); // 👈 مهم باش نشوفو

    res.json({ candidates: rows });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// 🔍 SEARCH CANDIDATES
router.get("/", protect, authorize("recruiter"), async (req, res) => {
  try {
    const { skill, location, experience } = req.query;

    let query = `
      SELECT 
        users.id,
        users.full_name,
        candidate_profiles.location,
        candidate_profiles.professional_headline
      FROM users
      JOIN candidate_profiles 
        ON users.id = candidate_profiles.user_id
      WHERE users.role = 'candidate'
    `;

    let params = [];

    // 🎯 FILTER LOCATION
    if (location) {
      query += " AND candidate_profiles.location = ?";
      params.push(location);
    }

    // 🎯 FILTER EXPERIENCE
    if (experience) {
      query += `
        AND EXISTS (
          SELECT 1 FROM experience 
          WHERE experience.user_id = users.id 
          AND experience.years >= ?
        )
      `;
      params.push(experience);
    }

    // 🎯 FILTER SKILL
    if (skill) {
      query += `
        AND EXISTS (
          SELECT 1 FROM skills 
          WHERE skills.user_id = users.id 
          AND skills.skill_name LIKE ?
        )
      `;
      params.push(`%${skill}%`);
    }

    const [candidates] = await db.query(query, params);

    res.status(200).json({ candidates });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});

module.exports = router;