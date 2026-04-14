// Import des bibliothèques nécessaires :
// - dart:convert pour la sérialisation JSON.
// - file_picker pour sélectionner un fichier CV.
// - flutter/material.dart pour construire l'interface utilisateur.
// - http et http_parser pour les requêtes multipart vers l'API.
// - mime pour détecter le type MIME du fichier.
// - shared_preferences pour récupérer le token d'authentification.
// - url_launcher pour ouvrir le CV dans une application externe.
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
  // Couleurs réutilisées dans l'écran CV & compétences.
  static const Color kPrimaryBlue = Color(0xFF1E6CFF);
  static const Color kBackground = Color(0xFF050A12);
  static const Color kCard = Color(0xFF121C31);

  // Points de terminaison API utilisés dans ce screen.
  static const String baseUrl = 'http://192.168.100.47:5000/api';
  static const String uploadsBaseUrl = 'http://192.168.100.47:5000/';

  // États de l'écran : chargement et enregistrement en cours.
  bool isLoading = true;
  bool isSaving = false;

  // Informations sur le CV affiché et le fichier sélectionné.
  String cvFileName = 'No CV uploaded';
  String? cvFilePath;
  String? cvFileUrl;
  PlatformFile? pickedFile;
  String? pickedFilePath;

  // Contrôleur de champ pour ajouter une nouvelle compétence.
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

  // Récupère le token d'authentification stocké localement.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Charge les données du CV et des compétences depuis l'API.
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

      // Lance les deux requêtes en parallèle pour réduire la latence.
      final responses = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/cv/me'),
          headers: {'Authorization': 'Bearer $token'},
        ),
        http.get(
          Uri.parse('$baseUrl/skills/me'),
          headers: {'Authorization': 'Bearer $token'},
        ),
      ]);

      final cvRes = responses[0];
      final skillsRes = responses[1];

      if (cvRes.statusCode == 200) {
        final data = jsonDecode(cvRes.body);
        cvFileName = (data['cv']['file_name'] ?? 'No CV uploaded').toString();
        cvFilePath = data['cv']['file_path']?.toString();
        cvFileUrl = data['cv']['file_url']?.toString();
        if (cvFileUrl == null && cvFilePath != null) {
          final normalized = cvFilePath!.replaceAll('\\', '/');
          final fileName = normalized.split('/').last;
          cvFileUrl = '${uploadsBaseUrl}uploads/$fileName';
        }
      } else {
        cvFileName = 'No CV uploaded';
        cvFilePath = null;
        cvFileUrl = null;
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

  // Ouvre le sélecteur de fichier pour choisir un CV au format PDF.
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFile = result.files.first;
        pickedFilePath = pickedFile?.path;
        cvFileName = pickedFile?.name ?? 'No CV uploaded';
      });
    }
  }

  // Envoie le CV sélectionné vers l'API si un fichier est présent.
  Future<bool> uploadCv() async {
    if (pickedFile == null) return true;

    try {
      final token = await getToken();

      if (token == null || token.isEmpty) return false;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/cv/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Détection du type MIME du fichier PDF avant l'envoi.
      final filePath = pickedFilePath;
      final fileName = pickedFile?.name ?? 'cv.pdf';
      final mimeType = lookupMimeType(filePath ?? fileName) ?? 'application/pdf';
      final split = mimeType.split('/');

      if (filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'cv',
            filePath,
            contentType: MediaType(split[0], split[1]),
          ),
        );
      } else if (pickedFile?.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cv',
            pickedFile!.bytes!,
            filename: fileName,
            contentType: MediaType(split[0], split[1]),
          ),
        );
      } else {
        return false;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Recharge seulement les données de CV après un upload réussi.
        debugPrint("UPLOAD SUCCESS");
        debugPrint(response.body);
        pickedFile = null;
        pickedFilePath = null;
        await loadCv();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }





  // Ajoute une compétence via l'API en utilisant le texte saisi.
  Future<void> addSkill() async {
    final text = skillController.text.trim();
    if (text.isEmpty) return;

    final token = await getToken();
    if (token == null || token.isEmpty) return;

    final response = await http.post(
      Uri.parse('$baseUrl/skills'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'skill_name': text}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      skillController.clear();
      await loadSkills();
    }
  }

  // Supprime une compétence existante et met à jour la liste localement.
  Future<void> deleteSkill(int id) async {
    final token = await getToken();
    if (token == null || token.isEmpty) return;

    final response = await http.delete(
      Uri.parse('$baseUrl/skills/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      skills.removeWhere((skill) => skill['id'] == id);
      setState(() {});
    }
  }

  // Recharge uniquement la liste des compétences sans recharger tout l'écran.
  Future<void> loadSkills() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return;

    final skillsRes = await http.get(
      Uri.parse('$baseUrl/skills/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (skillsRes.statusCode == 200) {
      final data = jsonDecode(skillsRes.body);
      skills = List<Map<String, dynamic>>.from(data['skills'] ?? []);
      setState(() {});
    }
  }

  // Recharge uniquement les données de CV sans toucher aux compétences.
  Future<void> loadCv() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return;

    final cvRes = await http.get(
      Uri.parse('$baseUrl/cv/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (cvRes.statusCode == 200) {
      final data = jsonDecode(cvRes.body);
      cvFileName = (data['cv']['file_name'] ?? 'No CV uploaded').toString();
      cvFilePath = data['cv']['file_path']?.toString();
      cvFileUrl = data['cv']['file_url']?.toString();
      if (cvFileUrl == null && cvFilePath != null) {
        final normalized = cvFilePath!.replaceAll('\\', '/');
        final fileName = normalized.split('/').last;
        cvFileUrl = '${uploadsBaseUrl}uploads/$fileName';
      }
      setState(() {});
    }
  }

  // Ouvre le CV dans une application externe s'il est disponible.
  Future<void> openCv() async {
  if (cvFileUrl == null || cvFileUrl!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aucun CV disponible")),
    );
    return;
  }

  final uri = Uri.parse(cvFileUrl!);

  try {
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir le CV: ${cvFileUrl!}")),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur ouverture CV: ${cvFileUrl!}")),
    );
  }
}

  // Enregistre les changements : ajoute la compétence en cours et upload le CV.
  Future<void> saveChanges() async {
    setState(() {
      isSaving = true;
    });

    bool ok = true;

    final pendingSkill = skillController.text.trim();
    if (pendingSkill.isNotEmpty) {
      await addSkill();
    }

    if (pickedFile != null) {
      ok = await uploadCv();
    }

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

  // Carte d'affichage du CV actuel avec un bouton pour le consulter et
  // un bouton permettant de choisir un nouveau fichier.
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

  // Section de saisie pour ajouter une nouvelle compétence au profil.
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

  // Liste des compétences affichées avec la possibilité de suppression.
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
    // Affiche un écran de chargement tant que les données sont en cours de
    // récupération depuis l'API.
    if (isLoading) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Interface principale du screen CV & compétences.
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