const express = require("express");
const router = express.Router();
const db = require("../config/db");
const path = require("path");
const fs = require("fs");
const PDFDocument = require("pdfkit");
const { protect, authorize } = require("../middleware/authMiddleware");
const evaluateCV = require("./aiScore");

// ===============================
// 🔥 GENERATE CV (FINAL ATS PRO)
// ===============================
router.post("/generate", protect, authorize("candidate"), async (req, res) => {
  try {
    const userId = req.user.id;

    // USER
    const [userRows] = await db.query(
      "SELECT full_name, email FROM users WHERE id = ?",
      [userId]
    );

    // PROFILE
    const [profileRows] = await db.query(
      "SELECT * FROM candidate_profiles WHERE user_id = ?",
      [userId]
    );

    // SKILLS
    const [skillsRows] = await db.query(
      "SELECT skill_name FROM skills WHERE user_id = ?",
      [userId]
    );

    // EXPERIENCE
    const [expRows] = await db.query(
      "SELECT job_title, company, start_date, end_date, description FROM experiences WHERE user_id = ?",
      [userId]
    );

    // EDUCATION
    const [eduRows] = await db.query(
      "SELECT degree, school, field, start_date, end_date FROM education WHERE user_id = ?",
      [userId]
    );

    const user = userRows[0];
    const profile = profileRows[0] || {};

    const fileName = `cv_${userId}.pdf`;
    const filePath = path.join(__dirname, "../uploads", fileName);

    const doc = new PDFDocument({ margin: 40 });
    const stream = fs.createWriteStream(filePath);
    doc.pipe(stream);

    // ===============================
    // 🎯 HEADER (NAME + HEADLINE)
    // ===============================
    doc.fontSize(26).text(user.full_name, { align: "center" });

    doc.moveDown(0.3);

    doc
      .fontSize(12)
      .fillColor("gray")
      .text(
        `${profile.professional_headline || "Professional"} • ${profile.location || ""}`,
        { align: "center" }
      );

    doc.fillColor("black");
    doc.moveDown();

    doc.moveTo(40, doc.y).lineTo(550, doc.y).stroke();
    doc.moveDown();

    // ===============================
    // 🧠 STANDARD INTRODUCTION (FIXED)
    // ===============================
    doc.fontSize(14).text("PROFILE", { underline: true });
    doc.moveDown(0.3);

    doc.fontSize(11).text(
      "Dynamic and motivated professional with a strong commitment to delivering high-quality results. "
      + "Adaptable and detail-oriented, with the ability to quickly learn and apply new skills in diverse environments. "
      + "Seeking opportunities to contribute effectively to organizational success while continuously growing professionally."
    );

    doc.moveDown();

    // ===============================
    // 📞 CONTACT (CLICKABLE)
    // ===============================
    doc.fontSize(14).text("CONTACT", { underline: true });
    doc.moveDown(0.3);

    doc
      .fillColor("blue")
      .text(user.email, { link: `mailto:${user.email}` });

    if (profile.phone_number) {
      doc.text(profile.phone_number, {
        link: `tel:${profile.phone_number}`,
      });
    }

    doc.fillColor("black");
    doc.moveDown();

    // ===============================
    // 🛠 SKILLS
    // ===============================
    doc.fontSize(14).text("SKILLS", { underline: true });
    doc.moveDown(0.3);

    if (skillsRows.length === 0) {
      doc.text("No skills added");
    } else {
      doc.text(skillsRows.map(s => s.skill_name).join(" • "));
    }

    doc.moveDown();

    // ===============================
    // 💼 EXPERIENCE
    // ===============================
    doc.fontSize(14).text("PROFESSIONAL EXPERIENCE", { underline: true });
    doc.moveDown();

    if (expRows.length === 0) {
      doc.text("No experience added");
    } else {
      expRows.forEach(exp => {
        const endDate =
          !exp.end_date || exp.end_date === "0000-00-00"
            ? "Present"
            : exp.end_date;

        doc.fontSize(12).text(exp.job_title, { continued: true });
        doc.text(` - ${exp.company}`);

        doc
          .fontSize(10)
          .fillColor("gray")
          .text(`${exp.start_date} - ${endDate}`);

        doc.fillColor("black");

        if (exp.description) {
          doc.fontSize(11).text(`• ${exp.description}`);
        }

        doc.moveDown();
      });
    }

    // ===============================
    // 🎓 EDUCATION
    // ===============================
    doc.fontSize(14).text("EDUCATION", { underline: true });
    doc.moveDown();

    if (eduRows.length === 0) {
      doc.text("No education added");
    } else {
      eduRows.forEach(edu => {
        doc.fontSize(12).text(
          `${edu.degree} (${edu.field || ""})`
        );

        doc.text(edu.school);

        doc
          .fontSize(10)
          .fillColor("gray")
          .text(`${edu.start_date} - ${edu.end_date || ""}`);

        doc.fillColor("black");
        doc.moveDown();
      });
    }

    // ===============================
    // 🙏 FINAL MESSAGE (STANDARD)
    // ===============================
    doc.moveDown();
    doc.moveTo(40, doc.y).lineTo(550, doc.y).stroke();
    doc.moveDown();

    doc.fontSize(11).text(
      "Thank you for considering my application. "
      + "I am eager to contribute my skills and motivation to your organization. "
      + "I remain available for any further information or interview opportunity.",
      { align: "center" }
    );

    doc.end();

    // SAVE
    stream.on("finish", async () => {
      const fileUrl = `${req.protocol}://${req.get("host")}/uploads/${fileName}`;

      await db.query(
        "UPDATE candidate_profiles SET cv_generated = ? WHERE user_id = ?",
        [`/uploads/${fileName}`, userId]
      );

      res.json({
        message: "CV generated successfully",
        cv_url: fileUrl,
      });
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Error generating CV",
      error: err.message,
    });
  }
});

