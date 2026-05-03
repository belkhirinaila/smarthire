const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// ==============================
// 📊 ADMIN DASHBOARD STATS
// ==============================
router.get("/stats", protect, authorize("admin"), async (req, res) => {
  try {
    // 🔥 total users
    const [users] = await db.query("SELECT COUNT(*) AS total FROM users");

    // 🔥 candidates
    const [candidates] = await db.query(
      "SELECT COUNT(*) AS total FROM users WHERE role = 'candidate'"
    );

    // 🔥 recruiters
    const [recruiters] = await db.query(
      "SELECT COUNT(*) AS total FROM users WHERE role = 'recruiter'"
    );

    // 🔥 companies
    const [companies] = await db.query(
      "SELECT COUNT(*) AS total FROM company_profiles"
    );

    // 🔥 jobs
    const [jobs] = await db.query(
      "SELECT COUNT(*) AS total FROM jobs"
    );

    res.json({
      users: users[0].total,
      candidates: candidates[0].total,
      recruiters: recruiters[0].total,
      companies: companies[0].total,
      jobs: jobs[0].total
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// 📈 USERS PER DAY
// ==============================
router.get("/users-per-day", protect, authorize("admin"), async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        DATE(created_at) as date,
        COUNT(*) as count
      FROM users
      GROUP BY DATE(created_at)
      ORDER BY date ASC
    `);

    res.json(rows);

  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});

module.exports = router;