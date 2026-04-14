import 'package:flutter/material.dart';

// Ecran de confirmation affiché après l'envoi d'une candidature.
// Il présente un message de succès, détaille l'offre concernée et propose
// des actions de navigation ainsi que des suggestions d'offres similaires.
class ApplicationSuccessScreen extends StatelessWidget {
  const ApplicationSuccessScreen({super.key});

  /// ==============================
  /// Couleurs principales
  /// ==============================
  // Couleurs utilisées dans l'interface pour harmoniser le thème sombre.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  @override
  Widget build(BuildContext context) {
    // Récupération des arguments transmis à partir de la navigation.
    // Ils contiennent le titre et le nom de l'entreprise de l'offre ciblée.
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String title = args?['title'] ?? "Job";
    final String company =
        args?['company'] ?? args?['company_name'] ?? "Company";

    /// ==============================
    /// Jobs similaires temporaires
    /// ==============================
    // Liste de données factices affichée comme exemples de postes similaires.
    final List<Map<String, dynamic>> similarJobs = [
      {
        "title": "Job title",
        "company": "Company name",
        "type1": "FULL-TIME",
        "type2": "REMOTE",
      },
      {
        "title": "Job title",
        "company": "Company name",
        "type1": "ON-SITE",
        "type2": "HYBRID",
      },
    ];

    // Construction de l'interface principale de l'écran de succès.
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
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barre du haut contenant le bouton de fermeture et le titre.
                      _buildTopBar(context),
                      const SizedBox(height: 24),
                      _buildSuccessIcon(),
                      const SizedBox(height: 28),
                      // Message de succès principal affiché au centre de l'écran.
                      const Center(
                        child: Text(
                          "Application Sent!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          "$title at $company",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          "Your application has been submitted successfully.\nGood luck with your journey!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      // Section de suggestions affichant des emplois similaires.
                      _buildSectionHeader(
                        title: "Similar Jobs in Algeria",
                        onSeeAll: () {},
                      ),
                      const SizedBox(height: 14),
                      ...similarJobs.map(_buildSimilarJobCard),
                      const SizedBox(height: 18),
                      _buildDiscoverCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Bloc fixe en bas avec les actions principales de l'utilisateur.
              Container(
                color: backgroundBottom,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        // Bouton qui ramène l'utilisateur à l'accueil du candidat.
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Return to Home",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Lien secondaire vers la liste des candidatures de l'utilisateur.
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/applications');
                      },
                      child: const Text(
                        "View My Applications",
                        style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ==============================
  /// Top bar avec bouton fermer
  /// ==============================
  /// Retourne une ligne contenant le bouton de fermeture et le titre.
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/candidate',
              (route) => false,
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const Spacer(),
        const Text(
          "Success",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  /// ==============================
  /// Icône de succès principale
  /// ==============================
  /// Conteneur circulaire stylisé avec une coche pour indiquer la réussite.
  Widget _buildSuccessIcon() {
    return Center(
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.28),
              blurRadius: 45,
              spreadRadius: 8,
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E6CFF), Color(0xFF39C3FF)],
          ),
        ),
        child: Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: primaryBlue,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  /// ==============================
  /// Header de section
  /// ==============================
  /// Renvoie un en-tête de section avec un titre et un bouton "Voir tout".
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            "View all",
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// ==============================
  /// Card job similaire
  /// ==============================
  /// Génère une carte de poste similaire à partir des données fournies.
  Widget _buildSimilarJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job["title"] ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job["company"] ?? "",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(
                      text: job["type1"] ?? "",
                      background: primaryBlue.withOpacity(0.16),
                      textColor: primaryBlue,
                    ),
                    _buildTag(
                      text: job["type2"] ?? "",
                      background: Colors.white.withOpacity(0.08),
                      textColor: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.bookmark_border_rounded,
            color: Colors.white.withOpacity(0.75),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Card découverte
  /// ==============================
  /// Carte mise en avant invitant l'utilisateur à découvrir davantage d'offres.
  Widget _buildDiscoverCard() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.withOpacity(0.65),
            const Color(0xFF1A385F),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Opacity(
                opacity: 0.12,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/logo.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Text(
                  "Discover jobs near you",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Explore more opportunities that match your profile.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Tag réutilisable
  /// ==============================
  /// Petit badge de type d'offre utilisé dans les cartes similaires.
  Widget _buildTag({
    required String text,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
}