import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationsListScreen extends StatefulWidget {
  const ApplicationsListScreen({super.key});

  @override
  State<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends State<ApplicationsListScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  int selectedTabIndex = 0;

  final List<String> tabs = [
    "All",
    "Active",
    "Accepted",
    "Rejected",
  ];

  final TextEditingController searchController = TextEditingController();

  List<dynamic> applications = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchApplications() async {
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

      final response = await http.get(
        Uri.parse('$baseUrl/applications/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          applications = data['applications'] ?? [];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              data['message'] ?? "Erreur lors du chargement des candidatures";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  void openApplicationDetails(Map<String, dynamic> application) {
    Navigator.pushNamed(
      context,
      '/application-details',
      arguments: application,
    );
  }

  String formatDate(dynamic createdAt) {
    if (createdAt == null) return "Applied recently";

    final raw = createdAt.toString();
    if (raw.length >= 10) {
      return "Applied on ${raw.substring(0, 10)}";
    }
    return "Applied recently";
  }

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

  List<dynamic> get filteredApplications {
    List<dynamic> result = List.from(applications);

    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
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
      result = result
          .where((application) =>
              (application['status'] ?? '').toString().toLowerCase() ==
              'pending')
          .toList();
    } else if (selectedTabIndex == 2) {
      result = result
          .where((application) =>
              (application['status'] ?? '').toString().toLowerCase() ==
              'accepted')
          .toList();
    } else if (selectedTabIndex == 3) {
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