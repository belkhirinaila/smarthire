// Import des bibliothèques nécessaires :
// - dart:async pour le timer de compte à rebours.
// - dart:convert pour encoder/décoder le JSON des requêtes HTTP.
// - flutter/material.dart pour les widgets visuels.
// - flutter/services.dart pour le filtrage des entrées numériques.
// - package:http pour appel au backend.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// Ecran de saisie du code OTP envoyé lors de la réinitialisation de mot de passe.
// L'email est passé depuis l'écran précédent afin de l'utiliser dans les requêtes.
class ResetOtpScreen extends StatefulWidget {
  final String email;

  const ResetOtpScreen({super.key, required this.email});

  @override
  State<ResetOtpScreen> createState() => _ResetOtpScreenState();
}

class _ResetOtpScreenState extends State<ResetOtpScreen> {
  // Couleur principale de l'écran utilisée pour le bouton et les éléments focusés.
  static const Color primaryBlue = Color(0xFF1E6CFF);

  // Contrôleurs de texte pour les 4 champs OTP individuels.
  // Chaque controller contient un seul chiffre.
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  final _c4 = TextEditingController();

  // FocusNodes pour permettre la navigation automatique entre les champs OTP.
  // Lorsqu'un chiffre est saisi, le focus passe à la case suivante.
  final _f1 = FocusNode();
  final _f2 = FocusNode();
  final _f3 = FocusNode();
  final _f4 = FocusNode();

  // Timer utilisé pour bloquer le renvoi de code pendant 59 secondes.
  Timer? _timer;
  int _seconds = 59;

  // Etats d'affichage de chargement pour les boutons Verify et Resend.
  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    // Démarrage du compte à rebours dès que l'écran est affiché.
    _startTimer();
  }

  /// ==============================
  /// Démarrer le compte à rebours
  /// ==============================
  void _startTimer() {
    // Annule tout timer précédent pour éviter plusieurs timers actifs.
    _timer?.cancel();

    // Réinitialise le compteur à 59 secondes.
    setState(() => _seconds = 59);

    // Lance un timer périodique qui décompte chaque seconde.
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (_seconds <= 0) {
        // Lorsque le temps est écoulé, arrêter le timer.
        t.cancel();
      } else {
        // Décrémenter le compteur et redessiner l'écran.
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    /// Annuler le timer
    _timer?.cancel();

    /// Libérer les controllers
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();

    /// Libérer les focus nodes
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    _f4.dispose();

    super.dispose();
  }

  /// Récupérer le code complet
  String get code => "${_c1.text}${_c2.text}${_c3.text}${_c4.text}";

  /// ==============================
  /// Vérifier OTP avec le backend
  /// ==============================
  /// Cette méthode envoie le code OTP saisi au serveur pour validation.
  /// Si le code est correct, elle redirige l'utilisateur vers l'étape suivante.
  Future<void> _verify() async {
    final otp = code;

    // Vérifie que l'utilisateur a bien saisi les 4 chiffres du code.
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrez le code complet")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.100.47:5000/api/auth/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        /// Aller à l'écran du nouveau mot de passe avec email
        Navigator.pushReplacementNamed(
          context,
          '/new-password',
          arguments: {
            "email": widget.email,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur OTP")),
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

  /// ==============================
  /// Renvoyer un nouveau code OTP
  /// ==============================
  /// Cette fonction est déclenchée lorsque l'utilisateur demande un nouveau code.
  /// Elle est désactivée tant que le compte à rebours n'est pas terminé.
  Future<void> _resendCode() async {
    // Empêche le renvoi tant que le délai est encore en cours.
    if (_seconds > 0) return;

    setState(() {
      isResending = true;
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.100.47:5000/api/auth/resend-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Code renvoyé")),
        );

        /// Relancer le timer après renvoi réussi
        _startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur resend")),
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
        isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resendEnabled = _seconds == 0;

    // Construction de l'interface utilisateur complète de l'écran.
    return Scaffold(
      /// Permet à l'écran de s'adapter au clavier.
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
          /// Scroll pour éviter le yellow overflow
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                        const Spacer(),
                        const Text(
                          "Verification",
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

                    /// Icône email
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.25),
                                blurRadius: 25,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mail_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF22C55E),
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    /// Titre principal
                    const Text(
                      "Check your email",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Texte explicatif
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 15,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(
                            text: "We've sent a 4-digit verification code to\n",
                          ),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Cases OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _WhiteOtpBox(
                          controller: _c1,
                          focusNode: _f1,
                          next: _f2,
                          autoFocus: true,
                        ),
                        _WhiteOtpBox(
                          controller: _c2,
                          focusNode: _f2,
                          prev: _f1,
                          next: _f3,
                        ),
                        _WhiteOtpBox(
                          controller: _c3,
                          focusNode: _f3,
                          prev: _f2,
                          next: _f4,
                        ),
                        _WhiteOtpBox(
                          controller: _c4,
                          focusNode: _f4,
                          prev: _f3,
                          onDone: _verify,
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    /// Texte resend
                    Text(
                      "Didn't receive a code?",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Bouton resend avec timer
                    GestureDetector(
                      onTap: (resendEnabled && !isResending) ? _resendCode : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Colors.white.withOpacity(0.65),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            isResending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    resendEnabled
                                        ? "Resend code"
                                        : "Resend in 00:${_seconds.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(
                                        resendEnabled ? 0.9 : 0.6,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// Bouton verify
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _verify,
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Verify & Continue",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Revenir pour changer email
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Try another email address",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    /// Espace supplémentaire pour éviter overflow
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ==============================
/// Widget OTP BOX
/// Chaque case contient un seul chiffre
/// ==============================
/// Widget réutilisable pour une case du code OTP, gérant le focus et la saisie.
class _WhiteOtpBox extends StatelessWidget {
  static const Color primaryBlue = Color(0xFF1E6CFF);

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? next;
  final FocusNode? prev;
  final bool autoFocus;
  final VoidCallback? onDone;

  const _WhiteOtpBox({
    required this.controller,
    required this.focusNode,
    this.next,
    this.prev,
    this.autoFocus = false,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          color: Colors.black,
          fontSize: 26,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.65)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: primaryBlue, width: 2.2),
          ),
        ),
        onChanged: (v) {
          // Lorsque l'utilisateur saisit un chiffre, le focus passe automatiquement
          // au champ suivant. Si c'est le dernier champ, la validation est déclenchée.
          if (v.isNotEmpty) {
            if (next != null) {
              FocusScope.of(context).requestFocus(next);
            } else {
              FocusScope.of(context).unfocus();
              onDone?.call();
            }
          } else {
            // Si l'utilisateur supprime le chiffre et que le champ devient vide,
            // le focus revient sur le champ précédent.
            if (prev != null) {
              FocusScope.of(context).requestFocus(prev);
            }
          }
        },
        onSubmitted: (_) => onDone?.call(),
      ),
    );
  }
}