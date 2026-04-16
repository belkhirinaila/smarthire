import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color background = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  Map<String, dynamic>? company;
  List jobs = [];

  bool isLoading = true;

  // ================= FETCH =================
  Future<void> fetchCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/company-profile/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      company = data["company"];
      jobs = data["jobs"];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCompany();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: background,

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 45,
                    backgroundImage: company?["logo"] != null
                        ? NetworkImage("http://192.168.100.47:5000/${company!["logo"]}")
                        : null,
                    backgroundColor: Colors.grey,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Modifier la photo",
                    style: TextStyle(color: primaryBlue),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    company?["name"] ?? "Company",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white54, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        company?["location"] ?? "",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _verificationBadge(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= ACTIONS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [

                  _actionCard(Icons.edit, "Edit Profile", () {
                    Navigator.pushNamed(context, "/edit-company");
                  }),

                  _actionCard(Icons.settings, "Settings", () {}),

                  _actionCard(Icons.share, "Share Company", () {}),

                  _actionCard(Icons.work, "Jobs", () async {
  await Navigator.pushNamed(context, "/recruiter-jobs");

  // 🔥 refresh كي ترجعي
  fetchCompany();
}),

                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= ABOUT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "About Company",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  _card(
                    Text(
                      company?["description"] ?? "No description",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= EXTRA INFO =================
                  Row(
                    children: [

                      _infoCard(
                        Icons.people,
                        "${company?["company_size"] ?? 0}",
                        "Employees",
                      ),

                      const SizedBox(width: 10),

                      _infoCard(
                        Icons.calendar_today,
                        company?["created_at"] != null
                            ? company!["created_at"]
                                .toString()
                                .substring(0, 4)
                            : "----",
                        "Founded",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= JOBS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Jobs",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...jobs.map((job) => _jobCard(job)).toList(),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _verificationBadge() {
    String status = company?["verification_status"] ?? "pending";

    Color color;
    IconData icon;
    String text;

    if (status == "approved") {
      color = Colors.green;
      icon = Icons.verified;
      text = "Verified";
    } else if (status == "rejected") {
      color = Colors.red;
      icon = Icons.cancel;
      text = "Rejected";
    } else {
      color = Colors.orange;
      icon = Icons.hourglass_top;
      text = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _actionCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryBlue),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryBlue),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _jobCard(dynamic job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.work, color: primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              job["title"],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.white38)
        ],
      ),
    );
  }
}