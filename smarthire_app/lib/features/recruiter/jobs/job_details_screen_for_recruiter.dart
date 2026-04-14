import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JobDetailsScreenForRecruiter extends StatefulWidget {
  final int jobId;

  const JobDetailsScreenForRecruiter({super.key, required this.jobId});

  @override
  State<JobDetailsScreenForRecruiter> createState() =>
      _JobDetailsScreenForRecruiterState();
}

class _JobDetailsScreenForRecruiterState
    extends State<JobDetailsScreenForRecruiter> {

  static const Color primaryBleu= Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = "http://192.168.100.47:5000/api";

  Map job = {};
  List skills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJob();
  }

  Future<void> fetchJob() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.get(
        Uri.parse("$baseUrl/recruiter/jobs/${widget.jobId}"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      setState(() {
        job = data["job"] ?? {};
        skills = data["skills"] ?? [];
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

                      // 🔙 BACK
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white),
                      ),

                      const SizedBox(height: 20),

                      // 🏷️ TITLE
                      Text(
                        job["title"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        job["location"] ?? "",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6)),
                      ),

                      const SizedBox(height: 12),

                      // STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (job["status"] == "active")
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          job["status"] ?? "",
                          style: TextStyle(
                            color: (job["status"] == "active")
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 📄 DESCRIPTION
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          job["description"] ?? "",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🧠 SKILLS
                      const Text("Skills",
                          style: TextStyle(color: Colors.white)),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skills.map<Widget>((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              s["skill_name"],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),

                      // 🔥 BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/recruiter-applicants',
                              arguments: {"jobId": widget.jobId},
                            );
                          },
                          child: const Text("View Applicants"),
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