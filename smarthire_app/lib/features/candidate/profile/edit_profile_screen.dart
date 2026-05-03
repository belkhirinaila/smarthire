// Import des bibliothèques nécessaires :
// - dart:convert pour décoder les réponses JSON provenant du backend.
// - flutter/material.dart pour la construction de l'interface utilisateur.
// - package:http pour envoyer des requêtes HTTP.
// - shared_preferences pour récupérer le token d'authentification stocké localement.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Écran permettant au candidat d'éditer son profil.
// Il gère le chargement des données existantes, l'affichage des champs,
// et l'enregistrement vers l'API.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Couleurs constantes utilisées dans l'interface du profil.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  // URL de base de l'API pour les appels liés au profil.
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  // Contrôleurs de saisie pour chaque champ du formulaire.
  final TextEditingController headlineController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final TextEditingController behanceController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController photoController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // États locaux pour indiquer le chargement, l'enregistrement et l'existence du profil.
  bool isLoading = true;
  bool isSaving = false;
  bool profileExists = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Au démarrage du widget, on charge les données du profil depuis l'API.
    loadProfileData();
  }

  @override
  void dispose() {
    // Libération des ressources des contrôleurs de texte.
    headlineController.dispose();
    locationController.dispose();
    bioController.dispose();
    githubController.dispose();
    behanceController.dispose();
    websiteController.dispose();
    photoController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Charge les informations du profil candidat et pré-remplit le formulaire.
  Future<void> loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Vérifie que l'utilisateur est authentifié avant de charger le profil.
      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable. Veuillez vous reconnecter.";
        });
        return;
      }

      // Requête API pour récupérer le profil candidat courant.
      final response = await http.get(
        Uri.parse('$baseUrl/candidate-profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final profile = data['profile'];

        if (profile != null) {
          profileExists = true;
          headlineController.text =
              (profile['professional_headline'] ?? '').toString();
          locationController.text = (profile['location'] ?? '').toString();
          bioController.text = (profile['bio'] ?? '').toString();
          githubController.text = (profile['github_link'] ?? '').toString();
          behanceController.text = (profile['behance_link'] ?? '').toString();
          websiteController.text =
              (profile['personal_website'] ?? '').toString();
          photoController.text = (profile['profile_photo'] ?? '').toString();
          phoneController.text = (profile['phone'] ?? '').toString();
          emailController.text = (profile['email'] ?? '').toString();
        } else {
          profileExists = false;
        }

        setState(() {
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              data['message'] ?? "Erreur lors du chargement du profil";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  // Valide les champs obligatoires et enregistre le profil via l'API.
  // Si un profil existe déjà, il est mis à jour, sinon il est créé.
  Future<void> saveProfile() async {
    if (headlineController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        bioController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Headline, location et bio sont obligatoires"),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Token introuvable. Veuillez vous reconnecter."),
          ),
        );
        return;
      }

      final body = {
        'professional_headline': headlineController.text.trim(),
        'location': locationController.text.trim(),
        'bio': bioController.text.trim(),
        'github_link': githubController.text.trim(),
        'behance_link': behanceController.text.trim(),
        'personal_website': websiteController.text.trim(),
        'profile_photo': photoController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'email': emailController.text.trim(),
      };

      late http.Response response;

      if (profileExists) {
        // Mise à jour d'un profil existant.
        response = await http.put(
          Uri.parse('$baseUrl/candidate-profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );
      } else {
        // Création d'un nouveau profil candidat.
        response = await http.post(
          Uri.parse('$baseUrl/candidate-profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              profileExists
                  ? "Profil mis à jour avec succès"
                  : "Profil créé avec succès",
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? "Erreur lors de l'enregistrement du profil",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur de connexion au serveur"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Affiche un loader global tant que les données du profil sont en cours de chargement.
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Affiche un message d'erreur si le chargement du profil a échoué.
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
                    loadProfileData();
                  },
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Affiche le formulaire d'édition du profil avec tous les champs.
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
                      _buildInputCard(
                        label: "Professional Headline *",
                        controller: headlineController,
                        hint: "Ex: Flutter Developer",
                      ),
                      const SizedBox(height: 16),
                      _buildInputCard(
                        label: "Location *",
                        controller: locationController,
                        hint: "Ex: Algiers, Algeria",
                      ),
                      const SizedBox(height: 16),
                      _buildInputCard(
                        label: "Bio *",
                        controller: bioController,
                        hint: "Tell recruiters about yourself...",
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      _buildInputCard(
                        label: "GitHub Link",
                        controller: githubController,
                        hint: "https://github.com/username",
                      ),
                      const SizedBox(height: 16),
                      _buildInputCard(
                        label: "Behance Link",
                        controller: behanceController,
                        hint: "https://behance.net/username",
                      ),
                      const SizedBox(height: 16),
                      _buildInputCard(
                        label: "Personal Website",
                        controller: websiteController,
                        hint: "https://yourwebsite.com",
                      ),
                      const SizedBox(height: 16),
                      _buildInputCard(
                        label: "Phone Number *",
                        controller: phoneController,
                        hint: "+213 123 4567",
                      ),

                      
                      const SizedBox(height: 16),
                      _buildInputCard(
                        label: "Email *",
                        controller: emailController,
                        hint: "youremail@example.com",
                        
                      ),

                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Container(
                color: backgroundBottom,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            profileExists ? "Update Profile" : "Create Profile",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Barre supérieure du formulaire avec le bouton retour et le titre.
  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const Spacer(),
        const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  // Carte de champ réutilisable pour chaque champ du formulaire.
  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.35),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}