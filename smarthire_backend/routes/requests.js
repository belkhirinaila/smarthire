const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// SEND ACCESS REQUEST (recruiter)
// ==============================
router.post("/", protect, authorize("recruiter"), async (req, res) => {
  try {
    const { candidate_id } = req.body;
    const recruiter_id = req.user.id;

    // 🔍 Vérifier si déjà existe
    const [existing] = await db.query(
      `
      SELECT id FROM access_requests 
      WHERE recruiter_id = ? AND candidate_id = ?
      `,
      [recruiter_id, candidate_id]
    );

    if (existing.length > 0) {
      return res.status(409).json({
        message: "Request déjà envoyée"
      });
    }

    // 📝 Insert request
    await db.query(
      `
      INSERT INTO access_requests (recruiter_id, candidate_id)
      VALUES (?, ?)
      `,
      [recruiter_id, candidate_id]
    );

    // 🔔 Notification pour candidate
    await db.query(
      `
      INSERT INTO notifications (user_id, title, message, type)
      VALUES (?, ?, ?, ?)
      `,
      [
        candidate_id,
        "New recruiter request",
        "A recruiter sent you a request.",
        "request"
      ]
    );

    res.status(201).json({
      message: "Request envoyée avec succès"
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// GET SENT REQUESTS (recruiter)
// ==============================
router.get("/sent", protect, authorize("recruiter"), async (req, res) => {
  try {
    const recruiter_id = req.user.id;

    const [rows] = await db.query(
      `
      SELECT 
        access_requests.*,
        users.full_name
      FROM access_requests
      JOIN users ON users.id = access_requests.candidate_id
      WHERE recruiter_id = ?
      ORDER BY created_at DESC
      `,
      [recruiter_id]
    );

    res.status(200).json({
      count: rows.length,
      requests: rows
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// GET RECEIVED REQUESTS (candidate)
// ==============================
router.get("/received", protect, authorize("candidate"), async (req, res) => {
  try {
    const candidate_id = req.user.id;

    const [rows] = await db.query(
      `
      SELECT 
        access_requests.*,
        users.full_name
      FROM access_requests
      JOIN users ON users.id = access_requests.recruiter_id
      WHERE candidate_id = ?
      ORDER BY created_at DESC
      `,
      [candidate_id]
    );

    res.status(200).json({
      count: rows.length,
      requests: rows
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// UPDATE REQUEST (approve / reject)
// ==============================
router.put("/:id", protect, authorize("candidate"), async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    // 🔍 Vérifier statut valide
    if (!["approved", "rejected"].includes(status)) {
      return res.status(400).json({
        message: "Statut invalide"
      });
    }

    // 🔍 Vérifier ownership
    const [rows] = await db.query(
      `
      SELECT * FROM access_requests 
      WHERE id = ? AND candidate_id = ?
      `,
      [id, req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: "Request non trouvée"
      });
    }

    const request = rows[0];

    // 🔄 Update
    await db.query(
      `
      UPDATE access_requests 
      SET status = ?
      WHERE id = ?
      `,
      [status, id]
    );

    // 🔔 Notification pour recruiter
    await db.query(
      `
      INSERT INTO notifications (user_id, title, message, type)
      VALUES (?, ?, ?, ?)
      `,
      [
        request.recruiter_id,
        "Request updated",
        `Your access request was ${status}.`,
        "request"
      ]
    );

    res.status(200).json({
      message: "Request mise à jour avec succès"
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});

module.exports = router;