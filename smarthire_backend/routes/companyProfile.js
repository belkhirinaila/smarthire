const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// GET MY COMPANY PROFILE
// ==============================
router.get("/me", protect, authorize("recruiter"), async (req, res) => {
  try {
    // 🔥 1. company
    const [companyRows] = await db.query(
      "SELECT * FROM company_profiles WHERE user_id = ?",
      [req.user.id]
    );

    if (companyRows.length === 0) {
      return res.status(200).json({
        company: null,
        jobs: [],
        stats: {}
      });
    }

    const company = companyRows[0];

    // 🔥 2. jobs (IMPORTANT)
    const [jobs] = await db.query(
      "SELECT * FROM jobs WHERE recruiter_id = ? ORDER BY created_at DESC",
      [req.user.id]
    );

    // 🔥 3. applications count
    const [applications] = await db.query(
      `
      SELECT COUNT(*) as total 
      FROM applications a
      JOIN jobs j ON a.job_id = j.id
      WHERE j.recruiter_id = ?
      `,
      [req.user.id]
    );

    // 🔥 4. stats REAL
    const stats = {
      jobs: jobs.length,
      applications: applications[0].total,
      employees: company.company_size || 0
    };

    // 🔥 FINAL RESPONSE
    res.status(200).json({
      company,
      jobs,
      stats
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// CREATE COMPANY PROFILE
// ==============================
router.post("/", protect, authorize("recruiter"), async (req, res) => {
  try {
    const {
      name,
      industry,
      website,
      description,
      logo,
      cover_image,
      location,
      company_size
    } = req.body;

    // 🔍 vérifier si déjà existe
    const [existing] = await db.query(
      "SELECT id FROM company_profiles WHERE user_id = ?",
      [req.user.id]
    );

    if (existing.length > 0) {
      return res.status(409).json({
        message: "Company déjà existante"
      });
    }

    // 📝 insertion
    const [result] = await db.query(
      `
      INSERT INTO company_profiles
      (user_id, name, industry, website, description, logo, cover_image, location, company_size)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        req.user.id,
        name,
        industry,
        website,
        description,
        logo,
        cover_image,
        location,
        company_size
      ]
    );

    res.status(201).json({
      message: "Company créée avec succès",
      companyId: result.insertId
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// UPDATE COMPANY PROFILE
// ==============================
router.put("/", protect, authorize("recruiter"), async (req, res) => {
  try {
    const {
      name,
      industry,
      website,
      description,
      logo,
      cover_image,
      location,
      company_size
    } = req.body;

    // 🔍 vérifier existence
    const [existing] = await db.query(
      "SELECT id FROM company_profiles WHERE user_id = ?",
      [req.user.id]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        message: "Company non trouvée"
      });
    }

    // 🔄 update
    const [updateResult] = await db.query(
      `
      UPDATE company_profiles
      SET
        name = ?,
        description = ?,
        website = ?,
        location = ?,
        industry = ?,
        company_size = ?
      WHERE user_id = ?
      `,
      [
        name,
        description,
        website,
        location,
        industry,
        company_size,
        req.user.id
      ]
    );

    console.log("Company profile update result:", {
      userId: req.user.id,
      name,
      description,
      website,
      location,
      industry,
      company_size,
      affectedRows: updateResult.affectedRows
    });

    if (updateResult.affectedRows === 0) {
      return res.status(400).json({
        message: "Aucune ligne mise à jour"
      });
    }

    res.status(200).json({
      message: "Company mise à jour avec succès",
      affectedRows: updateResult.affectedRows
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});

module.exports = router;