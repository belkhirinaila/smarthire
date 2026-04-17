import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CandidateProfileForRecruiterScreen extends StatefulWidget {
  const CandidateProfileForRecruiterScreen({super.key});

  @override
  State<CandidateProfileForRecruiterScreen> createState() =>
      _CandidateProfileForRecruiterScreenState();
}

class _CandidateProfileForRecruiterScreenState
    extends State<CandidateProfileForRecruiterScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color background = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  Map profile = {};
  bool isLoading = true;
  int? userId;

  // ================= FETCH =================
  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/candidate/$userId"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      profile = data["profile"];
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    userId = args["userId"];

    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(height: 50),

                  // BACK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PROFILE HEADER
                  Column(
                    children: [

                      CircleAvatar(
                        radius: 60,
                        backgroundImage: profile["profile_image"] != null
                            ? NetworkImage(
                                "http://192.168.100.47:5000/uploads/${profile["profile_image"]}")
                            : null,
                        child: profile["profile_image"] == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        profile["name"] ?? "",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),

                      Text(
                        profile["title"] ?? "",
                        style: const TextStyle(color: Colors.white54),
                      ),

                      Text(
                        profile["location"] ?? "",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= PRIVATE =================
                  if (profile["is_public"] != 1)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [

                          const Icon(Icons.lock,
                              color: primaryBlue, size: 40),

                          const SizedBox(height: 10),

                          const Text(
                            "Private Profile",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "This profile is private. Send a request to view full details.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: () {
                              // TODO request access
                            },
                            child: const Text("Request Full Access"),
                          )
                        ],
                      ),
                    ),

                  // ================= PUBLIC =================
                  if (profile["is_public"] == 1) ...[

                    const SizedBox(height: 20),

                    // SKILLS
                    const Text("Skills",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 6,
                      children: (profile["skills"] != null)
                          ? List.generate(
                              (jsonDecode(profile["skills"]) as List).length,
                              (i) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  jsonDecode(profile["skills"])[i],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : [],
                    ),

                    const SizedBox(height: 20),

                    // CV BUTTON
                    ElevatedButton(
                      onPressed: () {
                        // TODO open CV
                      },
                      child: const Text("View CV"),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}