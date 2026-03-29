import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);

  // Etats pour afficher/masquer password
  bool obscure1 = true;
  bool obscure2 = true;

  // Etat loading pour désactiver bouton
  bool isLoading = false;

  // Controllers pour récupérer les valeurs saisies
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  /// ==============================
  /// Fonction principale: Reset Password
  /// ==============================
  Future<void> resetPassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    // 🔹 Récupérer email depuis navigation (arguments)
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final email = args['email'];

    // 🔹 Vérifier champs vides
    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs sont obligatoires")),
      );
      return;
    }

    // 🔹 Vérifier longueur minimale
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le mot de passe doit contenir au moins 6 caractères"),
        ),
      );
      return;
    }

    // 🔹 Vérifier correspondance password
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Les mots de passe ne correspondent pas"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 🔹 Envoyer requête au backend
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/auth/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "newPassword": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        // 🔹 Succès → aller à écran confirmation
        Navigator.pushReplacementNamed(context, '/password-success');
      } else {
        // 🔹 Erreur backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur")),
        );
      }
    } catch (e) {
      // 🔹 Erreur serveur
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
    return Scaffold(
      // 🔹 Important pour éviter overflow avec clavier
      resizeToAvoidBottomInset: true,

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
          // 🔹 Scroll pour éviter overflow
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                /// 🔹 Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                    ),
                    const Spacer(),
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),

                const SizedBox(height: 26),

                /// 🔹 Titre principal
                const Text(
                  "Set New\nPassword",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔹 Description
                Text(
                  "Your new password must be different from\npreviously used passwords.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 34),

                /// 🔹 Champ password
                const Text("New Password",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),

                _PasswordInput(
                  controller: passwordController,
                  obscure: obscure1,
                  onToggle: () => setState(() => obscure1 = !obscure1),
                ),

                const SizedBox(height: 26),

                /// 🔹 Champ confirmation
                const Text("Confirm New Password",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),

                _PasswordInput(
                  controller: confirmController,
                  obscure: obscure2,
                  onToggle: () => setState(() => obscure2 = !obscure2),
                ),

                const SizedBox(height: 40),

                /// 🔹 Bouton
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Update Password",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ==============================
/// Champ password réutilisable
/// ==============================
class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordInput({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),

        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}