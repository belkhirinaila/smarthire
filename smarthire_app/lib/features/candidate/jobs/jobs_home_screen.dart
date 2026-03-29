import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';

class JobsHomeScreen extends StatefulWidget {
  const JobsHomeScreen({super.key});

  @override
  State<JobsHomeScreen> createState() => JobsHomeScreenState();
}

// ignore: camel_case_types
class JobsHomeScreenState extends State<JobsHomeScreen> {
  int selectedBottomNav = 0;
  int selectedFilterIndex = 0;

  final List<String> filters = ['All Jobs', 'Remote', 'Full-time', 'Design'];

  final List<Map<String, dynamic>> recommendedJobs = [
    {
      "title": "Senior UX Designer",
      "company": "Yassir",
      "location": "Algiers, DZ",
      "type": "FULL-TIME",
      "badge": "TOP RATED",
      "salary": "250k - 350k DA",
      "time": "2 hours ago",
    },
    {
      "title": "Product Designer",
      "company": "Ooredoo",
      "location": "Algiers, DZ",
      "type": "REMOTE",
      "badge": "DESIGN",
      "salary": "180k - 240k DA",
      "time": "4 hours ago",
    },
  ];

  final List<Map<String, dynamic>> recentJobs = [
    {
      "title": "Backend Developer (Go)",
      "company": "Sonatrach Tech",
      "location": "Oran, DZ",
      "type": "FULL-TIME",
      "salary": "140k DA",
      "time": "1 day ago",
    },
    {
      "title": "Marketing Lead",
      "company": "Jumia DZ",
      "location": "Algiers, DZ",
      "type": "ON-SITE",
      "salary": "90k DA",
      "time": "3 days ago",
    },
    {
      "title": "Mobile App Developer",
      "company": "SmartHire Studio",
      "location": "Sétif, DZ",
      "type": "FREELANCE",
      "salary": "Project-based",
      "time": "5 days ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildSearchSection(),
              const SizedBox(height: 16),
              _buildFilterRow(),
              const SizedBox(height: 30),
              _buildSectionHeader("Recommended for You", "See all"),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedJobs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    return _buildRecommendedCard(recommendedJobs[index]);
                  },
                ),
              ),
              const SizedBox(height: 28),
              _buildSectionHeader("Recent Jobs", null),
              const SizedBox(height: 16),
              ...recentJobs.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildRecentJobCard(job),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 23,
          backgroundColor: Color(0xFF1A2234),
          backgroundImage: AssetImage('assets/images/profile.png'),
          onBackgroundImageError: null,
          child: Icon(Icons.person, color: Colors.white70),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sahit, Ahmed 👋',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Find your next role',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF131C2D),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            Positioned(
              top: 11,
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
        )
      ],
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF141E31),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search jobs in Algiers, Oran...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x552F80FF),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilterIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFF141E31),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Text(
                    filters[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (index != 0) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? action) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          Text(
            action,
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedCard(Map<String, dynamic> job) {
    return Container(
      width: 255,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141D2F),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2438),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white24,
                  size: 24,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.bookmark_border_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
          const Spacer(),
          Text(
            job["title"],
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${job["company"]} • ${job["location"]}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _smallTag(
                job["type"],
                bg: const Color(0xFF0E2C6F),
                fg: const Color(0xFF2E7DFF),
              ),
              const SizedBox(width: 8),
              _smallTag(
                job["badge"],
                bg: const Color(0xFF143324),
                fg: const Color(0xFF20C77B),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  job["salary"],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                job["time"],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentJobCard(Map<String, dynamic> job) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141D2F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2438),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.business, color: Colors.white24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job["title"],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job["company"]} • ${job["location"]}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      job["type"],
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      job["time"],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.more_horiz, color: Colors.white60, size: 20),
              const SizedBox(height: 18),
              Text(
                job["salary"],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _smallTag(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 86,
      padding: const EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0A1324),
        border: Border(
          top: BorderSide(color: Color(0xFF1B2638), width: 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.work_outline_rounded, "Jobs", 0),
          _navItem(Icons.bookmark_border_rounded, "Saved", 1),
          _centerAddButton(),
          _navItem(Icons.assignment_outlined, "Applied", 2),
          _navItem(Icons.person_outline_rounded, "Profile", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = selectedBottomNav == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBottomNav = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerAddButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x662F80FF),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }
}