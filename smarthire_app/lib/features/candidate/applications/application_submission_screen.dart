import 'package:flutter/material.dart';

class ApplicationSubmissionScreen extends StatefulWidget {
  const ApplicationSubmissionScreen({super.key});

  @override
  State<ApplicationSubmissionScreen> createState() =>
      _ApplicationSubmissionScreenState();
}

class _ApplicationSubmissionScreenState
    extends State<ApplicationSubmissionScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  /// Controller pour le message optionnel
  final TextEditingController messageController = TextEditingController();

  /// Etat de chargement du bouton Submit
  bool isSubmitting = false;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// ==============================
    /// Récupération des données du job
    /// ==============================
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String title = args?['title'] ?? "Job title";
    final String company = args?['company'] ?? "Company name";
    final String location = args?['location'] ?? "Location";

    return Scaffold(
      /// Couleur générale du scaffold pour éviter le blanc
      backgroundColor: backgroundBottom,

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),

                      const SizedBox(height: 24),

                      _buildJobCard(title, company, location),

                      const SizedBox(height: 28),

                      const Text(
                        "Your Message (optional)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildMessageInput(),

                      const SizedBox(height: 26),

                      _buildUploadCV(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// ==============================
      /// Barre du bas avec fond sombre
      /// ==============================
      bottomNavigationBar: Container(
        color: backgroundBottom,
        child: SafeArea(
          top: false,
          child: _buildBottomButton(),
        ),
      ),
    );
  }

  /// ==============================
  /// Top bar
  /// ==============================
  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const Spacer(),
        const Text(
          "Apply Job",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 54),
      ],
    );
  }

  /// ==============================
  /// Carte du job sélectionné
  /// ==============================
  Widget _buildJobCard(String title, String company, String location) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
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
                  title,
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
                  "$company • $location",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
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
  /// Champ message
  /// ==============================
  Widget _buildMessageInput() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: TextField(
        controller: messageController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Write a short message...",
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// ==============================
  /// Bloc upload CV (visuel pour le moment)
  /// ==============================
  Widget _buildUploadCV() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.upload_file_rounded,
            color: Colors.white.withOpacity(0.65),
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            "Upload your CV",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "PDF, DOCX",
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Bouton du bas
  /// ==============================
  Widget _buildBottomButton() {
    return Container(
      color: backgroundBottom,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: SizedBox(
        height: 58,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : submitApplication,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primaryBlue.withOpacity(0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  "Submit Application",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  /// ==============================
  /// Soumission temporaire
  /// Plus tard: appel backend
  /// ==============================
  void submitApplication() async {
    setState(() {
      isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    /// Navigation temporaire vers l'écran success
    Navigator.pushReplacementNamed(context, '/application-success');
  }
}