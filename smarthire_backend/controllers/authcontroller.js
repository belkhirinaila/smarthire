const db = require("../config/db");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");

// ==============================
// Transporteur Mailtrap
// ==============================
const transporter = nodemailer.createTransport({
  host: process.env.MAIL_HOST,
  port: Number(process.env.MAIL_PORT),
  auth: {
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS,
  },
});

// ==============================
// Envoyer OTP par email
// ==============================
const sendOtpEmail = async (to, otpCode) => {
  await transporter.sendMail({
    from: "SmartHire <no-reply@smarthire.com>",
    to: to,
    subject: "Code OTP SmartHire DZ",
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>SmartHire DZ</h2>
        <p>Votre code OTP est :</p>
        <h1 style="letter-spacing: 6px;">${otpCode}</h1>
        <p>Ce code expire dans 10 minutes.</p>
      </div>
    `,
  });
};

// ==============================
// REGISTER
// Sauvegarder l'utilisateur dans pending_users seulement
// ==============================
const register = async (req, res) => {
  try {
    const { full_name, email, password, role } = req.body;

    // Nettoyer email
    const cleanEmail = email?.trim();

    // Vérifier les champs obligatoires
    if (!full_name || !cleanEmail || !password || !role) {
      return res.status(400).json({
        message: "Tous les champs sont obligatoires",
      });
    }

    // Vérifier format email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(cleanEmail)) {
      return res.status(400).json({
        message: "Format d'email invalide",
      });
    }

    // Vérifier longueur minimale du mot de passe
    if (password.length < 6) {
      return res.status(400).json({
        message: "Mot de passe trop court",
      });
    }

    // Vérifier si role est valide
    if (role !== "candidate" && role !== "recruiter") {
      return res.status(400).json({
        message: "Rôle invalide",
      });
    }

    // Vérifier si email existe déjà dans users
    const [existingUsers] = await db.query(
      "SELECT id FROM users WHERE email = ?",
      [cleanEmail]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        message: "Email déjà utilisé",
      });
    }

    // Vérifier si email existe déjà dans pending_users
    const [existingPending] = await db.query(
      "SELECT id FROM pending_users WHERE email = ?",
      [cleanEmail]
    );

    if (existingPending.length > 0) {
      return res.status(409).json({
        message: "Un code OTP a déjà été envoyé pour cet email",
      });
    }

    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Générer OTP
    const otpCode = Math.floor(1000 + Math.random() * 9000).toString();
    const otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000);

    // Sauvegarder dans pending_users
    await db.query(
      `INSERT INTO pending_users
      (full_name, email, password, role, otp_code, otp_expires_at)
      VALUES (?, ?, ?, ?, ?, ?)`,
      [full_name, cleanEmail, hashedPassword, role, otpCode, otpExpiresAt]
    );

    // Envoyer OTP par email
    await sendOtpEmail(cleanEmail, otpCode);

    return res.status(201).json({
      message: "Compte temporaire créé. Code OTP envoyé.",
      email: cleanEmail,
    });
  } catch (err) {
    return res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
};

// ==============================
// VERIFY OTP
// Déplacer l'utilisateur de pending_users vers users
// ==============================
const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    const cleanEmail = email?.trim();

    if (!cleanEmail || !otp) {
      return res.status(400).json({
        message: "Email et OTP requis",
      });
    }

    const [pendingUsers] = await db.query(
      "SELECT * FROM pending_users WHERE email = ? AND otp_code = ?",
      [cleanEmail, otp]
    );

    if (pendingUsers.length === 0) {
      return res.status(400).json({
        message: "Code OTP invalide",
      });
    }

    const pendingUser = pendingUsers[0];

    if (
      pendingUser.otp_expires_at &&
      new Date(pendingUser.otp_expires_at) < new Date()
    ) {
      return res.status(400).json({
        message: "Code OTP expiré",
      });
    }

    const [existingUsers] = await db.query(
      "SELECT id FROM users WHERE email = ?",
      [cleanEmail]
    );

    if (existingUsers.length > 0) {
      await db.query("DELETE FROM pending_users WHERE email = ?", [cleanEmail]);

      return res.status(409).json({
        message: "Email déjà utilisé",
      });
    }

    await db.query(
      `INSERT INTO users (full_name, email, password, role, is_verified)
       VALUES (?, ?, ?, ?, ?)`,
      [
        pendingUser.full_name,
        pendingUser.email,
        pendingUser.password,
        pendingUser.role,
        1,
      ]
    );

    await db.query("DELETE FROM pending_users WHERE email = ?", [cleanEmail]);

    return res.status(200).json({
      message: "Email vérifié avec succès",
    });
  } catch (err) {
    return res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
};

// ==============================
// RESEND OTP
// Générer et renvoyer un nouveau code OTP
// ==============================
const resendOtp = async (req, res) => {
  try {
    const { email } = req.body;
    const cleanEmail = email?.trim();

    if (!cleanEmail) {
      return res.status(400).json({
        message: "Email requis",
      });
    }

    const [pendingUsers] = await db.query(
      "SELECT * FROM pending_users WHERE email = ?",
      [cleanEmail]
    );

    if (pendingUsers.length === 0) {
      return res.status(404).json({
        message: "Utilisateur temporaire introuvable",
      });
    }

    const otpCode = Math.floor(1000 + Math.random() * 9000).toString();
    const otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await db.query(
      "UPDATE pending_users SET otp_code = ?, otp_expires_at = ? WHERE email = ?",
      [otpCode, otpExpiresAt, cleanEmail]
    );

    await sendOtpEmail(cleanEmail, otpCode);

    return res.status(200).json({
      message: "Nouveau code OTP envoyé avec succès",
    });
  } catch (err) {
    return res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
};

// ==============================
// FORGOT PASSWORD
// Générer un code OTP pour réinitialiser le mot de passe
// ==============================
const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const cleanEmail = email?.trim();

    if (!cleanEmail) {
      return res.status(400).json({
        message: "Email requis",
      });
    }

    const [users] = await db.query(
      "SELECT * FROM users WHERE email = ?",
      [cleanEmail]
    );

    if (users.length === 0) {
      return res.status(404).json({
        message: "Aucun compte trouvé avec cet email",
      });
    }

    const resetOtpCode = Math.floor(1000 + Math.random() * 9000).toString();
    const resetOtpExpiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await db.query(
      "UPDATE users SET reset_otp_code = ?, reset_otp_expires_at = ? WHERE email = ?",
      [resetOtpCode, resetOtpExpiresAt, cleanEmail]
    );

    await transporter.sendMail({
      from: "SmartHire <no-reply@smarthire.com>",
      to: cleanEmail,
      subject: "Code OTP de réinitialisation - SmartHire DZ",
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>Réinitialisation du mot de passe</h2>
          <p>Votre code OTP est :</p>
          <h1 style="letter-spacing: 6px;">${resetOtpCode}</h1>
          <p>Ce code expire dans 10 minutes.</p>
        </div>
      `,
    });

    return res.status(200).json({
      message: "Code OTP de réinitialisation envoyé avec succès",
      email: cleanEmail,
    });
  } catch (err) {
    return res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
};

