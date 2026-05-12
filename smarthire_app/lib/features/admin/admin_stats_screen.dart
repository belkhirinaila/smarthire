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
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  static const Color bg = Color(0xFF081015);
  static const Color card = Color(0xFF162332);
  static const Color blue = Color(0xFF1E6CFF);

  Map<String, dynamic>? stats;
  List chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> loadAll() async {
    setState(() => isLoading = true);
    await loadStats();
    await loadChart();

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> loadStats() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/admin-dashboard/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      stats = jsonDecode(res.body);
    }
  }

  Future<void> loadChart() async {
    final token = await getToken();

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
      return const Center(
        child: CircularProgressIndicator(color: blue),
      );
    }

    return Container(
      color: bg,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.people_alt_rounded,
                        iconColor: Colors.blue,
                        title: "ACTIVE USERS",
                        value: stats?['users'] ?? 0,
                        badge: "+5.2%",
                        badgeColor: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _statCard(
                        icon: Icons.verified_rounded,
                        iconColor: Colors.orange,
                        title: "COMPANIES",
                        value: stats?['companies'] ?? 0,
                        badge: "URGENT",
                        badgeColor: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.work_rounded,
                        iconColor: Colors.green,
                        title: "LIVE JOBS",
                        value: stats?['jobs'] ?? 0,
                        badge: "+2.1%",
                        badgeColor: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _statCard(
                        icon: Icons.report_problem_rounded,
                        iconColor: Colors.pinkAccent,
                        title: "REPORTS",
                        value: 0,
                        badge: "-10%",
                        badgeColor: Colors.pinkAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _growthCard(),

                const SizedBox(height: 24),

                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        "Recent Critical Alerts",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "View All",
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _alertCard(
                  color: Colors.orange,
                  icon: Icons.business_center_rounded,
                  title: "Verification: Company",
                  subtitle: "New enterprise registration",
                  time: "2m",
                ),
                _alertCard(
                  color: Colors.pinkAccent,
                  icon: Icons.gavel_rounded,
                  title: "Report: High volume",
                  subtitle: "Job listing received reports",
                  time: "15m",
                ),
                _alertCard(
                  color: Colors.blue,
                  icon: Icons.storage_rounded,
                  title: "Latency: SmartHire DZ",
                  subtitle: "System activity checked",
                  time: "1h",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: blue.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SmartHire DZ",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Admin Overview",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        _circleIcon(Icons.notifications_rounded),

        const SizedBox(width: 10),

        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, color: Colors.white70, size: 23)),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required dynamic value,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const Spacer(),
              Flexible(
                child: Text(
                  badge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthCard() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PLATFORM GROWTH",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Text(
                "+15%",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: blue,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const Spacer(),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: blue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "2026",
                  style: TextStyle(
                    color: blue,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            "Last 30 days  +${stats?['users'] ?? 0} users",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (_) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.08),
                      strokeWidth: 1,
                      dashArray: [6, 6],
                    );
                  },
                  getDrawingVerticalLine: (_) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.08),
                      strokeWidth: 1,
                      dashArray: [6, 6],
                    );
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots(),
                    isCurved: true,
                    color: blue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: blue.withOpacity(0.18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          
        ],
      ),
    );
  }

  List<FlSpot> _spots() {
    if (chartData.isEmpty) {
      return const [
        FlSpot(0, 2),
        FlSpot(1, 3),
        FlSpot(2, 4),
        FlSpot(3, 3),
        FlSpot(4, 5),
        FlSpot(5, 4),
      ];
    }

    return List.generate(chartData.length, (i) {
      final count = chartData[i]['count'];
      return FlSpot(i.toDouble(), double.parse(count.toString()));
    });
  }

  Widget _alertCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 76,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 76,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
            ),
          ),

          const SizedBox(width: 12),

          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.20),
            child: Icon(icon, color: color, size: 21),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white38,
            size: 14,
          ),

          const SizedBox(width: 12),
        ],
      ),
    );
  }
}