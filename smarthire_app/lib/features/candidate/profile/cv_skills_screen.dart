import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CvSkillsScreen extends StatefulWidget {
  const CvSkillsScreen({super.key});

  @override
  State<CvSkillsScreen> createState() => _CvSkillsScreenState();
}

class _CvSkillsScreenState extends State<CvSkillsScreen> {
  static const Color kPrimaryBlue = Color(0xFF1E6CFF);
  static const Color kBackground = Color(0xFF050A12);
  static const Color kCard = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';
  static const String uploadsBaseUrl = 'http://192.168.100.47:5000/';

  bool isLoading = true;
  bool isSaving = false;

  String cvFileName = 'No CV uploaded';
  String? cvFilePath;
  String? pickedFilePath;

  final TextEditingController skillController = TextEditingController();
  List<Map<String, dynamic>> skills = [];

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

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final token = await getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final cvRes = await http.get(
        Uri.parse('$baseUrl/cv/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final skillsRes = await http.get(
        Uri.parse('$baseUrl/skills/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (cvRes.statusCode == 200) {
        final data = jsonDecode(cvRes.body);
        cvFileName = (data['cv']['file_name'] ?? 'No CV uploaded').toString();
        cvFilePath = data['cv']['file_path']?.toString();
      } else {
        cvFileName = 'No CV uploaded';
        cvFilePath = null;
      }

      if (skillsRes.statusCode == 200) {
        final data = jsonDecode(skillsRes.body);
        skills = List<Map<String, dynamic>>.from(data['skills'] ?? []);
      } else {
        skills = [];
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFilePath = result.files.first.path;
        cvFileName = result.files.first.name;
      });
    }
  }

  Future<bool> uploadCv() async {
    if (pickedFilePath == null) return true;

    try {
      final token = await getToken();

      if (token == null || token.isEmpty) return false;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/cv/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final mimeType = lookupMimeType(pickedFilePath!) ?? 'application/pdf';
      final split = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'cv',
          pickedFilePath!,
          contentType: MediaType(split[0], split[1]),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        pickedFilePath = null;
        await loadData();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> addSkill() async {
    final text = skillController.text.trim();
    if (text.isEmpty) return;

    final token = await getToken();
    if (token == null || token.isEmpty) return;

    await http.post(
      Uri.parse('$baseUrl/skills'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'skill_name': text}),
    );

    skillController.clear();
    await loadData();
  }

  Future<void> deleteSkill(int id) async {
    final token = await getToken();
    if (token == null || token.isEmpty) return;

    await http.delete(
      Uri.parse('$baseUrl/skills/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    await loadData();
  }

 Future<void> openCv() async {
  if (cvFilePath == null || cvFilePath!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aucun CV disponible")),
    );
    return;
  }

  final normalized = cvFilePath!.replaceAll('\\', '/');
  final cleaned = normalized.replaceAll('uploads/', '');
  final url = '${uploadsBaseUrl}uploads/$cleaned';
  final uri = Uri.parse(url);

  try {
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir le CV: $url")),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur ouverture CV: $url")),
    );
  }
}

  Future<void> saveChanges() async {
    setState(() {
      isSaving = true;
    });

    final ok = await uploadCv();

    setState(() {
      isSaving = false;
    });

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'enregistrement du CV")),
      );
    }
  }

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
              const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cvFileName,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: openCv,
                child: const Text('View'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Choose CV'),
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
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryBlue),
              ),
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

    return Expanded(
      child: ListView.builder(
        itemCount: skills.length,
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
                (skill['skill_name'] ?? '').toString(),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => deleteSkill(skill['id']),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: CircularProgressIndicator(),
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildCvCard(),
            const SizedBox(height: 20),
            buildSkillInput(),
            const SizedBox(height: 20),
            buildSkillsList(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isSaving ? null : saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBlue,
              foregroundColor: Colors.white,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ),
    );
  }
}