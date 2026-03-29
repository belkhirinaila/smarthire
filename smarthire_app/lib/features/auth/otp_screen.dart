import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// ==============================
/// OTP SCREEN
/// Cette page permet de :
/// 1) vérifier le code OTP
/// 2) renvoyer un nouveau code OTP
/// ==============================
class OtpScreen extends StatefulWidget {
  final String email; // Email reçu depuis l'écran précédent

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  /// Couleur principale utilisée dans l'écran
  static const Color primaryBlue = Color(0xFF1E6CFF);

  /// Controllers pour les 4 cases OTP
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  final _c4 = TextEditingController();

  /// FocusNodes pour passer automatiquement d'une case à l'autre
  late final FocusNode _f1 = FocusNode();
  late final FocusNode _f2 = FocusNode();
  late final FocusNode _f3 = FocusNode();
  late final FocusNode _f4 = FocusNode();

  /// Etat de chargement du bouton Verify
  bool isVerifying = false;

  /// Etat de chargement du bouton Resend
  bool isResending = false;

  /// Nombre de secondes restantes avant de pouvoir renvoyer le code
  int resendSeconds = 60;

  /// Timer pour le countdown
  Timer? _timer;

  /// Récupérer les 4 chiffres OTP sous forme d'une seule chaîne
  String get code => "${_c1.text}${_c2.text}${_c3.text}${_c4.text}";

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  /// ==============================
  /// Démarrer le countdown du bouton Resend
  /// ==============================
  void _startResendTimer() {
    resendSeconds = 60;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          resendSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    /// Annuler le timer pour éviter les erreurs mémoire
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

  /// ==============================
  /// Vérifier le code OTP
  /// ==============================
  Future<void> _verify() async {
    final otp = code;

    /// Vérifier si l'utilisateur a saisi les 4 chiffres
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrez le code OTP complet")),
      );
      return;
    }

    setState(() {
      isVerifying = true;
    });

    try {
      /// Envoyer le code OTP au backend pour vérification
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/auth/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      /// Si le code est correct -> aller vers success
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/success');
      } else {
        /// Si le code est incorrect ou expiré
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Code OTP incorrect")),
        );
      }
    } catch (e) {
      /// Si le serveur ne répond pas
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur serveur")),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isVerifying = false;
      });
    }
  }

  /// ==============================
  /// Renvoyer un nouveau code OTP
  /// ==============================
  Future<void> _resendOtp() async {
    /// Bloquer le renvoi si le timer n'est pas encore terminé
    if (resendSeconds > 0) return;

    setState(() {
      isResending = true;
    });

    try {
      /// Appel API pour renvoyer un nouveau code OTP
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/api/auth/resend-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Code OTP renvoyé')),
        );

        /// Réinitialiser le timer après un renvoi réussi
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Erreur renvoi OTP')),
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

  /// ==============================
  /// Interface utilisateur
  /// ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Permet à l'écran de s'adapter quand le clavier apparaît
      resizeToAvoidBottomInset: true,

      body: Container(
        width: double.infinity,

        /// Fond en dégradé
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1B33), Color(0xFF070A10)],
          ),
        ),

        child: SafeArea(
          /// Scroll pour éviter le overflow jaune avec le clavier
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    /// Bouton retour
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),

                    const SizedBox(height: 6),

                    /// Petit titre en haut
                    const Center(
                      child: Text(
                        "Verify Email",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Grand titre
                    const Text(
                      "Verify Your Email",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Texte explicatif
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 15,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: "We've sent a 4-digit code to\n"),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                            text: ". Please enter it below to\ncontinue.",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// Cases OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _OtpBox(
                          controller: _c1,
                          focusNode: _f1,
                          next: _f2,
                          autoFocus: true,
                        ),
                        _OtpBox(
                          controller: _c2,
                          focusNode: _f2,
                          next: _f3,
                          prev: _f1,
                        ),
                        _OtpBox(
                          controller: _c3,
                          focusNode: _f3,
                          next: _f4,
                          prev: _f2,
                        ),
                        _OtpBox(
                          controller: _c4,
                          focusNode: _f4,
                          prev: _f3,
                          onDone: _verify,
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    /// Partie Resend avec countdown
                    Center(
                      child: Column(
                        children: [
                          Text(
                            resendSeconds > 0
                                ? "Vous pouvez renvoyer le code dans $resendSeconds s"
                                : "Vous pouvez maintenant renvoyer le code",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: (resendSeconds == 0 && !isResending)
                                ? _resendOtp
                                : null,
                            child: isResending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primaryBlue,
                                    ),
                                  )
                                : const Text(
                                    "Resend Code",
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    /// Bouton principal Verify
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isVerifying ? null : _verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isVerifying
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : const Text(
                                "Verify & Proceed",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    /// Espace supplémentaire pour éviter overflow avec clavier
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
/// OTP BOX
/// Chaque case contient un seul chiffre
/// ==============================
class _OtpBox extends StatelessWidget {
  static const Color primaryBlue = Color(0xFF1E6CFF);

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? next;
  final FocusNode? prev;
  final bool autoFocus;
  final VoidCallback? onDone;

  const _OtpBox({
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
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: primaryBlue, width: 2.0),
          ),
        ),
        onChanged: (v) {
          /// Si un chiffre est saisi -> aller à la case suivante
          if (v.isNotEmpty) {
            if (next != null) {
              FocusScope.of(context).requestFocus(next);
            } else {
              FocusScope.of(context).unfocus();
              onDone?.call();
            }
          }
          /// Si la case devient vide -> revenir à la case précédente
          else {
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