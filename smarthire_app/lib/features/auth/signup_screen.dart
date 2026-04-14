import 'package:flutter/material.dart';

// Ecran d'inscription permettant à l'utilisateur de créer un nouveau compte.
// Il recueille le nom complet, l'email, le mot de passe et l'acceptation des conditions.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Couleur principale utilisée pour les éléments interactifs.
  static const Color primaryBlue = Color(0xFF1E6CFF);

  // Contrôleurs pour récupérer le texte saisi dans chaque champ du formulaire.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Etat indiquant si l'utilisateur a accepté les termes et conditions.
  bool agreeTerms = false;

  // Etat pour masquer ou afficher le mot de passe.
  bool obscurePassword = true;

  @override
  // Libération des ressources des controllers lorsque le widget est détruit.
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Fonction appelée lorsque l'utilisateur valide le formulaire.
  // Elle vérifie les champs, s'assure que les conditions sont acceptées,
  // puis navigue vers l'écran de choix de rôle.
  void goToRoleScreen() {
    final fullName = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validation côté client : tous les champs doivent être remplis.
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Remplis tous les champs")),
      );
      return;
    }

    // L'utilisateur doit accepter les termes et conditions avant de continuer.
    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tu dois accepter les Terms & Conditions"),
        ),
      );
      return;
    }

    // Navigation vers l'écran de sélection de rôle après validation du formulaire.
    Navigator.pushNamed(
      context,
      '/role',
      arguments: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construction de l'interface du formulaire d'inscription.
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1B33),
              Color(0xFF070A10),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),

                const SizedBox(height: 18),

                // Titre principal de la page d'inscription.
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Join SmartHire DZ and find your dream job\nin Algeria.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.55),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                // Étiquette pour le champ du nom complet.
                const Text(
                  "Full Name",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                // Champ de saisie du nom complet.
                _inputField(
                  "Enter your full name",
                  controller: nameController,
                ),

                const SizedBox(height: 20),

                // Étiquette pour le champ de l'adresse email.
                const Text(
                  "Email Address",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                // Champ de saisie de l'email.
                _inputField(
                  "name@example.dz",
                  controller: emailController,
                ),

                const SizedBox(height: 20),

                // Étiquette pour le champ du mot de passe.
                const Text(
                  "Password",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                // Champ de saisie du mot de passe avec option de visibilité.
                _inputField(
                  "Create a password",
                  isPassword: true,
                  controller: passwordController,
                  obscurePassword: obscurePassword,
                  onTogglePassword: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),

                const SizedBox(height: 18),

                // Bloc de case à cocher pour accepter les termes et conditions.
                Row(
                  children: [
                    Checkbox(
                      value: agreeTerms,
                      onChanged: (v) {
                        setState(() {
                          agreeTerms = v ?? false;
                        });
                      },
                      activeColor: primaryBlue,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                          ),
                          children: const [
                            TextSpan(text: "I agree to the "),
                            TextSpan(
                              text: "Terms & Conditions",
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: " and\n"),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Bouton principal qui lance la validation du formulaire
                // puis la navigation vers l'étape suivante.
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: goToRoleScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Join SmartHire DZ",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withOpacity(0.15),
                      ),
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
                      child: Divider(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Séparateur puis options de connexion sociale.
                // Ces boutons sont affichés à titre esthétique et peuvent
                // être connectés à des services externes si nécessaire.
                Row(
                  children: [
                    Expanded(
                      child: _socialButton("LinkedIn"),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _socialButton("Google"),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Lien informatif vers la page de connexion existante.
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 14,
                      ),
                      children: const [
                        TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: "Log In",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget utilitaire pour créer un champ de saisie stylisé.
  // Il prend en charge les champs de mot de passe avec icône de visibilité.
  static Widget _inputField(
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
    bool obscurePassword = false,
    VoidCallback? onTogglePassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscurePassword : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        // Icône pour basculer l'affichage du mot de passe lorsqu'il s'agit d'un champ sécurisé.
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white.withOpacity(0.45),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryBlue, width: 1.4),
        ),
      ),
    );
  }

  // Bouton de style social. Aucune logique d'authentification n'est
  // encore attachée ici, c'est uniquement un rendu visuel.
  static Widget _socialButton(String text) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}