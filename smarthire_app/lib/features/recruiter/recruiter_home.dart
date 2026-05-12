import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:smarthire_app/route_observer.dart';

class RecruiterHome extends StatefulWidget {
  const RecruiterHome({super.key});

  @override
  State<RecruiterHome> createState() => _RecruiterHomeState();
}

class _RecruiterHomeState extends State<RecruiterHome> with RouteAware {
  static const String baseUrl = 'https://smarthire-1-xe6v.onrender.com/api';
  static const String serverUrl = 'https://smarthire-1-xe6v.onrender.com';

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

  @override
  void initState() {
    super.initState();
    loadDashboard();
    fetchUnread();
    initSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    socket.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    loadDashboard();
    fetchUnread();
  }

  String getImageUrl(dynamic path) {
    if (path == null) return "";
    final p = path.toString().trim();

    if (p.isEmpty || p == "null" || p == "NULL") return "";
    if (p.startsWith("http")) return p;
    if (p.startsWith("/")) return "$serverUrl$p";

    return "$serverUrl/$p";
  }

  bool isPublicProfile(dynamic value) {
    return value == 1 || value == true || value.toString() == "1";
  }

  Future<int> _getLoggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final int? storedInt = prefs.getInt("userId");
    if (storedInt != null) return storedInt;
    final String? storedString =
        prefs.getString("user_id") ?? prefs.getString("userId");
    return int.tryParse(storedString ?? '') ?? 0;
  }

  void initSocket() {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.connect();

    socket.onConnect((_) async {
      final int userId = await _getLoggedUserId();
      socket.emit("joinUser", userId);
    });

    socket.on("newNotification", (data) {
      setState(() {
        unreadCount++;
      });
    });

    socket.on("newApplication", (data) {
      loadDashboard();
    });

    socket.on("newJob", (data) {
      loadDashboard();
    });
  }

  Future<void> fetchUnread() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/notifications/unread-count"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      unreadCount = data["count"] ?? 0;
    });
  }

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
        final rawStats = Map<String, dynamic>.from(data['stats'] ?? {});
        final totalApplicants = rawStats['totalApplicants'] ?? 0;
        final activeJobs = rawStats['activeJobs'] ?? 0;

        rawStats['applicationsPerJob'] = activeJobs > 0
            ? (totalApplicants / activeJobs).toStringAsFixed(1)
            : "0.0";

        setState(() {
          stats = rawStats;
          recentApplicants = data['recentApplicants'] ?? [];
          chartData = data['chartData'] ?? [];
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

  void openApplicant(dynamic item) {
    Navigator.pushNamed(
      context,
      "/candidate-profile-recruiter",
      arguments: {
        "userId": item["candidate_id"] ?? item["user_id"],
      },
    );
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
            onRefresh: () async {
              await loadDashboard();
              await fetchUnread();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _topBar(),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                          child: _stat("Applicants",
                              stats?['totalApplicants'], Colors.orange)),
                      const SizedBox(width: 10),
                      Expanded(
                          child:
                              _stat("Jobs", stats?['activeJobs'], Colors.green)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _stat("Apps / Job",
                              stats?['applicationsPerJob'], Colors.blueAccent)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                          child:
                              _stat("Pending", stats?['pending'], Colors.red)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _stat(
                              "Interview", stats?['interviewing'], primaryBlue)),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _chart(),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    final logoUrl = getImageUrl(companyLogo);

    return Row(
      children: [
        ClipOval(
          child: Container(
            width: 46,
            height: 46,
            color: cardColor,
            child: logoUrl.isNotEmpty
                ? Image.network(
                    logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(Icons.business, color: Colors.white);
                    },
                  )
                : const Icon(Icons.business, color: Colors.white),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            companyName.isEmpty ? "My Company" : companyName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Stack(
          children: [
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, '/recruiter-notifications');
                fetchUnread();
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
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
      ],
    );
  }

  Widget _stat(String title, dynamic val, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            val?.toString() ?? "0",
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _chart() {
    if (chartData.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "No activity yet",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    List<FlSpot> applicants = [];
    List<FlSpot> jobs = [];

    for (int i = 0; i < chartData.length; i++) {
      applicants.add(
        FlSpot(i.toDouble(), (chartData[i]['applicants'] ?? 0).toDouble()),
      );
      jobs.add(
        FlSpot(i.toDouble(), (chartData[i]['jobs'] ?? 0).toDouble()),
      );
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
          lineTouchData: LineTouchData(enabled: false),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= chartData.length) {
                    return const SizedBox();
                  }

                  final label = chartData[index]['date']?.toString() ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label.length >= 5
                          ? label.substring(label.length - 5)
                          : label,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: applicants,
              isCurved: true,
              color: primaryBlue,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: jobs,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }


}