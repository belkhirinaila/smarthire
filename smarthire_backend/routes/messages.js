const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect } = require("../middleware/authMiddleware");

// ==============================
// CREATE OR GET CONVERSATION
// ==============================
router.post("/conversation", protect, async (req, res) => {
  try {
    const { user_id } = req.body;
    const currentUser = req.user.id;

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
    console.error(err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });
  }
});

// ==============================
// GET MY CONVERSATIONS
// ==============================
router.get("/conversations", protect, async (req, res) => {
  try {
    const userId = req.user.id;

    const [rows] = await db.query(
      `
      SELECT
        conversations.*,
        u.full_name AS other_user_name,
        cp.name AS company_name,
        COALESCE(unread.unread_count, 0) AS unread_count
      FROM conversations
      JOIN users u
        ON u.id = IF(conversations.candidate_id = ?, conversations.recruiter_id, conversations.candidate_id)
      LEFT JOIN company_profiles cp
        ON cp.user_id = IF(conversations.candidate_id = ?, conversations.recruiter_id, conversations.candidate_id)
      LEFT JOIN (
        SELECT conversation_id, COUNT(*) AS unread_count
        FROM messages
        WHERE sender_id != ?
        GROUP BY conversation_id
      ) unread ON unread.conversation_id = conversations.id
      WHERE conversations.candidate_id = ? OR conversations.recruiter_id = ?
      ORDER BY conversations.created_at DESC
      `,
      [userId, userId, userId, userId, userId]
    );

    res.status(200).json({
      count: rows.length,
      conversations: rows
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
// SEND MESSAGE (REALTIME 🔥)
// ==============================
router.post("/", protect, async (req, res) => {
  try {
    const { conversation_id, message } = req.body;

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

    const [result] = await db.query(
      `
      INSERT INTO messages (conversation_id, sender_id, message)
      VALUES (?, ?, ?)
      `,
      [conversation_id, req.user.id, message]
    );

    const createdAt = new Date();

    // 🔥 SOCKET REALTIME
    const io = req.app.get("io");

    if (io) {
      io.to(conversation_id).emit("newMessage", {
        id: result.insertId,
        conversation_id,
        sender_id: req.user.id,
        message,
        created_at: createdAt.toISOString(),
      });
    }

    res.status(201).json({
      message: "Message envoyé",
      messageId: result.insertId,
      created_at: createdAt.toISOString(),
    });

  } catch (err) {
  console.error("ERROR SEND MESSAGE:", err);

  res.status(500).json({
    message: "Erreur serveur",
    error: err.message
  });
}
});

// ==============================
// DELETE MESSAGE
// ==============================
router.delete("/:messageId", protect, async (req, res) => {
  try {
    const { messageId } = req.params;

    const [rows] = await db.query(
      `SELECT * FROM messages WHERE id = ?`,
      [messageId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Message introuvable" });
    }

    const message = rows[0];
    if (message.sender_id !== req.user.id) {
      return res.status(403).json({ message: "Action interdite" });
    }

    await db.query(
      `DELETE FROM messages WHERE id = ?`,
      [messageId]
    );

    const io = req.app.get("io");
    if (io) {
      io.to(message.conversation_id).emit("deleteMessage", {
        id: Number(messageId),
      });
    }

    res.status(200).json({ message: "Message supprimé" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// ==============================
// GET MESSAGES
// ==============================
router.get("/:conversationId", protect, async (req, res) => {
  try {
    const { conversationId } = req.params;

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
    console.error(err);
    res.status(500).json({
      message: "Erreur serveur"
    });
  }
});

module.exports = router;