import 'package:flutter/material.dart';
import 'recruiter_home.dart';
import 'jobs/recruiter_jobs_screen.dart';
import 'messages/recruiter_messages_screen.dart';
import 'company/company_profile_screen.dart';

class RecruiterMainScreen extends StatefulWidget {
  const RecruiterMainScreen({super.key});

  @override
  State<RecruiterMainScreen> createState() =>
      _RecruiterMainScreenState();
}

class _RecruiterMainScreenState extends State<RecruiterMainScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundBottom = Color(0xFF050A12);

  int currentIndex = 0;

  final List<Widget> screens = const [
    RecruiterHome(),
    RecruiterJobsScreen(),
    RecruiterMessagesScreen(),
    CompanyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBottom, // 🔥 يحبس الأبيض

      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: Container(
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

              _buildNavItem(0, Icons.dashboard, "Dashboard"),
              _buildNavItem(1, Icons.work_outline, "Jobs"),

              // 🔥 CENTER + BUTTON
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/create-job');
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),

              _buildNavItem(2, Icons.chat_bubble_outline, "Messages"),
              _buildNavItem(3, Icons.person_outline, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  // ================= NAV ITEM =================
  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (currentIndex == index) return;

        setState(() {
          currentIndex = index;
        });
      },
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