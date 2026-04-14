import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Écran d'accueil candidat.
// Affiche la liste des offres, le profil de l'utilisateur, les notifications
// et permet de filtrer / rechercher des opportunités.
class CandidateHomeScreen extends StatefulWidget {
  const CandidateHomeScreen({super.key});

  @override
  State<CandidateHomeScreen> createState() => _CandidateHomeScreenState();
}

class _CandidateHomeScreenState extends State<CandidateHomeScreen> {
  // Couleurs principales utilisées dans l'UI.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);
  static const Color chipColor = Color(0xFF18233A);

  // URL de base vers l'API backend.
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  // Données des offres et version filtrée pour l'affichage.
  List<dynamic> allJobs = [];
  List<dynamic> filteredJobs = [];

  // États de chargement / erreur pour l'affichage.
  bool isLoading = true;
  String? errorMessage;

  // Contrôleur et état pour la recherche et le filtre sélectionné.
  final TextEditingController searchController = TextEditingController();
  int selectedFilterIndex = 0;
  int unreadNotificationsCount = 0;

  // Informations statiques et dynamiques de l'utilisateur.
  final String userName = "Candidate";
  final String userSubtitle = "Find your next role";
  String dynamicUserName = "";
  String? dynamicProfilePhoto;

  // Liste des filtres de recherche / catégories affichées à l'écran.
  final List<String> filters = [
    "All Jobs",
    "Remote",
    "Full-time",
    "Part-time",
    "Internship",
    "Design",
  ];

  @override
  void initState() {
    super.initState();
    // Au démarrage de l'écran, on charge les offres, le nombre de notifications,
    // les informations utilisateur et la photo de profil.
    fetchJobs();
    fetchUnreadNotificationsCount();
    fetchUserData();
    fetchProfilePhoto();
  }

  // Charge la liste des jobs depuis l'API et initialise l'état de l'écran.
  Future<void> fetchJobs() async {
    try {
      final response = await http
    .get(Uri.parse('$baseUrl/jobs'))
    .timeout(const Duration(seconds: 10));
    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        allJobs = data['jobs'] ?? [];
        filteredJobs = List.from(allJobs);

        setState(() {
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = data['message'] ?? 'Erreur lors du chargement des jobs';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Impossible de charger les jobs';
      });
    }
  }



  // Récupère les données du candidat connecté, notamment son nom affiché.
  Future<void> fetchUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
  

    if (token == null) return;

