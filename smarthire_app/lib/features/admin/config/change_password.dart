import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminChangePasswordScreen extends StatefulWidget {
  const AdminChangePasswordScreen({super.key});

  @override
  State<AdminChangePasswordScreen> createState() =>
      _AdminChangePasswordScreenState();
}

class _AdminChangePasswordScreenState
    extends State<AdminChangePasswordScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = "http://192.168.100.47:5000/api";

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool oldVisible = false;
  bool newVisible = false;
  bool confirmVisible = false;
  bool isLoading = false;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> changePassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      showMsg("Tous les champs sont obligatoires");
      return;
    }

    if (newPassword.length < 6) {
      showMsg("Le mot de passe doit contenir au moins 6 caractères");
      return;
    }

    if (newPassword != confirmPassword) {
      showMsg("Les mots de passe ne correspondent pas");
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await getToken();

      final response = await http.put(
        Uri.parse("$baseUrl/admin/change-password"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        showMsg(data["message"] ?? "Mot de passe modifié ✅");

        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        Navigator.pop(context);
      } else {
        showMsg(data["message"] ?? "Erreur");
      }
    } catch (e) {
      showMsg("Erreur serveur");
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Change Password",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              _passwordField(
                label: "Old Password",
                controller: oldPasswordController,
                visible: oldVisible,
                onToggle: () {
                  setState(() => oldVisible = !oldVisible);
                },
              ),

              const SizedBox(height: 18),

              _passwordField(
                label: "New Password",
                controller: newPasswordController,
                visible: newVisible,
                onToggle: () {
                  setState(() => newVisible = !newVisible);
                },
              ),

              const SizedBox(height: 18),

              _passwordField(
                label: "Confirm New Password",
                controller: confirmPasswordController,
                visible: confirmVisible,
                onToggle: () {
                  setState(() => confirmVisible = !confirmVisible);
                },
              ),

              const SizedBox(height: 35),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update Password",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: !visible,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            prefixIcon: const Icon(Icons.lock, color: primaryBlue),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white54,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}