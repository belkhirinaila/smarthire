const express = require("express");
const cors = require("cors");
const path = require("path");
require("dotenv").config();

const http = require("http"); // 🔥 جديد
const { Server } = require("socket.io"); // 🔥 جديد

const db = require("./config/db");

const uploadRoutes = require("./routes/upload");

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
const notificationsRoutes = require("./routes/notifications");

const recruiterJobsRoutes = require("./routes/recruiterJobs");
const companyProfileRoutes = require("./routes/companyProfile");
const recruiterCandidatesRoutes = require("./routes/recruiterCandidates");
const recruiterApplicationsRoutes = require("./routes/recruiterApplications");
const recruiterDashboardRoutes = require("./routes/recruiterDashboard");
const companySettingsRoutes = require("./routes/companySettings");  
const companyVerificationRoutes = require("./routes/companyVerification");

const adminDashboardRoutes = require("./routes/admin_dasshboad");
const adminRoutes = require("./routes/admin");

const app = express();

// ==============================
// 🔥 CREATE SERVER + SOCKET
// ==============================
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

// ==============================
// 🔥 SOCKET CONNECTION
// ==============================
io.on("connection", (socket) => {
  console.log("🟢 User connected:", socket.id);

  // 🔥 join room (chat)
  socket.on("joinConversation", (conversationId) => {
    socket.join(conversationId);
    console.log("Joined room:", conversationId);
  });

  socket.on("joinUser", (userId) => {
    const userRoom = `user_${userId}`;
    socket.join(userRoom);
    console.log("Joined user room:", userRoom);
  });

  socket.on("disconnect", () => {
    console.log("🔴 User disconnected");
  });
});

// 🔥 نربط socket مع routes
app.set("io", io);

// ==============================
// MIDDLEWARES
// ==============================
app.use(cors());
app.use(express.json());

// ==============================
// STATIC FILES
// ==============================
app.use("/uploads", express.static(__dirname + "/uploads", {
  setHeaders: (res, path) => {
    if (path.endsWith(".pdf")) {
      res.setHeader("Content-Type", "application/pdf");
    }
  }
}));

// ==============================
// TEST ROUTE
// ==============================
app.get("/", (req, res) => {
  res.send("SmartHire API is running 🚀");
});

// ==============================
// ROUTES
// ==============================
app.use("/api/upload", uploadRoutes);

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
app.use("/api/notifications", notificationsRoutes);

app.use("/api/recruiter/jobs", recruiterJobsRoutes);
app.use("/api/recruiter/company-profile", companyProfileRoutes);
app.use("/api/recruiter/candidates", recruiterCandidatesRoutes);
app.use("/api/recruiter/applications", recruiterApplicationsRoutes);
app.use("/api/recruiter/dashboard", recruiterDashboardRoutes);
app.use("/api/recruiter/company-settings", companySettingsRoutes);
app.use("/api/recruiter/company-verification", companyVerificationRoutes);
app.use("/api/recruiter", recruiterCandidatesRoutes);



app.use("/api/admin", adminRoutes);
app.use("/api/admin-dashboard", adminDashboardRoutes);



// ==============================
// 🚀 START SERVER
// ==============================
const PORT = process.env.PORT || 5000;

server.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);
});