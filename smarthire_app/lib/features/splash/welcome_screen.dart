import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _primary = Color(0xFF1E6CFF);
  static const _bgTop = Color.fromARGB(255, 32, 103, 210);
  static const _bgBottom = Color(0xFF070A10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Top logo + name
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.25),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 38,
                          height: 38,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(text: 'SmartHire ', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'DZ', style: TextStyle(color: _primary)),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Big title
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: 'Elevate Your Career\nin '),
                      TextSpan(text: 'Algeria', style: TextStyle(color: _primary)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Find premium opportunities tailored\nfor the local market and top\ncompanies.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 30),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');

                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Bottom cards
                Row(
                  children: const [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.verified_rounded,
                        label: 'Trust',
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.location_on_rounded,
                        label: 'Local',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          )
        ],
      ),
    );
  }
}
