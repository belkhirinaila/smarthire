import 'package:flutter/material.dart';
import 'package:smarthire_app/features/candidate/candidate_home_screen.dart';
import 'package:smarthire_app/features/candidate/applications/applications_list_screen.dart';
import 'package:smarthire_app/features/candidate/requests/messages_screen.dart';
import 'package:smarthire_app/features/candidate/profile/candidate_profile_screen.dart';

class CandidateMainScreen extends StatefulWidget {
  const CandidateMainScreen({super.key});

  @override
  State<CandidateMainScreen> createState() => _CandidateMainScreenState();
}

class _CandidateMainScreenState extends State<CandidateMainScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundBottom = Color(0xFF050A12);

  /// ==============================
  /// Index actif de la bottom navigation
  /// ==============================
  int currentIndex = 0;

  /// ==============================
  /// Ecrans principaux du candidate
  /// ==============================
  final List<Widget> screens = const [
    CandidateHomeScreen(),
    ApplicationsListScreen(),
    MessagesScreen(),
    CandidateProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBottom,
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
              _buildNavItem(
                index: 0,
                icon: Icons.travel_explore_rounded,
                label: "Explore",
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.description_outlined,
                label: "Applications",
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.chat_bubble_outline_rounded,
                label: "Messages",
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ==============================
  /// Item réutilisable de navigation
  /// ==============================
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
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