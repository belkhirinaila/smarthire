import 'package:flutter/material.dart';

class AdminConfigScreen extends StatelessWidget {
  const AdminConfigScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

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
            padding: const EdgeInsets.all(16),
            children: [

              /// ================= HEADER =================
              const Text(
                "Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// ================= ADMIN INFO =================
              _sectionTitle("Admin Info"),
              _tile(Icons.person, "Admin Account", "admin@smarthire.com"),

              const SizedBox(height: 20),

              /// ================= SECURITY =================
              _sectionTitle("Security"),
              _tile(Icons.lock, "Change Password", "Update your password", onTap: () {
                Navigator.pushNamed(context, "/admin-change-password");
              }),

              const SizedBox(height: 20),

              /// ================= BLOCKED =================
              _sectionTitle("Blocked Management"),

              _tile(Icons.block, "Blocked Candidates", "View blocked candidates",
                  onTap: () {
                Navigator.pushNamed(context, "/blocked-candidates");
              }),

              _tile(Icons.business, "Blocked Companies", "View blocked companies",
                  onTap: () {
                Navigator.pushNamed(context, "/blocked-companies");
              }),

              _tile(Icons.work_off, "Blocked Jobs", "View blocked jobs",
                  onTap: () {
                Navigator.pushNamed(context, "/blocked-jobs");
              }),

              const SizedBox(height: 20),

              /// ================= LOGOUT =================
              _sectionTitle("Account"),

              _tile(Icons.logout, "Logout", "Sign out from admin",
                  color: Colors.red,
                  onTap: () {
                // TODO: logout logic
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// ================= TILE =================
  Widget _tile(IconData icon, String title, String subtitle,
      {VoidCallback? onTap, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? primaryBlue),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.white54, size: 16),
      ),
    );
  }
}