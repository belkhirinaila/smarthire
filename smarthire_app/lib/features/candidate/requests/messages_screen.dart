import 'package:flutter/material.dart';

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

  late TabController _tabController;

  final List<Map<String, dynamic>> chats = [
    {
      "company": "Company name",
      "lastMessage": "We would like to discuss an opportunity with you.",
      "time": "09:15",
      "isUnread": true,
      "title": "Recruiter Chat",
    },
    {
      "company": "Company name",
      "lastMessage": "Thank you for your reply. We will contact you soon.",
      "time": "Yesterday",
      "isUnread": false,
      "title": "Interview Follow-up",
    },
  ];

  final List<Map<String, dynamic>> requests = [
    {
      "company": "Company name",
      "title": "Interview invitation",
      "subtitle": "We would like to discuss an opportunity with you.",
      "time": "2 min ago",
      "isUnread": true,
      "type": "INVITE",
      "color": const Color(0xFF22C55E),
    },
    {
      "company": "Company name",
      "title": "Profile request",
      "subtitle": "A recruiter wants to view more details about your profile.",
      "time": "1 hour ago",
      "isUnread": true,
      "type": "REQUEST",
      "color": const Color(0xFF1E6CFF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void openChat(Map<String, dynamic> chat) {
    Navigator.pushNamed(
      context,
      '/direct-chat',
      arguments: chat,
    );
  }

  void openRequest(Map<String, dynamic> request) {
    Navigator.pushNamed(
      context,
      '/request-decision',
      arguments: request,
    );
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
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                children: [
                  Stack(
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
                      if (chat["isUnread"] == true)
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
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
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
}