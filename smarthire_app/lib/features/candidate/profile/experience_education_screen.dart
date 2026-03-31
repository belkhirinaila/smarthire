import 'package:flutter/material.dart';

class ExperienceEducationScreen extends StatefulWidget {
  const ExperienceEducationScreen({super.key});

  @override
  State<ExperienceEducationScreen> createState() =>
      _ExperienceEducationScreenState();
}

class _ExperienceEducationScreenState extends State<ExperienceEducationScreen> {
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
  /// Liste des expériences
  /// Chaque expérience contient ses propres controllers
  /// Plus tard: viendra du backend
  /// ==============================
  final List<Map<String, TextEditingController>> experiences = [
    {
      "role": TextEditingController(text: "UI/UX Designer"),
      "company": TextEditingController(text: "Company name"),
      "period": TextEditingController(text: "2023 - Present"),
      "description": TextEditingController(
        text: "Describe your role, missions and achievements.",
      ),
    },
  ];

  /// ==============================
  /// Liste des éducations
  /// Chaque éducation contient ses propres controllers
  /// Plus tard: viendra du backend
  /// ==============================
  final List<Map<String, TextEditingController>> educations = [
    {
      "degree": TextEditingController(text: "Master Degree"),
      "school": TextEditingController(text: "University name"),
      "period": TextEditingController(text: "2020 - 2022"),
      "description": TextEditingController(
        text: "Describe your studies, specialization or academic projects.",
      ),
    },
  ];

  @override
  void dispose() {
    /// Libérer les controllers des expériences
    for (final exp in experiences) {
      for (final controller in exp.values) {
        controller.dispose();
      }
    }

    /// Libérer les controllers des éducations
    for (final edu in educations) {
      for (final controller in edu.values) {
        controller.dispose();
      }
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

                      _buildSectionHeaderWithAdd(
                        title: "Experience",
                        onAdd: _addExperience,
                      ),

                      const SizedBox(height: 14),

                      ...List.generate(
                        experiences.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildExperienceCard(index),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildSectionHeaderWithAdd(
                        title: "Education",
                        onAdd: _addEducation,
                      ),

                      const SizedBox(height: 14),

                      ...List.generate(
                        educations.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildEducationCard(index),
                        ),
                      ),

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
          "Experience & Education",
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
  /// Header section avec bouton Add
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
  /// Carte expérience
  /// ==============================
  Widget _buildExperienceCard(int index) {
    final item = experiences[index];

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
              const Expanded(
                child: Text(
                  "Experience Entry",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _removeExperience(index),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildInputField(
            label: "Role / Position",
            hint: "Enter your role",
            controller: item["role"]!,
            icon: Icons.work_outline_rounded,
          ),

          const SizedBox(height: 14),

          _buildInputField(
            label: "Company",
            hint: "Enter company name",
            controller: item["company"]!,
            icon: Icons.business_outlined,
          ),

          const SizedBox(height: 14),

          _buildInputField(
            label: "Period",
            hint: "Ex: 2022 - 2024",
            controller: item["period"]!,
            icon: Icons.calendar_month_outlined,
          ),

          const SizedBox(height: 14),

          _buildMultilineField(
            label: "Description",
            hint: "Describe your missions and achievements",
            controller: item["description"]!,
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Carte éducation
  /// ==============================
  Widget _buildEducationCard(int index) {
    final item = educations[index];

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
              const Expanded(
                child: Text(
                  "Education Entry",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _removeEducation(index),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildInputField(
            label: "Degree / Diploma",
            hint: "Enter your degree",
            controller: item["degree"]!,
            icon: Icons.school_outlined,
          ),

          const SizedBox(height: 14),

          _buildInputField(
            label: "School / University",
            hint: "Enter school name",
            controller: item["school"]!,
            icon: Icons.account_balance_outlined,
          ),

          const SizedBox(height: 14),

          _buildInputField(
            label: "Period",
            hint: "Ex: 2020 - 2022",
            controller: item["period"]!,
            icon: Icons.calendar_month_outlined,
          ),

          const SizedBox(height: 14),

          _buildMultilineField(
            label: "Description",
            hint: "Describe your studies or academic projects",
            controller: item["description"]!,
          ),
        ],
      ),
    );
  }

  /// ==============================
  /// Input simple réutilisable
  /// ==============================
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
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
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.30),
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.white.withOpacity(0.45),
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
      ],
    );
  }

  /// ==============================
  /// Input multiline réutilisable
  /// ==============================
  Widget _buildMultilineField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
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
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.30),
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
      ],
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
          onPressed: isSaving ? null : _saveExperienceEducation,
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
  /// Ajouter une expérience
  /// ==============================
  void _addExperience() {
    setState(() {
      experiences.add({
        "role": TextEditingController(),
        "company": TextEditingController(),
        "period": TextEditingController(),
        "description": TextEditingController(),
      });
    });
  }

  /// ==============================
  /// Supprimer une expérience
  /// ==============================
  void _removeExperience(int index) {
    if (experiences.length == 1) return;

    setState(() {
      for (final controller in experiences[index].values) {
        controller.dispose();
      }
      experiences.removeAt(index);
    });
  }

  /// ==============================
  /// Ajouter une éducation
  /// ==============================
  void _addEducation() {
    setState(() {
      educations.add({
        "degree": TextEditingController(),
        "school": TextEditingController(),
        "period": TextEditingController(),
        "description": TextEditingController(),
      });
    });
  }

  /// ==============================
  /// Supprimer une éducation
  /// ==============================
  void _removeEducation(int index) {
    if (educations.length == 1) return;

    setState(() {
      for (final controller in educations[index].values) {
        controller.dispose();
      }
      educations.removeAt(index);
    });
  }

  /// ==============================
  /// Save temporaire
  /// Plus tard: appel backend
  /// ==============================
  void _saveExperienceEducation() async {
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
        content: Text("Experience and education updated successfully"),
      ),
    );

    Navigator.pop(context);
  }
}