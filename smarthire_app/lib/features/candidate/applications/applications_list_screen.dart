import 'package:flutter/material.dart';

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

  int selectedTabIndex = 0;

  final List<String> tabs = [
    "All",
    "Active",
    "Interviewing",
    "Closed",
  ];

  final List<Map<String, dynamic>> applications = [
    {
      "title": "Job title",
      "company": "Company name",
      "location": "Location",
      "status": "INTERVIEW",
      "date": "Applied recently",
      "statusColor": const Color(0xFF1E6CFF),
    },
    {
      "title": "Job title",
      "company": "Company name",
      "location": "Location",
      "status": "UNDER REVIEW",
      "date": "Applied recently",
      "statusColor": const Color(0xFFFFB020),
    },
    {
      "title": "Job title",
      "company": "Company name",
      "location": "Location",
      "status": "REJECTED",
      "date": "Closed recently",
      "statusColor": const Color(0xFFFF5A6E),
    },
    {
      "title": "Job title",
      "company": "Company name",
      "location": "Location",
      "status": "ACTIVE",
      "date": "Applied recently",
      "statusColor": const Color(0xFF22C55E),
    },
  ];

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openApplicationDetails(Map<String, dynamic> application) {
    Navigator.pushNamed(
      context,
      '/application-details',
      arguments: application,
    );
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
                      _buildApplicationsList(),
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

  Widget _buildApplicationsList() {
    if (applications.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: applications.map((application) {
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
                          "${application["company"] ?? ""} • ${application["location"] ?? ""}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 15,
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
                                application["date"] ?? "",
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
                        text: application["status"] ?? "",
                        color: application["statusColor"] ?? primaryBlue,
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