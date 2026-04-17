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

  List messages = [];
  TextEditingController controller = TextEditingController();
  late ScrollController _scrollController;

  int myId = 0;
  int conversationId = 0;

  late IO.Socket socket;

  static const Color background = Color(0xFF050A12);
  static const Color myColor = Color(0xFF1E6CFF);
  static const Color otherColor = Color(0xFF121C31);

  bool isLoaded = false;

  int? _parseMessageId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int? _parseSenderId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  DateTime? _parseCreatedAt(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.tryParse(value.toString());
  }

  String _formatTime(dynamic value) {
    final dateTime = _parseCreatedAt(value);
    if (dateTime == null) return "";
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animate) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    myId = prefs.getInt("userId") ?? 0;
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/messages/$conversationId"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      messages = List.from(data["messages"] ?? []);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animate: false));
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final text = controller.text;
    controller.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final tempMessage = {
      "message": text,
      "sender_id": myId,
      "conversation_id": conversationId,
      "created_at": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(tempMessage);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    await http.post(
      Uri.parse("http://192.168.100.47:5000/api/messages"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "conversation_id": conversationId,
        "message": text
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      conversationId = args?["conversationId"] ?? 0;

      if (conversationId == 0) return;

      await loadUser();
      await fetchMessages();

      socket = IO.io("http://192.168.100.47:5000", {
        "transports": ["websocket"],
      });

      socket.emit("joinConversation", conversationId);

      socket.on("newMessage", (data) {
        if (data["conversation_id"] == conversationId) {
          final senderId = _parseSenderId(data["sender_id"]);
          if (senderId == myId) return;

          setState(() {
            messages.add(data);
          });

          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      });

      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    socket.dispose();
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: isLoaded == false
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Chat",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),

                // MESSAGES
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = _parseSenderId(msg["sender_id"]) == myId;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? myColor : otherColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg["message"] ?? "",
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                _formatTime(msg["created_at"]),
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // INPUT
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: "Message"),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: sendMessage,
                    )
                  ],
                )
              ],
            ),
    );
  }
}