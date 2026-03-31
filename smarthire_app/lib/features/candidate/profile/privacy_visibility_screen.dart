import 'package:flutter/material.dart';

class PrivacyVisibilityScreen extends StatefulWidget {
  const PrivacyVisibilityScreen({super.key});

  @override
  State<PrivacyVisibilityScreen> createState() =>
      _PrivacyVisibilityScreenState();
}

class _PrivacyVisibilityScreenState extends State<PrivacyVisibilityScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  /// ==============================
  /// Etats des options
  /// Plus tard: ces valeurs viendront du backend
  /// ==============================
  bool isProfilePublic = true;
  bool showEmail = false;
  bool showPhone = false;
  bool allowRecruiterContact = true;
  bool openToOpportunities = true;
  bool jobAlertsEnabled = true;
  bool requestNotificationsEnabled = true;
  bool messageNotificationsEnabled = true;

  /// Etat loading du bouton save
  bool isSaving = false;

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Profile Visibility"),
                      const SizedBox(height: 12),
                      _buildVisibilityCard(),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Contact Preferences"),
                      const SizedBox(height: 12),
                      _buildContactCard(),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Opportunities"),
                      const SizedBox(height: 12),
                      _buildOpportunitiesCard(),

                      const SizedBox(height: 24),

                      _buildSectionTitle("Notifications"),
                      const SizedBox(height: 12),
                      _buildNotificationsCard(),

                      const SizedBox(height: 24),

                      _buildInfoCard(),

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
      /// Bouton fixe en bas
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
          "Privacy & Visibility",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  /// ==============================
  /// Titre section
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
  /// Carte visibilité profil
  /// ==============================
  Widget _buildVisibilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.public_rounded,
            title: "Public Profile",
            subtitle: "Allow your profile to be visible in the platform.",
            value: isProfilePublic,
            onChanged: (value) {
              setState(() {
                isProfilePublic = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: "Show Email",
            subtitle: "Display your email on your public profile.",
            value: showEmail,
            onChanged: (value) {
              setState(() {
                showEmail = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            icon: Icons.phone_outlined,
            title: "Show Phone Number",
            subtitle: "Display your phone number on your profile.",
            value: showPhone,
            onChanged: (value) {
              setState(() {
                showPhone = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Carte préférences de contact
  /// ==============================
  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.mark_email_read_outlined,
            title: "Allow Recruiter Contact",
            subtitle: "Recruiters can contact you directly from the platform.",
            value: allowRecruiterContact,
            onChanged: (value) {
              setState(() {
                allowRecruiterContact = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Carte opportunités
  /// ==============================
  Widget _buildOpportunitiesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.work_outline_rounded,
            title: "Open to Opportunities",
            subtitle: "Show recruiters that you are open to new roles.",
            value: openToOpportunities,
            onChanged: (value) {
              setState(() {
                openToOpportunities = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Carte notifications
  /// ==============================
  Widget _buildNotificationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: "Job Alerts",
            subtitle: "Receive notifications for matching job offers.",
            value: jobAlertsEnabled,
            onChanged: (value) {
              setState(() {
                jobAlertsEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            icon: Icons.inventory_2_outlined,
            title: "Request Notifications",
            subtitle: "Receive updates about recruiter requests.",
            value: requestNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                requestNotificationsEnabled = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: "Message Notifications",
            subtitle: "Receive alerts when you get new messages.",
            value: messageNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                messageNotificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Carte info
  /// ==============================
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primaryBlue.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: primaryBlue,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "These settings are currently local on the app interface. Later, they will be connected to backend preferences and stored in the database.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Switch tile réutilisable
  /// ==============================
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
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
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryBlue,
            activeTrackColor: primaryBlue.withOpacity(0.45),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Bouton save
  /// ==============================
  Widget _buildBottomButton() {
    return Container(
      color: backgroundBottom,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: SizedBox(
        height: 58,
        child: ElevatedButton(
          onPressed: isSaving ? null : _savePrivacySettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primaryBlue.withOpacity(0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  "Save Settings",
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
  /// Save temporaire
  /// Plus tard: appel backend
  /// ==============================
  void _savePrivacySettings() async {
    setState(() {
      isSaving = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Privacy and visibility settings updated successfully"),
      ),
    );

    Navigator.pop(context);
  }
}