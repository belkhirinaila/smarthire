import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  List skills = [];
  List experiences = [];
  List education = [];

  bool isLoading = true;
  int? userId;

  late IO.Socket socket;

  // ================= SOCKET =================
  void initSocket() {
    socket = IO.io("http://192.168.100.47:5000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });
  }

  // ================= FETCH =================
  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/jobs/candidate-full/$userId"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      profile = data["profile"] ?? {};
      skills = data["skills"] ?? [];
      experiences = data["experiences"] ?? [];
      education = data["education"] ?? [];
      isLoading = false;
    });
  }

  // ================= OPEN CHAT (FIX 🔥) =================
  Future<void> openChat() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final res = await http.post(
    Uri.parse("http://192.168.100.47:5000/api/messages/conversation"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    },
    body: jsonEncode({
      "user_id": userId
    }),
  );

  final data = jsonDecode(res.body);

  int conversationId =
      data["conversation"]?["id"] ?? data["conversationId"];

  // 🔥 هنا pushNamed
  Navigator.pushNamed(
    context,
    "/chat",
    arguments: {
      "conversationId": conversationId,
    },
  );
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    userId = args["userId"];

    initSocket();
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

                  // HEADER
                  Column(
                    children: [

                      CircleAvatar(
                        radius: 60,
                        backgroundImage: (profile["profile_image"] != null &&
                                profile["profile_image"].toString().isNotEmpty)
                            ? NetworkImage(
                                "http://192.168.100.47:5000/uploads/${profile["profile_image"]}")
                            : null,
                        child: (profile["profile_image"] == null ||
                                profile["profile_image"].toString().isEmpty)
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

                  // PRIVATE
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
                            "Send request to unlock full profile",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                            ),
                            onPressed: () {},
                            child: const Text("Request Access"),
                          )
                        ],
                      ),
                    ),

                  // PUBLIC
                  if (profile["is_public"] == 1) ...[

                    _card(Icons.phone, profile["phone"] ?? "No phone"),

                    const SizedBox(height: 10),

                    _sectionTitle("Skills"),
                    ...skills.map((s) => _card(Icons.star, s["skill_name"])),

                    const SizedBox(height: 10),

                    _sectionTitle("Experience"),
                    ...experiences.map((e) => _card(
                          Icons.work,
                          "${e["job_title"]} chez ${e["company"]}\n"
                          "${e["start_date"] ?? ""} → ${e["end_date"] ?? "Present"}",
                        )),

                    const SizedBox(height: 10),

                    _sectionTitle("Education"),
                    ...education.map((ed) => _card(
                          Icons.school,
                          "${ed["degree"]} ${ed["field"]}\n${ed["school"]}",
                        )),

                    const SizedBox(height: 20),

                    // 🔥 SEND MESSAGE FIXED
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          if (userId != null) {
                            openChat(); // 🔥 الحل هنا
                          }
                        },
                        child: const Text("Send Message"),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // UI
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _card(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}