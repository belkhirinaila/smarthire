import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Écran de connexion principal de l'application.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Couleur principale utilisée dans l'interface de connexion.
  static const Color primaryBlue = Color(0xFF1E6CFF);

  /// ==============================
  /// Base URL API
  /// ==============================
  static const String baseUrl = 'http://192.168.100.47:5000/api';

  bool _obscure = true;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  // Libération des contrôleurs lorsque le widget est supprimé.
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Méthode d'authentification qui valide les champs, appelle l'API et gère la navigation.
  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Vérification que l'utilisateur a bien renseigné les deux champs.
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Remplis tous les champs")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        /// ==============================
        /// Sauvegarde du token + infos user
        /// ==============================
        final prefs = await SharedPreferences.getInstance();

        final String? token = data['token'];
        final String? role = data['user']?['role'];
        final dynamic userId = data['user']?['id'];

        if (token != null && token.isNotEmpty) {
          await prefs.setString('token', token);
        }

        if (role != null) {
          await prefs.setString('role', role);
        }

        if (userId != null) {
          await prefs.setString('user_id', userId.toString());
        }

        /// Debug temporaire
        debugPrint("TOKEN SAVED: ${prefs.getString('token')}");
        debugPrint("ROLE SAVED: ${prefs.getString('role')}");

        if (role == "candidate") {
          Navigator.pushReplacementNamed(context, '/candidate');
        } else if (role == "company" || role == "recruiter") {
          Navigator.pushReplacementNamed(context, '/recruiter');
        } else if (role == "admin") {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Erreur login')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint("catch error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur serveur: $e")),
      );
    }
  }

  @override
  // Construction de l'interface utilisateur de l'écran de connexion.
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // En-tête avec logo et nom de l'application.
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "SmartHire DZ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Find your next career move in Algeria",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 26),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email Address",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      _Input(
                        controller: emailController,
                        hint: "name@example.dz",
                        prefix: Icons.mail_outline_rounded,
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Password",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      _Input(
                        controller: passwordController,
                        hint: "••••••••",
                        prefix: Icons.lock_outline_rounded,
                        suffix: _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        onSuffixTap: () => setState(() => _obscure = !_obscure),
                        obscure: _obscure,
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/reset-password');
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color(0xFF2D9CFF),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : loginUser,
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
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.login_rounded),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.15)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "OR CONTINUE WITH",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.15)),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: const [
                    Expanded(
                      child: _SocialButton(
                        label: "Google",
                        icon: Icons.g_mobiledata,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: _SocialButton(
                        label: "LinkedIn",
                        icon: Icons.work,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 38),

                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 14,
                      ),
                      children: const [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Create Account",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget réutilisable pour un champ de saisie personnalisé.
class _Input extends StatelessWidget {
  final String hint;
  final IconData prefix;
  final IconData? suffix;
  final VoidCallback? onSuffixTap;
  final bool obscure;
  final TextEditingController? controller;

  const _Input({
    required this.hint,
    required this.prefix,
    this.suffix,
    this.onSuffixTap,
    this.obscure = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        filled: true,
        fillColor: Colors.black.withOpacity(0.12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        prefixIcon: Icon(prefix, color: Colors.white.withOpacity(0.55)),
        suffixIcon: suffix == null
            ? null
            : InkWell(
                onTap: onSuffixTap,
                child: Icon(suffix, color: Colors.white.withOpacity(0.45)),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1E6CFF), width: 1.6),
        ),
      ),
    );
  }
}

// Bouton générique pour les options de connexion sociales.
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SocialButton({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}