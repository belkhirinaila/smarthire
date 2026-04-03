import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? errorMessage;
  String visibility = 'public';

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable. Veuillez vous reconnecter.";
        });
        return;
      }

      final profileResponse = await http.get(
        Uri.parse('$baseUrl/candidate-profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final visibilityResponse = await http.get(
        Uri.parse('$baseUrl/visibility/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final profileData = jsonDecode(profileResponse.body);

      String fetchedVisibility = 'public';
      if (visibilityResponse.statusCode == 200) {
        final visibilityData = jsonDecode(visibilityResponse.body);
        fetchedVisibility =
            (visibilityData['visibility']?['visibility'] ?? 'public')
                .toString();
      }

      if (profileResponse.statusCode == 200) {
        setState(() {
          profile = profileData['profile'];
          visibility = fetchedVisibility;
          isLoading = false;
          errorMessage = null;
        });
      } else {
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
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    fetchProfile();
                  },
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bool profileNotCreated = profile == null;

    final String fullName = "Candidate";
    final String headline = profileNotCreated
        ? "Complete your profile"
        : _safeString(
            profile?['professional_headline'],
            fallback: "Your professional headline",
          );

    final String location = profileNotCreated
        ? "Algeria"
        : _safeString(
            profile?['location'],
            fallback: "Algeria",
          );

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
    final String profilePhoto = _safeString(profile?['profile_photo']);

    return Scaffold(
      backgroundColor: backgroundBottom,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundTop, backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 24),
                      _buildProfileHeader(
                        fullName: fullName,
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
                        _buildEmptyProfileCard(),
                        const SizedBox(height: 24),
                      ],
                      _buildSectionTitle("About Me"),
                      const SizedBox(height: 12),
                      _buildAboutCard(about),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Links"),
                      const SizedBox(height: 12),
                      _buildLinksCard(
                        githubLink: githubLink,
                        behanceLink: behanceLink,
                        personalWebsite: personalWebsite,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Documents"),
                      const SizedBox(height: 12),
                      _buildDocumentCard(),
                      const SizedBox(height: 26),
                    ],
                  ),
                ),
              ),
            ],
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
        Container(
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
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: profilePhoto.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profilePhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 42,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
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
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white.withOpacity(0.45),
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  location,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.48),
                    fontSize: 14,
                  ),
                ),
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
                  final result =
                      await Navigator.pushNamed(context, '/edit-profile');

                  if (result == true) {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    await fetchProfile();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.description_outlined,
                label: "CV & Skills",
                onTap: () async {
                  final result =
                      await Navigator.pushNamed(context, '/cv-skills');

                  if (result == true) {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    await fetchProfile();
                  }
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

                  if (result == true) {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    await fetchProfile();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.visibility_outlined,
                label: "Privacy & Visibility",
                onTap: () async {
                  final result =
                      await Navigator.pushNamed(context, '/privacy-visibility');

                  if (result == true) {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    await fetchProfile();
                  }
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
            const Expanded(
              child: SizedBox(),
            ),
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
        height: 96,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryBlue, size: 24),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
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

  Widget _buildEmptyProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        "Profil non encore créé. Tu peux le compléter depuis Edit Profile.",
        style: TextStyle(
          color: Colors.white.withOpacity(0.72),
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildAboutCard(String about) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        about,
        style: TextStyle(
          color: Colors.white.withOpacity(0.72),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: links.map((item) {
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
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value.isEmpty ? "Not added yet" : value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              "candidate_resume.pdf",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "View",
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}