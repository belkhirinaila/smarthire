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

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundBottom = Color(0xFF081015);

  int currentIndex = 0;

  final List<Widget> screens = const [

    AdminStatsScreen(),
    AdminUsersScreen(),
    AdminJobsScreen(),
    AdminCompaniesScreen(),
    AdminConfigScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: backgroundBottom,

      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: SafeArea(
        child: Container(

          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 10),

          decoration: BoxDecoration(
            color: backgroundBottom,
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,

            children: [

              _navItem(
                0,
                Icons.dashboard_rounded,
                "Stats",
              ),

              _navItem(
                1,
                Icons.people_alt_rounded,
                "Users",
              ),

              _navItem(
                2,
                Icons.work_rounded,
                "Jobs",
              ),

              _navItem(
                3,
                Icons.business_rounded,
                "Companies",
              ),

              _navItem(
                4,
                Icons.settings_rounded,
                "Config",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String label,
  ) {

    final bool selected =
        currentIndex == index;

    return GestureDetector(

      onTap: () {

        setState(() {
          currentIndex = index;
        });
      },

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 220),

        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),

        decoration: BoxDecoration(

          color: selected
              ? primaryBlue.withOpacity(0.12)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,

              color: selected
                  ? primaryBlue
                  : Colors.white54,

              size: 24,
            ),

            const SizedBox(height: 4),

            Text(
              label,

              style: TextStyle(

                color: selected
                    ? primaryBlue
                    : Colors.white54,

                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}