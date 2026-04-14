// Import des packages nécessaires :
// - dart:convert pour le décodage JSON.
// - flutter/material.dart pour l'interface utilisateur Flutter.
// - http pour les requêtes vers l'API.
// - shared_preferences pour récupérer le token stocké localement.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Écran principal de gestion des expériences et formations du candidat.
// Cet écran affiche les sections "Experience" et "Education" et permet
// d'ajouter, modifier ou supprimer des éléments.
class ExperienceEducationScreen extends StatefulWidget {
  const ExperienceEducationScreen({super.key});

  @override
  State<ExperienceEducationScreen> createState() =>
      _ExperienceEducationScreenState();
}

class _ExperienceEducationScreenState extends State<ExperienceEducationScreen> {
  // Couleurs de l'interface utilisées pour les boutons et le fond.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  // URL de base de l'API.
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  // États pour le chargement de la page, l'état de sauvegarde et les erreurs.
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  // Listes contenant les expériences et les formations du candidat.
  List<Map<String, dynamic>> experiences = [];
  List<Map<String, dynamic>> educations = [];

  @override
  void initState() {
    super.initState();
    // Démarrage initial : on charge les données existantes depuis l'API.
    loadExperienceAndEducation();
  }

  // Récupère le token d'authentification depuis le stockage local.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Charge les expériences et formations de l'utilisateur connecté.
  Future<void> loadExperienceAndEducation() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await _getToken();

