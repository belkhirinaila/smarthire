import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Écran de conversation directe entre le candidat et un recruteur.
// Il gère l'initialisation de la conversation, l'envoi et la lecture des messages.
class DirectChatThreadScreen extends StatefulWidget {
  const DirectChatThreadScreen({super.key});

  @override
  State<DirectChatThreadScreen> createState() => _DirectChatThreadScreenState();
}

class _DirectChatThreadScreenState extends State<DirectChatThreadScreen> {
  // Couleurs principales de l'écran et des bulles de message.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color myMessageColor = Color(0xFF1E6CFF);
  static const Color otherMessageColor = Color(0xFF121C31);

  // URL de base vers l'API backend.
  static const String baseUrl = 'https://smarthire-fpa1.onrender.com/api';

  // Contrôleur pour le champ de saisie de message.
  final TextEditingController messageController = TextEditingController();

  // État des messages et des chargements.
  List<dynamic> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;

  // Identifiant de conversation et informations d'en-tête.
  int? conversationId;
  String company = "Recruiter";
  String title = "Direct Chat";

  @override
  void initState() {
    super.initState();
    // Utilise microtask pour récupérer les arguments de navigation après
    // que le widget soit monté et construire la conversation.
    Future.microtask(() => initializeConversation());
  }

  @override
  void dispose() {
    // Libère le contrôleur de texte lorsque l'écran est détruit.
    messageController.dispose();
    super.dispose();
  }

  // Initialise la conversation en récupérant les arguments de la route,
  // puis crée ou récupère la conversation côté serveur.
  Future<void> initializeConversation() async {
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      company = args?['company'] ?? "Recruiter";
      title = args?['title'] ?? "Recruiter Chat";

      final recruiterId = args?['recruiter_id'];

      if (recruiterId == null) {
        // Si l'ID du recruteur n'est pas passé, on ne peut pas ouvrir la conversation.
        setState(() {
          isLoading = false;
          errorMessage = "Recruiter ID introuvable";
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        // Si le token d'authentification est introuvable, on ne peut pas appeler l'API.
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable";
        });
        return;
      }

      // Crée ou récupère la conversation pour ce recruteur sur le serveur.
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
          // Si l'ID de conversation n'est pas fourni par l'API, on affiche une erreur.
          setState(() {
            isLoading = false;
            errorMessage = "Conversation introuvable";
          });
          return;
        }

        // Si tout est bon, on charge les messages de la conversation.
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

  // Récupère la liste des messages pour la conversation actuelle.
  Future<void> fetchMessages() async {
    if (conversationId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final myUserId = prefs.getString('user_id');

      // Appel API pour récupérer les messages de la conversation donnée.
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$conversationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> backendMessages = data['messages'] ?? [];

        // Mappe chaque message en ajoutant un flag 'isMe' et un formatage d'heure.
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

  // Formate l'heure d'envoi du message à partir du timestamp reçu.
  String formatMessageTime(dynamic createdAt) {
    if (createdAt == null) return "Now";
    final raw = createdAt.toString();
    if (raw.length >= 16) {
      final cleaned = raw.replaceFirst('T', ' ');
      return cleaned.substring(11, 16);
    }
    return raw;
  }

  // Envoie le message saisi dans la conversation en cours.
  Future<void> _sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty || conversationId == null || isSending) return;

    setState(() {
      isSending = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Envoi de la requête pour poster un nouveau message.
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
        // Si l'envoi est réussi, on efface le champ puis recharge les messages.
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
    // Construction de l'interface générale du chat avec en-tête,
    // contenu et barre de saisie.
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

  // Contenu principal de l'écran qui affiche l'état de chargement,
  // les erreurs ou la liste des messages.
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

  // En-tête du chat avec le bouton retour, le recruteur et le bouton appel.
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

  // Construction d'une bulle de message, alignée à droite si elle est envoyée par l'utilisateur.
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

  // Barre de saisie en bas de l'écran avec pièce jointe et bouton d'envoi.
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