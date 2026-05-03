const express = require("express");
const router = express.Router();
const db = require("../config/db");
const bcrypt = require("bcryptjs");
const { protect, authorize } = require("../middleware/authMiddleware");
// ==============================
// 🛡️ CREATE ADMIN (ONLY ONCE)
// ==============================
/*
router.post("/create-admin", async (req, res) => {
  try {
    const { full_name, email, password } = req.body;

    // 🔥 vérifier s'il existe déjà un admin
    const [existingAdmin] = await db.query(
      "SELECT * FROM users WHERE role = 'admin'"
    );

    if (existingAdmin.length > 0) {
      return res.status(403).json({
        message: "Admin déjà existant ❌"
      });
    }

    // 🔐 hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // 🧑‍💼 create admin
    await db.query(
      "INSERT INTO users (full_name, email, password, role) VALUES (?, ?, ?, 'admin')",
      [full_name, email, hashedPassword]
    );

    res.json({
      message: "Admin créé avec succès ✅"
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
}); */




// ==============================
// 👥 GET ALL USERS
// ==============================
router.get("/users", protect, authorize("admin"), async (req, res) => {
  try {
    const [users] = await db.query(`
      SELECT id, email, role, is_blocked, created_at
      FROM users
      ORDER BY created_at DESC
    `);

    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// ==============================
// ❌ DELETE USER
// ==============================
router.delete("/users/:id", protect, authorize("admin"), async (req, res) => {
  try {
    const userId = req.params.id;

    await db.query("DELETE FROM users WHERE id = ?", [userId]);

    res.json({ message: "User supprimé ✅" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// ==============================
// 🚫 BLOCK / UNBLOCK USER
// ==============================
router.put("/users/:id/block", protect, authorize("admin"), async (req, res) => {
  try {
    const userId = req.params.id;
    const { is_blocked } = req.body; // true / false

    await db.query(
      "UPDATE users SET is_blocked = ? WHERE id = ?",
      [is_blocked, userId]
    );

    res.json({ message: "User status updated ✅" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});


// ==============================
// 📄 GET ALL JOBS
// ==============================
router.get("/jobs", protect, authorize("admin"), async (req, res) => {
  try {
    const [jobs] = await db.query(`
      SELECT j.*, u.email as recruiter_email
      FROM jobs j
      LEFT JOIN users u ON j.recruiter_id = u.id
      ORDER BY j.created_at DESC
    `);

    res.json(jobs);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});


// ==============================
// ❌ DELETE JOB
// ==============================
router.delete("/jobs/:id", protect, authorize("admin"), async (req, res) => {
  try {
    const jobId = req.params.id;

    await db.query("DELETE FROM jobs WHERE id = ?", [jobId]);

    res.json({ message: "Job supprimé ✅" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// ==============================
// 🏢 GET ALL COMPANIES
// ==============================
router.get("/companies", protect, authorize("admin"), async (req, res) => {
  try {
    const [companies] = await db.query(`
      SELECT *
      FROM company_profiles
      ORDER BY created_at DESC
    `);

    res.json(companies);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// ==============================
// 🟢 APPROVE / 🔴 REJECT COMPANY
// ==============================
router.put("/companies/:id/status", protect, authorize("admin"), async (req, res) => {
  try {
    const companyId = req.params.id;
    const { status } = req.body; // 'approved' | 'rejected'

    await db.query(
      "UPDATE company_profiles SET status = ? WHERE id = ?",
      [status, companyId]
    );

    res.json({ message: "Company status updated ✅" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// ==============================
// 🚫 GET BLOCKED USERS
// ==============================
router.get("/users/blocked", protect, authorize("admin"), async (req, res) => {
  try {
    const [users] = await db.query(`
      SELECT id, email, role, is_blocked, created_at
      FROM users
      WHERE is_blocked = 1
      ORDER BY created_at DESC
    `);

    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});


// ==============================
// ⏳ GET PENDING COMPANIES
// ==============================
router.get("/companies/pending", protect, authorize("admin"), async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT * FROM company_profiles
      WHERE status = 'pending'
      ORDER BY created_at DESC
    `);

    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: "Erreur serveur" });
  }
});



// ==============================
// ✅ GET APPROVED COMPANIES
// ==============================
router.get("/companies/approved", protect, authorize("admin"), async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT * FROM company_profiles
      WHERE status = 'approved'
      ORDER BY created_at DESC
    `);

    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: "Erreur serveur" });
  }
});



// ==============================
// ❌ GET REJECTED COMPANIES
// ==============================
router.get("/companies/rejected", protect, authorize("admin"), async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT * FROM company_profiles
      WHERE status = 'rejected'
      ORDER BY created_at DESC
    `);

    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// ==============================
// 🚫 GET BLOCKED JOBS
// ==============================
router.get("/jobs/blocked", protect, authorize("admin"), async (req, res) => {
  try {
    const [jobs] = await db.query(`
      SELECT * FROM jobs
      WHERE is_blocked = 1
      ORDER BY created_at DESC
    `);

    res.json(jobs);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

module.exports = router;