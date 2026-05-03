import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminJobsScreen extends StatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  State<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends State<AdminJobsScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  List jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ================= LOAD JOBS =================
  Future<void> loadJobs() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/admin/jobs'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() {
        jobs = jsonDecode(res.body);
        isLoading = false;
      });
    }
  }

  /// ================= DELETE JOB =================
  Future<void> deleteJob(int id) async {
    final token = await getToken();

    await http.delete(
      Uri.parse('$baseUrl/admin/jobs/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    loadJobs();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          child: RefreshIndicator(
            onRefresh: loadJobs,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, i) {
                final job = jobs[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [

                      /// 🧾 ICON
                      const CircleAvatar(
                        backgroundColor: primaryBlue,
                        child: Icon(Icons.work, color: Colors.white),
                      ),

                      const SizedBox(width: 10),

                      /// 📄 JOB INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['title'] ?? "No title",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              job['recruiter_email'] ?? "",
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),

                      /// ❌ DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteJob(job['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}