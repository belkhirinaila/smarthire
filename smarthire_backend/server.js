const express = require("express");
const cors = require("cors");
const path = require("path");
require("dotenv").config();

const db = require("./config/db");

const authRoutes = require("./routes/auth");
const jobRoutes = require("./routes/jobs");
const applicationRoutes = require("./routes/applications");
const candidateProfileRoutes = require("./routes/candidateProfile");
const experienceRoutes = require("./routes/experience");
const educationRoutes = require("./routes/education");
const skillsRoutes = require("./routes/skills");
const cvRoutes = require("./routes/cv");
const visibilityRoutes = require("./routes/visibility");
const portfolioRoutes = require("./routes/portfolio");
const savedJobsRoutes = require("./routes/savedJobs");
const messagesRoutes = require("./routes/messages");
const requestRoutes = require("./routes/requests");

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Static files
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Test route
app.get("/", (req, res) => {
  res.send("SmartHire API is running 🚀");
});

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/jobs", jobRoutes);
app.use("/api/applications", applicationRoutes);
app.use("/api/candidate-profile", candidateProfileRoutes);
app.use("/api/experience", experienceRoutes);
app.use("/api/education", educationRoutes);
app.use("/api/skills", skillsRoutes);
app.use("/api/cv", cvRoutes);
app.use("/api/visibility", visibilityRoutes);
app.use("/api/portfolio", portfolioRoutes);
app.use("/api/saved-jobs", savedJobsRoutes);
app.use("/api/messages", messagesRoutes);
app.use("/api/requests", requestRoutes);
const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});