// Import des bibliothèques nécessaires :
// - dart:convert pour décoder les réponses JSON du backend.
// - flutter/material.dart pour construire l'interface utilisateur.
// - package:http pour communiquer avec l'API.
// - shared_preferences pour récupérer le token d'authentification local.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Ecran qui affiche la liste des candidatures d'un candidat.
// Il propose des onglets de filtrage, une recherche textuelle, et des cartes
// détaillant chaque candidature.
class ApplicationsListScreen extends StatefulWidget {
  const ApplicationsListScreen({super.key});

  @override
  State<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends State<ApplicationsListScreen> {
  // Palette de couleurs utilisée pour l'apparence de l'écran.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  // URL de base de l'API utilisée pour charger les candidatures.
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  // Index de l'onglet sélectionné pour filtrer les candidatures.
  int selectedTabIndex = 0;

  // Libellés des onglets de filtrage.
  final List<String> tabs = [
    "All",
    "Active",
    "Accepted",
    "Rejected",
  ];

  // Contrôleur pour le champ de recherche textuelle.
  final TextEditingController searchController = TextEditingController();

  // Liste des candidatures récupérées depuis le backend.
  List<dynamic> applications = [];
  // Indicateur de chargement pendant l'appel API.
  bool isLoading = true;
  // Message d'erreur affiché en cas de problème de chargement.
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Au démarrage de l'écran, on déclenche la récupération des candidatures.
    fetchApplications();
  }

  @override
  void dispose() {
    // Libération des ressources du contrôleur de recherche.
    searchController.dispose();
    super.dispose();
  }

  // Méthode principale pour récupérer les candidatures de l'utilisateur.
  // Elle charge le token depuis le stockage local, appelle l'API et met à jour
  // l'état en fonction du résultat.
  Future<void> fetchApplications() async {
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

      // Requête GET vers le point de terminaison des candidatures du candidat.
      final response = await http.get(
        Uri.parse('$baseUrl/applications/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Si la requête réussit, on stocke les candidatures et on réinitialise
        // l'état de chargement et d'erreur.
        setState(() {
          applications = data['applications'] ?? [];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        // En cas d'erreur côté backend, affichage du message renvoyé.
        setState(() {
          isLoading = false;
          errorMessage =
              data['message'] ?? "Erreur lors du chargement des candidatures";
        });
      }
    } catch (e) {
      // Gestion des erreurs réseau ou de décodage.
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  // Ouvre l'écran de détail d'une candidature lorsque l'utilisateur
  // appuie sur une carte d'application.
  void openApplicationDetails(Map<String, dynamic> application) {
    Navigator.pushNamed(
      context,
      '/application-details',
      arguments: application,
    );
  }

  // Formatte la date de création de la candidature pour l'affichage.
  String formatDate(dynamic createdAt) {
    if (createdAt == null) return "Applied recently";

    final raw = createdAt.toString();
    if (raw.length >= 10) {
      return "Applied on ${raw.substring(0, 10)}";
    }
    return "Applied recently";
  }

  // Retourne une couleur en fonction du statut de la candidature.
  // Ces couleurs sont utilisées dans le badge d'état pour améliorer la lisibilité.
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFFF5A6E);
      case 'pending':
        return const Color(0xFFFFB020);
      default:
        return primaryBlue;
    }
  }

  // Formatte le texte affiché pour le statut afin d'avoir un libellé uniforme.
  String getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'ACCEPTED';
      case 'rejected':
        return 'REJECTED';
      case 'pending':
        return 'PENDING';
      default:
        return status.toUpperCase();
    }
  }

  // Getter qui applique les filtres de recherche et d'onglet à la liste
  // des candidatures récupérées.
  List<dynamic> get filteredApplications {
    List<dynamic> result = List.from(applications);

    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      // Filtrage en fonction du texte saisi par l'utilisateur.
      result = result.where((application) {
        final title = (application['title'] ?? '').toString().toLowerCase();
        final company =
            (application['company_name'] ?? '').toString().toLowerCase();
        final location =
            (application['location'] ?? '').toString().toLowerCase();

        return title.contains(query) ||
            company.contains(query) ||
            location.contains(query);
      }).toList();
    }

    if (selectedTabIndex == 1) {
      // Onglet "Active" : on garde uniquement les candidatures en attente.
      result = result
          .where((application) =>
              (application['status'] ?? '').toString().toLowerCase() ==
              'pending')
          .toList();
    } else if (selectedTabIndex == 2) {
      // Onglet "Accepted" : on garde uniquement les candidatures acceptées.
      result = result
          .where((application) =>
              (application['status'] ?? '').toString().toLowerCase() ==
              'accepted')
          .toList();
    } else if (selectedTabIndex == 3) {
      // Onglet "Rejected" : on garde uniquement les candidatures refusées.
      result = result
          .where((application) =>
              (application['status'] ?? '').toString().toLowerCase() ==
              'rejected')
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Structure principale de l'écran : un Scaffold avec un fond dégradé
    // et un SafeArea pour respecter les zones non-interactives.
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
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 18),
                      _buildTabs(),
                      const SizedBox(height: 18),
                      _buildBodyContent(),
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

  Widget _buildBodyContent() {
    // Contenu principal de la page : affichage conditionnel selon l'état.
    // - Chargement pendant l'appel API.
    // - Erreur si la requête échoue.
    // - Message vide si aucune candidature ne correspond aux filtres.
    // - Liste de candidatures sinon.
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
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
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
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
                fetchApplications();
              },
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (filteredApplications.isEmpty) {
      return _buildEmptyState();
    }

    // Affichage des candidatures filtrées sous forme de liste de cartes.
    return Column(
      children: filteredApplications.map((application) {
        final status = (application["status"] ?? "pending").toString();
        final statusColor = getStatusColor(status);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => openApplicationDetails(application),
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
                      Icons.business_rounded,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application["title"] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${application["company_name"] ?? ""} • ${application["location"] ?? ""}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          application["salary"]?.toString() ?? "",
                          style: const TextStyle(
                            color: primaryBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 15,
                              color: Colors.white.withOpacity(0.45),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                formatDate(application["created_at"]),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.45),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(
                        text: getDisplayStatus(status),
                        color: statusColor,
                      ),
                      const SizedBox(height: 42),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Barre supérieure de l'écran contenant l'icône utilisateur, le titre et
  // l'indicateur de notifications.
  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        const Text(
          "Applications",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Champ de recherche pour filtrer les candidatures par titre, entreprise
  // ou localisation. La recherche met à jour l'interface à chaque modification.
  Widget _buildSearchBar() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (_) {
          setState(() {});
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search applications...",
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.45),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // Onglets de filtrage qui permettent de basculer entre toutes les
  // candidatures, les candidatures en attente, acceptées ou refusées.
  Widget _buildTabs() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final bool isSelected = selectedTabIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTabIndex = index;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? primaryBlue
                        : Colors.white.withOpacity(0.55),
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 3,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Petit badge coloré qui indique le statut de la candidature.
  // Le texte et la couleur varient selon l'état (accepted/rejected/pending).
  Widget _buildStatusBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // Affichage lorsqu'aucune candidature ne correspond aux critères de
  // recherche ou lorsque la liste est vide.
  Widget _buildEmptyState() {
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
            Icons.assignment_outlined,
            size: 34,
            color: Colors.white.withOpacity(0.45),
          ),
          const SizedBox(height: 10),
          Text(
            "No applications yet",
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}