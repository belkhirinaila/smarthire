import 'package:flutter/material.dart';

// Ecran de succès affiché après la création du compte ou la validation OTP.
// Il présente une confirmation visuelle et offre deux actions principales :
// 1) aller vers le tableau de bord
// 2) compléter son profil selon le rôle.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  // Couleur principale utilisée pour les éléments interactifs et les accents.
  static const Color primaryBlue = Color(0xFF1E6CFF);

  @override
  Widget build(BuildContext context) {
    // Structure principale de l'écran : un Scaffold avec un fond en dégradé.
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
          // Padding horizontal pour conserver des marges sur les côtés.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Success",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                // Illustration principale : un grand cercle de confirmation avec
                // une coche au centre, renforçant visuellement le succès.
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E6CFF), Color(0xFF2D9CFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF1E6CFF),
                        size: 46,
                      ),
                    ),
                  ),
                ),

                // Petite animation de félicitations : carrés colorés disposés
                // en forme de confettis pour renforcer le message de réussite.
                const SizedBox(height: 18),
                Opacity(
                  opacity: 0.35,
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: List.generate(
                      8,
                      (i) => Transform.rotate(
                        angle: (i % 2 == 0) ? 0.4 : -0.35,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: i % 3 == 0
                                ? Colors.white
                                : (i % 3 == 1 ? primaryBlue : Colors.tealAccent),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Message principal de confirmation affiché en grand.
                const Text(
                  "Account Created!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Welcome to the future of hiring in\nAlgeria.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                const Spacer(),

                // Premier bouton d'action : redirige vers le tableau de bord adapté au rôle.
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                 onPressed: () {
                    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                   final role = args['role'];
                  if (role == "candidate") {
                    Navigator.pushReplacementNamed(context, '/candidate');
                 } else {
                    Navigator.pushReplacementNamed(context, '/recruiter');
                  }
                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Go to Dashboard",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Deuxième bouton d'action : propose de compléter le profil
                // après la création du compte, avec navigation dépendante du rôle.
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  final role = args['role'];
  if (role == "candidate") {
    Navigator.pushReplacementNamed(context, '/edit-profile');
  } else {
    Navigator.pushReplacementNamed(context, '/company-profile');
  }
},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.18)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Complete My Profile",
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