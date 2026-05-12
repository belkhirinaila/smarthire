import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static const String baseUrl = "http://192.168.100.47:5000/api";
  static const String serverUrl = "http://192.168.100.47:5000";

  Map profile = {};
  List skills = [];
  List experiences = [];
  List education = [];

  bool isLoading = true;
  int? userId;

  String getFileUrl(dynamic path) {
    if (path == null) return "";
    final p = path.toString().trim();

    if (p.isEmpty || p == "null" || p == "NULL") return "";
    if (p.startsWith("http")) return p;
    if (p.startsWith("/")) return "$serverUrl$p";

    return "$serverUrl/$p";
  }

  String safe(dynamic value, {String fallback = ""}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text == "null") return fallback;
    return text;
  }

  bool get isPublic {
    return profile["is_public"] == 1 ||
        profile["is_public"] == true ||
        profile["is_public"].toString() == "1";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (userId == null) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      userId = args["userId"];
      fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.get(
        Uri.parse("$baseUrl/recruiter/jobs/candidate-full/$userId"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      debugPrint("CANDIDATE PROFILE DATA: $data");

      if (!mounted) return;

      setState(() {
        profile = data["profile"] ?? {};
        skills = data["skills"] ?? [];
        experiences = data["experiences"] ?? [];
        education = data["education"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("FETCH PROFILE ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openChat() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/messages/conversation"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_id": userId,
      }),
    );

    final data = jsonDecode(res.body);

    final int conversationId =
        data["conversation"]?["id"] ?? data["conversationId"];

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      "/chat",
      arguments: {
        "conversationId": conversationId,
      },
    );
  }

  Future<void> openCV() async {
    final cvUrl = getFileUrl(profile["cv_file"]);

    if (cvUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CV not available")),
      );
      return;
    }

    await launchUrl(
      Uri.parse(cvUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> sendRequest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.post(
        Uri.parse("$baseUrl/requests"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "candidate_id": userId,
        }),
      );

      final data = jsonDecode(res.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Request sent")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur serveur")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = getFileUrl(
      profile["profile_image"] ?? profile["profile_photo"],
    );

    final name = safe(profile["name"], fallback: "Candidate");
    final title = safe(profile["title"], fallback: "No headline");
    final location = safe(profile["location"], fallback: "No location");
    final phone = safe(profile["phone_number"], fallback: "No phone");
    final email = safe(
      profile["profile_email"] ?? profile["email"],
      fallback: "No email",
    );
    final bio = safe(profile["bio"], fallback: "No bio added yet");
    final github = safe(profile["github_link"]);
    final behance = safe(profile["behance_link"]);
    final website = safe(profile["personal_website"]);
    final cvUrl = getFileUrl(profile["cv_file"]);

    return Scaffold(
      backgroundColor: background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Candidate Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  CircleAvatar(
                    radius: 62,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    backgroundImage:
                        photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.white54,
                          )
                        : null,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    location,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 20),

                  if (!isPublic)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.lock,
                            color: primaryBlue,
                            size: 42,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Private Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                            onPressed: sendRequest,
                            child: const Text("Request Access"),
                          ),
                        ],
                      ),
                    ),

                  if (isPublic) ...[
                    _sectionTitle("Contact"),
                    _card(Icons.phone, phone),
                    _card(Icons.email, email),

                    _sectionTitle("About"),
                    _card(Icons.info_outline, bio),

                    _sectionTitle("Skills"),
                    if (skills.isEmpty)
                      _card(Icons.star, "No skills added")
                    else
                      ...skills.map(
                        (s) => _card(
                          Icons.star,
                          safe(s["skill_name"], fallback: "-"),
                        ),
                      ),

                    _sectionTitle("Experience"),
                    if (experiences.isEmpty)
                      _card(Icons.work, "No experience added")
                    else
                      ...experiences.map(
                        (e) => _card(
                          Icons.work,
                          "${safe(e["job_title"], fallback: "Job")}\n"
                          "${safe(e["company"], fallback: "Company")}\n"
                          "${safe(e["start_date"])} → ${safe(e["end_date"], fallback: "Present")}",
                        ),
                      ),

                    _sectionTitle("Education"),
                    if (education.isEmpty)
                      _card(Icons.school, "No education added")
                    else
                      ...education.map(
                        (ed) => _card(
                          Icons.school,
                          "${safe(ed["degree"], fallback: "Degree")} ${safe(ed["field"])}\n"
                          "${safe(ed["school"], fallback: "School")}",
                        ),
                      ),

                    if (github.isNotEmpty ||
                        behance.isNotEmpty ||
                        website.isNotEmpty) ...[
                      _sectionTitle("Links"),
                      if (github.isNotEmpty) _linkCard("GitHub", github),
                      if (behance.isNotEmpty) _linkCard("Behance", behance),
                      if (website.isNotEmpty) _linkCard("Website", website),
                    ],

                    _sectionTitle("Generated Resume"),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: GestureDetector(
                              onTap: openCV,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cvUrl.isEmpty
                                        ? "No CV available"
                                        : "generated_cv.pdf",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Tap to open CV",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: openCV,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          if (userId != null) openChat();
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  Widget _linkCard(String label, String url) {
    return GestureDetector(
      onTap: () async {
        final fixedUrl = url.startsWith("http") ? url : "https://$url";
        await launchUrl(
          Uri.parse(fixedUrl),
          mode: LaunchMode.externalApplication,
        );
      },
      child: _card(Icons.link, "$label\n$url"),
    );
  }
}