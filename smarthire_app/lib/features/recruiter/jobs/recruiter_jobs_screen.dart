import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecruiterJobsScreen extends StatefulWidget {
  const RecruiterJobsScreen({super.key});

  @override
  State<RecruiterJobsScreen> createState() =>
      _RecruiterJobsScreenState();
}

class _RecruiterJobsScreenState extends State<RecruiterJobsScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = "http://192.168.100.47:5000/api";

  List jobs = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.get(
        Uri.parse("$baseUrl/recruiter/jobs/my"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        setState(() {
          jobs = data["jobs"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = data["message"];
          isLoading = false;
        });
      }

    } catch (e) {
      setState(() {
        error = "Error loading jobs";
        isLoading = false;
      });
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
              : error != null
                  ? Center(
                      child: Text(error!,
                          style: const TextStyle(color: Colors.white)),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "My Jobs",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 20),

                          ...jobs.map((job) => _jobCard(job)).toList(),

                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  // ================= JOB CARD =================
  Widget _jobCard(dynamic job) {
    final status = job["status"] ?? "active";

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/recruiter-job-details',
          arguments: {"jobId": job["id"]},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [

            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.work, color: Colors.white54),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    job["title"] ?? "",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    job["location"] ?? "",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5)),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    job["salary"]?.toString() ?? "",
                    style: const TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: status == "active"
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status == "active"
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}