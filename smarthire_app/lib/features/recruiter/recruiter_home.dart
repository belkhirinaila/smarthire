import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecruiterHome extends StatefulWidget {
  const RecruiterHome({super.key});

  @override
  State<RecruiterHome> createState() => _RecruiterHomeState();
}

class _RecruiterHomeState extends State<RecruiterHome> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = "http://192.168.100.47:5000/api";

  bool isLoading = true;

  Map stats = {};
  List recentApplicants = [];

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.get(
        Uri.parse("$baseUrl/recruiter/dashboard"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      setState(() {
        stats = data["stats"] ?? {};
        recentApplicants = data["recent_applicants"] ?? [];
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);
    }
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _header(),

                      const SizedBox(height: 20),

                      const Text("OVERVIEW",
                          style: TextStyle(color: Colors.white54)),

                      const SizedBox(height: 12),

                      _bigCard(),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: _smallCard("Active Jobs", stats["total_jobs"], "Pending")),
                          const SizedBox(width: 10),
                          Expanded(child: _smallCard("Interviewing", stats["shortlisted"], "Today")),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _searchCard(),

                      const SizedBox(height: 20),

                      _sectionHeader(),

                      const SizedBox(height: 10),

                      ...recentApplicants.map((e) => _applicantCard(e)).toList(),
                    ],
                  ),
                ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () {
          Navigator.pushNamed(context, '/create-job');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("SmartHire DZ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Icon(Icons.notifications, color: Colors.white),
      ],
    );
  }

  // ================= BIG CARD =================
  Widget _bigCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Applicants",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text(
            "${stats["total_applications"] ?? 0}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= SMALL CARD =================
  Widget _smallCard(String title, dynamic value, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text("${value ?? 0}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _searchCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/search-candidates');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.white),
            SizedBox(width: 10),
            Text("Find Candidates",
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _sectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("Recent Applicants",
            style: TextStyle(color: Colors.white)),
        Text("View All", style: TextStyle(color: primaryBlue)),
      ],
    );
  }

  // ================= CARD =================
  Widget _applicantCard(dynamic app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(app["full_name"] ?? "",
                style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Shortlist"),
          )
        ],
      ),
    );
  }
}