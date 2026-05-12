import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  /// ==============================
  /// Base URL API
  /// ==============================
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  /// ==============================
  /// Etats
  /// ==============================
  bool isSaved = false;
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;
  Map<String, dynamic>? job;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => fetchJob());
  }

  /// ==============================
  /// Récupérer les détails du job
  /// ==============================
  Future<void> fetchJob() async {
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      final jobId = args?['id'];

      if (jobId == null) {
        setState(() {
          isLoading = false;
          errorMessage = "Job ID introuvable";
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/jobs/$jobId'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        job = data['job'];

        /// Vérifier si ce job est déjà sauvegardé
        await checkIfSaved(jobId);

        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = data['message'] ?? "Erreur lors du chargement du job";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur de connexion";
      });
    }
  }

  /// ==============================
  /// Vérifier si le job est déjà sauvegardé
  /// ==============================
  Future<void> checkIfSaved(dynamic jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        isSaved = false;
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/saved-jobs/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> savedJobs = data['jobs'] ?? [];

        isSaved = savedJobs.any((savedJob) => savedJob['id'] == jobId);
      } else {
        isSaved = false;
      }
    } catch (e) {
      isSaved = false;
    }
  }

  /// ==============================
  /// Sauvegarder / supprimer des favoris
  /// ==============================
  Future<void> toggleSaveJob() async {
    final currentJobId = job?['id'];

    if (currentJobId == null || isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() {
          isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Token introuvable. Veuillez vous reconnecter."),
          ),
        );
        return;
      }

      http.Response response;

      if (!isSaved) {
        response = await http.post(
          Uri.parse('$baseUrl/saved-jobs'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'job_id': currentJobId,
          }),
        );
      } else {
        response = await http.delete(
          Uri.parse('$baseUrl/saved-jobs/$currentJobId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final bool newSavedState = !isSaved;

        setState(() {
          isSaved = newSavedState;
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ??
                  (newSavedState
                      ? "Job sauvegardé"
                      : "Job supprimé des favoris"),
            ),
          ),
        );
      } else {
        setState(() {
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? "Erreur lors de la sauvegarde",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur de connexion au serveur"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final String title = job?['title'] ?? "Job title";
    final String company = job?['company_name'] ?? "Company name";
    final String location = job?['location'] ?? "Location";
    final String salary = job?['salary']?.toString() ?? "Salary";
    final String type = job?['type']?.toString() ?? "FULL-TIME";
    final String description =
     job?['description'] ?? "No description available for this job yet.";

    final List<dynamic> requirements =
    job?['requirements'] is List ? job!['requirements'] : [];

    return Scaffold(
      backgroundColor: backgroundBottom,
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
                      _buildAboutRoleCard(
                        experience: job?["experience"]?.toString() ?? "-",
                       education: job?["education"] ?? "-",
                       languages: job?["languages"] ?? "-",
                       team: job?["team"] ?? "-",
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  /// ==============================
  /// Barre supérieure
  /// ==============================
  Widget _buildTopBar() {
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
          "Job Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: toggleSaveJob,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: isSaving
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
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
          GestureDetector(

           onTap: () {

             Navigator.pushNamed(
               context,
               '/candidate-company-profile',
               arguments: job?["company_id"] ?? 0,
              );

            },
 
           child: Text(
             "$company • $location",
              textAlign: TextAlign.center,
              style: TextStyle(
               color: Colors.white.withOpacity(0.55),
               fontSize: 15,
               fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 18),
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
    if (requirements.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Text(
          "No specific requirements available yet.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      );
    }

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
  Widget _buildAboutRoleCard({
  required String experience,
  required String education,
  required String languages,
  required String team,
}) {
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
          value: experience,
        ),

        const SizedBox(height: 16),

        _buildRoleInfoRow(
          icon: Icons.school_outlined,
          label: "Education",
          value: education,
        ),

        const SizedBox(height: 16),

        _buildRoleInfoRow(
          icon: Icons.language_rounded,
          label: "Languages",
          value: languages,
        ),

        const SizedBox(height: 16),

        _buildRoleInfoRow(
          icon: Icons.people_outline_rounded,
          label: "Team",
          value: team,
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
  Widget _buildBottomActionBar() {
    final currentJob = job;

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
          GestureDetector(
            onTap: toggleSaveJob,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isSaved ? primaryBlue : Colors.white,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/apply',
                    arguments: currentJob,
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