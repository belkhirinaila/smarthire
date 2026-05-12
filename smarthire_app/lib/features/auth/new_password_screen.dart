// Import des packages nécessaires :
// - dart:convert pour encoder/décoder le JSON utilisé dans les requêtes HTTP
// - flutter/material.dart pour les widgets de l'interface utilisateur
// - package:http pour envoyer les requêtes vers le backend
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Widget étatful qui représente l'écran de réinitialisation du mot de passe.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  // Couleur principale utilisée dans l'interface, notamment pour les boutons.
  static const Color primaryBlue = Color(0xFF1E6CFF);

  // Etats pour masquer ou afficher les champs de mot de passe.
  // obscure1 correspond au champ "nouveau mot de passe".
  // obscure2 correspond au champ "confirmation du mot de passe".
  bool obscure1 = true;
  bool obscure2 = true;

  // Etat de chargement utilisé pour désactiver le bouton pendant la requête.
  bool isLoading = false;

  // Contrôleurs pour récupérer et manipuler les valeurs saisies.
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  // Méthode appelée lorsque ce State est supprimé. Elle libère les ressources des contrôleurs.
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  /// ==============================
  /// Fonction principale: Reset Password
  /// ==============================
  // Fonction appelée lors de la soumission du formulaire pour mettre à jour le mot de passe.
  // Elle effectue plusieurs validations avant d'envoyer la requête au backend.
  Future<void> resetPassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    // Récupération de l'email transmis depuis l'écran précédent via les arguments de navigation.
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final email = args['email'];

    // Vérifications côté client avant l'envoi de la requête : champs requis.
    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs sont obligatoires")),
      );
      return;
    }

    // Vérification de la longueur minimale du mot de passe pour sécurité.
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le mot de passe doit contenir au moins 6 caractères"),
        ),
      );
      return;
    }

    // Vérification que le mot de passe et sa confirmation sont identiques.
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Les mots de passe ne correspondent pas"),
        ),
      );
      return;
    }

    // Activation de l'indicateur de chargement et désactivation du bouton.
    setState(() {
      isLoading = true;
    });

    try {
      // Envoi de la requête POST au backend avec l'email et le nouveau mot de passe.
      final response = await http.post(
        Uri.parse("http://192.168.100.47:5000/api/auth/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "newPassword": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      // Si le backend retourne un succès, on redirige vers l'écran de confirmation.
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/password-success');
      } else {
        // En cas d'erreur, on affiche le message renvoyé par le serveur.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur")),
        );
      }
    } catch (e) {
      // Gestion des erreurs réseau ou exceptions inattendues.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur serveur")),
      );
    } finally {
      // Arrêt de l'indicateur de chargement quel que soit le résultat.
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  // Construction de l'interface utilisateur de l'écran de réinitialisation.
  Widget build(BuildContext context) {
    return Scaffold(
      // Permet à l'écran de se redimensionner lorsque le clavier apparaît.
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
          // Scroll pour éviter les débordements quand le clavier est ouvert.
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                /// En-tête de l'écran avec bouton retour et titre.
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

                /// Titre principal de l'écran qui indique l'action attendue.
                const Text(
                  "Set New\nPassword",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                /// Description d'aide pour préciser les exigences du nouveau mot de passe.
                Text(
                  "Your new password must be different from\npreviously used passwords.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 34),

                /// Champ pour saisir le nouveau mot de passe.
                const Text("New Password",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),

                _PasswordInput(
                  controller: passwordController,
                  obscure: obscure1,
                  onToggle: () => setState(() => obscure1 = !obscure1),
                ),

                const SizedBox(height: 26),

                /// Champ pour confirmer le nouveau mot de passe.
                const Text("Confirm New Password",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),

                _PasswordInput(
                  controller: confirmController,
                  obscure: obscure2,
                  onToggle: () => setState(() => obscure2 = !obscure2),
                ),

                const SizedBox(height: 40),

                /// Bouton de validation qui déclenche la réinitialisation.
                /// Il est désactivé tant que la requête est en cours.
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
/// Ce widget encapsule le comportement d'un champ de saisie masqué,
/// avec une icône permettant de basculer l'affichage du texte.
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
  // Construction du champ de mot de passe avec icône de visibilité.
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

        // Icône affichée à droite pour basculer l'affichage du mot de passe.
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