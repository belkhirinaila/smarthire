import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CvSkillsScreen extends StatefulWidget {
  const CvSkillsScreen({super.key});

  @override
  State<CvSkillsScreen> createState() => _CvSkillsScreenState();
}

class _CvSkillsScreenState extends State<CvSkillsScreen> {
  // Colors
  static const Color kPrimaryBlue = Color(0xFF1E6CFF);
  static const Color kBackground = Color(0xFF050A12);
  static const Color kCard = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  bool isLoading = true;
  bool isSaving = false;

  // CV
  String cvFileName = 'No CV generated';
  String? cvFileUrl;

  // Skills
  final TextEditingController skillController = TextEditingController();
  List<Map<String, dynamic>> skills = [];

  // 🔥 AI SCORE
  String? scoreRaw;
  int? scoreValue;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    skillController.dispose();
    super.dispose();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ===============================
  // LOAD DATA
  // ===============================
  Future<void> loadData() async {
    try {
      setState(() => isLoading = true);

      final token = await getToken();
      if (token == null) {
        setState(() => isLoading = false);
        return;
      }

      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/cv/me'),
            headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('$baseUrl/skills/me'),
            headers: {'Authorization': 'Bearer $token'}),
      ]);

      final cvRes = responses[0];
      if (cvRes.statusCode == 200) {
        final data = jsonDecode(cvRes.body);
        cvFileUrl = data['cv_url'];
        cvFileName =
            cvFileUrl != null ? "Generated CV" : "No CV generated";
      } else {
        cvFileUrl = null;
        cvFileName = "No CV generated";
      }

      final skillsRes = responses[1];
      if (skillsRes.statusCode == 200) {
        final data = jsonDecode(skillsRes.body);
        skills = List<Map<String, dynamic>>.from(data['skills'] ?? []);
      } else {
        skills = [];
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ===============================
  // AI SCORE
  // ===============================
  Future<void> getScore() async {
    final token = await getToken();
    if (token == null) return;

    final res = await http.get(
      Uri.parse('$baseUrl/cv/score'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final text = data['score'];

      setState(() {
        scoreRaw = text;
        scoreValue = extractScore(text);
      });
    }
  }

  int extractScore(String text) {
    final match = RegExp(r'Score:\s*(\d+)/100').firstMatch(text);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }

  Color getScoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Map<String, List<String>> parseSections(String text) {
    final sections = {
      "Strengths": <String>[],
      "Weaknesses": <String>[],
      "Suggestions": <String>[],
    };

    String current = "";

    for (var line in text.split("\n")) {
      line = line.trim();

      if (line.startsWith("Strengths")) current = "Strengths";
      else if (line.startsWith("Weaknesses")) current = "Weaknesses";
      else if (line.startsWith("Suggestions")) current = "Suggestions";
      else if (line.startsWith("-") && current.isNotEmpty) {
        sections[current]!.add(line.replaceFirst("-", "").trim());
      }
    }

    return sections;
  }

  Widget buildScoreCard() {
    if (scoreRaw == null) return const SizedBox();

    final sections = parseSections(scoreRaw!);
    final color = getScoreColor(scoreValue ?? 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("AI CV Score",
                  style: TextStyle(color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("${scoreValue ?? 0}/100",
                    style: TextStyle(color: color)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildSection("Strengths", sections["Strengths"]!, Colors.green),
          buildSection("Weaknesses", sections["Weaknesses"]!, Colors.red),
          buildSection("Suggestions", sections["Suggestions"]!, Colors.orange),
        ],
      ),
    );
  }

  Widget buildSection(String title, List<String> items, Color color) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...items.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text("• $e",
                  style: const TextStyle(color: Colors.white70)),
            )),
        const SizedBox(height: 12),
      ],
    );
  }

  // ===============================
  // CV
  // ===============================
  Future<void> generateCV() async {
    final token = await getToken();
    if (token == null) return;

    setState(() => isSaving = true);

    final res = await http.post(
      Uri.parse('$baseUrl/cv/generate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    setState(() => isSaving = false);

    if (res.statusCode == 200) {
      await loadCv();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CV generated successfully")),
      );
    }
  }

  Future<void> deleteCV() async {
    final token = await getToken();
    if (token == null) return;

    await http.delete(
      Uri.parse('$baseUrl/cv/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );

    setState(() {
      cvFileUrl = null;
      cvFileName = "No CV generated";
    });
  }

  Future<void> loadCv() async {
    final token = await getToken();
    if (token == null) return;

    final res = await http.get(
      Uri.parse('$baseUrl/cv/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      cvFileUrl = data['cv_url'];
      cvFileName =
          cvFileUrl != null ? "Generated CV" : "No CV generated";
      setState(() {});
    }
  }

  Future<void> openCv() async {
    if (cvFileUrl == null) return;

    await launchUrl(Uri.parse(cvFileUrl!),
        mode: LaunchMode.externalApplication);
  }

  // ===============================
  // SKILLS
  // ===============================
  Future<void> addSkill() async {
    final text = skillController.text.trim();
    if (text.isEmpty) return;

    final token = await getToken();
    if (token == null) return;

    await http.post(
      Uri.parse('$baseUrl/skills'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'skill_name': text}),
    );

    skillController.clear();
    await loadSkills();
  }

  Future<void> deleteSkill(int id) async {
    final token = await getToken();
    if (token == null) return;

    await http.delete(
      Uri.parse('$baseUrl/skills/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    skills.removeWhere((s) => s['id'] == id);
    setState(() {});
  }

  Future<void> loadSkills() async {
    final token = await getToken();
    if (token == null) return;

    final res = await http.get(
      Uri.parse('$baseUrl/skills/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      skills = List<Map<String, dynamic>>.from(data['skills']);
      setState(() {});
    }
  }

  // ===============================
  // UI
  // ===============================
  Widget buildCvCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf,
                  color: Colors.redAccent, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cvFileName,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: openCv,
                    child: const Text('View'),
                  ),
                  TextButton(
                    onPressed: deleteCV,
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: getScore,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Check CV Score"),
          ),

          const SizedBox(height: 10),

          buildScoreCard(),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : generateCV,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Generate CV'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSkillInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          TextField(
            controller: skillController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Skill',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: addSkill,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Skill'),
          ),
        ],
      ),
    );
  }

  Widget buildSkillsList() {
    if (skills.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'No skills yet',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: skills.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final skill = skills[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            title: Text(
              skill['skill_name'],
              style: const TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => deleteSkill(skill['id']),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'CV & Skills',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildCvCard(),
              const SizedBox(height: 20),
              buildSkillInput(),
              const SizedBox(height: 20),
              buildSkillsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}