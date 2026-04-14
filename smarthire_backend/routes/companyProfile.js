const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// GET MY COMPANY PROFILE
// ==============================
router.get("/me", protect, authorize("recruiter"), async (req, res) => {
  try {
    // 🔍 récupérer la company liée au recruiter
    const [rows] = await db.query(
      "SELECT * FROM company_profiles WHERE user_id = ?",
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(200).json({
        message: "Company non encore créée",
        company: null
      });
    }

    res.status(200).json({
      company: rows[0]
    });

  } catch (err) {
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
    await db.query(
      `
      UPDATE company_profiles
      SET 
        name = ?,
        industry = ?,
        website = ?,
        description = ?,
        logo = ?,
        cover_image = ?,
        location = ?,
        company_size = ?
      WHERE user_id = ?
      `,
      [
        name,
        industry,
        website,
        description,
        logo,
        cover_image,
        location,
        company_size,
        req.user.id
      ]
    );

    res.status(200).json({
      message: "Company mise à jour avec succès"
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});

module.exports = router;