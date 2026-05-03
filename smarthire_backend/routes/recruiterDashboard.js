const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");

// ==============================
// 📊 DASHBOARD DATA
// ==============================
router.get("/", protect, authorize("recruiter"), async (req, res) => {
  try {
    const recruiterId = req.user.id;

    // 🔥 1. TOTAL APPLICANTS
    const [totalApplicants] = await db.query(
      `
      SELECT COUNT(*) as total
      FROM applications a
      JOIN jobs j ON j.id = a.job_id
      WHERE j.created_by = ?
      `,
      [recruiterId]
    );

    // 🔥 2. ACTIVE JOBS
    const [activeJobs] = await db.query(
      `
      SELECT COUNT(*) as total
      FROM jobs
      WHERE created_by = ? AND status != 'closed'
      `,
      [recruiterId]
    );

    // 🔥 3. PENDING APPLICATIONS
    const [pending] = await db.query(
      `
      SELECT COUNT(*) as total
      FROM applications a
      JOIN jobs j ON j.id = a.job_id
      WHERE j.created_by = ? AND a.status = 'pending'
      `,
      [recruiterId]
    );

    // 🔥 4. INTERVIEWING
    const [interviewing] = await db.query(
      `
      SELECT COUNT(*) as total
      FROM applications a
      JOIN jobs j ON j.id = a.job_id
      WHERE j.created_by = ? AND a.status = 'shortlisted'
      `,
      [recruiterId]
    );

    // 🔥 5. RECENT APPLICANTS
    const [recentApplicants] = await db.query(
      `
      SELECT 
        users.full_name,
        applications.status,
        applications.created_at
      FROM applications
      JOIN users ON users.id = applications.candidate_id
      JOIN jobs ON jobs.id = applications.job_id
      WHERE jobs.created_by = ?
      ORDER BY applications.created_at DESC
      LIMIT 5
      `,
      [recruiterId]
    );

    // 🔥 6. CHART (last 7 days)
     const [chart] = await db.query(
     `
      SELECT 
        DATE(a.created_at) as date,
        COUNT(DISTINCT a.id) as applicants,
        COUNT(DISTINCT j.id) as jobs
      FROM jobs j
      LEFT JOIN applications a ON j.id = a.job_id
      WHERE j.created_by = ?
      AND (a.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) OR a.created_at IS NULL)
      GROUP BY DATE(a.created_at)
      ORDER BY date ASC
      `,
      [recruiterId]
    );
      // 🔥 GET COMPANY NAME
      const [company] = await db.query(
  "SELECT name, logo FROM company_profiles WHERE user_id = ?",
  [recruiterId]
);

    res.status(200).json({
      stats: {
        totalApplicants: totalApplicants[0].total,
        activeJobs: activeJobs[0].total,
        pending: pending[0].total,
        interviewing: interviewing[0].total
      },
      recentApplicants,
      chartData: chart,
      company: company[0] || null
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});

module.exports = router;