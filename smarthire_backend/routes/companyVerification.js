const express = require("express");
const router = express.Router();
const db = require("../config/db");
const upload = require("../config/upload"); // multer
const { protect, authorize } = require("../middleware/authMiddleware");


// ==============================
// 📤 SUBMIT VERIFICATION DOCUMENT
// ==============================
router.post(
  "/",
  protect,
  authorize("recruiter"),
  upload.single("document"), // 📎 file upload (PDF/image)
  async (req, res) => {
    try {
      // 🔍 récupérer la company du recruiter
      const [company] = await db.query(
        "SELECT id FROM company_profiles WHERE user_id = ?",
        [req.user.id]
      );

      if (company.length === 0) {
        return res.status(400).json({
          message: "Company introuvable"
        });
      }

      const companyId = company[0].id;

      // 🔍 vérifier si déjà une demande existe
      const [existing] = await db.query(
        "SELECT id, status FROM company_verifications WHERE company_id = ?",
        [companyId]
      );

      const filePath = "uploads/" + req.file.filename;

      // 🧠 si existe déjà → update (re-submit)
      if (existing.length > 0) {
        await db.query(
          `
          UPDATE company_verifications
          SET document = ?, status = 'pending', updated_at = NOW()
          WHERE company_id = ?
          `,
          [filePath, companyId]
        );

        return res.status(200).json({
          message: "Document mis à jour, en attente de validation"
        });
      }

      // 📝 sinon → insert
      await db.query(
        `
        INSERT INTO company_verifications (company_id, document)
        VALUES (?, ?)
        `,
        [companyId, filePath]
      );

      res.status(201).json({
        message: "Demande envoyée (pending)"
      });

    } catch (err) {
      res.status(500).json({
        message: "Erreur serveur",
        error: err.message
      });
    }
  }
);


// ==============================
// 🔍 GET VERIFICATION STATUS
// ==============================
router.get(
  "/",
  protect,
  authorize("recruiter"),
  async (req, res) => {
    try {
      // 🔍 récupérer company
      const [company] = await db.query(
        "SELECT id FROM company_profiles WHERE user_id = ?",
        [req.user.id]
      );

      if (company.length === 0) {
        return res.status(400).json({
          message: "Company introuvable"
        });
      }

      const companyId = company[0].id;

      const [verification] = await db.query(
        `
        SELECT id, document, status, created_at, updated_at
        FROM company_verifications
        WHERE company_id = ?
        `,
        [companyId]
      );

      res.status(200).json({
        verification: verification[0] || null
      });

    } catch (err) {
      res.status(500).json({
        message: "Erreur serveur"
      });
    }
  }
);


// ==============================
// 🛠️ ADMIN: UPDATE STATUS (approve / reject)
// ==============================
// ⚠️ هذا endpoint تستعمليه فقط في admin panel (اختياري)
router.put(
  "/:id",
  protect,
  // authorize("admin") ← إذا عندك role admin
  async (req, res) => {
    try {
      const { status } = req.body; // approved / rejected

      // 🔍 vérifier statut valide
      if (!["approved", "rejected"].includes(status)) {
        return res.status(400).json({
          message: "Statut invalide"
        });
      }

      await db.query(
        `
        UPDATE company_verifications
        SET status = ?, updated_at = NOW()
        WHERE id = ?
        `,
        [status, req.params.id]
      );

      res.status(200).json({
        message: "Status mis à jour"
      });

    } catch (err) {
      res.status(500).json({
        message: "Erreur serveur"
      });
    }
  }
);

module.exports = router;