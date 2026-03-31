import 'package:flutter/material.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  const ApplicationDetailsScreen({super.key});

  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  @override
  Widget build(BuildContext context) {
    /// ==============================
    /// Données reçues depuis la liste
    /// Si rien n'est envoyé, on met des valeurs visuelles temporaires
    /// ==============================
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String title = args?['title'] ?? "Job title";
    final String company = args?['company'] ?? "Company name";
    final String location = args?['location'] ?? "Location";
    final String status = args?['status'] ?? "UNDER REVIEW";
    final String date = args?['date'] ?? "Applied recently";
    final Color statusColor = args?['statusColor'] ?? primaryBlue;

    /// Message temporaire
    final String candidateMessage =
        args?['message'] ??
            "I am very interested in this opportunity and I believe my profile matches the role requirements.";

    /// Nom temporaire du CV
    final String cvName = args?['cvName'] ?? "resume_candidate.pdf";

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
              /// ==============================
              /// Contenu principal scrollable
              /// ==============================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),

                      const SizedBox(height: 22),

                      _buildApplicationCard(
                        title: title,
                        company: company,
                        location: location,
                        status: status,
                        date: date,
                        statusColor: statusColor,
                      ),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Application Message"),

                      const SizedBox(height: 12),

                      _buildMessageCard(candidateMessage),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Attached CV"),

                      const SizedBox(height: 12),

                      _buildCvCard(cvName),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Application Timeline"),

                      const SizedBox(height: 12),

                      _buildTimelineCard(statusColor),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// ==============================
      /// Barre d'action en bas
      /// ==============================
      bottomNavigationBar: _buildBottomBar(context),
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
          "Application Details",
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
  /// Carte principale de candidature
  /// ==============================
  Widget _buildApplicationCard({
    required String title,
    required String company,
    required String location,
    required String status,
    required String date,
    required Color statusColor,
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
                  Icons.business_center_rounded,
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
                    const SizedBox(height: 6),
                    Text(
                      "$company • $location",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildStatusBadge(
                text: status,
                color: statusColor,
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
                    date,
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
  /// Carte message
  /// ==============================
  Widget _buildMessageCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white.withOpacity(0.72),
          fontSize: 15,
          height: 1.7,
        ),
      ),
    );
  }

  /// ==============================
  /// Carte CV
  /// ==============================
  Widget _buildCvCard(String cvName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              cvName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "View",
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Timeline simple
  /// ==============================
  Widget _buildTimelineCard(Color statusColor) {
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
          _buildTimelineItem(
            title: "Application Submitted",
            subtitle: "Your application was sent successfully.",
            isDone: true,
            color: const Color(0xFF22C55E),
          ),
          const SizedBox(height: 18),
          _buildTimelineItem(
            title: "Under Review",
            subtitle: "Recruiter is reviewing your application.",
            isDone: true,
            color: statusColor,
          ),
          const SizedBox(height: 18),
          _buildTimelineItem(
            title: "Interview / Final Decision",
            subtitle: "Next update will appear here.",
            isDone: false,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Item timeline
  /// ==============================
  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isDone,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(isDone ? 0.18 : 0.08),
                border: Border.all(color: color),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.circle,
                color: color,
                size: isDone ? 14 : 8,
              ),
            ),
            Container(
              width: 2,
              height: 42,
              color: Colors.white.withOpacity(0.08),
            ),
          ],
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

  /// ==============================
  /// Badge de statut
  /// ==============================
  Widget _buildStatusBadge({
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
  /// Barre du bas
  /// ==============================
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: backgroundBottom,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Back",
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
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/candidate',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Go Home",
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
    );
  }
}