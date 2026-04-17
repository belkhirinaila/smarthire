import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecruiterJobDetailsScreenRecruiter extends StatefulWidget {
  final int jobId;

  const RecruiterJobDetailsScreenRecruiter({
    super.key,
    required this.jobId,
  });

  @override
  State<RecruiterJobDetailsScreenRecruiter> createState() =>
      _RecruiterJobDetailsScreenRecruiterState();
}

class _RecruiterJobDetailsScreenRecruiterState
    extends State<RecruiterJobDetailsScreenRecruiter> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color background = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  Map job = {};
  List applicants = [];

  bool isLoading = true;
  late int? jobId;

  // ================= FETCH JOB =================
  Future<void> fetchJob() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/jobs/$jobId"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      job = data["job"];
      isLoading = false;
    });
  }

  // ================= FETCH APPLICANTS =================
  Future<void> fetchApplicants() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  debugPrint("JOB ID: $jobId");
 debugPrint("TOKEN: $token");
 
 
  final res = await http.get(
    Uri.parse("http://192.168.100.47:5000/api/recruiter/jobs/$jobId/applicants"),
    headers: {
      "Authorization": "Bearer $token", // 🔥 الحل هنا
    },
  );

  debugPrint("RESPONSE: ${res.body}");

  final data = jsonDecode(res.body);

  setState(() {
    applicants = data["applicants"] ?? [];
  });
}

  // ================= PUBLISH =================
  Future<void> publishJob() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.put(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/jobs/${job["id"]}"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"status": "active"}),
    );

    fetchJob();
  }

  @override
   void initState() {
   super.initState();

   jobId = widget.jobId;

   fetchJob();
   fetchApplicants();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // HEADER
                Padding(
                  padding: const EdgeInsets.only(
                      top: 50, left: 16, right: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Text("Job Details",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),

                      const Spacer(),

                      _statusBadge(job["status"]),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [

                        // CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [

                              const Icon(Icons.business,
                                  size: 50,
                                  color: Colors.white54),

                              const SizedBox(height: 10),

                              Text(
                                job["title"] ?? "",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                job["location"] ?? "",
                                style: const TextStyle(
                                    color: Colors.white54),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "${job["salary_min"]} - ${job["salary_max"]} DZD",
                                style: const TextStyle(
                                    color: primaryBlue),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // DESCRIPTION
                        const Text("Description",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Text(
                            job["description"] ?? "",
                            style: const TextStyle(
                                color: Colors.white),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // JOB INFO
                        const Text("Job Info",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _infoRow(Icons.work, "Type", job["type"] ?? "-"),
                              _infoRow(Icons.location_on, "Mode", job["work_mode"] ?? "-"),
                              _infoRow(Icons.category, "Category", job["category"] ?? "-"),
                              _infoRow(Icons.business, "Company", job["company_name"] ?? "-"),
                              _infoRow(Icons.access_time, "Posted", job["created_at"] ?? "-"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // SKILLS
                        const Text("Skills",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),

                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 8,
                          children: (job["skills"] != null)
                              ? List.generate(
                                  (jsonDecode(job["skills"]) as List).length,
                                  (i) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      jsonDecode(job["skills"])[i],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              : [],
                        ),

                        const SizedBox(height: 20),

                        // ================= APPLICANTS =================
                        const Text("Applicants",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),

                        const SizedBox(height: 10),

                        applicants.isEmpty
                            ? const Text(
                                "No applicants yet",
                                style: TextStyle(color: Colors.white54),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: applicants.length,
                                itemBuilder: (context, index) {
                                  final c = applicants[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/candidate-profile-recruiter",
                                        arguments: {"userId": c["user_id"]},
                                      );
                                    },

                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [

                                          Row(
                                            children: [

                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage:
                                                    c["profile_image"] != null
                                                        ? NetworkImage(
                                                            "http://192.168.100.47:5000/uploads/${c["profile_image"]}")
                                                        : null,
                                                child:
                                                    c["profile_image"] == null
                                                        ? const Icon(Icons.person)
                                                        : null,
                                              ),

                                              const SizedBox(width: 10),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [

                                                    Text(
                                                      c["full_name"] ?? "",
                                                      style:
                                                          const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight.bold),
                                                    ),

                                                    Text(
                                                      c["title"] ?? "",
                                                      style: const TextStyle(
                                                          color: Colors.blue),
                                                    ),

                                                    const SizedBox(height: 4),

                                                    Text(
                                                      c["location"] ?? "",
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.white54),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const Icon(Icons.circle,
                                                  color: Colors.green,
                                                  size: 10),
                                            ],
                                          ),

                                          const SizedBox(height: 10),

                                          Wrap(
                                            spacing: 6,
                                            children: (c["skills"] != null)
                                                ? List.generate(
                                                    (jsonDecode(c["skills"])
                                                            as List)
                                                        .length,
                                                    (i) => Container(
                                                      padding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 10,
                                                              vertical: 4),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: primaryBlue
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                        jsonDecode(c["skills"])[i],
                                                        style:
                                                            const TextStyle(
                                                                color: Colors.white),
                                                      ),
                                                    ),
                                                  )
                                                : [],
                                          ),

                                          const SizedBox(height: 10),

                                          Row(
                                            children: [

                                              if (c["is_public"] == 1)
                                                const Text("Public CV",
                                                    style: TextStyle(
                                                        color: Colors.green))
                                              else
                                                const Text("Private CV",
                                                    style: TextStyle(
                                                        color: Colors.orange)),

                                              const Spacer(),

                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    "/candidate-profile-recruiter",
                                                    arguments: {
                                                      "userId": c["user_id"]
                                                    },
                                                  );
                                                },
                                                child:
                                                    const Text("View Profile"),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildBottomButton(),
                )
              ],
            ),
    );
  }

  // ================= STATUS =================
  Widget _statusBadge(String status) {
    Color color;

    if (status == "active") {
      color = Colors.green;
    } else if (status == "draft") {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _buildBottomButton() {

    if (job["status"] == "draft") {
      return Row(
        children: [

          Expanded(
            child: _button("Edit", () async {
              final result = await Navigator.pushNamed(
                context,
                "/edit-job",
                arguments: {"job": job},
              );

              if (result == true) {
                fetchJob();
              }
            }),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _button("Publish", publishJob),
          ),
        ],
      );
    }

    if (job["status"] == "active") {
      return _button("Edit Job", () {
        Navigator.pushNamed(context, "/edit-job",
            arguments: {"job": job});
      });
    }

    return Container();
  }

  Widget _button(String text, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 8),
          Text("$title: ",
              style: const TextStyle(color: Colors.white54)),
          Text(value,
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}