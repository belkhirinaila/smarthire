import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthire_app/features/recruiter/messages/request_service.dart';

class ApplicantsScreen extends StatefulWidget {
  final int jobId;

  const ApplicantsScreen({super.key, required this.jobId});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'https://smarthire-fpa1.onrender.com/api';

  List applicants = [];
  bool isLoading = true;
  String currentFilter = "pending";

  @override
  void initState() {
    super.initState();
    fetchApplicants();
  }

  Future<void> fetchApplicants() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/recruiter/applications/${widget.jobId}?status=$currentFilter"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      applicants = data["applicants"] ?? [];
      isLoading = false;
    });
  }

  Future<void> updateStatus(int id, String status, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.put(
      Uri.parse("$baseUrl/recruiter/applications/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "status": status,
        "score": score
      }),
    );

    fetchApplicants();
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
          child: Column(
            children: [

              // 🔙 HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text("Applicants",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // 🔥 TABS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _tab("pending"),
                  _tab("shortlisted"),
                  _tab("rejected"),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: applicants.length,
                        itemBuilder: (c, i) {
                          return _applicantCard(applicants[i]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TAB =================
  Widget _tab(String status) {
    final isSelected = currentFilter == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentFilter = status;
          isLoading = true;
        });
        fetchApplicants();
      },
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isSelected ? primaryBlue : Colors.white54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _applicantCard(dynamic app) {

    double score = 50;

    final isPrivate = app["cv_visibility"] == "private";
    final requestStatus = app["request_status"];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Row(
            children: [
              const CircleAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(app["full_name"] ?? "",
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Slider(
            value: score,
            min: 0,
            max: 100,
            onChanged: (v) {},
          ),

          Row(
            children: [

              ElevatedButton(
                onPressed: () => updateStatus(app["application_id"], "shortlisted", score.toInt()),
                child: const Text("Shortlist"),
              ),

              const SizedBox(width: 8),

              ElevatedButton(
                onPressed: () => updateStatus(app["application_id"], "rejected", score.toInt()),
                child: const Text("Reject"),
              ),

              const Spacer(),

              isPrivate
                  ? ElevatedButton(
                      onPressed: requestStatus == "pending"
                          ? null
                          : () async {
                              await RequestService.sendRequest(app["candidate_id"]);
                              setState(() {
                                app["request_status"] = "pending";
                              });
                            },
                      child: Text(requestStatus == "pending"
                          ? "Requested"
                          : "Request"),
                    )
                  : ElevatedButton(
                      onPressed: () {},
                      child: const Text("CV"),
                    ),
            ],
          )
        ],
      ),
    );
  }
}