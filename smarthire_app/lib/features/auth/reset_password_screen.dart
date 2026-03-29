import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E6CFF);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  /// ==============================
  /// Envoyer email pour reset password
  /// ==============================
  Future<void> sendResetCode() async {

    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email requis")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {

        /// Aller à écran OTP avec email
        Navigator.pushReplacementNamed(
          context,
          '/reset-otp',
          arguments: {
            "email": email,
          },
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur")),
        );
      }

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur serveur")),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Reset Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 30),

                /// Email Input
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : sendResetCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ResetPasswordScreen.primaryBlue,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Send Reset Code"),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}