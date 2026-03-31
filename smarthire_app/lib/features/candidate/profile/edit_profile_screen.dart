import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  /// ==============================
  /// Controllers des champs
  /// Plus tard: ces valeurs viendront du backend
  /// ==============================
  final TextEditingController fullNameController =
      TextEditingController(text: "Candidate Name");
  final TextEditingController headlineController =
      TextEditingController(text: "Your professional headline");
  final TextEditingController locationController =
      TextEditingController(text: "Algeria");
  final TextEditingController phoneController =
      TextEditingController(text: "+213 000 00 00 00");
  final TextEditingController aboutController = TextEditingController(
    text:
        "Tell recruiters about your profile, your goals and your strengths.",
  );

  /// Etat loading du bouton save
  bool isSaving = false;

  @override
  void dispose() {
    fullNameController.dispose();
    headlineController.dispose();
    locationController.dispose();
    phoneController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),

                      const SizedBox(height: 24),

                      _buildAvatarSection(),

                      const SizedBox(height: 28),

                      _buildSectionTitle("Personal Information"),

                      const SizedBox(height: 14),

                      _buildInputCard(
                        label: "Full Name",
                        hint: "Enter your full name",
                        controller: fullNameController,
                        icon: Icons.person_outline_rounded,
                      ),

                      const SizedBox(height: 14),

                      _buildInputCard(
                        label: "Professional Headline",
                        hint: "Ex: UI/UX Designer",
                        controller: headlineController,
                        icon: Icons.work_outline_rounded,
                      ),

                      const SizedBox(height: 14),

                      _buildInputCard(
                        label: "Location",
                        hint: "Enter your location",
                        controller: locationController,
                        icon: Icons.location_on_outlined,
                      ),

                      const SizedBox(height: 14),

                      _buildInputCard(
                        label: "Phone Number",
                        hint: "Enter your phone number",
                        controller: phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 24),

                      _buildSectionTitle("About Me"),

                      const SizedBox(height: 14),

                      _buildAboutInput(),

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
          "Edit Profile",
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
  /// Avatar + action changement photo
  /// ==============================
  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: const Icon(
                  Icons.person,
                  size: 46,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Change Profile Photo",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
  /// Carte input réutilisable
  /// ==============================
  Widget _buildInputCard({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.30),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.white.withOpacity(0.45),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide(color: primaryBlue, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Champ about multiline
  /// ==============================
  Widget _buildAboutInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: TextField(
        controller: aboutController,
        maxLines: 7,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.6,
        ),
        decoration: InputDecoration(
          hintText: "Write something about yourself...",
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.30),
            fontSize: 15,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: primaryBlue, width: 1.4),
          ),
        ),
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
          onPressed: isSaving ? null : _saveProfile,
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
                  "Save Changes",
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
  /// Sauvegarde temporaire
  /// Plus tard: appel backend
  /// ==============================
  void _saveProfile() async {
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
        content: Text("Profile updated successfully"),
      ),
    );

    Navigator.pop(context);
  }
}