      // Vérifie la présence du token avant d'effectuer les appels API.
      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable. Veuillez vous reconnecter.";
        });
        return;
      }

      // Requête pour récupérer les expériences du candidat.
      final expResponse = await http.get(
        Uri.parse('$baseUrl/experience/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Requête pour récupérer les formations du candidat.
      final eduResponse = await http.get(
        Uri.parse('$baseUrl/education/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (expResponse.statusCode == 200) {
        final expData = jsonDecode(expResponse.body);
        // Convertit les données en liste de maps pour l'affichage.
        experiences = List<Map<String, dynamic>>.from(expData['experiences'] ?? []);
      } else {
        experiences = [];
      }

      if (eduResponse.statusCode == 200) {
        final eduData = jsonDecode(eduResponse.body);
        educations = List<Map<String, dynamic>>.from(eduData['education'] ?? []);
      } else {
        educations = [];
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion au serveur";
      });
    }
  }

  // Ouvre une boîte de dialogue pour ajouter une nouvelle expérience.
  // Si l'utilisateur confirme, la nouvelle expérience est envoyée à l'API.
  Future<void> _addExperience() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _ExperienceDialog(),
    );

    // Si la boîte de dialogue est fermée sans sauvegarde, on ne fait rien.
    if (result == null) return;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.post(
        Uri.parse('$baseUrl/experience'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(result),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Experience ajoutée avec succès'),
          ),
        );
        // Recharge les listes après ajout.
        await loadExperienceAndEducation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erreur lors de l’ajout'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion au serveur")),
      );
    }
  }

  // Ouvre une boîte de dialogue pour modifier une expérience existante.
  // Les champs sont préremplis avec les valeurs actuelles.
  Future<void> _editExperience(Map<String, dynamic> item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _ExperienceDialog(
        initialJobTitle: (item['job_title'] ?? '').toString(),
        initialCompany: (item['company'] ?? '').toString(),
        initialStartDate: _formatDateInput(item['start_date']),
        initialEndDate: _formatDateInput(item['end_date']),
        initialDescription: (item['description'] ?? '').toString(),
      ),
    );

    if (result == null) return;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.put(
        Uri.parse('$baseUrl/experience/${item['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(result),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Experience mise à jour avec succès'),
          ),
        );
        await loadExperienceAndEducation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erreur lors de la mise à jour'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion au serveur")),
      );
    }
  }

  // Supprime une expérience identifiée par son ID.
  Future<void> _deleteExperience(int id) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.delete(
        Uri.parse('$baseUrl/experience/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Experience supprimée avec succès'),
          ),
        );
        await loadExperienceAndEducation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erreur lors de la suppression'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion au serveur")),
      );
    }
  }

  // Ouvre une boîte de dialogue pour ajouter une nouvelle formation.
  // Si l'utilisateur valide, les données sont envoyées à l'API.
  Future<void> _addEducation() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _EducationDialog(),
    );

    if (result == null) return;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.post(
        Uri.parse('$baseUrl/education'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(result),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Education ajoutée avec succès'),
          ),
        );
        await loadExperienceAndEducation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erreur lors de l’ajout'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion au serveur")),
      );
    }
  }

  // Ouvre une boîte de dialogue pour modifier une formation existante.
  // Les champs sont remplis avec l'état actuel de l'élément.
  Future<void> _editEducation(Map<String, dynamic> item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EducationDialog(
        initialSchool: (item['school'] ?? '').toString(),
        initialDegree: (item['degree'] ?? '').toString(),
        initialField: (item['field'] ?? '').toString(),
        initialStartDate: _formatDateInput(item['start_date']),
        initialEndDate: _formatDateInput(item['end_date']),
      ),
    );

    if (result == null) return;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.put(
        Uri.parse('$baseUrl/education/${item['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(result),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Education mise à jour avec succès'),
          ),
        );
        await loadExperienceAndEducation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erreur lors de la mise à jour'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion au serveur")),
      );
    }
  }

  // Supprime une formation identifiée par son ID.
  Future<void> _deleteEducation(int id) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.delete(
        Uri.parse('$baseUrl/education/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Education supprimée avec succès'),
          ),
        );
        await loadExperienceAndEducation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erreur lors de la suppression'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion au serveur")),
      );
    }
  }

  // Formate une date pour la réutiliser dans les champs de saisie.
  // On conserve seulement la partie YYYY-MM-DD si la valeur est plus longue.
  String _formatDateInput(dynamic value) {
    if (value == null) return '';
    final raw = value.toString();
    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }
    return raw;
  }

  // Formate une date pour l'affichage dans les cartes.
  // Retourne "Present" si la valeur est vide ou nulle.
  String _formatDateDisplay(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'Present';
    final raw = value.toString();
    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }
    return raw;
  }

  // Barre supérieure comprenant le bouton retour et le titre de la page.
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context, true),
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

  // En-tête de section réutilisable avec un bouton d'ajout à droite.
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

  // Carte d'affichage d'une expérience individuelle.
  // Contient les actions d'édition et de suppression.
  Widget _buildExperienceCard(Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                onTap: () => _editExperience(item),
                child: Container(
                  width: 42,
                  height: 42,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: primaryBlue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _deleteExperience(item['id'] as int),
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
          _buildInfoLine(Icons.work_outline_rounded, item['job_title'] ?? ''),
          const SizedBox(height: 12),
          _buildInfoLine(Icons.business_outlined, item['company'] ?? ''),
          const SizedBox(height: 12),
          _buildInfoLine(
            Icons.calendar_month_outlined,
            "${_formatDateDisplay(item['start_date'])} - ${_formatDateDisplay(item['end_date'])}",
          ),
          const SizedBox(height: 12),
          _buildDescription(item['description'] ?? ''),
        ],
      ),
    );
  }

  // Carte d'affichage d'une formation individuelle.
  // Contient les informations principales et les actions associées.
  Widget _buildEducationCard(Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                onTap: () => _editEducation(item),
                child: Container(
                  width: 42,
                  height: 42,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: primaryBlue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _deleteEducation(item['id'] as int),
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
          _buildInfoLine(Icons.school_outlined, item['degree'] ?? ''),
          const SizedBox(height: 12),
          _buildInfoLine(Icons.account_balance_outlined, item['school'] ?? ''),
          const SizedBox(height: 12),
          _buildInfoLine(Icons.menu_book_outlined, item['field'] ?? ''),
          const SizedBox(height: 12),
          _buildInfoLine(
            Icons.calendar_month_outlined,
            "${_formatDateDisplay(item['start_date'])} - ${_formatDateDisplay(item['end_date'])}",
          ),
        ],
      ),
    );
  }

  // Ligne de détail réutilisable avec une icône et du texte.
  Widget _buildInfoLine(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.55),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // Bloc d'affichage de la description d'une expérience.
  Widget _buildDescription(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.78),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  // Bouton bas de page qui permet de revenir et de fermer l'écran.
  Widget _buildBottomButton() {
    return Container(
      color: backgroundBottom,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: SizedBox(
        height: 58,
        child: ElevatedButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.pop(context, true);
                },
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
                  "Done",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Affiche un indicateur de chargement tant que les données ne sont pas prêtes.
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si une erreur est survenue pendant le chargement, on affiche un message.
    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: loadExperienceAndEducation,
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Affiche le contenu principal : sections d'expérience et d'éducation.
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
                      if (experiences.isEmpty)
                        _buildEmptyCard("No experience added yet"),
                      ...experiences.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildExperienceCard(item),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeaderWithAdd(
                        title: "Education",
                        onAdd: _addEducation,
                      ),
                      const SizedBox(height: 14),
                      if (educations.isEmpty)
                        _buildEmptyCard("No education added yet"),
                      ...educations.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildEducationCard(item),
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
      bottomNavigationBar: Container(
        color: backgroundBottom,
        child: SafeArea(
          top: false,
          child: _buildBottomButton(),
        ),
      ),
    );
  }

  // Carte affichée quand il n'y a pas d'élément dans la section.
  Widget _buildEmptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.65),
          fontSize: 14,
        ),
      ),
    );
  }
}

