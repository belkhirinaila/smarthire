import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RecruiterHome extends StatefulWidget {
  const RecruiterHome({super.key});

  @override
  State<RecruiterHome> createState() => _RecruiterHomeState();
}

class _RecruiterHomeState extends State<RecruiterHome> {

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  Map<String, dynamic>? stats;
  List recentApplicants = [];
  List chartData = [];

  String companyName = "";
  String companyLogo = "";

  bool isLoading = true;

  int unreadCount = 0;
  late IO.Socket socket;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    loadDashboard();
    fetchUnread();
    initSocket();
  }

  // ================= SOCKET =================
  void initSocket() {
    socket = IO.io(
      "http://192.168.100.47:5000",
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.connect();

    socket.onConnect((_) async {
      print("🟢 SOCKET CONNECTED");

      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt("userId") ?? 0;

      socket.emit("joinUser", userId);
      print("👤 Joined room: $userId");
    });

    // 🔥 realtime badge
    socket.on("newNotification", (data) {
      setState(() {
        unreadCount++;
      });
    });
  }

  // ================= UNREAD =================
  Future<void> fetchUnread() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/notifications/unread-count"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      unreadCount = data["count"];
    });
  }

  // ================= DASHBOARD =================
  Future<void> loadDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.get(
        Uri.parse('$baseUrl/recruiter/dashboard'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        setState(() {
          stats = data['stats'];
          recentApplicants = data['recentApplicants'];
          chartData = data['chartData'];

          companyName = data['company']?['name'] ?? "";
          companyLogo = data['company']?['logo'] ?? "";

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await loadDashboard();
              await fetchUnread();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // ================= TOP BAR =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // 🔔 NOTIFICATIONS + BADGE
                      Stack(
                        children: [

                          GestureDetector(
                            onTap: () async {
                              await Navigator.pushNamed(context, '/notifications');
                              fetchUnread(); // 🔥 refresh after back
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: cardColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none, color: Colors.white),
                            ),
                          ),

                          if (unreadCount > 0)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$unreadCount",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // 🏢 NAME
                      Expanded(
                        child: Text(
                          companyName.isEmpty ? "My Company" : companyName,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // 🏢 LOGO
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: companyLogo.isNotEmpty
                              ? Image.network(
                                  "http://192.168.100.47:5000/$companyLogo",
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey,
                                  child: const Icon(Icons.business, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= STATS =================
                  Row(
                    children: [
                      Expanded(child: _stat("Applicants", stats?['totalApplicants'], Colors.orange)),
                      const SizedBox(width: 10),
                      Expanded(child: _stat("Jobs", stats?['activeJobs'], Colors.green)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(child: _stat("Pending", stats?['pending'], Colors.red)),
                      const SizedBox(width: 10),
                      Expanded(child: _stat("Interview", stats?['interviewing'], primaryBlue)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _chart(),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recent Applicants",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _applicants(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= STAT =================
  Widget _stat(String title, dynamic val, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(val?.toString() ?? "0",
              style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // ================= CHART =================
  Widget _chart() {
    if (chartData.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text("No activity yet", style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    List<FlSpot> applicants = [];
    List<FlSpot> jobs = [];

    for (int i = 0; i < chartData.length; i++) {
      applicants.add(FlSpot(i.toDouble(), (chartData[i]['applicants'] ?? 0).toDouble()));
      jobs.add(FlSpot(i.toDouble(), (chartData[i]['jobs'] ?? 0).toDouble()));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(spots: applicants, isCurved: true, color: primaryBlue),
            LineChartBarData(spots: jobs, isCurved: true, color: Colors.green),
          ],
        ),
      ),
    );
  }

  // ================= APPLICANTS =================
  Widget _applicants() {
    if (recentApplicants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("No applicants yet", style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      itemCount: recentApplicants.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        final item = recentApplicants[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['full_name'], style: const TextStyle(color: Colors.white)),
                    Text(item['status'], style: const TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
              Text(
                item['created_at'].toString().substring(0, 10),
                style: const TextStyle(color: Colors.white38),
              ),
            ],
          ),
        );
      },
    );
  }
}