import 'package:flutter/material.dart';

class CvSkillsScreen extends StatefulWidget {
  const CvSkillsScreen({super.key});

  @override
  State<CvSkillsScreen> createState() => _CvSkillsScreenState();
}

class _CvSkillsScreenState extends State<CvSkillsScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  /// ==============================
  /// Etat loading du bouton save
  /// ==============================
  bool isSaving = false;

  /// ==============================
  /// Nom du CV (temporaire)
  /// Plus tard: viendra du backend
  /// ==============================
  String cvFileName = "candidate_resume.pdf";

  /// ==============================
  /// Liste des skills
  /// Plus tard: viendra du backend
  /// ==============================
  final List<TextEditingController> skillControllers = [
    TextEditingController(text: "Communication"),
    TextEditingController(text: "Problem Solving"),
    TextEditingController(text: "UI Design"),
  ];

  /// ==============================
  /// Liste des certifications
  /// Plus tard: viendra du backend
  /// ==============================
  final List<TextEditingController> certificationControllers = [
    TextEditingController(text: "Google UX Design Certificate"),
    TextEditingController(text: "English Proficiency Certificate"),
  ];

  @override
  void dispose() {
    for (final controller in skillControllers) {
      controller.dispose();
    }
    for (final controller in certificationControllers) {
      controller.dispose();
    }
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

                      _buildSectionTitle("My CV"),

                      const SizedBox(height: 12),

                      _buildCvCard(),

                      const SizedBox(height: 24),

                      _buildSectionHeaderWithAdd(
                        title: "Skills",
                        onAdd: _addSkillField,
                      ),

                      const SizedBox(height: 12),

                      _buildSkillsCard(),

                      const SizedBox(height: 24),

                      _buildSectionHeaderWithAdd(
                        title: "Certifications",
                        onAdd: _addCertificationField,
                      ),

                      const SizedBox(height: 12),

                      _buildCertificationsCard(),

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
          "CV & Skills",
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
  /// Titre simple
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
  /// Titre avec bouton add
  /// ==============================
  Widget _buildSectionHeaderWithAdd({
    required String title,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.add_rounded,
                  color: primaryBlue,
                  size: 18,
                ),
                SizedBox(width: 4),
                Text(
                  "Add",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w700,
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
  /// Carte CV
  /// ==============================
  Widget _buildCvCard() {
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
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
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
                  cvFileName,
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _changeCv,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.10)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text(
                "Change CV",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Carte skills
  /// ==============================
  Widget _buildSkillsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: List.generate(skillControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: skillControllers[index],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter a skill",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.30),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
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
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _removeSkillField(index),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// ==============================
  /// Carte certifications
  /// ==============================
  Widget _buildCertificationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: List.generate(certificationControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: certificationControllers[index],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter a certification",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.30),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
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
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _removeCertificationField(index),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
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
          onPressed: isSaving ? null : _saveCvSkills,
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
  /// Ajouter skill
  /// ==============================
  void _addSkillField() {
    setState(() {
      skillControllers.add(TextEditingController());
    });
  }

  /// ==============================
  /// Supprimer skill
  /// ==============================
  void _removeSkillField(int index) {
    if (skillControllers.length == 1) return;

    setState(() {
      skillControllers[index].dispose();
      skillControllers.removeAt(index);
    });
  }

  /// ==============================
  /// Ajouter certification
  /// ==============================
  void _addCertificationField() {
    setState(() {
      certificationControllers.add(TextEditingController());
    });
  }

  /// ==============================
  /// Supprimer certification
  /// ==============================
  void _removeCertificationField(int index) {
    if (certificationControllers.length == 1) return;

    setState(() {
      certificationControllers[index].dispose();
      certificationControllers.removeAt(index);
    });
  }

  /// ==============================
  /// Changer CV (temporaire)
  /// Plus tard: file picker
  /// ==============================
  void _changeCv() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("File picker bientôt disponible"),
      ),
    );
  }

  /// ==============================
  /// Save temporaire
  /// Plus tard: appel backend
  /// ==============================
  void _saveCvSkills() async {
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
        content: Text("CV, skills and certifications updated successfully"),
      ),
    );

    Navigator.pop(context);
  }
}