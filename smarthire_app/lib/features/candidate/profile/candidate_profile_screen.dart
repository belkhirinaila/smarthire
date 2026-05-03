// Import des bibliothèques nécessaires :
// - dart:convert pour la sérialisation et désérialisation JSON.
// - flutter/material.dart pour construire l'interface utilisateur.
// - package:http pour les requêtes HTTP vers le backend.
// - shared_preferences pour récupérer le token d'authentification local.
// - dart:io pour manipuler les fichiers sélectionnés sur l'appareil.
// - image_picker pour ouvrir la galerie et sélectionner une photo.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

// Écran de profil candidat qui affiche les informations du profil,
// gère la visibilité et permet de mettre à jour la photo de profil.
class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  // Couleurs réutilisées dans l'affichage du profil.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);
  static const Color cardBorderColor = Color(0x0AFFFFFF);
  static const TextStyle sectionTitleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle cardBodyTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: 15,
    height: 1.7,
  );
  static const TextStyle actionButtonLabelStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // URL de base de l'API pour toutes les requêtes de ce screen.
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  // Données du profil récupérées depuis le backend.
  Map<String, dynamic>? profile;
  // Indicateur de chargement pendant la récupération des données.
  bool isLoading = true;
  // Message d'erreur à afficher si la récupération échoue.
  String? errorMessage;
  // Visibilité du profil (public/private/selective).
  String visibility = 'public';
  // Nom dynamique affiché dans l'en-tête.
  String dynamicUserName = "";
  // Image sélectionnée localement avant envoi au backend.
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    // Au lancement de l'écran, on charge toutes les données nécessaires en
    // une seule opération optimisée.
    loadData();
  }

  // Charge le profil, la visibilité et le nom dynamique en parallèle.
  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable. Veuillez vous reconnecter.";
        });
        return;
      }

      final responses = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/candidate-profile/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        http.get(
          Uri.parse('$baseUrl/visibility/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        http.get(
          Uri.parse('$baseUrl/auth/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      ]);

      final profileResponse = responses[0];
      final visibilityResponse = responses[1];
      final authResponse = responses[2];

      final profileData = jsonDecode(profileResponse.body);
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

      if (!mounted) return;

      if (profileResponse.statusCode == 200) {
        setState(() {
          profile = profileData['profile'];
          visibility = fetchedVisibility;
          dynamicUserName = fetchedName;
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
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de connexion au serveur';
      });
    }
  }

  Future<void> fetchProfile() async {
    await loadData();
  }

  // Ouvre la galerie et permet à l'utilisateur de sélectionner une photo.
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });

      // Après sélection, on lance l'upload vers le serveur.
      await uploadImage();
    }
  }

  // Envoie une requête multipart vers l'API pour téléverser l'image sélectionnée.
  Future<void> uploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (selectedImage == null || token == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.100.47:5000/api/upload/profile'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('image', selectedImage!.path),
    );
    debugPrint("UPLOAD START");
    var response = await request.send();

    var resBody = await response.stream.bytesToString();
    final data = jsonDecode(resBody);

    if (response.statusCode == 200) {
      String path = data['profile_photo'];

      // Sauvegarde le chemin de la photo sur le profil et recharge les données.
      await savePhotoToProfile(path);
      await fetchProfile();
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint(resBody);
    }
  }

  // Met à jour le champ profile_photo du profil candidat.
  Future<void> savePhotoToProfile(String filename) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) return;

    await http.put(
      Uri.parse('$baseUrl/candidate-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"profile_photo": filename}),
    );
  }

  // Retourne une chaîne sûre pour l'affichage, en gérant null et vide.
  String _safeString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  @override
  Widget build(BuildContext context) {
    // Affiche un écran de chargement tant que les données ne sont pas prêtes.
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Affiche un message d'erreur si la récupération du profil a échoué.
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
                  style: const TextStyle(color: Colors.white, fontSize: 15),
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

    // Détermine si le profil candidat existe ou si l'utilisateur doit le créer.
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
    final String phone = _safeString(profile?['phone_number'], fallback: "Not added yet");
    final String email = _safeString(profile?['email'], fallback: "Not added yet");

    final String profilePhoto =
        profile?['profile_photo'] != null && profile?['profile_photo'] != ""
        ? "http://192.168.100.47:5000/${profile!['profile_photo']}"
        : "";

    // Affiche le contenu principal du profil : en-tête, actions rapides et
    // sections supplémentaires.
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
                      // Boutons d'actions rapides pour modifier le profil, gérer le
                      // CV, l'expérience et la visibilité.
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
                      _buildSectionTitle("Contact"),
                      const SizedBox(height: 12),
                      _buildContactCard(
                        phone: phone,
                        email: email,
                      ),
                      const SizedBox(height: 24),
                      
                     
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

  // Barre supérieure de l'écran avec le titre du profil.
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
          child: const Icon(Icons.settings_outlined, color: Colors.white),
        ),
      ],
    );
  }

  // En-tête du profil affichant la photo, le nom, la localisation et le badge
  // de visibilité.
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
          // Zone cliquable de la photo de profil : si l'utilisateur a déjà
          // sélectionné une image locale, on affiche celle-ci sinon on affiche
          // la photo de profil distante ou une icône par défaut.
          GestureDetector(
            onTap: pickImage,
            child: Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: selectedImage != null
                  ? ClipOval(
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                        width: 94,
                        height: 94,
                      ),
                    )
                  : profilePhoto.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        profilePhoto,
                        fit: BoxFit.cover,
                        width: 94,
                        height: 94,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      ),
                    )
                  : const Icon(Icons.person, size: 42, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // Lien d'action pour modifier la photo de profil via la galerie.
          GestureDetector(
            onTap: pickImage,
            child: Text(
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

  // Badge de visibilité affichant l'état public/privé/selectionnel du profil.
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

  // Section des actions rapides permettant de naviguer vers les écrans
  // d'édition et de gestion du profil.
  // Section offrant des boutons action vers les écrans de modification
  // et de gestion du profil candidat.
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
                  final result = await Navigator.pushNamed(
                    context,
                    '/cv-skills',
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
                  final result = await Navigator.pushNamed(
                    context,
                    '/privacy-visibility',
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

  // Bouton visuel réutilisable pour chaque action rapide.
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
          border: Border.all(color: cardBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryBlue, size: 24),
            const Spacer(),
            Text(label, style: actionButtonLabelStyle),
          ],
        ),
      ),
    );
  }

  // Titre de section utilisé avant chaque bloc de contenu du profil.
  Widget _buildSectionTitle(String title) {
    return Text(title, style: sectionTitleTextStyle);
  }

  // Carte affichée lorsque le profil candidat n'a pas encore été créé.
  Widget _buildEmptyProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorderColor),
      ),
      child: Text(
        "Profil non encore créé. Tu peux le compléter depuis Edit Profile.",
        style: cardBodyTextStyle.copyWith(height: 1.6),
      ),
    );
  }

  // Carte affichant la section "About Me" avec la biographie du candidat.
  Widget _buildAboutCard(String about) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorderColor),
      ),
      child: Text(about, style: cardBodyTextStyle),
    );
  }

  // Carte affichant les liens externes du candidat (GitHub, Behance, site web).
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
        border: Border.all(color: cardBorderColor),
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

  // Carte réservée aux documents du candidat, ici un PDF de CV avec un bouton.
  /*Widget _buildDocumentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorderColor),
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
            onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('$baseUrl/cv/me'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    String url = data['cv']['file_url'];

    debugPrint("CV URL: $url");

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
},
            child: const Text(
              "View",
              style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }*/

  // Carte affichant les informations de contact du candidat (téléphone et email).
  Widget _buildContactCard({
  required String phone,
  required String email,
}) {
  final items = [
    {"label": "Phone", "value": phone},
    {"label": "Email", "value": email},
  ];

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
