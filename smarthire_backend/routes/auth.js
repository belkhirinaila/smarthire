const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");
const { register, login , verifyOtp ,resendOtp ,forgotPassword ,verifyResetOtp,resetPassword} = require("../controllers/authcontroller");
const { getMe } = require("../controllers/authcontroller");
// REGISTER
router.post("/register", register);

// LOGIN
router.post("/login", login);

// OTP VERIFICATION
router.post("/verify-otp", verifyOtp);

// RESEND OTP
router.post("/resend-otp", resendOtp);

// FORGOT PASSWORD
router.post("/forgot-password", forgotPassword);

// VERIFY RESET OTP
router.post("/verify-reset-otp", verifyResetOtp);

// RESET PASSWORD
router.post("/reset-password", resetPassword);

// GET CURRENT USER
router.get("/me", protect, getMe);
module.exports = router;