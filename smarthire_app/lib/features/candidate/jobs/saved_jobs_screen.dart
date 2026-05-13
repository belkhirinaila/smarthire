// Import des bibliothèques nécessaires :
// - dart:convert pour décoder les réponses JSON du backend.
// - flutter/material.dart pour construire l'interface et les widgets.
// - package:http pour envoyer des requêtes HTTP à l'API.
// - shared_preferences pour récupérer le token d'authentification stocké localement.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Écran affichant les offres sauvegardées par le candidat.
// Ce widget conserve son propre état pour charger, afficher et supprimer
// des offres favorites.
class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  // Palette de couleurs utilisée pour l'interface de l'écran.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  // URL de base du backend pour les requêtes d'offres sauvegardées.
  static const String baseUrl = 'https://smarthire-fpa1.onrender.com/api';

  // Liste des offres sauvegardées récupérées depuis le serveur.
  List<dynamic> jobs = [];
  // Indicateur de chargement pendant l'appel réseau.
  bool isLoading = true;
  // Message d'erreur à afficher en cas de problème.
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Au chargement de l'écran, on déclenche la récupération des offres
    // sauvegardées depuis l'API.
    fetchSavedJobs();
  }

  // Charge les offres sauvegardées de l'utilisateur via l'API.
  // La méthode gère l'authentification grâce au token stocké en local.
  Future<void> fetchSavedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Vérifie que l'utilisateur est bien authentifié avant d'appeler l'API.
      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable. Veuillez vous reconnecter.";
        });
        return;
      }

      // Appel HTTP pour récupérer les offres sauvegardées de l'utilisateur.
      final response = await http.get(
        Uri.parse('$baseUrl/saved-jobs/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Si la réponse est correcte, on met à jour la liste des jobs et
        // on supprime l'état de chargement.
        setState(() {
          jobs = data['jobs'] ?? [];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        // En cas d'erreur serveur, on affiche le message renvoyé ou un message
        // générique.
        setState(() {
          isLoading = false;
          errorMessage =
              data['message'] ?? "Erreur lors du chargement des favoris";
        });
      }
    } catch (e) {
      // Gestion des erreurs réseau ou de décodage de la réponse.
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  // Supprime une offre des favoris côté backend puis met à jour l'interface.
  Future<void> removeJob(int jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Si le token n'existe pas, on abandonne simplement la suppression.
      if (token == null || token.isEmpty) return;

      // Requête DELETE vers l'API pour retirer l'offre des favoris.
      final response = await http.delete(
        Uri.parse('$baseUrl/saved-jobs/$jobId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Mise à jour locale immédiate pour retirer l'offre supprimée.
        setState(() {
          jobs.removeWhere((job) => job['id'] == jobId);
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Job retiré des favoris"),
          ),
        );
      }
    } catch (e) {
      // Affiche un message d'erreur si la suppression échoue.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la suppression"),
        ),
      );
    }
  }

  // Navigation vers les détails d'une offre lorsqu'on appuie sur une carte.
  void openJobDetails(Map<String, dynamic> job) {
    Navigator.pushNamed(
      context,
      '/job-details',
      arguments: {
        'id': job['id'],
        'title': job['title'],
        'company': job['company_name'],
        'company_name': job['company_name'],
        'location': job['location'],
        'salary': job['salary']?.toString() ?? '',
        'type': job['type'] ?? 'Not specified',
        'description': job['description'] ?? 'No description available',
        'requirements': job['requirements'] ?? [],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construction de l'interface principale de l'écran.
    // On utilise un dégradé en arrière-plan et un SafeArea pour
    // respecter les zones de l'écran.
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
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 24),
                      const Text(
                        "Your saved opportunities",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Keep track of jobs you want to revisit later.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Corps de l'écran avec gestion de l'état de chargement,
                      // des erreurs et de l'affichage des offres sauvegardées.
                      _buildBody(),
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

  // Barre du haut contenant le bouton retour, le titre et l'icône des favoris.
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
          "Saved Jobs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Icon(
            Icons.bookmark_outline_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  // Contenu principal de l'écran : il affiche soit un loader, soit un message
  // d'erreur, soit l'état vide, soit la liste des offres sauvegardées.
  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      // Affiche une carte d'erreur avec un bouton de réessai.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                fetchSavedJobs();
              },
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (jobs.isEmpty) {
      // Affiche un état vide lorsque l'utilisateur n'a pas encore sauvegardé
      // d'offres.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.bookmark_outline_rounded,
              size: 38,
              color: Colors.white.withOpacity(0.45),
            ),
            const SizedBox(height: 12),
            const Text(
              "No saved jobs yet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Save jobs from the explore page and they will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    // Affiche la liste des offres sauvegardées sous forme de cartes.
    return Column(
      children: jobs.map((job) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => openJobDetails(job),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.business_center_rounded,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${job['company_name'] ?? ''} • ${job['location'] ?? ''}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job['salary']?.toString() ?? '',
                          style: const TextStyle(
                            color: primaryBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            "View details",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    // Suppression locale et backend de l'offre sauvegardée.
                    onTap: () => removeJob(job['id']),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}