import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Écran principal de la boîte de réception des demandes pour le candidat.
// Il récupère les demandes depuis l'API, affiche des onglets de filtrage,
// et permet d'accéder au détail d'une demande.
class RequestsInboxScreen extends StatefulWidget {
  const RequestsInboxScreen({super.key});

  @override
  State<RequestsInboxScreen> createState() => _RequestsInboxScreenState();
}

class _RequestsInboxScreenState extends State<RequestsInboxScreen> {
  // Couleurs de l'interface utilisées dans tout l'écran.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  // URL de base pour les appels vers l'API backend.
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  // Contrôleur pour le champ de recherche.
  final TextEditingController searchController = TextEditingController();

  // Index de l'onglet sélectionné dans le filtre de demande.
  int selectedTabIndex = 0;

  // Libellés des onglets de filtrage des demandes.
  final List<String> tabs = [
    "All",
    "Pending",
    "Approved",
    "Rejected",
  ];

  // Données des demandes reçues, état de chargement et message d'erreur.
  List<dynamic> requests = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Au démarrage de l'écran, lance la récupération des demandes.
    fetchRequests();
  }

  @override
  void dispose() {
    // Libère le contrôleur de recherche lors de la destruction de l'écran.
    searchController.dispose();
    super.dispose();
  }

  // Méthode asynchrone qui récupère les demandes reçues depuis le serveur.
  Future<void> fetchRequests() async {
    try {
      // Récupère le token stocké localement pour l'authentification.
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        // Si le token n'existe pas, on affiche une erreur et on quitte.
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable. Veuillez vous reconnecter.";
        });
        return;
      }

      // Envoie la requête GET à l'API pour obtenir les demandes reçues.
      final response = await http.get(
        Uri.parse('$baseUrl/requests/received'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Decode la réponse JSON pour récupérer le contenu.
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Si la réponse est bonne, met à jour la liste des demandes.
        setState(() {
          requests = data['requests'] ?? [];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        // Si le serveur renvoie une erreur, affiche le message correspondant.
        setState(() {
          isLoading = false;
          errorMessage =
              data['message'] ?? "Erreur lors du chargement des requests";
        });
      }
    } catch (e) {
      // En cas d'exception réseau ou JSON invalide, on affiche une erreur.
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  // Ouvre l'écran de détails de la demande puis recharge la liste au retour.
  void openRequestDetails(Map<String, dynamic> request) {
    Navigator.pushNamed(
      context,
      '/request-decision',
      arguments: request,
    ).then((_) {
      // Recharge les demandes après la navigation retour.
      fetchRequests();
    });
  }

  // Retourne une couleur de badge en fonction du statut de la demande.
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFFF5A6E);
      case 'pending':
      default:
        return const Color(0xFFFFB020);
    }
  }

  String formatDate(dynamic createdAt) {
    if (createdAt == null) return "Recently";
    final raw = createdAt.toString();
    if (raw.length >= 16) {
      return raw.substring(0, 16).replaceFirst('T', ' ');
    }
    return raw;
  }

  // Liste filtrée des demandes selon la recherche et l'onglet sélectionné.
  List<dynamic> get filteredRequests {
    // Partie de filtrage : on clone la liste complète pour éviter de modifier l'original.
    List<dynamic> result = List.from(requests);

    // Applique le filtre de recherche textuelle si un terme est saisi.
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((request) {
        final recruiter =
            "recruiter #${request['recruiter_id'] ?? ''}".toLowerCase();
        final status = (request['status'] ?? '').toString().toLowerCase();
        return recruiter.contains(query) || status.contains(query);
      }).toList();
    }

    // Applique le filtre par onglet selon l'index sélectionné.
    if (selectedTabIndex == 1) {
      result = result
          .where((request) =>
              (request['status'] ?? 'pending').toString().toLowerCase() ==
              'pending')
          .toList();
    } else if (selectedTabIndex == 2) {
      result = result
          .where((request) =>
              (request['status'] ?? '').toString().toLowerCase() == 'approved')
          .toList();
    } else if (selectedTabIndex == 3) {
      result = result
          .where((request) =>
              (request['status'] ?? '').toString().toLowerCase() == 'rejected')
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Construction du Scaffold principal de l'écran, contenant le corps et la navigation.
    return Scaffold(
      backgroundColor: backgroundBottom,
      extendBody: true,
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
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Gère le contenu principal de l'écran : état de chargement, erreur, vide ou liste.
  Widget _buildBodyContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      // Affiche une carte d'erreur avec un bouton de réessai.
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
                fetchRequests();
              },
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (filteredRequests.isEmpty) {
      // Si aucun résultat ne correspond aux filtres, affiche un état vide.
      return _buildEmptyState();
    }

    // Affiche la liste des demandes filtrées.
    return Column(
      children: filteredRequests.map((request) {
        final status = (request["status"] ?? "pending").toString();
        final badgeColor = getStatusColor(status);

        // Prépare une version du request enrichie avec les champs nécessaires
        // pour l'affichage de la carte et la navigation vers le détail.
        final Map<String, dynamic> mappedRequest = {
          ...request as Map<String, dynamic>,
         "company": "Recruiter #${request["recruiter_id"] ?? ""}",
         "title": "Access Request",
         "subtitle": "A recruiter wants access to your profile.",
         "time": formatDate(request["created_at"]),
         "isUnread": status.toLowerCase() == "pending",
         "type": status.toUpperCase(),
         "color": badgeColor,
       };

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => openRequestDetails(mappedRequest),
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
                  Stack(
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
                      if (status.toLowerCase() == "pending")
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mappedRequest["company"] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mappedRequest["title"] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mappedRequest["subtitle"] ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTypeBadge(
                              text: mappedRequest["type"] ?? "",
                              color: mappedRequest["color"] ?? primaryBlue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                mappedRequest["time"] ?? "",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.42),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.35),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Barre supérieure de l'écran avec icônes et titre central.
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
          "Requests Inbox",
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

  // Barre de recherche textuelle pour filtrer les demandes.
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
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search requests...",
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

  // Liste d'onglets horizontaux pour filtrer par statut de demande.
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

  // Badge de statut affiché sur chaque demande.
  Widget _buildTypeBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
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

  // Affiche un état vide lorsque aucune demande n'est disponible.
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
            Icons.inbox_outlined,
            size: 34,
            color: Colors.white.withOpacity(0.45),
          ),
          const SizedBox(height: 10),
          Text(
            "No requests available",
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

  // Barre de navigation inférieure avec accès aux principaux écrans candidat.
  Widget _buildBottomNav() {
    return Container(
      color: backgroundBottom,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1220).withOpacity(0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.travel_explore_rounded,
              label: "Explore",
              isSelected: false,
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/candidate',
                  (route) => false,
                );
              },
            ),
            _buildNavItem(
              icon: Icons.description_outlined,
              label: "Applications",
              isSelected: false,
              onTap: () {
                Navigator.pushNamed(context, '/applications');
              },
            ),
            _buildNavItem(
              icon: Icons.inbox_outlined,
              label: "Requests",
              isSelected: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.person_outline_rounded,
              label: "Profile",
              isSelected: false,
              onTap: () {
                Navigator.pushNamed(context, '/candidate-profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryBlue : Colors.white.withOpacity(0.65),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryBlue : Colors.white.withOpacity(0.65),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}