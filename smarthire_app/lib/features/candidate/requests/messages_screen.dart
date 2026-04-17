// Import des packages utilisés ici :
// - dart:convert pour décoder les réponses JSON du backend.
// - flutter/material.dart pour l'UI et les widgets Flutter.
// - http pour envoyer des requêtes réseau.
// - shared_preferences pour récupérer le token et l'ID utilisateur stockés localement.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Écran principal de gestion des messages et des demandes reçues.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  // Définition des couleurs réutilisées dans l'interface.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  // URL de base de l'API.
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  // Contrôleur de tabulation pour alterner entre les onglets Chats et Requests.
  late TabController _tabController;

  // Listes des conversations et des demandes reçues.
  List<dynamic> chats = [];
  List<dynamic> requests = [];

  // États de chargement pour chaque onglet.
  bool isLoadingChats = true;
  bool isLoadingRequests = true;

  // Messages d'erreur spécifiques à chaque onglet.
  String? chatsError;
  String? requestsError;

  @override
  void initState() {
    super.initState();
    // Initialise le TabController pour deux onglets.
    _tabController = TabController(length: 2, vsync: this);
    // Charge les données des conversations et des demandes dès l'ouverture.
    fetchChats();
    fetchRequests();
  }

  @override
  void dispose() {
    // Libère le contrôleur de tabulation lorsque le widget est détruit.
    _tabController.dispose();
    super.dispose();
  }

  // Récupère les conversations de l'utilisateur connecté.
  Future<void> fetchChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final myUserId = prefs.getString('user_id');

      if (token == null || token.isEmpty) {
        setState(() {
          isLoadingChats = false;
          chatsError = "Token introuvable";
        });
        return;
      }

      // Requête API pour récupérer les conversations de l'utilisateur.
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> conversations = data['conversations'] ?? [];

        // Transforme chaque conversation en objet plus facile à afficher.
        final mappedChats = conversations.map((chat) {
          final bool amCandidate =
              chat['candidate_id']?.toString() == myUserId?.toString();

          final dynamic otherUserId =
              amCandidate ? chat['recruiter_id'] : chat['candidate_id'];

          final String companyName = (chat['company_name']?.toString().trim().isNotEmpty == true)
              ? chat['company_name'].toString()
              : (chat['other_user_name']?.toString().trim().isNotEmpty == true)
                  ? chat['other_user_name'].toString()
                  : 'Company';

          final int unreadCount = int.tryParse(chat['unread_count']?.toString() ?? '') ?? 0;

          return {
            ...chat,
            'company': companyName,
            'title': "Direct Conversation",
            'lastMessage': "Open conversation",
            'time': _formatDate(chat['created_at']),
            'isUnread': unreadCount > 0,
            'unread_count': unreadCount,
            'other_user_id': otherUserId,
            'recruiter_id': chat['recruiter_id'],
          };
        }).toList();

        setState(() {
          chats = mappedChats;
          isLoadingChats = false;
          chatsError = null;
        });
      } else {
        setState(() {
          isLoadingChats = false;
          chatsError =
              data['message'] ?? "Erreur lors du chargement des conversations";
        });
      }
    } catch (e) {
      setState(() {
        isLoadingChats = false;
        chatsError = "Erreur de connexion au serveur";
      });
    }
  }

  // Récupère les demandes d'accès reçues par le candidat.
  Future<void> fetchRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          isLoadingRequests = false;
          requestsError = "Token introuvable";
        });
        return;
      }

      // Requête API pour obtenir les demandes reçues.
      final response = await http.get(
        Uri.parse('$baseUrl/requests/received'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> backendRequests = data['requests'] ?? [];

        // Transforme chaque demande pour l'affichage dans la liste.
        final mappedRequests = backendRequests.map((request) {
          final status = (request['status'] ?? 'pending').toString();
          return {
            ...request,
            "company": "Recruiter #${request['recruiter_id']}",
            "title": "Access Request",
            "subtitle": "A recruiter wants to access your profile.",
            "time": _formatDate(request['created_at']),
            "isUnread": status.toLowerCase() == 'pending',
            "type": status.toUpperCase(),
            "color": _getStatusColor(status),
          };
        }).toList();

        setState(() {
          requests = mappedRequests;
          isLoadingRequests = false;
          requestsError = null;
        });
      } else {
        setState(() {
          isLoadingRequests = false;
          requestsError =
              data['message'] ?? "Erreur lors du chargement des requests";
        });
      }
    } catch (e) {
      setState(() {
        isLoadingRequests = false;
        requestsError = "Erreur de connexion au serveur";
      });
    }
  }

  // Retourne une couleur adaptée à l'état de la demande.
  // Approuvé = vert, rejeté = rouge, en attente = orange.
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFFF5A6E);
      case 'pending':
      default:
        return const Color(0xFFFFB020);
    }
  }

  // Formate la date renvoyée par le backend pour affichage.
  // On garde les 16 premiers caractères après avoir remplacé le 'T'.
  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return "Recently";
    final raw = createdAt.toString().replaceFirst('T', ' ');
    if (raw.length >= 16) return raw.substring(0, 16);
    return raw;
  }

  // Ouvre l'écran de chat direct en transmettant les informations nécessaires.
  // Après retour, on recharge la liste des conversations.
  void openChat(Map chat) {
    final conversationId = chat['id'] ?? chat['conversation_id'];

    debugPrint('Opening candidate chat - conversationId: $conversationId, chat: $chat');

    Navigator.pushNamed(
      context,
      '/chat_candidate',
      arguments: {
        'conversationId': conversationId,
        'company': chat['company'],
        'title': chat['title'],
      },
    ).then((_) {
      fetchChats();
    });
  }

  // Ouvre l'écran de décision de la demande et recharge les listes après retour.
  void openRequest(Map<String, dynamic> request) {
    Navigator.pushNamed(
      context,
      '/request-decision',
      arguments: request,
    ).then((_) {
      fetchRequests();
      fetchChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Structure principale de l'écran : barre de titre, onglets et contenu.
    return Scaffold(
      backgroundColor: backgroundBottom,
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
              _buildTopBar(),
              const SizedBox(height: 14),
              _buildTabs(),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChatsTab(),
                    _buildRequestsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Barre de titre fixe de l'écran.
  Widget _buildTopBar() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Row(
        children: [
          Spacer(),
          Text(
            "Messages",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  // Onglets pour naviguer entre listes de conversations et demandes.
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: "Chats"),
            Tab(text: "Requests"),
          ],
        ),
      ),
    );
  }

  // Contenu de l'onglet Conversations.
  // Affiche soit un loader, soit un message d'erreur, soit la liste des chats.
  Widget _buildChatsTab() {
    if (isLoadingChats) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chatsError != null) {
      return _buildErrorState(
        chatsError!,
        onRetry: () {
          setState(() {
            isLoadingChats = true;
            chatsError = null;
          });
          fetchChats();
        },
      );
    }

    if (chats.isEmpty) {
      return _buildEmptyState("No chats available");
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => openChat(chat),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat["company"] ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chat["title"] ?? "",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              chat["lastMessage"] ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        chat["time"] ?? "",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.42),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if ((chat['unread_count'] as int? ?? 0) > 0)
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
                        border: Border.all(color: backgroundBottom, width: 2),
                      ),
                      child: Text(
                        (chat['unread_count'] as int).toString(),
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
      },
    );
  }

  // Contenu de l'onglet Requests.
  // Affiche les demandes d'accès reçues, ou les états de chargement / erreur.
  Widget _buildRequestsTab() {
    if (isLoadingRequests) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (requestsError != null) {
      return _buildErrorState(
        requestsError!,
        onRetry: () {
          setState(() {
            isLoadingRequests = true;
            requestsError = null;
          });
          fetchRequests();
        },
      );
    }

    if (requests.isEmpty) {
      return _buildEmptyState("No requests available");
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => openRequest(request),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: Colors.white54,
                        ),
                      ),
                      if (request["isUnread"] == true)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request["company"] ?? "",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request["title"] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          request["subtitle"] ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTypeBadge(
                              text: request["type"] ?? "",
                              color: request["color"] ?? primaryBlue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                request["time"] ?? "",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.42),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.35),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Badge d'état affichant le statut de la demande (APPROVED / REJECTED / PENDING).
  Widget _buildTypeBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // État affiché lorsqu'il n'y a aucune conversation ou demande à afficher.
  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
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
              text,
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

  // État affiché lorsqu'une erreur survient durant le chargement d'un onglet.
  // Propose un bouton de réessayage pour relancer la requête correspondante.
  Widget _buildErrorState(String text, {required VoidCallback onRetry}) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      ),
    );
  }
}