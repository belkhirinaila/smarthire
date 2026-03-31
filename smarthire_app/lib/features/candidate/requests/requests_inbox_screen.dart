import 'package:flutter/material.dart';

class RequestsInboxScreen extends StatefulWidget {
  const RequestsInboxScreen({super.key});

  @override
  State<RequestsInboxScreen> createState() => _RequestsInboxScreenState();
}

class _RequestsInboxScreenState extends State<RequestsInboxScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  /// ==============================
  /// Contrôleur de recherche
  /// ==============================
  final TextEditingController searchController = TextEditingController();

  /// ==============================
  /// Filtre sélectionné
  /// ==============================
  int selectedTabIndex = 0;

  /// ==============================
  /// Onglets de filtre
  /// ==============================
  final List<String> tabs = [
    "All",
    "Unread",
    "Invites",
    "Archived",
  ];

  /// ==============================
  /// Liste temporaire des requests
  /// Plus tard: viendra du backend
  /// ==============================
  final List<Map<String, dynamic>> requests = [
    {
      "company": "Company name",
      "title": "Interview invitation",
      "subtitle": "We would like to discuss an opportunity with you.",
      "time": "2 min ago",
      "isUnread": true,
      "type": "INVITE",
      "color": const Color(0xFF22C55E),
    },
    {
      "company": "Company name",
      "title": "Profile request",
      "subtitle": "A recruiter wants to view more details about your profile.",
      "time": "1 hour ago",
      "isUnread": true,
      "type": "REQUEST",
      "color": const Color(0xFF1E6CFF),
    },
    {
      "company": "Company name",
      "title": "Conversation request",
      "subtitle": "A recruiter is interested in contacting you directly.",
      "time": "Yesterday",
      "isUnread": false,
      "type": "MESSAGE",
      "color": const Color(0xFFFFB020),
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// ==============================
  /// Ouvrir détails d'une request
  /// ==============================
  void openRequestDetails(Map<String, dynamic> request) {
    Navigator.pushNamed(
      context,
      '/request-decision',
      arguments: request,
    );
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

                      _buildRequestsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// ==============================
      /// Bottom navigation
      /// ==============================
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// ==============================
  /// Barre supérieure
  /// ==============================
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

  /// ==============================
  /// Barre de recherche
  /// ==============================
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

  /// ==============================
  /// Onglets horizontaux
  /// ==============================
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

  /// ==============================
  /// Liste des requests
  /// ==============================
  Widget _buildRequestsList() {
    if (requests.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: requests.map((request) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => openRequestDetails(request),
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
                  /// Avatar / logo entreprise
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
                      if (request["isUnread"] == true)
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

                  /// Contenu principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request["company"] ?? "",
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
                          request["title"] ?? "",
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
                          request["subtitle"] ?? "",
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
                              text: request["type"] ?? "",
                              color: request["color"] ?? primaryBlue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                request["time"] ?? "",
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

  /// ==============================
  /// Badge type
  /// ==============================
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

  /// ==============================
  /// Etat vide
  /// ==============================
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

  /// ==============================
  /// Bottom nav
  /// ==============================
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

  /// ==============================
  /// Item nav
  /// ==============================
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