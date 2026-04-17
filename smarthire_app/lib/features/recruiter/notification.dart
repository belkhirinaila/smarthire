import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RecruiterNotificationsScreen extends StatefulWidget {
  const RecruiterNotificationsScreen({super.key});

  @override
  State<RecruiterNotificationsScreen> createState() =>
      _RecruiterNotificationsScreenState();
}

class _RecruiterNotificationsScreenState
    extends State<RecruiterNotificationsScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  List notifications = [];
  bool isLoading = true;

  late IO.Socket socket;

  // ================= SOCKET =================
  Future<int> _getLoggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final int? storedInt = prefs.getInt("userId");
    if (storedInt != null) return storedInt;
    final String? storedString = prefs.getString("user_id") ?? prefs.getString("userId");
    return int.tryParse(storedString ?? '') ?? 0;
  }

  void initSocket() {
    socket = IO.io(
      "http://192.168.100.47:5000",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) async {
      debugPrint("🟢 NOTIFICATION SOCKET CONNECTED");

      final int userId = await _getLoggedUserId();

      socket.emit("joinUser", userId);

      debugPrint("👤 Joined notification room: $userId");
    });

    // 🔥 realtime notification
    socket.on("newNotification", (data) {
      setState(() {
        notifications.insert(0, data);
      });
    });
  }

  // ================= TOKEN =================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ================= FETCH =================
  Future<void> fetchNotifications() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/notifications/me"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(res.body);

    setState(() {
      notifications = data["notifications"];
      isLoading = false;
    });
  }


  void handleNotificationTap(dynamic item) {
    final String type = item["type"]?.toString() ?? "";
    final int id = int.tryParse(item["related_id"]?.toString() ?? '') ?? 0;

    if (type == "message") {
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          "conversationId": id,
          "socket": socket,
        },
      );
    } else if (type == "request") {
      Navigator.pushNamed(context, '/requests');
    } else if (type == "job") {
      Navigator.pushNamed(
        context,
        '/job-details',
        arguments: {"jobId": id},
      );
    } else if (type == "application" && id > 0) {
      Navigator.pushNamed(
        context,
        '/candidate-profile-recruiter',
        arguments: {"userId": id},
      );
    }
  }

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    fetchNotifications();
    initSocket();
    markAllRead(); 
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

Future<void> markAllRead() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  await http.put(
    Uri.parse("http://192.168.100.47:5000/api/notifications/read-all/me"),
    headers: {"Authorization": "Bearer $token"},
  );
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= HEADER =================
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 24),

                // ================= LIST =================
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : notifications.isEmpty
                          ? const Center(
                              child: Text(
                                "No notifications",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: notifications.length,
                              itemBuilder: (c, i) {
                                final item = notifications[i];

                                return GestureDetector(
  onTap: () {
    handleNotificationTap(item);
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: item["is_read"] == 0
          ? cardColor.withOpacity(0.9)
          : cardColor.withOpacity(0.4),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [

        // ICON
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            item["type"] == "message"
                ? Icons.chat
                : item["type"] == "request"
                    ? Icons.person_add
                    : item["type"] == "application"
                        ? Icons.person_outline
                        : Icons.work,
            color: primaryBlue,
          ),
        ),

        const SizedBox(width: 12),

        // TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item["title"] ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item["message"] ?? "",
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}