import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DirectChatThreadScreen extends StatefulWidget {
  const DirectChatThreadScreen({super.key});

  @override
  State<DirectChatThreadScreen> createState() => _DirectChatThreadScreenState();
}

class _DirectChatThreadScreenState extends State<DirectChatThreadScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color myMessageColor = Color(0xFF1E6CFF);
  static const Color otherMessageColor = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  final TextEditingController messageController = TextEditingController();

  List<dynamic> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  int? conversationId;
  String company = "Recruiter";
  String title = "Direct Chat";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => initializeConversation());
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> initializeConversation() async {
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      company = args?['company'] ?? "Recruiter";
      title = args?['title'] ?? "Recruiter Chat";

      final recruiterId = args?['recruiter_id'];

      if (recruiterId == null) {
        setState(() {
          isLoading = false;
          errorMessage = "Recruiter ID introuvable";
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable";
        });
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/messages/conversation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recruiter_id': recruiterId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        conversationId =
            data['conversation']?['id'] ?? data['conversationId'];

        if (conversationId == null) {
          setState(() {
            isLoading = false;
            errorMessage = "Conversation introuvable";
          });
          return;
        }

        await fetchMessages();
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              data['message'] ?? "Erreur lors de l'ouverture du chat";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  Future<void> fetchMessages() async {
    if (conversationId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final myUserId = prefs.getString('user_id');

      final response = await http.get(
        Uri.parse('$baseUrl/messages/$conversationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> backendMessages = data['messages'] ?? [];

        final mappedMessages = backendMessages.map((message) {
          final senderId = message['sender_id']?.toString();
          return {
            ...message,
            "isMe": senderId == myUserId,
            "text": message["message"] ?? "",
            "time": formatMessageTime(message["created_at"]),
          };
        }).toList();

        setState(() {
          messages = mappedMessages;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = data['message'] ?? "Erreur lors du chargement";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  String formatMessageTime(dynamic createdAt) {
    if (createdAt == null) return "Now";
    final raw = createdAt.toString();
    if (raw.length >= 16) {
      final cleaned = raw.replaceFirst('T', ' ');
      return cleaned.substring(11, 16);
    }
    return raw;
  }

  Future<void> _sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty || conversationId == null || isSending) return;

    setState(() {
      isSending = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'conversation_id': conversationId,
          'message': text,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        messageController.clear();
        await fetchMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Erreur lors de l'envoi"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur de connexion au serveur"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBottom,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundTop, backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, company, title),
              Expanded(
                child: _buildBodyContent(),
              ),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Text(
          "No messages yet",
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 15,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(
          text: message["text"] ?? "",
          time: message["time"] ?? "",
          isMe: message["isMe"] ?? false,
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, String company, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.call_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required String time,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 290),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isMe ? myMessageColor : otherMessageColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              border: Border.all(
                color: isMe
                    ? primaryBlue.withOpacity(0.22)
                    : Colors.white.withOpacity(0.04),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: backgroundBottom,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.attach_file_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Write a message...",
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isSending ? null : _sendMessage,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.24),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}