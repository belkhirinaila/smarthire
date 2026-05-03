import 'package:flutter/material.dart';

import 'admin_stats_screen.dart';
import 'admin_users_screen.dart';
import 'admin_jobs_screen.dart';
import 'admin_companies_screen.dart';
import 'admin_config_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {

  /// 🎨 COLORS (نفس app)
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundBottom = Color(0xFF050A12);

  /// 🔢 index
  int currentIndex = 0;

  /// 📱 SCREENS (كاملين مربوطين)
  final List<Widget> screens = const [
    AdminStatsScreen(),       // 0
    AdminUsersScreen(),       // 1
    AdminJobsScreen(),        // 2
    AdminCompaniesScreen(),   // 3
    AdminConfigScreen(),      // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBottom,

      /// 🔥 نفس candidate
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      /// 🔥 NAVBAR PRO
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
                icon: Icons.dashboard,
                label: "Stats",
              ),

              _buildNavItem(
                index: 1,
                icon: Icons.people,
                label: "Users",
              ),

              _buildNavItem(
                index: 2,
                icon: Icons.work,
                label: "Jobs",
              ),

              _buildNavItem(
                index: 3,
                icon: Icons.business,
                label: "Companies",
              ),

              _buildNavItem(
                index: 4,
                icon: Icons.settings,
                label: "Config",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 NAV ITEM (نفس candidate EXACT)
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
            color: isSelected
                ? primaryBlue
                : Colors.white.withOpacity(0.65),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? primaryBlue
                  : Colors.white.withOpacity(0.65),
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}