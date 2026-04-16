import 'package:flutter/material.dart';

class JobSuccessScreen extends StatelessWidget {
  const JobSuccessScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color bgBottom = Color(0xFF050A12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBottom,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.work, size: 80, color: primaryBlue),

              const SizedBox(height: 20),

              const Text(
                "Job Published Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Your listing is now active and visible",
                style: TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/recruiter');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Go to Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}