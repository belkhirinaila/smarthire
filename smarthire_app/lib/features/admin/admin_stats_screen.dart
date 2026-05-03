import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {

  /// 🎨 COLORS (نفس app)
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  Map<String, dynamic>? stats;
  List chartData = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    await loadStats();
    await loadChart();
    setState(() => isLoading = false);
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse('$baseUrl/admin-dashboard/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      stats = jsonDecode(res.body);
    }
  }

  Future<void> loadChart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse('$baseUrl/admin-dashboard/users-per-day'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      chartData = jsonDecode(res.body);
    }
  }

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
            onRefresh: loadAll,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 🔥 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SmartHire DZ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text("Admin Overview",
                              style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(Icons.notifications, color: Colors.white),
                          SizedBox(width: 10),
                          CircleAvatar(
                            backgroundColor: primaryBlue,
                            child: Icon(Icons.person, color: Colors.white),
                          )
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 CARDS
                  Row(
                    children: [
                      Expanded(child: _card("ACTIVE USERS", stats?['users'], Icons.people, Colors.blue)),
                      const SizedBox(width: 10),
                      Expanded(child: _card("PENDING", stats?['companies'], Icons.verified, Colors.orange)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(child: _card("LIVE JOBS", stats?['jobs'], Icons.work, Colors.green)),
                      const SizedBox(width: 10),
                      Expanded(child: _card("REPORTS", "0", Icons.warning, Colors.red)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 GRAPH
                  _graph(),

                  const SizedBox(height: 20),

                  /// 🔥 ALERTS (static دكا)
                  _alert("Verification: Sonatrach Spa", "Urgent: New enterprise registration...", Colors.orange),
                  _alert("Report: High volume", "Spam detected in job...", Colors.red),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= CARD =================
  Widget _card(String title, dynamic value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 5),
          Text(
            value?.toString() ?? "0",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// ================= GRAPH =================
  Widget _graph() {
    if (chartData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
      );
    }

    List<FlSpot> spots = [];

    for (int i = 0; i < chartData.length; i++) {
      spots.add(FlSpot(i.toDouble(), chartData[i]['count'].toDouble()));
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: primaryBlue,
              barWidth: 3,
              dotData: FlDotData(show: false),
            )
          ],
        ),
      ),
    );
  }

  /// ================= ALERT =================
  Widget _alert(String title, String sub, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, child: const Icon(Icons.warning)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white)),
                Text(sub, style: const TextStyle(color: Colors.white54)),
              ],
            ),
          )
        ],
      ),
    );
  }
}