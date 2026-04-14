const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// GET DASHBOARD STATS
// ==============================
router.get("/", protect, authorize("recruiter"), async (req, res) => {
  try {
    const recruiterId = req.user.id;

    // ==============================
    // 🔍 Total jobs du recruiter
    // ==============================
    const [jobs] = await db.query(
      "SELECT id FROM jobs WHERE created_by = ?",
      [recruiterId]
    );

    const jobIds = jobs.map(j => j.id);

    if (jobIds.length === 0) {
      return res.status(200).json({
        totalApplicants: 0,
        activeJobs: 0,
        interviewing: 0,
        trends: []
      });
    }

    // ==============================
    // 🔍 Total applicants
    // ==============================
    const [totalApplicantsResult] = await db.query(
      `
      SELECT COUNT(*) AS total 
      FROM applications
      WHERE job_id IN (${jobIds.map(() => "?").join(",")})
      `,
      jobIds
    );

    // ==============================
    // 🔍 Active jobs
    // ==============================
    const [activeJobsResult] = await db.query(
      `
      SELECT COUNT(*) AS total
      FROM jobs
      WHERE created_by = ? AND status = 'active'
      `,
      [recruiterId]
    );

    // ==============================
    // 🔍 Interviewing (shortlisted)
    // ==============================
    const [interviewingResult] = await db.query(
      `
      SELECT COUNT(*) AS total
      FROM applications
      WHERE status = 'shortlisted'
      AND job_id IN (${jobIds.map(() => "?").join(",")})
      `,
      jobIds
    );

    // ==============================
    // 🔍 Applications last 7 days (graph)
    // ==============================
    const [trends] = await db.query(
      `
      SELECT DATE(created_at) as date, COUNT(*) as count
      FROM applications
      WHERE job_id IN (${jobIds.map(() => "?").join(",")})
      AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
      GROUP BY DATE(created_at)
      ORDER BY DATE(created_at)
      `,
      jobIds
    );

    res.status(200).json({
      totalApplicants: totalApplicantsResult[0].total,
      activeJobs: activeJobsResult[0].total,
      interviewing: interviewingResult[0].total,
      trends
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});

module.exports = router;