// ==============================
// VERIFY RESET OTP
// Vérifier le code OTP de réinitialisation
// ==============================
const verifyResetOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    const cleanEmail = email?.trim();

    if (!cleanEmail || !otp) {
      return res.status(400).json({
        message: "Email et OTP requis",
      });
    }

    const [users] = await db.query(
      "SELECT * FROM users WHERE email = ? AND reset_otp_code = ?",
      [cleanEmail, otp]
    );

    if (users.length === 0) {
      return res.status(400).json({
        message: "Code OTP invalide",
      });
    }

    const user = users[0];

    if (
      user.reset_otp_expires_at &&
      new Date(user.reset_otp_expires_at) < new Date()
    ) {
      return res.status(400).json({
        message: "Code OTP expiré",
      });
    }

    return res.status(200).json({
      message: "Code OTP vérifié avec succès",
    });
  } catch (err) {
    return res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
};

// ==============================
// RESET PASSWORD
// Mettre à jour le mot de passe après vérification OTP
// ==============================
const resetPassword = async (req, res) => {
  try {
    const { email, newPassword } = req.body;
    const cleanEmail = email?.trim();

    if (!cleanEmail || !newPassword) {
      return res.status(400).json({
        message: "Email et nouveau mot de passe requis",
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        message: "Le mot de passe doit contenir au moins 6 caractères",
      });
    }

    const [users] = await db.query(
      "SELECT * FROM users WHERE email = ?",
      [cleanEmail]
    );

    if (users.length === 0) {
      return res.status(404).json({
        message: "Utilisateur introuvable",
      });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await db.query(
      `UPDATE users
       SET password = ?, reset_otp_code = NULL, reset_otp_expires_at = NULL
       WHERE email = ?`,
      [hashedPassword, cleanEmail]
    );

    return res.status(200).json({
      message: "Mot de passe réinitialisé avec succès",
    });
  } catch (err) {
    return res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
};

// ==============================
// LOGIN
// Autoriser uniquement les utilisateurs vérifiés dans users
// ==============================
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const cleanEmail = email?.trim();

    if (!cleanEmail || !password) {
      return res.status(400).json({
        message: "Email et mot de passe requis",
      });
    }

    const [users] = await db.query(
      "SELECT * FROM users WHERE email = ?",
      [cleanEmail]
    );

    if (users.length === 0) {
      return res.status(401).json({
        message: "Email ou mot de passe incorrect",
      });
    }

    const user = users[0];

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        message: "Email ou mot de passe incorrect",
      });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    return res.status(200).json({
      message: "Connexion réussie",
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    return res.status(500).json({
      message: "Erreur serveur",
      error: err.message,
    });
  }
};

module.exports = {
  register,
  login,
  verifyOtp,
  resendOtp,
  forgotPassword,
  verifyResetOtp,
  resetPassword,
};