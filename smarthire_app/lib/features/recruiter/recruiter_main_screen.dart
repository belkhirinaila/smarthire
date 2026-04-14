import 'package:flutter/material.dart';

// 📌 screens (نخلوهم empty دكا)
import 'recruiter_home.dart';
import 'jobs/recruiter_jobs_screen.dart';
import 'messages/recruiter_messages_screen.dart';
import 'company/company_profile_screen.dart';

class RecruiterMainScreen extends StatefulWidget {
  const RecruiterMainScreen({super.key});

  @override
  State<RecruiterMainScreen> createState() => _RecruiterMainScreenState();
}

class _RecruiterMainScreenState extends State<RecruiterMainScreen> {

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
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      // 🔥 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: "Jobs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: "Company",
          ),
        ],
      ),

      // ➕ Create Job
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-job');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}