// ===============================
// 👁 GET CV
// ===============================
router.get("/me", protect, authorize("candidate"), async (req, res) => {
  const [rows] = await db.query(
    "SELECT cv_generated FROM candidate_profiles WHERE user_id = ?",
    [req.user.id]
  );

  if (!rows[0]?.cv_generated) {
    return res.status(404).json({ message: "No CV found" });
  }

  res.json({
    cv_url: `${req.protocol}://${req.get("host")}${rows[0].cv_generated}`,
  });
});

// ===============================
// 🗑 DELETE CV
// ===============================
router.delete("/delete", protect, authorize("candidate"), async (req, res) => {
  const [rows] = await db.query(
    "SELECT cv_generated FROM candidate_profiles WHERE user_id = ?",
    [req.user.id]
  );

  if (!rows[0]?.cv_generated) {
    return res.status(404).json({ message: "No CV found" });
  }

  const filePath = path.join(__dirname, "..", rows[0].cv_generated);

  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }

  await db.query(
    "UPDATE candidate_profiles SET cv_generated = NULL WHERE user_id = ?",
    [req.user.id]
  );

  res.json({ message: "CV deleted" });
});



// ===============================
// 🤖 AI SCORE
// ===============================
router.get("/score", protect, authorize("candidate"), async (req, res) => {
  try {
    const userId = req.user.id;

    const [profile] = await db.query(
      "SELECT * FROM candidate_profiles WHERE user_id = ?",
      [userId]
    );

    const [skills] = await db.query(
      "SELECT skill_name FROM skills WHERE user_id = ?",
      [userId]
    );

    const [exp] = await db.query(
      "SELECT job_title, company FROM experiences WHERE user_id = ?",
      [userId]
    );

    const [edu] = await db.query(
      "SELECT degree, school FROM education WHERE user_id = ?",
      [userId]
    );

    const result = await evaluateCV(profile[0], skills, exp, edu);

    res.json({ score: result });

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;