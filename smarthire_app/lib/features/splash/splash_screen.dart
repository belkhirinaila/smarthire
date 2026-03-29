import 'dart:async';
import 'package:flutter/material.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // animation progress (approx 2.5s)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() {
        _progress += 0.02;
        if (_progress >= 1) {
          _progress = 1;
          t.cancel();

          Navigator.pushReplacementNamed(context, '/onboarding');
           //Navigator.pushReplacementNamed()
          
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [
              Color(0xFF081A3B), // bleu très sombre (glow zone)
              Color(0xFF05060A), // presque noir
              Color(0xFF000000), // noir
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo + glow
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D7CFF).withOpacity(0.25),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'SmartHire DZ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),

              const Spacer(flex: 2),

              // Progress bar fine
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: _ProgressLine(value: _progress),
              ),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final double value;
  const _ProgressLine({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 5,
        color: Colors.white.withOpacity(0.12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: MediaQuery.of(context).size.width * 0.55 * value,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E6CFF),
                  Color(0xFF2D9CFF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D7CFF).withOpacity(0.35),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
