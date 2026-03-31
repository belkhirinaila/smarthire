import 'package:flutter/material.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardData> pages = const [
    _OnboardData(
      imagePath: 'assets/images/sh.jpeg',
      title: 'Discover Careers\nin Algeria',
      subtitle:
          'Access the best opportunities across all\n58 wilayas, tailored to your skills and\nlocation.',
    ),
    // Tu peux remplacer par tes vraies pages après
    _OnboardData(
      imagePath: 'assets/images/sh.jpeg',
      title: 'Apply Faster\nwith SmartHire',
      subtitle: 'Save your profile and apply to jobs in\nseconds with one tap.',
    ),
    _OnboardData(
      imagePath: 'assets/images/sh.jpeg',
      title: 'Get Matched\nSmartly',
      subtitle: 'We suggest offers based on your skills,\nexperience, and preferences.',
    ),
  ];

  void _next() {
    if (_index < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgTop = Color(0xFF0A1B2F);
    const bgBottom = Color(0xFF06080D);
    const card = Color(0xFF0B0F18);
    const primary = Color(0xFF1E6CFF);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = pages[i];
                    return Column(
                      children: [
                        const SizedBox(height: 16),

                        // Image en haut (comme dans le design)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              height: 360,
                              width: double.infinity,
                              child: Image.asset(
                                p.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Section texte sur fond sombre
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 20),
                            decoration: const BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(22),
                                topRight: Radius.circular(22),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 22),

                                Text(
                                  p.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  p.subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),

                                const Spacer(),

                                // Dots (indicateur)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    pages.length,
                                    (dot) => AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      height: 8,
                                      width: dot == _index ? 26 : 8,
                                      decoration: BoxDecoration(
                                        color: dot == _index
                                            ? primary
                                            : Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Bouton Next (gros arrondi)
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _next,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      _index == pages.length - 1
                                          ? 'Get Started'
                                          : 'Next',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardData {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

