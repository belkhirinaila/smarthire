import 'package:flutter/material.dart';

class CandidateHomeScreen extends StatefulWidget {
  const CandidateHomeScreen({super.key});

  @override
  State<CandidateHomeScreen> createState() => _CandidateHomeScreenState();
}

class _CandidateHomeScreenState extends State<CandidateHomeScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);
  static const Color chipColor = Color(0xFF18233A);

  final TextEditingController searchController = TextEditingController();
  int selectedFilterIndex = 0;

  final String userName = "Candidate";
  final String userSubtitle = "Find your next role";

  final List<Map<String, dynamic>> recommendedJobs = [
    {
      "title": "Job title",
      "company": "Company name",
      "location": "Location",
      "type": "FULL-TIME",
      "tag": "TOP MATCH",
      "salary": "Salary",
      "time": "Recently",
      "logo": null,
    },
    {
      "title": "Job title",
      "company": "Company name",
      "location": "Location",
      "type": "REMOTE",
      "tag": "NEW",
      "salary": "Salary",
      "time": "Recently",
      "logo": null,
    },
  ];

  final List<Map<String, dynamic>> recentJobs = [
    {
      "title": "Job title",
      "company": "Company name",
      "location": "Location",
      "type": "FULL-TIME",
      "salary": "Salary",
      "time": "Recently",
      "logo": null,
    },
    {
      "title": "Job title",
      "company": "Company name",
      "location": "Location",
      "type": "ON-SITE",
      "salary": "Salary",
      "time": "Recently",
      "logo": null,
    },
    {
      "title": "Job title",
      "company": "Company name",
      "location": "Location",
      "type": "FREELANCE",
      "salary": "Salary",
      "time": "Recently",
      "logo": null,
    },
  ];

  final List<String> filters = [
    "All Jobs",
    "Remote",
    "Full-time",
    "Design",
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Advanced Filters bientôt disponible"),
      ),
    );
  }

  void openJobDetails(Map<String, dynamic> job) {
    Navigator.pushNamed(
      context,
      '/job-details',
      arguments: job,
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
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildSearchRow(),
                      const SizedBox(height: 18),
                      _buildFilters(),
                      const SizedBox(height: 28),
                      _buildSectionHeader(
                        title: "Recommended for You",
                        onSeeAll: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildRecommendedJobs(),
                      const SizedBox(height: 30),
                      const Text(
                        "Recent Jobs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecentJobs(),
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
          child: const Icon(
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
                "Salut, $userName 👋",
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
        Container(
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
              Positioned(
                top: 13,
                right: 13,
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
        ),
      ],
    );
  }

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
            onTap: () {
              setState(() {
                selectedFilterIndex = index;
              });
            },
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
              child: Row(
                children: [
                  Text(
                    filters[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (index != 0) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withOpacity(0.85),
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildRecommendedJobs() {
    if (recommendedJobs.isEmpty) {
      return _buildEmptyState("No recommended jobs available yet");
    }

    return SizedBox(
      height: 255,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recommendedJobs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final job = recommendedJobs[index];

          return GestureDetector(
            onTap: () => openJobDetails(job),
            child: Container(
              width: 290,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: Colors.white54,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.bookmark_border_rounded,
                        color: Colors.white.withOpacity(0.75),
                        size: 26,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    job["title"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${job["company"] ?? ""} • ${job["location"] ?? ""}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(
                        text: job["type"] ?? "",
                        background: primaryBlue.withOpacity(0.16),
                        textColor: primaryBlue,
                      ),
                      _buildTag(
                        text: job["tag"] ?? "",
                        background: const Color(0xFF0D3A2A),
                        textColor: const Color(0xFF22C55E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job["salary"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        job["time"] ?? "",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentJobs() {
    if (recentJobs.isEmpty) {
      return _buildEmptyState("No recent jobs available yet");
    }

    return Column(
      children: recentJobs.map((job) {
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
                          "${job["company"] ?? ""} • ${job["location"] ?? ""}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              job["type"] ?? "",
                              style: const TextStyle(
                                color: primaryBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                job["time"] ?? "",
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
                      Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.white.withOpacity(0.65),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        job["salary"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
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

  Widget _buildTag({
    required String text,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

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