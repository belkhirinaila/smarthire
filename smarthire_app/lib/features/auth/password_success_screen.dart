import 'package:flutter/material.dart';


class PasswordSuccessScreen extends StatelessWidget {
  const PasswordSuccessScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E6CFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1B33), Color(0xFF070A10)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 14),

                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Icon Image
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withOpacity(0.04),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.verified_rounded,
                      size: 90,
                      color: primaryBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Title
                const Text(
                  "Password Updated\nSuccessfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                // Subtitle
                Text(
                  "Your security is our priority. You can\nnow use your new password to sign\nin to your SmartHire DZ account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                const Spacer(),

                // Proceed Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Proceed to Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Help text
                Text(
                  "Need help? Contact support",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
