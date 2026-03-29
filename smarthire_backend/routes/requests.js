const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect } = require("../middleware/authMiddleware");

// CREATE REQUEST (recruiter → candidate)
router.post("/", protect, async (req, res) => {
  try {
    const { candidate_id } = req.body;

    const recruiter_id = req.user.id;

    await db.query(
      "INSERT INTO access_requests (recruiter_id, candidate_id) VALUES (?, ?)",
      [recruiter_id, candidate_id]
    );

    res.status(201).json({ message: "Request envoyée" });
  } catch (err) {
    if (err.code === "ER_DUP_ENTRY") {
      return res.status(400).json({ message: "Request déjà envoyée" });
    }
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// GET RECEIVED REQUESTS (candidate)
router.get("/received", protect, async (req, res) => {
  try {
    const candidate_id = req.user.id;

    const [rows] = await db.query(
      "SELECT * FROM access_requests WHERE candidate_id = ?",
      [candidate_id]
    );

    res.json({
      count: rows.length,
      requests: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// GET SENT REQUESTS (recruiter)
router.get("/sent", protect, async (req, res) => {
  try {
    const recruiter_id = req.user.id;

    const [rows] = await db.query(
      "SELECT * FROM access_requests WHERE recruiter_id = ?",
      [recruiter_id]
    );

    res.json({
      count: rows.length,
      requests: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// UPDATE REQUEST (candidate approve / reject)
router.put("/:id", protect, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!["approved", "rejected"].includes(status)) {
      return res.status(400).json({ message: "Statut invalide" });
    }

    // check ownership
    const [rows] = await db.query(
      "SELECT * FROM access_requests WHERE id = ? AND candidate_id = ?",
      [id, req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Request non trouvée" });
    }

    await db.query(
      "UPDATE access_requests SET status = ? WHERE id = ?",
      [status, id]
    );

    res.json({ message: "Request mise à jour" });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;