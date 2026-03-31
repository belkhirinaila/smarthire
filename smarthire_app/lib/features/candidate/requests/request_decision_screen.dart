import 'package:flutter/material.dart';

class RequestDecisionScreen extends StatefulWidget {
  const RequestDecisionScreen({super.key});

  @override
  State<RequestDecisionScreen> createState() => _RequestDecisionScreenState();
}

class _RequestDecisionScreenState extends State<RequestDecisionScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  /// Etats loading des boutons
  bool isAccepting = false;
  bool isDeclining = false;

  @override
  Widget build(BuildContext context) {
    /// ==============================
    /// Données reçues depuis inbox
    /// Si rien n'est envoyé, on met des valeurs visuelles temporaires
    /// ==============================
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String company = args?['company'] ?? "Company name";
    final String title = args?['title'] ?? "Interview invitation";
    final String subtitle =
        args?['subtitle'] ??
        "We would like to discuss an opportunity with you.";
    final String time = args?['time'] ?? "Recently";
    final String type = args?['type'] ?? "REQUEST";
    final Color badgeColor = args?['color'] ?? primaryBlue;

    /// Texte plus détaillé temporaire
    final String longDescription =
        args?['description'] ??
        "This request has been sent by a recruiter through the platform. "
            "You can accept it to continue the conversation, decline it, "
            "or open a direct chat to discuss the opportunity in more detail.";

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),

                      const SizedBox(height: 24),

                      _buildMainCard(
                        company: company,
                        title: title,
                        subtitle: subtitle,
                        time: time,
                        type: type,
                        badgeColor: badgeColor,
                      ),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Request Details"),

                      const SizedBox(height: 12),

                      _buildDescriptionCard(longDescription),

                      const SizedBox(height: 24),

                      _buildSectionTitle("What can you do?"),

                      const SizedBox(height: 12),

                      _buildActionsInfoCard(),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Contact Overview"),

                      const SizedBox(height: 12),

                      _buildContactOverviewCard(company, time),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// ==============================
      /// Actions du bas
      /// ==============================
      bottomNavigationBar: _buildBottomBar(context, args),
    );
  }

  /// ==============================
  /// Barre supérieure
  /// ==============================
  Widget _buildTopBar(BuildContext context) {
    return Row(
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
        const Spacer(),
        const Text(
          "Request Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Icon(
            Icons.more_horiz_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  /// ==============================
  /// Carte principale de la request
  /// ==============================
  Widget _buildMainCard({
    required String company,
    required String title,
    required String subtitle,
    required String time,
    required String type,
    required Color badgeColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: Colors.white54,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _buildTypeBadge(
                text: type,
                color: badgeColor,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    size: 15,
                    color: Colors.white.withOpacity(0.45),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Titre de section
  /// ==============================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  /// ==============================
  /// Carte description
  /// ==============================
  Widget _buildDescriptionCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.72),
          fontSize: 15,
          height: 1.7,
        ),
      ),
    );
  }

  /// ==============================
  /// Carte infos d'actions
  /// ==============================
  Widget _buildActionsInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: const [
          _ActionInfoRow(
            icon: Icons.check_circle_outline_rounded,
            title: "Accept",
            subtitle: "Continue with the recruiter and keep the request active.",
          ),
          SizedBox(height: 16),
          _ActionInfoRow(
            icon: Icons.cancel_outlined,
            title: "Decline",
            subtitle: "Refuse the request and close the current interaction.",
          ),
          SizedBox(height: 16),
          _ActionInfoRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: "Open Chat",
            subtitle: "Discuss directly with the recruiter before deciding.",
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Carte résumé contact
  /// ==============================
  Widget _buildContactOverviewCard(String company, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.business_center_outlined,
            label: "Company",
            value: company,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.schedule_outlined,
            label: "Received",
            value: time,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.verified_user_outlined,
            label: "Status",
            value: "Pending decision",
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Ligne d'information
  /// ==============================
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.78),
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// ==============================
  /// Badge type
  /// ==============================
  Widget _buildTypeBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.28)),
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

  /// ==============================
  /// Barre du bas avec actions
  /// ==============================
  Widget _buildBottomBar(
    BuildContext context,
    Map<String, dynamic>? args,
  ) {
    return Container(
      color: backgroundBottom,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: isDeclining ? null : _declineRequest,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isDeclining
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.3,
                            ),
                          )
                        : const Text(
                            "Decline",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isAccepting ? null : _acceptRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isAccepting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.3,
                            ),
                          )
                        : const Text(
                            "Accept",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/direct-chat',
                  arguments: args,
                );
              },
              child: const Text(
                "Open Chat",
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Accept temporaire
  /// Plus tard: appel backend
  /// ==============================
  void _acceptRequest() async {
    setState(() {
      isAccepting = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isAccepting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request accepted successfully"),
      ),
    );

    Navigator.pop(context);
  }

  /// ==============================
  /// Decline temporaire
  /// Plus tard: appel backend
  /// ==============================
  void _declineRequest() async {
    setState(() {
      isDeclining = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isDeclining = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request declined"),
      ),
    );

    Navigator.pop(context);
  }
}

/// ==============================
/// Widget réutilisable pour actions info
/// ==============================
class _ActionInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E6CFF),
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}