// Import des packages utilisés dans cet écran :
// - dart:convert pour décoder les réponses JSON.
// - flutter/material.dart pour construire l'interface Flutter.
// - http pour les requêtes réseau vers l'API.
// - shared_preferences pour récupérer le token d'authentification.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Écran qui permet au candidat de configurer la visibilité de son profil.
// Il récupère l'état actuel depuis le backend, affiche les options de visibilité,
// puis enregistre le choix de l'utilisateur.
class PrivacyVisibilityScreen extends StatefulWidget {
  const PrivacyVisibilityScreen({super.key});

  @override
  State<PrivacyVisibilityScreen> createState() =>
      _PrivacyVisibilityScreenState();
}

class _PrivacyVisibilityScreenState extends State<PrivacyVisibilityScreen> {
  // Couleurs statiques pour l'interface de l'écran.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  // URL de base du backend.
  static const String baseUrl = 'https://smarthire-1-xe6v.onrender.com/api';

  // États de chargement et de sauvegarde.
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  // Valeur sélectionnée pour la visibilité du profil.
  String selectedVisibility = 'public';

  @override
  void initState() {
    super.initState();
    // Au chargement du widget, on récupère l'état de visibilité actuel.
    fetchVisibility();
  }

  // Récupère le token d'authentification depuis le stockage local.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Charge la configuration de visibilité du profil depuis le backend.
  Future<void> fetchVisibility() async {
    try {
      final token = await _getToken();

      // Si le token est absent, on affiche un message d'erreur.
      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable. Veuillez vous reconnecter.";
        });
        return;
      }

      // Requête GET pour obtenir la visibilité actuelle du profil.
      final response = await http.get(
        Uri.parse('$baseUrl/visibility/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          // Lecture de la valeur de visibilité renvoyée par l'API.
          selectedVisibility =
              (data['visibility']?['visibility'] ?? 'public').toString();
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              data['message'] ?? "Erreur lors du chargement de la visibilité";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  // Enregistre la visibilité sélectionnée dans le backend.
  Future<void> saveVisibility() async {
    try {
      setState(() {
        isSaving = true;
      });

      final token = await _getToken();

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

      // Requête PUT pour mettre à jour le paramètre de visibilité.
      final response = await http.put(
        Uri.parse('$baseUrl/visibility'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'visibility': selectedVisibility,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Visibility mise à jour avec succès',
            ),
          ),
        );

        // Ferme l'écran et renvoie true pour indiquer une mise à jour réussie.
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? "Erreur lors de l'enregistrement",
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
    // Affiche un loader si les données de visibilité sont en cours de chargement.
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Affiche un écran d'erreur si le chargement a échoué.
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
                    fetchVisibility();
                  },
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Affiche l'interface principale lorsque les données sont prêtes.
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
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Profile Visibility"),
                      const SizedBox(height: 12),
                      _buildVisibilityCard(),
                      const SizedBox(height: 24),
                      _buildInfoCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: backgroundBottom,
        child: SafeArea(
          top: false,
          child: _buildBottomButton(),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
          "Privacy & Visibility",
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

  // Titre de section réutilisable.
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

  // Carte contenant les options de visibilité pour le profil.
  Widget _buildVisibilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildVisibilityOption(
            icon: Icons.public_rounded,
            title: "Public",
            subtitle: "Your profile can be visible to recruiters on the platform.",
            value: 'public',
          ),
          const SizedBox(height: 12),
          _buildVisibilityOption(
            icon: Icons.lock_outline_rounded,
            title: "Private",
            subtitle: "Your profile stays hidden and recruiters cannot browse it.",
            value: 'private',
          ),
          
        ],
      ),
    );
  }

  // Option de visibilité réutilisable.
  // Affiche une carte cliquable avec un titre, une description et un indicateur sélectionné.
  Widget _buildVisibilityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool isSelected = selectedVisibility == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVisibility = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryBlue.withOpacity(0.10)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? primaryBlue.withOpacity(0.45)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? primaryBlue : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  // Carte d'information expliquant l'impact de la visibilité choisie.
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primaryBlue.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: primaryBlue,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Choose how visible your profile is for recruiters. This setting is connected to your backend visibility preference.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bouton de sauvegarde en bas de l'écran.
  // Il déclenche l'enregistrement de la visibilité sélectionnée.
  Widget _buildBottomButton() {
    return Container(
      color: backgroundBottom,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: SizedBox(
        height: 58,
        child: ElevatedButton(
          onPressed: isSaving ? null : saveVisibility,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primaryBlue.withOpacity(0.7),
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
              : const Text(
                  "Save Settings",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}