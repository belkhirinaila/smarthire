import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CandidateChatScreen extends StatefulWidget {
  const CandidateChatScreen({super.key});

  @override
  State<CandidateChatScreen> createState() => _CandidateChatScreenState();
}

class _CandidateChatScreenState extends State<CandidateChatScreen> {
  static const String baseUrl = "http://192.168.100.47:5000/api";
  static const String socketUrl = "http://192.168.100.47:5000";
  static const String serverUrl = "http://192.168.100.47:5000";

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color bgTop = Color(0xFF08162D);
  static const Color bgBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  IO.Socket? socket;

  List messages = [];
  int myId = 0;
  int conversationId = 0;

  String title = "Chat";
  String subtitle = "";
  String? companyLogo;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initChat();
    });
  }

  String? fixImageUrl(dynamic value) {
    if (value == null) return null;

    final image = value.toString().trim();

    if (image.isEmpty || image == "null" || image == "NULL") {
      return null;
    }

    if (image.startsWith("http")) return image;
    if (image.startsWith("/")) return "$serverUrl$image";
    return "$serverUrl/$image";
  }

  Future<void> initChat() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    conversationId = int.tryParse(
          (args?["conversationId"] ?? args?["id"] ?? 0).toString(),
        ) ??
        0;

    title = args?["company"]?.toString() ?? "Chat";
    subtitle = args?["title"]?.toString() ?? "Direct Conversation";
    companyLogo = fixImageUrl(args?["company_logo"]);

    if (conversationId == 0) {
      setState(() {
        errorMessage = "Conversation introuvable";
        isLoading = false;
      });
      return;
    }

    await loadUser();
    await fetchMessages();
    connectSocket();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    myId = prefs.getInt("userId") ??
        int.tryParse(prefs.getString("user_id") ?? "0") ??
        0;
  }

  Future<void> fetchMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.get(
        Uri.parse("$baseUrl/messages/$conversationId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        messages = List.from(data["messages"] ?? []);

        if (data["conversation"] != null && companyLogo == null) {
          companyLogo = fixImageUrl(
            data["conversation"]["company_logo"] ??
                data["conversation"]["logo"] ??
                data["conversation"]["logo_url"],
          );
        }

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => scrollToBottom(animate: false),
        );
      } else {
        errorMessage = data["message"] ?? "Erreur chargement messages";
      }
    } catch (e) {
      errorMessage = "Erreur de connexion au serveur";
    }
  }

  void connectSocket() {
    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      socket!.emit("joinConversation", conversationId);
    });

    socket!.on("newMessage", (data) {
      final msgConversationId =
          int.tryParse(data["conversation_id"].toString()) ?? 0;

      if (msgConversationId != conversationId) return;

      final senderId = int.tryParse(data["sender_id"].toString()) ?? 0;

      if (senderId == myId) return;

      setState(() {
        messages.add(data);
      });

      WidgetsBinding.instance.addPostFrameCallback(
        (_) => scrollToBottom(),
      );
    });
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    controller.clear();

    final tempMessage = {
      "message": text,
      "sender_id": myId,
      "conversation_id": conversationId,
      "created_at": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(tempMessage);
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => scrollToBottom(),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final res = await http.post(
        Uri.parse("$baseUrl/messages"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "conversation_id": conversationId,
          "message": text,
        }),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        showMsg("Message not sent");
      }
    } catch (e) {
      showMsg("Erreur serveur");
    }
  }

  void scrollToBottom({bool animate = true}) {
    if (!scrollController.hasClients) return;

    final target = scrollController.position.maxScrollExtent;

    if (animate) {
      scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      scrollController.jumpTo(target);
    }
  }

  String formatTime(dynamic value) {
    if (value == null) return "";

    DateTime? date;

    if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(value.toString());
    }

    if (date == null) return "";

    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  void showMsg(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    socket?.dispose();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Widget headerLogo() {
    return ClipOval(
      child: Container(
        width: 44,
        height: 44,
        color: primaryBlue.withOpacity(0.18),
        child: companyLogo == null
            ? const Icon(
                Icons.business,
                color: primaryBlue,
              )
            : Image.network(
                companyLogo!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.business,
                    color: primaryBlue,
                  );
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: bgBottom,
        body: Center(
          child: CircularProgressIndicator(color: primaryBlue),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: bgBottom,
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Text(
                          "No messages yet",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];

                          final senderId =
                              int.tryParse(msg["sender_id"].toString()) ?? 0;

                          final bool isMe = senderId == myId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? primaryBlue : cardColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 18),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    msg["message"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    formatTime(msg["created_at"]),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              _inputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.65),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          headerLogo(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
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
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: bgBottom,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}