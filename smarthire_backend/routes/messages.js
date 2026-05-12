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
        conversation: existing[0],
      });
    }

    const [users] = await db.query(
      "SELECT id, role FROM users WHERE id IN (?, ?)",
      [currentUser, user_id]
    );

    const candidate = users.find((u) => u.role === "candidate");
    const recruiter = users.find((u) => u.role === "recruiter");

    if (!candidate || !recruiter) {
      return res.status(400).json({
        message: "Conversation invalide",
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
      conversationId: result.insertId,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
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

        otherUser.full_name AS other_user_name,
        otherUser.role AS other_user_role,

        candidateProfile.profile_photo AS candidate_photo,

        companyProfile.name AS company_name,
        companyProfile.logo AS company_logo,

        COALESCE(unread.unread_count, 0) AS unread_count

      FROM conversations

      JOIN users otherUser
        ON otherUser.id = IF(
          conversations.candidate_id = ?,
          conversations.recruiter_id,
          conversations.candidate_id
        )

      LEFT JOIN candidate_profiles candidateProfile
        ON candidateProfile.user_id = conversations.candidate_id

      LEFT JOIN company_profiles companyProfile
        ON companyProfile.user_id = conversations.recruiter_id

      LEFT JOIN (
        SELECT conversation_id, COUNT(*) AS unread_count
        FROM messages
        WHERE receiver_id = ?
        AND is_read = 0
        GROUP BY conversation_id
      ) unread 
        ON unread.conversation_id = conversations.id

      WHERE conversations.candidate_id = ?
         OR conversations.recruiter_id = ?

      ORDER BY conversations.created_at DESC
      `,
      [userId, userId, userId, userId]
    );

    res.status(200).json({
      count: rows.length,
      conversations: rows,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
});

// ==============================
// SEND MESSAGE REALTIME
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
        message: "Accès refusé",
      });
    }

    const receiverId =
      conv[0].candidate_id === req.user.id
        ? conv[0].recruiter_id
        : conv[0].candidate_id;

    const [result] = await db.query(
      `
      INSERT INTO messages 
        (conversation_id, sender_id, receiver_id, message, is_read)
      VALUES (?, ?, ?, ?, 0)
      `,
      [conversation_id, req.user.id, receiverId, message]
    );

    const createdAt = new Date();

    const io = req.app.get("io");

    if (io) {
      io.to(conversation_id).emit("newMessage", {
        id: result.insertId,
        conversation_id,
        sender_id: req.user.id,
        receiver_id: receiverId,
        message,
        is_read: 0,
        created_at: createdAt.toISOString(),
      });
    }

    res.status(201).json({
      message: "Message envoyé",
      messageId: result.insertId,
      receiver_id: receiverId,
      is_read: 0,
      created_at: createdAt.toISOString(),
    });
  } catch (err) {
    console.error("ERROR SEND MESSAGE:", err);

    res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
});

// ==============================
// MARK CONVERSATION AS READ
// ==============================
router.put("/:conversationId/read", protect, async (req, res) => {
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
        message: "Accès refusé",
      });
    }

    const [result] = await db.query(
      `
      UPDATE messages
      SET is_read = 1
      WHERE conversation_id = ?
      AND receiver_id = ?
      AND is_read = 0
      `,
      [conversationId, req.user.id]
    );

    res.status(200).json({
      success: true,
      message: "Messages marked as read",
      affectedRows: result.affectedRows,
    });
  } catch (error) {
    console.error("ERROR MARK AS READ:", error);
    res.status(500).json({
      message: "Server error",
      error: error.message,
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

    await db.query(`DELETE FROM messages WHERE id = ?`, [messageId]);

    const io = req.app.get("io");

    if (io) {
      io.to(message.conversation_id).emit("deleteMessage", {
        id: Number(messageId),
      });
    }

    res.status(200).json({ message: "Message supprimé" });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
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
        message: "Accès refusé",
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
      messages: rows,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
});

module.exports = router;