// Import des bibliothèques nécessaires :
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);
  static const Color cardBorderColor = Color(0x0AFFFFFF);

  static const String baseUrl = 'https://smarthire-fpa1.onrender.com/api';
  static const String serverUrl = 'https://smarthire-fpa1.onrender.com';

  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? errorMessage;
  String visibility = 'public';
  String dynamicUserName = "";
  File? selectedImage;

  String getImageUrl(dynamic path) {
    if (path == null) return "";
    final p = path.toString().trim();
    if (p.isEmpty) return "";
    if (p.startsWith("http")) return p;
    return "$serverUrl/$p";
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable. Veuillez vous reconnecter.";
        });
        return;
      }

      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/candidate-profile/me'),
            headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('$baseUrl/visibility/me'),
            headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('$baseUrl/auth/me'),
            headers: {'Authorization': 'Bearer $token'}),
      ]);

      final profileResponse = responses[0];
      final visibilityResponse = responses[1];
      final authResponse = responses[2];

      String fetchedVisibility = 'public';
      String fetchedName = '';

      if (visibilityResponse.statusCode == 200) {
        final visibilityData = jsonDecode(visibilityResponse.body);
        fetchedVisibility =
            (visibilityData['visibility']?['visibility'] ?? 'public')
                .toString();
      }

      if (authResponse.statusCode == 200) {
        final authData = jsonDecode(authResponse.body);
        fetchedName = authData['user']?['full_name'] ?? "";
      }

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);

        setState(() {
          profile = profileData['profile'];
          visibility = fetchedVisibility;
          dynamicUserName = fetchedName;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        final profileData = jsonDecode(profileResponse.body);
        setState(() {
          isLoading = false;
          errorMessage =
              profileData['message'] ?? 'Erreur lors du chargement du profil';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de connexion au serveur';
      });
    }
  }

  Future<void> fetchProfile() async {
    await loadData();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });

      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (selectedImage == null || token == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$serverUrl/api/upload/profile'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        selectedImage!.path,
      ),
    );

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    debugPrint("UPLOAD STATUS: ${response.statusCode}");
    debugPrint("UPLOAD BODY: $resBody");

    if (response.statusCode == 200) {
      final data = jsonDecode(resBody);
      final String path = data['profile_photo'];

      await savePhotoToProfile(path);

      setState(() {
        selectedImage = null;
      });

      await fetchProfile();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo updated successfully ✅")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur upload photo")),
      );
    }
  }

  Future<void> savePhotoToProfile(String filename) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) return;

    final response = await http.put(
      Uri.parse('$baseUrl/candidate-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "profile_photo": filename,
      }),
    );

    debugPrint("SAVE PHOTO STATUS: ${response.statusCode}");
    debugPrint("SAVE PHOTO BODY: ${response.body}");
  }

  String _safeString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final bool profileNotCreated = profile == null;

    final String headline = profileNotCreated
        ? "Complete your profile"
        : _safeString(
            profile?['professional_headline'],
            fallback: "Your professional headline",
          );

    final String location = profileNotCreated
        ? "Algeria"
        : _safeString(profile?['location'], fallback: "Algeria");

    final String about = profileNotCreated
        ? "You have not created your candidate profile yet."
        : _safeString(
            profile?['bio'],
            fallback:
                "Tell recruiters about your profile, your goals and your strengths.",
          );

    final String githubLink = _safeString(profile?['github_link']);
    final String behanceLink = _safeString(profile?['behance_link']);
    final String personalWebsite = _safeString(profile?['personal_website']);
    final String phone =
        _safeString(profile?['phone_number'], fallback: "Not added yet");
    final String email =
        _safeString(profile?['email'], fallback: "Not added yet");

    final String profilePhoto = getImageUrl(profile?['profile_photo']);

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 24),
                _buildProfileHeader(
                  fullName: "Candidate",
                  headline: headline,
                  location: location,
                  profilePhoto: profilePhoto,
                ),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                if (profileNotCreated) ...[
                  _buildSectionTitle("Profile Status"),
                  const SizedBox(height: 12),
                  _buildCardText(
                    "Profil non encore créé. Tu peux le compléter depuis Edit Profile.",
                  ),
                  const SizedBox(height: 24),
                ],
                _buildSectionTitle("About Me"),
                const SizedBox(height: 12),
                _buildCardText(about),
                const SizedBox(height: 24),
                _buildSectionTitle("Links"),
                const SizedBox(height: 12),
                _buildLinksCard(
                  githubLink: githubLink,
                  behanceLink: behanceLink,
                  personalWebsite: personalWebsite,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("Contact"),
                const SizedBox(height: 12),
                _buildContactCard(phone: phone, email: email),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
  return Row(
    children: [
      const Spacer(),
      const Text(
        "My Profile",
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      const Spacer(),

      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/candidate-settings');
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

  Widget _buildProfileHeader({
    required String fullName,
    required String headline,
    required String location,
    required String profilePhoto,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : profilePhoto.isNotEmpty
                            ? NetworkImage(profilePhoto) as ImageProvider
                            : null,
                    child: selectedImage == null && profilePhoto.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 42,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardColor, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: pickImage,
            child: const Text(
              "Modifier la photo",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            dynamicUserName.isEmpty ? fullName : dynamicUserName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text(
                location,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildVisibilityBadge(),
        ],
      ),
    );
  }

  Widget _buildVisibilityBadge() {
    Color color;
    IconData icon;
    String label;

    switch (visibility) {
      case 'private':
        color = Colors.redAccent;
        icon = Icons.lock_outline_rounded;
        label = 'Private';
        break;
      case 'selective':
        color = Colors.orangeAccent;
        icon = Icons.group_outlined;
        label = 'Selective';
        break;
      default:
        color = Colors.greenAccent;
        icon = Icons.public_rounded;
        label = 'Public';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit_outlined,
                label: "Edit Profile",
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/edit-profile',
                  );
                  if (result == true) await fetchProfile();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.description_outlined,
                label: "CV & Skills",
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/cv-skills',
                  );
                  if (result == true) await fetchProfile();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.work_outline_rounded,
                label: "Experience & Education",
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/experience-education',
                  );
                  if (result == true) await fetchProfile();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.visibility_outlined,
                label: "Privacy & Visibility",
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/privacy-visibility',
                  );
                  if (result == true) await fetchProfile();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.bookmark_outline_rounded,
                label: "Saved Jobs",
                onTap: () {
                  Navigator.pushNamed(context, '/saved-jobs');
                },
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 112,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryBlue, size: 24),
          const Spacer(),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildCardText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorderColor),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildLinksCard({
    required String githubLink,
    required String behanceLink,
    required String personalWebsite,
  }) {
    final links = [
      {"label": "GitHub", "value": githubLink},
      {"label": "Behance", "value": behanceLink},
      {"label": "Website", "value": personalWebsite},
    ];

    return _buildListCard(links);
  }

  Widget _buildContactCard({
    required String phone,
    required String email,
  }) {
    final items = [
      {"label": "Phone", "value": phone},
      {"label": "Email", "value": email},
    ];

    return _buildListCard(items);
  }

  Widget _buildListCard(List<Map<String, String>> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        children: items.map((item) {
          final value = item["value"] ?? "";
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    item["label"] ?? "",
                    style: const TextStyle(
                      color: Color(0x8CFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value.isEmpty ? "Not added yet" : value,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}