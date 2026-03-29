import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);

  // 0 = candidate, 1 = recruiter
  int selected = 0;
  bool isLoading = false;

  /// ==============================
  /// Envoyer les données d'inscription au backend
  /// ==============================
  Future<void> registerUser() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Nettoyer les données avant envoi
    final fullName = (args['full_name'] ?? '').toString().trim();
    final email = (args['email'] ?? '').toString().trim();
    final password = (args['password'] ?? '').toString();

    // IMPORTANT:
    // recruiter au lieu de company pour correspondre à la base de données
    final role = selected == 0 ? 'candidate' : 'recruiter';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": fullName,
          "email": email,
          "password": password,
          "role": role,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Compte créé avec succès')),
        );

        // Aller vers OTP avec l'email nettoyé
        Navigator.pushReplacementNamed(
          context,
          '/otp',
          arguments: {
            'email': email,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Erreur inscription')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur serveur")),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return const Scaffold(
        body: Center(
          child: Text("Aucune donnée reçue"),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1B33), Color(0xFF070A10)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Choose your role",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Select how you will use SmartHire DZ.\nYou can change this later.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 26),

                _RoleCard(
                  title: "Candidate",
                  subtitle: "Find jobs, apply, and track your applications.",
                  icon: Icons.person_rounded,
                  isSelected: selected == 0,
                  onTap: () => setState(() => selected = 0),
                ),

                const SizedBox(height: 14),

                _RoleCard(
                  title: "Recruiter",
                  subtitle: "Post jobs and manage candidates easily.",
                  icon: Icons.business_center_rounded,
                  isSelected: selected == 1,
                  onTap: () => setState(() => selected = 1),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.4,
                            ),
                          )
                        : const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  static const Color primaryBlue = Color(0xFF1E6CFF);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.18),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryBlue.withOpacity(0.18)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? primaryBlue : Colors.white.withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }
}