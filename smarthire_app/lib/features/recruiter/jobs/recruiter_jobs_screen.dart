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

class _RecruiterJobsScreenState
    extends State<RecruiterJobsScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color background = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  List jobs = [];
  String selectedFilter = "all";

  bool isLoading = true;

  // ================= FETCH =================
  Future<void> fetchJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/jobs/my"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      jobs = data["jobs"];
      isLoading = false;
    });
  }

  // ================= DELETE =================
  Future<void> deleteJob(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.delete(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/jobs/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    fetchJobs(); // 🔥 refresh
  }

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  // ================= FILTER =================
  List get filteredJobs {
  if (selectedFilter == "all") return jobs;

  return jobs.where((job) {
    if (selectedFilter == "active") {
      return job["status"] == "active";
    } 
    else if (selectedFilter == "draft") {
      return job["status"] == "draft";
    } 
    else if (selectedFilter == "closed") {
      return job["status"] == "closed";
    }
    return true;
  }).toList();
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Column(
          children: [

            // HEADER
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Jobs",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ================= FILTER =================
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterButton("all", "All Jobs"),
                  _filterButton("active", "Active"),
                  _filterButton("draft", "Draft"),
                  _filterButton("closed", "Closed"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ================= LIST =================
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredJobs.length,
                      itemBuilder: (c, i) {
                        final job = filteredJobs[i];

                        return _jobCard(job);
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  // ================= FILTER BUTTON =================
  Widget _filterButton(String value, String label) {
    final isSelected = selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ================= JOB CARD =================
  Widget _jobCard(dynamic job) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/job-details",
          arguments: {"jobId": job["id"]},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [

            const Icon(Icons.work, color: primaryBlue),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    job["title"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    job["location"] ?? "",
                    style: const TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    job["created_at"]
                        ?.toString()
                        .substring(0, 10) ??
                        "",
                    style: const TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),

            // ACTIONS
            Row(
              children: [

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/edit-job",
                      arguments: {"job": job},
                    );
                  },
                  child: const Icon(Icons.edit,
                      color: Colors.blue),
                ),

                const SizedBox(width: 12),

                GestureDetector(
                  onTap: () {
                    deleteJob(job["id"]);
                  },
                  child: const Icon(Icons.delete,
                      color: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}