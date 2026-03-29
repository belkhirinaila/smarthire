import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smarthire_app/features/splash/onboarding_screen.dart';
import 'package:smarthire_app/features/splash/welcome_screen.dart';
import 'package:smarthire_app/features/auth/login_screen.dart';
import 'package:smarthire_app/features/auth/signup_screen.dart';
import 'package:smarthire_app/features/auth/reset_password_screen.dart';
import 'package:smarthire_app/features/auth/reset_otp_screen.dart';
import 'package:smarthire_app/features/auth/new_password_screen.dart';
import 'package:smarthire_app/features/auth/password_success_screen.dart';
import 'package:smarthire_app/features/auth/otp_screen.dart';
import 'package:smarthire_app/features/auth/success_screen.dart';
import 'package:smarthire_app/features/auth/role_screen.dart';
import 'package:smarthire_app/features/candidate/candidate_home_screen.dart';
import 'package:smarthire_app/features/company/company_home_screen.dart';
import 'package:smarthire_app/features/admin/admin_home_screen.dart';

void main() {
  runApp(const SmartHireApp());
}

class SmartHireApp extends StatelessWidget {
  const SmartHireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/reset-otp': (context) {
         final args =
         ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
         return ResetOtpScreen(email: args['email']);
        },
        '/new-password': (context) => const NewPasswordScreen(),
        '/password-success': (context) => const PasswordSuccessScreen(),
        '/otp': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return OtpScreen(email: args['email']);
       },
        '/success': (context) => const SuccessScreen(),
        '/role': (context) => const RoleScreen(),
        '/candidate': (context) => const CandidateHomeScreen(),
        '/company': (context) => const CompanyHomeScreen(),
        '/admin': (context) => const AdminHomeScreen(),
       '/home': (context) => const Scaffold(
  body: Center(child: Text('Home Screen')),
),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0.0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      setState(() {
        progress += 0.02;

        if (progress >= 1) {
          progress = 1;
          t.cancel();

          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [
              Color(0xFF081A3B),
              Color(0xFF05060A),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 3),
            Container(
              width: 95,
              height: 95,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2D7CFF),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "SmartHire DZ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 5,
                  color: Colors.white.withOpacity(0.15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: MediaQuery.of(context).size.width * 0.55 * progress,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E6CFF),
                            Color(0xFF2D9CFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}