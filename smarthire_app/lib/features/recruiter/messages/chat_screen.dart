import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final IO.Socket socket;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.socket,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List messages = [];
  TextEditingController controller = TextEditingController();

  int myId = 0;

  static const Color background = Color(0xFF050A12);
  static const Color myColor = Color(0xFF1E6CFF);
  static const Color otherColor = Color(0xFF121C31);

  // ================= LOAD USER =================
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    myId = prefs.getInt("userId") ?? 0;
  }

  // ================= FETCH =================
  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/messages/${widget.conversationId}"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      messages = data["messages"];
    });
  }

  // ================= SEND =================
  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.post(
      Uri.parse("http://192.168.100.47:5000/api/messages"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "conversation_id": widget.conversationId,
        "message": controller.text
      }),
    );

    controller.clear();
  }

  @override
  void initState() {
    super.initState();
    loadUser();
    fetchMessages();

    widget.socket.emit("joinConversation", widget.conversationId);

    widget.socket.on("newMessage", (data) {
      if (data["conversation_id"] == widget.conversationId) {
        setState(() {
          messages.add(data);
        });
      }
    });
  }

  @override
  void dispose() {
    widget.socket.off("newMessage");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: Column(
        children: [

          // ================= HEADER =================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
            child: Row(
              children: [

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: otherColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

                const SizedBox(width: 12),

                const Text(
                  "Chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ================= MESSAGES =================
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (c, i) {
                final msg = messages[i];

                bool isMe = msg["sender_id"] == myId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                      color: isMe ? myColor : otherColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight:
                            isMe ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg["message"] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // ================= INPUT =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Colors.black,
            child: Row(
              children: [

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: otherColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  decoration: const BoxDecoration(
                    color: myColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}