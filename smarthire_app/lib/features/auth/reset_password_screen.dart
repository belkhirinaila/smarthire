// Import des packages nécessaires :
// - flutter/material.dart pour les widgets de l'interface utilisateur
// - dart:convert pour encoder les données JSON envoyées au backend
// - package:http pour effectuer les requêtes HTTP vers l'API
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Ecran de demande de réinitialisation de mot de passe.
// Il permet à l'utilisateur de saisir son adresse email et
// d'envoyer un code de reset via le backend.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E6CFF);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  // Contrôleur pour récupérer l'email saisi dans le champ de texte.
  final TextEditingController emailController = TextEditingController();

  // Etat de chargement utilisé pour désactiver le bouton pendant l'appel API.
  bool isLoading = false;

  /// ==============================
  /// Envoyer email pour reset password
  /// ==============================
  /// Cette méthode valide l'email, appelle l'API et redirige vers l'écran OTP.
  Future<void> sendResetCode() async {

    final email = emailController.text.trim();

    // Validation côté client : vérifier que l'utilisateur a bien saisi un email.
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email requis")),
      );
      return;
    }

    // Passage en état de chargement pour indiquer que la requête est en cours.
    setState(() {
      isLoading = true;
    });

    try {
      // Envoi d'une requête POST au backend avec l'email de l'utilisateur.
      final response = await http.post(
        Uri.parse("http://192.168.100.47:5000/api/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {

        // Si le backend renvoie un succès, on navigue vers l'écran OTP.
        // L'email est transmis en argument pour l'étape suivante.
        Navigator.pushReplacementNamed(
          context,
          '/reset-otp',
          arguments: {
            "email": email,
          },
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur")),
        );
      }

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur serveur")),
      );
    } finally {
      if (!mounted) return;

      // Retour à l'état initial une fois la requête terminée.
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construction de l'interface utilisateur de l'écran de réinitialisation.
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

                const SizedBox(height: 25),

                // Titre principal qui explique l'objectif de la page.
                const Text(
                  "Reset Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 30),

                /// Champ de saisie de l'email.
                /// Le contenu est géré par emailController.
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// Bouton d'envoi du code de réinitialisation.
                /// Il est désactivé pendant le chargement de la requête.
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : sendResetCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ResetPasswordScreen.primaryBlue,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Send Reset Code"),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}