// Dialogue modal pour ajouter ou modifier une expérience.
// Les valeurs initiales peuvent être fournies pour l'édition.
class _ExperienceDialog extends StatefulWidget {
  final String initialJobTitle;
  final String initialCompany;
  final String initialStartDate;
  final String initialEndDate;
  final String initialDescription;

  const _ExperienceDialog({
    this.initialJobTitle = '',
    this.initialCompany = '',
    this.initialStartDate = '',
    this.initialEndDate = '',
    this.initialDescription = '',
  });

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  late final TextEditingController jobTitleController;
  late final TextEditingController companyController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;
  late final TextEditingController descriptionController;

  // Ouvre le sélecteur de date et met à jour le champ correspondant.
  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();

    DateTime initialDate = now;
    if (controller.text.trim().isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text.trim());
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1E6CFF),
              surface: Color(0xFF121C31),
            ),
            dialogBackgroundColor: Color(0xFF121C31),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().substring(0, 10);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs de saisie avec les valeurs reçues.
    jobTitleController = TextEditingController(text: widget.initialJobTitle);
    companyController = TextEditingController(text: widget.initialCompany);
    startDateController = TextEditingController(text: widget.initialStartDate);
    endDateController = TextEditingController(text: widget.initialEndDate);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    jobTitleController.dispose();
    companyController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121C31),
      title: const Text(
        "Experience",
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogInput(jobTitleController, "Job title"),
            const SizedBox(height: 12),
            _dialogInput(companyController, "Company"),
            const SizedBox(height: 12),
            _dialogDateInput(
              startDateController,
              "Start date",
              () => _pickDate(startDateController),
            ),
            const SizedBox(height: 12),
            _dialogDateInput(
              endDateController,
              "End date",
              () => _pickDate(endDateController),
            ),
            const SizedBox(height: 12),
            _dialogInput(descriptionController, "Description", maxLines: 4),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'job_title': jobTitleController.text.trim(),
              'company': companyController.text.trim(),
              'start_date': startDateController.text.trim(),
              'end_date': endDateController.text.trim(),
              'description': descriptionController.text.trim(),
            });
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  // Champ de date réutilisable qui ouvre le sélecteur au clic.
  Widget _dialogDateInput(
    TextEditingController controller,
    String hint,
    VoidCallback onTap,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
        suffixIcon: const Icon(
          Icons.calendar_month_outlined,
          color: Colors.white70,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Champ de saisie texte réutilisable pour l'alerte.
  Widget _dialogInput(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// Dialogue modal pour ajouter ou modifier une formation.
class _EducationDialog extends StatefulWidget {
  final String initialSchool;
  final String initialDegree;
  final String initialField;
  final String initialStartDate;
  final String initialEndDate;

  const _EducationDialog({
    this.initialSchool = '',
    this.initialDegree = '',
    this.initialField = '',
    this.initialStartDate = '',
    this.initialEndDate = '',
  });

  @override
  State<_EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<_EducationDialog> {
  late final TextEditingController schoolController;
  late final TextEditingController degreeController;
  late final TextEditingController fieldController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;

  // Ouvre le sélecteur de date et met à jour le champ associé.
  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();

    DateTime initialDate = now;
    if (controller.text.trim().isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text.trim());
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1E6CFF),
              surface: Color(0xFF121C31),
            ),
            dialogBackgroundColor: Color(0xFF121C31),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().substring(0, 10);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    schoolController = TextEditingController(text: widget.initialSchool);
    degreeController = TextEditingController(text: widget.initialDegree);
    fieldController = TextEditingController(text: widget.initialField);
    startDateController = TextEditingController(text: widget.initialStartDate);
    endDateController = TextEditingController(text: widget.initialEndDate);
  }

  @override
  void dispose() {
    schoolController.dispose();
    degreeController.dispose();
    fieldController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121C31),
      title: const Text(
        "Education",
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogInput(schoolController, "School"),
            const SizedBox(height: 12),
            _dialogInput(degreeController, "Degree"),
            const SizedBox(height: 12),
            _dialogInput(fieldController, "Field"),
            const SizedBox(height: 12),
            _dialogDateInput(
              startDateController,
              "Start date",
              () => _pickDate(startDateController),
            ),
            const SizedBox(height: 12),
            _dialogDateInput(
              endDateController,
              "End date",
              () => _pickDate(endDateController),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'school': schoolController.text.trim(),
              'degree': degreeController.text.trim(),
              'field': fieldController.text.trim(),
              'start_date': startDateController.text.trim(),
              'end_date': endDateController.text.trim(),
            });
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  // Champ de date readonly utilisé dans la boîte de dialogue.
  Widget _dialogDateInput(
    TextEditingController controller,
    String hint,
    VoidCallback onTap,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
        suffixIcon: const Icon(
          Icons.calendar_month_outlined,
          color: Colors.white70,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Champ de texte réutilisable dans le dialogue.
  Widget _dialogInput(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
