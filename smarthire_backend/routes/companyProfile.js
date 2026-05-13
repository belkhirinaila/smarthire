const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");
const multer = require("multer");
const { CloudinaryStorage } = require("multer-storage-cloudinary");
const cloudinary = require("../config/cloudinary");
const fs = require("fs");

const uploadPath = path.join(__dirname, "../uploads/company");
fs.mkdirSync(uploadPath, { recursive: true });

const storage = new CloudinaryStorage({
  cloudinary,
  params: async (req, file) => {
    return {
      folder: "smarthire/company",
      resource_type: "auto",
      allowed_formats: [
        "jpg",
        "jpeg",
        "png",
        "webp",
        "pdf",
      ],
    };
  },
});

const upload = multer({ storage });

const upload = multer({ storage });


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
router.post(
  "/",
  protect,
  authorize("recruiter"),

  upload.fields([
    { name: "logo", maxCount: 1 },
    { name: "cover_image", maxCount: 1 },
    { name: "registre_commerce", maxCount: 1 },
    { name: "nif_nis", maxCount: 1 },
    { name: "carte_fiscale", maxCount: 1 },
  ]),

  async (req, res) => {
    try {
      const {
        name,
        industry,
        website,
        description,
        location,
        company_size,
      } = req.body;

      let logo = null;
      let cover_image = null;
      let registre_commerce = null;
      let nif_nis = null;
      let carte_fiscale = null;

      if (req.files?.logo) {
        logo = req.files.logo[0].path;
      }

      if (req.files?.cover_image) {
        cover_image =req.files.cover_image[0].path;
      }

      if (req.files?.registre_commerce) {
        registre_commerce = req.files.registre_commerce[0].path;
      }

      if (req.files?.nif_nis) {
        nif_nis = req.files.nif_nis[0].path;
      }

      if (req.files?.carte_fiscale) {
        carte_fiscale = req.files.carte_fiscale[0].path;
      }

      const [existing] = await db.query(
        "SELECT id FROM company_profiles WHERE user_id = ?",
        [req.user.id]
      );

      if (existing.length > 0) {
        return res.status(409).json({
          message: "Company déjà existante",
        });
      }

      const [result] = await db.query(
        `
        INSERT INTO company_profiles
        (
          user_id,
          name,
          industry,
          website,
          description,
          logo,
          cover_image,
          registre_commerce,
          nif_nis,
          carte_fiscale,
          location,
          company_size,
          status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')
        `,
        [
          req.user.id,
          name,
          industry,
          website,
          description,
          logo,
          cover_image,
          registre_commerce,
          nif_nis,
          carte_fiscale,
          location,
          company_size,
        ]
      );

      res.status(201).json({
        message: "Company created successfully",
        companyId: result.insertId,
      });
    } catch (err) {
      console.log(err);
      res.status(500).json({
        message: "Erreur serveur",
        error: err.message,
      });
    }
  }
);


// ==============================
// UPDATE COMPANY PROFILE
// ==============================
router.put(
  "/",
  protect,
  authorize("recruiter"),

  upload.fields([
    { name: "logo", maxCount: 1 },
    { name: "cover_image", maxCount: 1 },
    { name: "registre_commerce", maxCount: 1 },
    { name: "nif_nis", maxCount: 1 },
    { name: "carte_fiscale", maxCount: 1 },
  ]),

  async (req, res) => {
    try {
      const {
        name,
        industry,
        website,
        description,
        location,
        company_size,
      } = req.body;

      let logo = null;
      let cover_image = null;
      let registre_commerce = null;
      let nif_nis = null;
      let carte_fiscale = null;

      if (req.files?.logo) {
        logo = req.files.logo[0].path;
      }

      if (req.files?.cover_image) {
        cover_image = req.files.cover_image[0].path;
      }

      if (req.files?.registre_commerce) {
        registre_commerce = req.files.registre_commerce[0].path;
      }

      if (req.files?.nif_nis) {
        nif_nis = req.files.nif_nis[0].path;
      }

      if (req.files?.carte_fiscale) {
        carte_fiscale = req.files.carte_fiscale[0].path;
      }

      const [existing] = await db.query(
        "SELECT * FROM company_profiles WHERE user_id = ?",
        [req.user.id]
      );

      if (existing.length === 0) {
        return res.status(404).json({
          message: "Company non trouvée",
        });
      }

      const currentCompany = existing[0];

      logo = logo || currentCompany.logo;
      cover_image = cover_image || currentCompany.cover_image;
      registre_commerce =
        registre_commerce || currentCompany.registre_commerce;
      nif_nis = nif_nis || currentCompany.nif_nis;
      carte_fiscale = carte_fiscale || currentCompany.carte_fiscale;

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
          registre_commerce = ?,
          nif_nis = ?,
          carte_fiscale = ?,
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
          registre_commerce,
          nif_nis,
          carte_fiscale,
          location,
          company_size,
          req.user.id,
        ]
      );

      res.status(200).json({
        message: "Company updated successfully ✅",
      });
    } catch (err) {
      console.log(err);
      res.status(500).json({
        message: "Erreur serveur",
        error: err.message,
      });
    }
  }
);


// ========================================
// GET COMPANY PROFILE FOR CANDIDATE
// ========================================
router.get("/:id", async (req, res) => {

  try {

    const companyId = req.params.id;

    const [rows] = await db.query(
      `
      SELECT

        cp.*,

        u.email

      FROM company_profiles cp

      LEFT JOIN users u
        ON u.id = cp.user_id

      WHERE cp.id = ?
      `,
      [companyId]
    );

    if (rows.length === 0) {

      return res.status(404).json({
        message: "Company not found"
      });

    }

    // ========================================
    // GET COMPANY JOBS COUNT
    // ========================================
    const [jobsCount] = await db.query(
      `
      SELECT COUNT(*) as totalJobs
      FROM jobs
      WHERE company_id = ?
      `,
      [companyId]
    );

    res.status(200).json({

      company: {
        ...rows[0],
        total_jobs: jobsCount[0].totalJobs
      }

    });

  } catch (err) {

    console.log(err);

    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });

  }
});

module.exports = router;