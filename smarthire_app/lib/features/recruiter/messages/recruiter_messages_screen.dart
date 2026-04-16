import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RecruiterMessagesScreen extends StatefulWidget {
  const RecruiterMessagesScreen({super.key});

  @override
  State<RecruiterMessagesScreen> createState() =>
      _RecruiterMessagesScreenState();
}

class _RecruiterMessagesScreenState extends State<RecruiterMessagesScreen> {

  List conversations = [];
  bool isLoading = true;

  late IO.Socket socket;

  static const Color background = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  // ================= FETCH =================
  Future<void> fetchConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/messages/conversations"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      conversations = data["conversations"];
      isLoading = false;
    });
  }

  // ================= SOCKET =================
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
      print("🟢 SOCKET CONNECTED");

      // 🔥 IMPORTANT: join user room
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt("userId") ?? 0;

      socket.emit("joinUser", userId);

      print("👤 Joined user room: $userId");
    });
  }

  @override
  void initState() {
    super.initState();
    fetchConversations();
    initSocket();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Messages"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (c, i) {
                final conv = conversations[i];

                return GestureDetector(
                  onTap: () {

                    // 🔥 join chat room
                    socket.emit("joinConversation", conv["id"]);

                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        "conversationId": conv["id"],
                        "socket": socket,
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [

                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Candidate ${conv["candidate_id"]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Tap to open conversation",
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.white38),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}