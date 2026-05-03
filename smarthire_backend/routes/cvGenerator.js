const PDFDocument = require("pdfkit");
const fs = require("fs");
const path = require("path");

const generateCV = (user, profile) => {
  return new Promise((resolve, reject) => {
    const fileName = `cv_${user.id}.pdf`;
    const filePath = path.join(__dirname, "../uploads", fileName);

    const doc = new PDFDocument();

    const stream = fs.createWriteStream(filePath);
    doc.pipe(stream);

    // 🔹 HEADER
    doc.fontSize(20).text(user.full_name, { bold: true });
    doc.fontSize(12).text(user.email);
    doc.text(profile.phone || "");
    doc.moveDown();

    // 🔹 SUMMARY
    doc.fontSize(14).text("Summary", { underline: true });
    doc.fontSize(12).text(profile.bio || "");
    doc.moveDown();

    // 🔹 SKILLS
    doc.fontSize(14).text("Skills", { underline: true });
    doc.fontSize(12).text(profile.skills || "");
    doc.moveDown();

    // 🔹 EXPERIENCE
    doc.fontSize(14).text("Experience", { underline: true });
    doc.fontSize(12).text(profile.experience || "");
    doc.moveDown();

    // 🔹 EDUCATION
    doc.fontSize(14).text("Education", { underline: true });
    doc.fontSize(12).text(profile.education || "");

    doc.end();

    stream.on("finish", () => {
      resolve(`/uploads/${fileName}`);
    });

    stream.on("error", reject);
  });
};

module.exports = generateCV;