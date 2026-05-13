import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

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

  void _addMessage(Map message) {
    setState(() {
      messages.add(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _deleteMessageForMe(dynamic id) {
    setState(() {
      messages.removeWhere((m) => _parseMessageId(m["id"]) == _parseMessageId(id));
    });
  }

  Future<void> _deleteMessageForEveryone(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final messageId = _parseMessageId(id);
    if (messageId == null) return;

    final res = await http.delete(
      Uri.parse("https://smarthire-fpa1.onrender.com/api/messages/$messageId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      _deleteMessageForMe(messageId);
    } else {
      debugPrint("DELETE MESSAGE ERROR: ${res.statusCode} ${res.body}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de supprimer le message.")),
        );
      }
    }
  }

  void _showMessageActions(Map msg, bool isMe) {
    final messageId = msg["id"];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101822),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.white),
                title: const Text("Delete for me", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessageForMe(messageId);
                },
              ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.white),
                  title: const Text("Delete for everyone", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessageForEveryone(messageId);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ================= LOAD USER =================
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    final int? storedUserId = prefs.getInt("userId");
    final String? storedUserIdString = prefs.getString("user_id") ?? prefs.getString("userId");

    if (storedUserId != null) {
      myId = storedUserId;
    } else {
      myId = int.tryParse(storedUserIdString ?? '') ?? 0;
    }

    debugPrint("LOADED myId: $myId (userId=$storedUserId, user_id=$storedUserIdString)");
  }

  int? _parseSenderId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  // ================= FETCH =================
  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("https://smarthire-fpa1.onrender.com/api/messages/$conversationId"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      messages = List.from(data["messages"] ?? []);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animate: false));
  }

  // ================= SEND =================
  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final text = controller.text;
    controller.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final int tempId = DateTime.now().millisecondsSinceEpoch * -1;
    final tempMessage = {
      "id": tempId,
      "message": text,
      "sender_id": myId,
      "conversation_id": conversationId,
      "created_at": DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(tempMessage);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    final res = await http.post(
      Uri.parse("https://smarthire-fpa1.onrender.com/api/messages"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "conversation_id": conversationId,
        "message": text
      }),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final serverMessageId = _parseMessageId(data["messageId"]);
      if (serverMessageId != null) {
        setState(() {
          final index = messages.indexWhere((m) => _parseMessageId(m["id"]) == tempId);
          if (index != -1) {
            messages[index]["id"] = serverMessageId;
          }
        });
      }
    } else {
      debugPrint("SEND MESSAGE ERROR: ${res.statusCode} ${res.body}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message non envoyé. Réessayez.")),
        );
      }
    }
  }

  // ================= INIT =================
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

      socket = IO.io("https://smarthire-fpa1.onrender.com", {
        "transports": ["websocket"],
        "autoConnect": true,
      });

      socket.emit("joinConversation", conversationId);

      socket.on("newMessage", (data) {
        if (data["conversation_id"] == conversationId) {
          final int? senderId = _parseSenderId(data["sender_id"]);
          if (senderId != null && senderId == myId) return;

          final int? messageId = _parseMessageId(data["id"]);
          final bool exists = messageId != null && messages.any((m) => _parseMessageId(m["id"]) == messageId);

          if (!exists) {
            setState(() {
              messages.add(data);
            });
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          }
        }
      });

      socket.on("deleteMessage", (data) {
        final int? messageId = _parseMessageId(data["id"]);
        if (messageId == null) return;
        setState(() {
          messages.removeWhere((m) => _parseMessageId(m["id"]) == messageId);
        });
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: isLoaded == false
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // ===== HEADER =====
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

                // ===== MESSAGES =====
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (c, i) {
                      final msg = messages[i];
                      final int? senderId = _parseSenderId(msg["sender_id"]);
                      final bool isMe = senderId != null && senderId == myId;
                      final String time = _formatTime(msg["created_at"]);

                      debugPrint("MY ID: $myId, sender_id raw: ${msg["sender_id"]}, sender_id parsed: $senderId");

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: () => _showMessageActions(msg, isMe),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 250),
                            decoration: BoxDecoration(
                              color: isMe ? myColor : otherColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg["message"] ?? "",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                if (time.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ===== INPUT =====
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