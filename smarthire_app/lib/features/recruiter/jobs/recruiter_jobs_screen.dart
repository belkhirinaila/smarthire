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
      Uri.parse("https://smarthire-fpa1.onrender.com/api/recruiter/jobs/my"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      jobs = data["jobs"];
      isLoading = false;
    });
  }

  // ================= FILTER =================
  List getFilteredJobs() {
    if (selectedFilter == "active") {
      return jobs.where((j) => j["status"] == "active").toList();
    }
    if (selectedFilter == "closed") {
      return jobs.where((j) => j["status"] == "closed").toList();
    }
    if (selectedFilter == "draft") {
      return jobs.where((j) => j["status"] == "draft").toList();
    }
    return jobs;
  }

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  // ================= DELETE =================
  Future<void> deleteJob(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.delete(
      Uri.parse("https://smarthire-fpa1.onrender.com/api/recruiter/jobs/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    fetchJobs(); // 🔥 refresh
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    final filtered = getFilteredJobs();

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 29),
        title: const Text("My Jobs", style: TextStyle(color: Colors.white),),
      ),

      body: Column(
        children: [

          const SizedBox(height: 10),

          // FILTER BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _filterBtn("all", "All"),
              _filterBtn("active", "Active"),
              _filterBtn("draft", "Draft"),
              _filterBtn("closed", "Closed"),
            ],
          ),

          const SizedBox(height: 10),

          // LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final job = filtered[index];
                      return _jobCard(job);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= FILTER BUTTON =================
  Widget _filterBtn(String value, String text) {
    final active = selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? primaryBlue : cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // ================= JOB CARD =================
  Widget _jobCard(dynamic job) {
  return GestureDetector(
    onTap: () async {
      await Navigator.pushNamed(
        context,
        "/recruiter-job-details",
        arguments: {"jobId": job["id"]},
      );

      fetchJobs();
    },

    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // TITLE + ACTIONS
          Row(
            children: [
              Expanded(
                child: Text(
                  job["title"] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // EDIT
              GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    "/edit-job",
                    arguments: {"job": job},
                  );
                  fetchJobs();
                },
                child: const Icon(Icons.edit, color: Colors.blue),
              ),

              const SizedBox(width: 10),

              // DELETE
              GestureDetector(
                onTap: () {
                  deleteJob(job["id"]);
                },
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            job["location"] ?? "",
            style: const TextStyle(color: Colors.white54),
          ),

          const SizedBox(height: 6),

          Text(
            "${job["salary_min"] ?? 0} - ${job["salary_max"] ?? 0} DZD",
            style: const TextStyle(color: primaryBlue),
          ),

          const SizedBox(height: 8),

          // ✅ STATUS BADGE رجعناه
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: job["status"] == "active"
                  ? Colors.green
                  : job["status"] == "closed"
                      ? Colors.red
                      : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              job["status"].toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}