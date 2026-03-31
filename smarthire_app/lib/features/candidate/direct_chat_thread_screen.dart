import 'package:flutter/material.dart';

class DirectChatThreadScreen extends StatefulWidget {
  const DirectChatThreadScreen({super.key});

  @override
  State<DirectChatThreadScreen> createState() => _DirectChatThreadScreenState();
}

class _DirectChatThreadScreenState extends State<DirectChatThreadScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color myMessageColor = Color(0xFF1E6CFF);
  static const Color otherMessageColor = Color(0xFF121C31);

  /// ==============================
  /// Contrôleur du champ message
  /// ==============================
  final TextEditingController messageController = TextEditingController();

  /// ==============================
  /// Liste temporaire des messages
  /// Plus tard: viendra du backend
  /// ==============================
  late List<Map<String, dynamic>> messages;

  @override
  void initState() {
    super.initState();

    messages = [
      {
        "text": "Hello! We reviewed your profile and we would like to discuss this opportunity with you.",
        "isMe": false,
        "time": "09:12",
      },
      {
        "text": "Hello, thank you for reaching out. I’m interested in learning more.",
        "isMe": true,
        "time": "09:14",
      },
      {
        "text": "Great. Are you available for a short interview this week?",
        "isMe": false,
        "time": "09:15",
      },
    ];
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// ==============================
    /// Données envoyées depuis request details
    /// ==============================
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String company = args?['company'] ?? "Company name";
    final String title = args?['title'] ?? "Recruiter Chat";

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

              /// ==============================
              /// Liste des messages
              /// ==============================
              Expanded(
                child: ListView.builder(
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
                ),
              ),

              /// ==============================
              /// Barre d'envoi en bas
              /// ==============================
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  /// ==============================
  /// Top bar du chat
  /// ==============================
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

  /// ==============================
  /// Bulle de message
  /// ==============================
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

  /// ==============================
  /// Barre d'écriture
  /// ==============================
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
              onTap: _sendMessage,
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
                child: const Icon(
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

  /// ==============================
  /// Envoi temporaire du message
  /// Plus tard: appel backend / socket
  /// ==============================
  void _sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "text": text,
        "isMe": true,
        "time": "Now",
      });
    });

    messageController.clear();
  }
}