import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'request_decision_screen.dart';

class RequestsInboxScreen extends StatefulWidget {
  const RequestsInboxScreen({super.key});

  @override
  State<RequestsInboxScreen> createState() => _RequestsInboxScreenState();
}

class _RequestsInboxScreenState extends State<RequestsInboxScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'https://smarthire-fpa1.onrender.com/api';
  static const String serverUrl = 'https://smarthire-fpa1.onrender.com';

  final TextEditingController searchController = TextEditingController();

  int selectedTabIndex = 0;

  final List<String> tabs = ["All", "Pending", "Approved", "Rejected"];

  List<dynamic> requests = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String? fixImageUrl(dynamic value) {
    if (value == null) return null;
    final image = value.toString().trim();

    if (image.isEmpty || image == "null" || image == "NULL") return null;
    if (image.startsWith("http")) return image;
    if (image.startsWith("/")) return "$serverUrl$image";

    return "$serverUrl/$image";
  }

  String? getCompanyLogo(dynamic request) {
    if (request == null) return null;

    final keys = [
      "company_logo",
      "logo",
      "logo_url",
      "companyLogo",
      "company_image",
      "image",
      "profile_image",
      "profile_photo",
      "photo",
    ];

    for (final key in keys) {
      final logo = fixImageUrl(request[key]);
      if (logo != null) return logo;
    }

    return null;
  }

  Widget companyLogoWidget(dynamic request, {double size = 58}) {
    final logo = getCompanyLogo(request);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size,
        height: size,
        color: Colors.white.withOpacity(0.06),
        child: logo == null
            ? const Icon(
                Icons.business_rounded,
                color: Colors.white54,
                size: 28,
              )
            : Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.business_rounded,
                    color: Colors.white54,
                    size: 28,
                  );
                },
              ),
      ),
    );
  }

  Future<void> fetchRequests() async {
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
        Uri.parse('$baseUrl/requests/received'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          requests = data['requests'] ?? [];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              data['message'] ?? "Erreur lors du chargement des requests";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

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
    final raw = createdAt.toString().replaceFirst('T', ' ');
    if (raw.length >= 16) return raw.substring(0, 16);
    return raw;
  }

  Map<String, dynamic> buildRequestArgs(dynamic request) {
    final status = (request["status"] ?? "pending").toString();

    final recruiterName =
        request["full_name"]?.toString().trim().isNotEmpty == true
            ? request["full_name"].toString()
            : request["recruiter_name"]?.toString().trim().isNotEmpty == true
                ? request["recruiter_name"].toString()
                : "Recruiter";

    final companyName =
        request["company_name"]?.toString().trim().isNotEmpty == true
            ? request["company_name"].toString()
            : "Company";

    return {
      "id": request["id"],
      "request_id": request["id"],
      "recruiter_id": request["recruiter_id"],
      "candidate_id": request["candidate_id"],
      "recruiter_name": recruiterName,
      "company": recruiterName,
      "company_name": companyName,
      "title": "Access Request",
      "subtitle": "$companyName wants to access your profile.",
      "description":
          "$recruiterName from $companyName sent you an access request through SmartHire.",
      "time": formatDate(request["created_at"]),
      "created_at": request["created_at"]?.toString(),
      "status": status,
      "type": status.toUpperCase(),
      "company_logo": getCompanyLogo(request),
      "logo": getCompanyLogo(request),
    };
  }

  void openRequestDetails(dynamic request) {
    final args = buildRequestArgs(request);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDecisionScreen(request: args),
      ),
    ).then((_) {
      fetchRequests();
    });
  }

  List<dynamic> get filteredRequests {
    List<dynamic> result = List.from(requests);

    final query = searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((request) {
        final recruiter = (request["full_name"] ?? "").toString().toLowerCase();
        final company =
            (request["company_name"] ?? "").toString().toLowerCase();
        final status = (request["status"] ?? "").toString().toLowerCase();

        return recruiter.contains(query) ||
            company.contains(query) ||
            status.contains(query);
      }).toList();
    }

    if (selectedTabIndex == 1) {
      result = result
          .where(
            (request) =>
                (request["status"] ?? "pending").toString().toLowerCase() ==
                "pending",
          )
          .toList();
    } else if (selectedTabIndex == 2) {
      result = result
          .where(
            (request) =>
                (request["status"] ?? "").toString().toLowerCase() ==
                "approved",
          )
          .toList();
    } else if (selectedTabIndex == 3) {
      result = result
          .where(
            (request) =>
                (request["status"] ?? "").toString().toLowerCase() ==
                "rejected",
          )
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(color: primaryBlue),
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
      return _buildEmptyState();
    }

    return Column(
      children: filteredRequests.map((request) {
        final status = (request["status"] ?? "pending").toString();
        final badgeColor = getStatusColor(status);

        final recruiterName =
            request["full_name"]?.toString().trim().isNotEmpty == true
                ? request["full_name"].toString()
                : "Recruiter";

        final companyName =
            request["company_name"]?.toString().trim().isNotEmpty == true
                ? request["company_name"].toString()
                : "Company";

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => openRequestDetails(request),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      companyLogoWidget(request, size: 58),
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
                          recruiterName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          companyName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Access Request",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "A recruiter wants to access your profile.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildTypeBadge(
                              text: status.toUpperCase(),
                              color: badgeColor,
                            ),
                            const Spacer(),
                            Text(
                              formatDate(request["created_at"]),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.35),
                    size: 28,
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
          "Requests Inbox",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
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