const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect } = require("../middleware/authMiddleware");

// CREATE OR GET CONVERSATION
router.post("/conversation", protect, async (req, res) => {
  try {
    const { recruiter_id } = req.body;
    const candidate_id = req.user.id;

    // check if exists
    const [existing] = await db.query(
      "SELECT * FROM conversations WHERE candidate_id = ? AND recruiter_id = ?",
      [candidate_id, recruiter_id]
    );

    if (existing.length > 0) {
      return res.status(200).json({ conversation: existing[0] });
    }

    const [result] = await db.query(
      "INSERT INTO conversations (candidate_id, recruiter_id) VALUES (?, ?)",
      [candidate_id, recruiter_id]
    );

    res.status(201).json({
      message: "Conversation créée",
      conversationId: result.insertId
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// GET MY CONVERSATIONS
router.get("/conversations", protect, async (req, res) => {
  try {
    const userId = req.user.id;

    const [rows] = await db.query(
      `SELECT * FROM conversations 
       WHERE candidate_id = ? OR recruiter_id = ?`,
      [userId, userId]
    );

    res.status(200).json({
      count: rows.length,
      conversations: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// SEND MESSAGE
router.post("/", protect, async (req, res) => {
  try {
    const { conversation_id, message } = req.body;

    const [result] = await db.query(
      "INSERT INTO messages (conversation_id, sender_id, message) VALUES (?, ?, ?)",
      [conversation_id, req.user.id, message]
    );

    res.status(201).json({
      message: "Message envoyé",
      messageId: result.insertId
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

// GET MESSAGES OF CONVERSATION
router.get("/:conversationId", protect, async (req, res) => {
  try {
    const { conversationId } = req.params;

    const [rows] = await db.query(
      "SELECT * FROM messages WHERE conversation_id = ? ORDER BY created_at ASC",
      [conversationId]
    );

    res.status(200).json({
      count: rows.length,
      messages: rows
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur serveur", error: err.message });
  }
});

module.exports = router;