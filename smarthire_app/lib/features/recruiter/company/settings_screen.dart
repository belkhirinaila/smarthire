import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color bgTop = Color(0xFF08162D);
  static const Color bgBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF16243A);

  static const String baseUrl = "http://192.168.100.47:5000/api";

  // ================= CHANGE PASSWORD =================
  Future<void> changePassword() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldController, decoration: const InputDecoration(labelText: "Old Password")),
            TextField(controller: newController, decoration: const InputDecoration(labelText: "New Password")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString("token");

              final res = await http.put(
                Uri.parse("$baseUrl/auth/change-password"),
                headers: {
                  "Authorization": "Bearer $token",
                  "Content-Type": "application/json"
                },
                body: jsonEncode({
                  "oldPassword": oldController.text,
                  "newPassword": newController.text
                }),
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res.body)),
              );
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // ================= ADD RECRUITER =================
  Future<void> addRecruiter() async {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Recruiter"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString("token");

              final res = await http.post(
                Uri.parse("$baseUrl/recruiters"),
                headers: {
                  "Authorization": "Bearer $token",
                  "Content-Type": "application/json"
                },
                body: jsonEncode({
                  "email": emailController.text
                }),
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res.body)),
              );
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  // ================= DELETE COMPANY =================
  Future<void> deactivateCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.delete(
      Uri.parse("$baseUrl/company"),
      headers: {"Authorization": "Bearer $token"},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.body)),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              const Text("Company Settings",
                  style: TextStyle(color: Colors.white, fontSize: 18)),

              const SizedBox(height: 20),

              _item(Icons.lock, "Account Security", changePassword),

              _item(Icons.group, "Team Management", () {}),

              _item(Icons.person_add, "Add New Recruiter", addRecruiter),

              _item(Icons.notifications, "Notification Preferences", () {}),

              _item(Icons.payment, "Payment Methods", () {}),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: deactivateCompany,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Deactivate Account",
                      style: TextStyle(color: Colors.red)),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: logout,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Logout",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: const TextStyle(color: Colors.white)),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 16)
          ],
        ),
      ),
    );
  }
}