    final res = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
      
    );

    debugPrint(res.body);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      setState(() {
        dynamicUserName =
        data['user']['full_name'] ??
       data['user']['name'] ??
       data['user']['username'] ??
      "";
      });
    }
  } catch (e) {
    debugPrint("error user: $e");
  }

}




  // Charge la photo de profil du candidat pour l'afficher dans l'en-tête.
  Future<void> fetchProfilePhoto() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final res = await http.get(
      Uri.parse('$baseUrl/candidate-profile/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    debugPrint(res.body);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      setState(() {
        final photo = data['profile']?['profile_photo'];

      if (photo != null && photo.isNotEmpty) {
      dynamicProfilePhoto =
       "http://192.168.100.47:5000/" + photo;
}
      });
    }
  } catch (e) {
    debugPrint("error photo: $e");
  }
   
}




  Future<void> fetchUnreadNotificationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> notifications = data['notifications'] ?? [];

        final unread = notifications.where((item) {
          final value = item['is_read'];
          return value == false || value == 0 || value == null;
        }).length;

        setState(() {
          unreadNotificationsCount = unread;
        });
      }
    } catch (_) {}
  }

  // Applique un filtre à la liste des jobs selon l'onglet sélectionné.
  void applyFilter(int index) {
    final selected = filters[index].toLowerCase();

    List<dynamic> result = List.from(allJobs);

    if (selected == "remote") {
      result = allJobs.where((job) {
        return (job['work_mode'] ?? '').toString().toLowerCase() == 'remote';
      }).toList();
    } else if (selected == "full-time") {
      result = allJobs.where((job) {
        return (job['type'] ?? '').toString().toLowerCase() == 'full-time';
      }).toList();
    } else if (selected == "part-time") {
      result = allJobs.where((job) {
        return (job['type'] ?? '').toString().toLowerCase() == 'part-time';
      }).toList();
    } else if (selected == "internship") {
      result = allJobs.where((job) {
        return (job['type'] ?? '').toString().toLowerCase() == 'internship';
      }).toList();
    } else if (selected == "design") {
      result = allJobs.where((job) {
        return (job['category'] ?? '').toString().toLowerCase() == 'design';
      }).toList();
    }

    final query = searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((job) {
        final title = (job['title'] ?? '').toString().toLowerCase();
        final company = (job['company_name'] ?? '').toString().toLowerCase();
        final location = (job['location'] ?? '').toString().toLowerCase();
        final category = (job['category'] ?? '').toString().toLowerCase();

        return title.contains(query) ||
            company.contains(query) ||
            location.contains(query) ||
            category.contains(query);
      }).toList();
    }

    setState(() {
      selectedFilterIndex = index;
      filteredJobs = result;
    });
  }

  // Applique la recherche textuelle sur la liste de jobs déjà filtrée.
  void applySearch(String query) {
    final lowerQuery = query.toLowerCase().trim();
    final selected = filters[selectedFilterIndex].toLowerCase();

    List<dynamic> result = List.from(allJobs);

    if (selected == "remote") {
      result = allJobs.where((job) {
        return (job['work_mode'] ?? '').toString().toLowerCase() == 'remote';
      }).toList();
    } else if (selected == "full-time") {
      result = allJobs.where((job) {
        return (job['type'] ?? '').toString().toLowerCase() == 'full-time';
      }).toList();
    } else if (selected == "part-time") {
      result = allJobs.where((job) {
        return (job['type'] ?? '').toString().toLowerCase() == 'part-time';
      }).toList();
    } else if (selected == "internship") {
      result = allJobs.where((job) {
        return (job['type'] ?? '').toString().toLowerCase() == 'internship';
      }).toList();
    } else if (selected == "design") {
      result = allJobs.where((job) {
        return (job['category'] ?? '').toString().toLowerCase() == 'design';
      }).toList();
    }

    if (lowerQuery.isNotEmpty) {
      result = result.where((job) {
        final title = (job['title'] ?? '').toString().toLowerCase();
        final company = (job['company_name'] ?? '').toString().toLowerCase();
        final location = (job['location'] ?? '').toString().toLowerCase();
        final category = (job['category'] ?? '').toString().toLowerCase();

        return title.contains(lowerQuery) ||
            company.contains(lowerQuery) ||
            location.contains(lowerQuery) ||
            category.contains(lowerQuery);
      }).toList();
    }

    setState(() {
      filteredJobs = result;
    });
  }

  // Nettoie les ressources à la fermeture de l'écran.
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Affiche un message lorsque le bouton de filtres avancés est cliqué.
  void openFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Advanced Filters bientôt disponible"),
      ),
    );
  }

  // Ouvre l'écran des notifications et met à jour le badge au retour.
  Future<void> openNotifications() async {
    final result = await Navigator.pushNamed(context, '/notifications');

    if (result == true) {
      await fetchUnreadNotificationsCount();
    }
  }

  // Ouvre l'écran de détail d'une offre en passant les informations nécessaires.
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
        'work_mode': job['work_mode'] ?? 'Not specified',
        'category': job['category'] ?? 'General',
        'description': job['description'] ?? 'No description available',
        'requirements': job['requirements'] ?? [],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construction du layout principal de l'écran candidat.
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
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildSearchRow(),
                      const SizedBox(height: 18),
                      _buildFilters(),
                      const SizedBox(height: 28),
                      _buildSectionHeader(
                        title: "Available Jobs",
                        onSeeAll: () {
                          searchController.clear();
                          applyFilter(0);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildJobsContent(),
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

  // Contenu principal des jobs : affichage du chargement, des erreurs ou des offres.
  Widget _buildJobsContent() {
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
                fetchJobs();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (filteredJobs.isEmpty) {
      return _buildEmptyState("No jobs available for this category");
    }

    return Column(
      children: filteredJobs.map((job) {
        final String type = (job["type"] ?? "").toString();
        final String workMode = (job["work_mode"] ?? "").toString();
        final String category = (job["category"] ?? "").toString();

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => openJobDetails(job),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
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
                          job["title"] ?? "",
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
                          "${job["company_name"] ?? ""} • ${job["location"] ?? ""}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job["salary"]?.toString() ?? "",
                          style: const TextStyle(
                            color: primaryBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (type.isNotEmpty) _buildTag(type),
                            if (workMode.isNotEmpty) _buildTag(workMode),
                            if (category.isNotEmpty) _buildTag(category),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.65),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Étiquette utilisée pour afficher le type, le mode de travail ou la catégorie.
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // En-tête de l'écran avec l'avatar, le nom de l'utilisateur et les notifications.
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: dynamicProfilePhoto != null && dynamicProfilePhoto!.isNotEmpty
    ? ClipOval(
        child: Image.network(
          dynamicProfilePhoto!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      )
    : const Icon(
        Icons.person,
        color: Colors.white,
        size: 28,
      ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Salut, ${dynamicUserName.isNotEmpty ? dynamicUserName : userName} 👋",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userSubtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: openNotifications,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 25,
                ),
                if (unreadNotificationsCount > 0)
                  Positioned(
                    top: 10,
                    right: 8,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unreadNotificationsCount > 9
                              ? '9+'
                              : unreadNotificationsCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
      ],
    );
  }

  // Ligne de recherche avec champ de texte et bouton de filtres.
  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: applySearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search jobs in Algiers, Oran...",
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
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: openFilters,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.25),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  // Liste horizontale des filtres de job que l'utilisateur peut sélectionner.
  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final bool isSelected = selectedFilterIndex == index;

          return GestureDetector(
            onTap: () => applyFilter(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : chipColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? primaryBlue
                      : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Titre de section avec un bouton 'See all' pour réinitialiser les filtres.
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            "See all",
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // Affiche un état vide lorsque aucune offre n'est disponible.
  Widget _buildEmptyState(String text) {
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
          Icon(
            Icons.work_outline_rounded,
            color: Colors.white.withOpacity(0.45),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}