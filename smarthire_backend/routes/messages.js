const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect } = require("../middleware/authMiddleware");


// ==============================
// CREATE OR GET CONVERSATION
// ==============================
router.post("/conversation", protect, async (req, res) => {
  try {
    const { user_id } = req.body; // 🔥 generic (candidate OR recruiter)

    const currentUser = req.user.id;

    // 🔍 check if conversation exists
    const [existing] = await db.query(
      `
      SELECT * FROM conversations 
      WHERE 
        (candidate_id = ? AND recruiter_id = ?)
        OR
        (candidate_id = ? AND recruiter_id = ?)
      `,
      [currentUser, user_id, user_id, currentUser]
    );

    if (existing.length > 0) {
      return res.status(200).json({
        conversation: existing[0]
      });
    }

    // 🧠 déterminer qui est candidate / recruiter
    const [users] = await db.query(
      "SELECT id, role FROM users WHERE id IN (?, ?)",
      [currentUser, user_id]
    );

    const candidate = users.find(u => u.role === "candidate");
    const recruiter = users.find(u => u.role === "recruiter");

    if (!candidate || !recruiter) {
      return res.status(400).json({
        message: "Conversation invalide"
      });
    }

    // 📝 create conversation
    const [result] = await db.query(
      `
      INSERT INTO conversations (candidate_id, recruiter_id)
      VALUES (?, ?)
      `,
      [candidate.id, recruiter.id]
    );

    res.status(201).json({
      message: "Conversation créée",
      conversationId: result.insertId
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// GET MY CONVERSATIONS (INBOX)
// ==============================
router.get("/conversations", protect, async (req, res) => {
  try {
    const userId = req.user.id;

    const [rows] = await db.query(
      `
      SELECT 
        conversations.*,
        u.full_name AS other_user_name
      FROM conversations
      JOIN users u 
        ON u.id = IF(conversations.candidate_id = ?, conversations.recruiter_id, conversations.candidate_id)
      WHERE conversations.candidate_id = ? OR conversations.recruiter_id = ?
      ORDER BY conversations.created_at DESC
      `,
      [userId, userId, userId]
    );

    res.status(200).json({
      count: rows.length,
      conversations: rows
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});


// ==============================
// SEND MESSAGE (WITH FILE)
// ==============================
router.post("/", protect, async (req, res) => {
  try {
    const { conversation_id, message, file_url } = req.body;

    // 🔍 vérifier access
    const [conv] = await db.query(
      `
      SELECT * FROM conversations
      WHERE id = ? AND (candidate_id = ? OR recruiter_id = ?)
      `,
      [conversation_id, req.user.id, req.user.id]
    );

    if (conv.length === 0) {
      return res.status(403).json({
        message: "Accès refusé"
      });
    }

    // 📝 insert message
    const [result] = await db.query(
      `
      INSERT INTO messages (conversation_id, sender_id, message, file_url)
      VALUES (?, ?, ?, ?)
      `,
      [conversation_id, req.user.id, message, file_url || null]
    );

    res.status(201).json({
      message: "Message envoyé",
      messageId: result.insertId
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});


// ==============================
// GET MESSAGES OF CONVERSATION
// ==============================
router.get("/:conversationId", protect, async (req, res) => {
  try {
    const { conversationId } = req.params;

    // 🔍 vérifier access
    const [conv] = await db.query(
      `
      SELECT * FROM conversations
      WHERE id = ? AND (candidate_id = ? OR recruiter_id = ?)
      `,
      [conversationId, req.user.id, req.user.id]
    );

    if (conv.length === 0) {
      return res.status(403).json({
        message: "Accès refusé"
      });
    }

    const [rows] = await db.query(
      `
      SELECT 
        messages.*,
        users.full_name
      FROM messages
      JOIN users ON users.id = messages.sender_id
      WHERE conversation_id = ?
      ORDER BY created_at ASC
      `,
      [conversationId]
    );

    res.status(200).json({
      count: rows.length,
      messages: rows
    });

  } catch (err) {
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});

module.exports = router;