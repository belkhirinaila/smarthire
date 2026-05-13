import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'https://smarthire-fpa1.onrender.com/api';
  static const String serverUrl = 'https://smarthire-fpa1.onrender.com';

  late TabController _tabController;

  List<dynamic> chats = [];
  List<dynamic> requests = [];

  bool isLoadingChats = true;
  bool isLoadingRequests = true;

  String? chatsError;
  String? requestsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchChats();
    fetchRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? getImageUrl(dynamic item) {
    if (item == null) return null;

    final keys = [
      'company_logo',
      'logo',
      'logo_url',
      'companyLogo',
      'company_image',
      'image',
      'profile_image',
      'profile_photo',
      'photo',
    ];

    for (final key in keys) {
      final value = item[key]?.toString().trim();

      if (value != null &&
          value.isNotEmpty &&
          value != 'null' &&
          value != 'NULL') {
        if (value.startsWith('http')) return value;
        if (value.startsWith('/')) return '$serverUrl$value';
        return '$serverUrl/$value';
      }
    }

    return null;
  }

  Widget companyAvatar(dynamic item, {double size = 56}) {
    final imageUrl = getImageUrl(item);

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.white.withOpacity(0.06),
        child: imageUrl == null
            ? const Icon(
                Icons.business_rounded,
                color: Colors.white54,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.business_rounded,
                    color: Colors.white54,
                  );
                },
              ),
      ),
    );
  }

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

      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> conversations = data['conversations'] ?? [];

        final mappedChats = conversations.map((chat) {
          final bool amCandidate =
              chat['candidate_id']?.toString() == myUserId?.toString();

          final dynamic otherUserId =
              amCandidate ? chat['recruiter_id'] : chat['candidate_id'];

          final String companyName =
              (chat['company_name']?.toString().trim().isNotEmpty == true)
                  ? chat['company_name'].toString()
                  : (chat['other_user_name']?.toString().trim().isNotEmpty ==
                          true)
                      ? chat['other_user_name'].toString()
                      : 'Company';

          final int unreadCount =
              int.tryParse(chat['unread_count']?.toString() ?? '') ?? 0;

          final logo = getImageUrl(chat);

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
            'company_logo': logo,
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

      final response = await http.get(
        Uri.parse('$baseUrl/requests/received'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> backendRequests = data['requests'] ?? [];

        final mappedRequests = backendRequests.map((request) {
          final status = (request['status'] ?? 'pending').toString();

          return {
            ...request,
            "company": request['company_name']?.toString().trim().isNotEmpty ==
                    true
                ? request['company_name'].toString()
                : "Recruiter #${request['recruiter_id']}",
            "title": "Access Request",
            "subtitle": "A recruiter wants to access your profile.",
            "time": _formatDate(request['created_at']),
            "isUnread": status.toLowerCase() == 'pending',
            "type": status.toUpperCase(),
            "color": _getStatusColor(status),
            "company_logo": getImageUrl(request),
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

  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return "Recently";
    final raw = createdAt.toString().replaceFirst('T', ' ');
    if (raw.length >= 16) return raw.substring(0, 16);
    return raw;
  }

  void openChat(Map chat) async {
  final conversationId = chat['id'] ?? chat['conversation_id'];

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await http.put(
      Uri.parse(
        '$baseUrl/messages/$conversationId/read',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    setState(() {
      chat['unread_count'] = 0;
      chat['isUnread'] = false;
    });
  } catch (e) {
    debugPrint("Erreur mark as read: $e");
  }

  Navigator.pushNamed(
    context,
    '/chat_candidate',
    arguments: {
      'conversationId': conversationId,
      'company': chat['company'],
      'title': chat['title'],
      'company_logo': chat['company_logo'] ?? getImageUrl(chat),
    },
  ).then((_) {
    fetchChats();
  });
}

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

  Widget _buildChatsTab() {
    if (isLoadingChats) {
      return const Center(child: CircularProgressIndicator());
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
                      companyAvatar(chat, size: 56),
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

  Widget _buildRequestsTab() {
    if (isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
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
                      companyAvatar(request, size: 58),
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