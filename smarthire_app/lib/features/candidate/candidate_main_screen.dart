import 'package:flutter/material.dart';
import 'package:smarthire_app/features/candidate/candidate_home_screen.dart';
import 'package:smarthire_app/features/candidate/applications/applications_list_screen.dart';
import 'package:smarthire_app/features/candidate/requests/messages_screen.dart';
import 'package:smarthire_app/features/candidate/profile/candidate_profile_screen.dart';

// Écran principal du candidat qui contient la navigation basse
// et les écrans enfants correspondants aux sections principales.
class CandidateMainScreen extends StatefulWidget {
  const CandidateMainScreen({super.key});

  @override
  State<CandidateMainScreen> createState() => _CandidateMainScreenState();
}

class _CandidateMainScreenState extends State<CandidateMainScreen> {
  /// ==============================
  /// Couleurs principales
  /// ==============================
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundBottom = Color(0xFF050A12);

  /// ==============================
  /// Index actif de la bottom navigation
  /// ==============================
  ///
  /// currentIndex représente l'écran actuellement visible.
  /// Il est utilisé par l'IndexedStack ci-dessous pour garder
  /// l'état des écrans tout en ne montrant qu'un seul écran à la fois.
  int currentIndex = 0;

  /// ==============================
  /// Ecrans principaux du candidat
  /// ==============================
  ///
  /// Cette liste contient les différents écrans accessibles via
  /// la barre de navigation du bas. Le même index est utilisé
  /// pour afficher l'écran actif dans l'IndexedStack.
  final List<Widget> screens = const [
    CandidateHomeScreen(),
    ApplicationsListScreen(),
    MessagesScreen(),
    CandidateProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Build principal de l'écran candidat.
    // Utilise un Scaffold pour la structure générale.
    return Scaffold(
      backgroundColor: backgroundBottom,
      body: IndexedStack(
        // L'IndexedStack conserve l'état de tous les écrans enfants
        // même lorsque l'utilisateur navigue entre eux.
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        // Conteneur de la barre de navigation inférieure.
        color: backgroundBottom,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220).withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.travel_explore_rounded,
                label: "Explore",
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.description_outlined,
                label: "Applications",
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.chat_bubble_outline_rounded,
                label: "Messages",
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ==============================
  /// Item réutilisable de navigation
  /// ==============================
  ///
  /// Ce widget construit un onglet de la barre de navigation en bas.
  /// Il gère l'état sélectionné et met à jour l'écran actif lors du tap.
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        // Si l'onglet sélectionné est déjà actif, on ne fait rien.
        if (currentIndex == index) return;

        // Sinon, on change l'index actif et on déclenche un rebuild.
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryBlue : Colors.white.withOpacity(0.65),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              // Le texte et l'icône changent de couleur selon l'état actif.
              color: isSelected ? primaryBlue : Colors.white.withOpacity(0.65),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}