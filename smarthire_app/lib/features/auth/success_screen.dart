import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

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
                const SizedBox(height: 20),

                const Text(
                  "Success",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                // Big check circle
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E6CFF), Color(0xFF2D9CFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF1E6CFF),
                        size: 46,
                      ),
                    ),
                  ),
                ),

                // small confetti squares (simple)
                const SizedBox(height: 18),
                Opacity(
                  opacity: 0.35,
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: List.generate(
                      8,
                      (i) => Transform.rotate(
                        angle: (i % 2 == 0) ? 0.4 : -0.35,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: i % 3 == 0
                                ? Colors.white
                                : (i % 3 == 1 ? primaryBlue : Colors.tealAccent),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  "Account Created!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Welcome to the future of hiring in\nAlgeria.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                const Spacer(),

                // Button 1
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Go to Dashboard screen
                      // Navigator.pushReplacement(...);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Go to Dashboard",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Button 2 (outline)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Complete profile screen
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.18)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Complete My Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
