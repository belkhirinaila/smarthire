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
  static const String baseUrl = "https://smarthire-1-xe6v.onrender.com/api";
  static const String serverUrl = "https://smarthire-1-xe6v.onrender.com";

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  List conversations = [];
  bool isLoading = true;
  String? errorMessage;

  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    fetchConversations();
    initSocket();
  }

  String fileUrl(dynamic path) {
    if (path == null) return "";
    String p = path.toString().trim();
    if (p.isEmpty) return "";
    p = p.replaceAll("\\", "/");
    if (p.startsWith("http")) return p;
    return "$serverUrl/$p";
  }

  Future<void> fetchConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.get(
        Uri.parse("$baseUrl/messages/conversations"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);

      if (!mounted) return;

      if (res.statusCode == 200) {
        setState(() {
          conversations = data["conversations"] ?? [];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = data["message"] ?? "Erreur chargement messages";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  void initSocket() {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) async {
      final prefs = await SharedPreferences.getInstance();

      final int? storedInt = prefs.getInt("userId");
      final String? storedString =
          prefs.getString("user_id") ?? prefs.getString("userId");

      final int userId =
          storedInt ?? int.tryParse(storedString ?? "") ?? 0;

      socket!.emit("joinUser", userId);
    });
  }

  void openChat(dynamic conv) {
    socket?.emit("joinConversation", conv["id"]);

    Navigator.pushNamed(
      context,
      "/chat",
      arguments: {
        "conversationId": conv["id"],
        "socket": socket,
      },
    ).then((_) {
      fetchConversations();
    });
  }

  String formatDate(dynamic createdAt) {
    if (createdAt == null) return "Recently";

    final raw = createdAt.toString().replaceFirst("T", " ");

    if (raw.length >= 16) {
      return raw.substring(0, 16);
    }

    return raw;
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

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
          child: Column(
            children: [
              _header(),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryBlue,
                        ),
                      )
                    : errorMessage != null
                        ? _errorState()
                        : conversations.isEmpty
                            ? _emptyState()
                            : RefreshIndicator(
                                onRefresh: fetchConversations,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    10,
                                    18,
                                    24,
                                  ),
                                  itemCount: conversations.length,
                                  itemBuilder: (context, i) {
                                    final conv = conversations[i];

                                    final otherName =
                                        conv["other_user_name"]
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ==
                                                    true
                                                ? conv["other_user_name"]
                                                    .toString()
                                                : "Candidate";

                                    final photo = fileUrl(
                                      conv["profile_photo"] ??
                                          conv["candidate_photo"],
                                    );

                                    final unreadCount = int.tryParse(
                                          conv["unread_count"]?.toString() ??
                                              "0",
                                        ) ??
                                        0;

                                    return _chatCard(
                                      conv: conv,
                                      otherName: otherName,
                                      photo: photo,
                                      unreadCount: unreadCount,
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Row(
        children: [
          Spacer(),
          Text(
            "Messages",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _chatCard({
    required dynamic conv,
    required String otherName,
    required String photo,
    required int unreadCount,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => openChat(conv),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    backgroundImage:
                        photo.isNotEmpty ? NetworkImage(photo) : null,
                    child: photo.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.white54,
                            size: 28,
                          )
                        : null,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Direct Conversation",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Tap to open conversation",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.50),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatDate(conv["created_at"]),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.42),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white38,
                        size: 15,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (unreadCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: backgroundBottom,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 34,
              color: Colors.white.withOpacity(0.45),
            ),
            const SizedBox(height: 10),
            Text(
              "No chats available",
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                fetchConversations();
              },
              child: const Text("Réessayer"),
            ),
          ],
        ),
      ),
    );
  }
}