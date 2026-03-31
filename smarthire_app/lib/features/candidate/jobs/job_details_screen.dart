import 'package:flutter/material.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  /// ==============================
  /// Etat local pour bookmark
  /// Plus tard, cet état pourra venir depuis l'API
  /// ==============================
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    /// ==============================
    /// Récupération des données envoyées depuis l'écran précédent
    /// Si aucune donnée n'est envoyée, on met des valeurs visuelles minimales
    /// ==============================
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String title = args?['title'] ?? "Job title";
    final String company = args?['company'] ?? "Company name";
    final String location = args?['location'] ?? "Location";
    final String salary = args?['salary'] ?? "Salary";
    final String type = args?['type'] ?? "FULL-TIME";
    final String description =
        args?['description'] ?? "No description available for this job yet.";

    final List<dynamic> requirements =
        args?['requirements'] ??
            [
              "Requirement 1",
              "Requirement 2",
              "Requirement 3",
            ];

    return Scaffold(
      extendBody: true,
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
                      _buildTopBar(),

                      const SizedBox(height: 22),

                      _buildCompanyCard(
                        title: title,
                        company: company,
                        location: location,
                        salary: salary,
                        type: type,
                      ),

                      const SizedBox(height: 26),

                      _buildSectionTitle("Job Description"),

                      const SizedBox(height: 12),

                      _buildDescriptionCard(description),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Requirements"),

                      const SizedBox(height: 12),

                      _buildRequirementsCard(requirements),

                      const SizedBox(height: 24),

                      _buildSectionTitle("About this role"),

                      const SizedBox(height: 12),

                      _buildAboutRoleCard(),

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
      /// Bottom action bar
      /// ==============================
      bottomNavigationBar: _buildBottomActionBar(args),
    );
  }

  /// ==============================
  /// Barre supérieure
  /// ==============================
  Widget _buildTopBar() {
    return Row(
      children: [
        /// Bouton retour
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
          "Job Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const Spacer(),

        /// Bouton bookmark
        GestureDetector(
          onTap: () {
            setState(() {
              isSaved = !isSaved;
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Icon(
              isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isSaved ? primaryBlue : Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  /// ==============================
  /// Carte principale de l'entreprise / job
  /// ==============================
  Widget _buildCompanyCard({
    required String title,
    required String company,
    required String location,
    required String salary,
    required String type,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          /// Logo entreprise
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white54,
              size: 36,
            ),
          ),

          const SizedBox(height: 18),

          /// Titre du job
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          /// Entreprise + localisation
          Text(
            "$company • $location",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          /// Badges visuels
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildTag(
                text: type,
                background: primaryBlue.withOpacity(0.15),
                textColor: primaryBlue,
              ),
              _buildTag(
                text: salary,
                background: Colors.white.withOpacity(0.06),
                textColor: Colors.white,
              ),
              _buildTag(
                text: "Urgent",
                background: const Color(0xFF2A1620),
                textColor: const Color(0xFFFF6B8B),
              ),
            ],
          ),

          const SizedBox(height: 22),

          /// Petites infos complémentaires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniInfo(
                icon: Icons.access_time_rounded,
                label: "Posted",
                value: "Recently",
              ),
              _buildMiniInfo(
                icon: Icons.work_outline_rounded,
                label: "Level",
                value: "Mid-Level",
              ),
              _buildMiniInfo(
                icon: Icons.location_on_outlined,
                label: "Mode",
                value: "Hybrid",
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
  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        description,
        style: TextStyle(
          color: Colors.white.withOpacity(0.72),
          fontSize: 15,
          height: 1.7,
        ),
      ),
    );
  }

  /// ==============================
  /// Carte des requirements
  /// ==============================
  Widget _buildRequirementsCard(List<dynamic> requirements) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: requirements.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryBlue.withOpacity(0.18),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: primaryBlue,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ==============================
  /// Carte informations supplémentaires
  /// ==============================
  Widget _buildAboutRoleCard() {
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
          _buildRoleInfoRow(
            icon: Icons.calendar_today_outlined,
            label: "Experience",
            value: "2+ years",
          ),
          const SizedBox(height: 16),
          _buildRoleInfoRow(
            icon: Icons.school_outlined,
            label: "Education",
            value: "Relevant degree",
          ),
          const SizedBox(height: 16),
          _buildRoleInfoRow(
            icon: Icons.language_rounded,
            label: "Languages",
            value: "French / English",
          ),
          const SizedBox(height: 16),
          _buildRoleInfoRow(
            icon: Icons.people_outline_rounded,
            label: "Team",
            value: "Product / Design",
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Ligne d'information
  /// ==============================
  Widget _buildRoleInfoRow({
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
  /// Mini info horizontale
  /// ==============================
  Widget _buildMiniInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: primaryBlue,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Tag visuel réutilisable
  /// ==============================
  Widget _buildTag({
    required String text,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// ==============================
  /// Barre d'action en bas
  /// ==============================
  Widget _buildBottomActionBar(Map<String, dynamic>? args) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220).withOpacity(0.96),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),
      ),
      child: Row(
        children: [
          /// Bouton save
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Icon(
              isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isSaved ? primaryBlue : Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          /// Bouton principal Apply
          Expanded(
            child: SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  /// Navigation vers l'écran Apply
                  Navigator.pushNamed(
                    context,
                    '/apply',
                    arguments: args,
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Apply Now",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}