import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smarthire_app/route_observer.dart';

/// ==============================
/// SPLASH / ONBOARDING
/// ==============================
import 'package:smarthire_app/features/splash/onboarding_screen.dart';
import 'package:smarthire_app/features/splash/welcome_screen.dart';

/// ==============================
/// AUTH
/// ==============================
import 'package:smarthire_app/features/auth/login_screen.dart';
import 'package:smarthire_app/features/auth/signup_screen.dart';
import 'package:smarthire_app/features/auth/reset_password_screen.dart';
import 'package:smarthire_app/features/auth/reset_otp_screen.dart';
import 'package:smarthire_app/features/auth/new_password_screen.dart';
import 'package:smarthire_app/features/auth/password_success_screen.dart';
import 'package:smarthire_app/features/auth/otp_screen.dart';
import 'package:smarthire_app/features/auth/success_screen.dart';
import 'package:smarthire_app/features/auth/role_screen.dart';

/// ==============================
/// CANDIDATE
/// ==============================
import 'package:smarthire_app/features/candidate/candidate_main_screen.dart';
import 'package:smarthire_app/features/candidate/jobs/job_details_screen.dart';
import 'package:smarthire_app/features/candidate/applications/application_submission_screen.dart';
import 'package:smarthire_app/features/candidate/applications/application_success_screen.dart';
import 'package:smarthire_app/features/candidate/applications/application_details_screen.dart';
import 'package:smarthire_app/features/candidate/profile/edit_profile_screen.dart';
import 'package:smarthire_app/features/candidate/profile/cv_skills_screen.dart';
import 'package:smarthire_app/features/candidate/profile/experience_education_screen.dart';
import 'package:smarthire_app/features/candidate/profile/privacy_visibility_screen.dart';
import 'package:smarthire_app/features/candidate/requests/request_decision_screen.dart';
import 'package:smarthire_app/features/candidate/direct_chat_thread_screen.dart';
import 'package:smarthire_app/features/candidate/jobs/saved_jobs_screen.dart';
import 'package:smarthire_app/features/candidate/notifications_screen.dart';
import 'package:smarthire_app/features/recruiter/notification.dart';
import 'package:smarthire_app/features/candidate/requests/candidate_chat_screen.dart';
/// ==============================
/// RECRUITER
/// ==============================
import 'package:smarthire_app/features/recruiter/recruiter_main_screen.dart';
import 'package:smarthire_app/features/recruiter/jobs/create_job_screen.dart';
import 'package:smarthire_app/features/recruiter/jobs/recruiter_jobs_screen.dart';
import 'package:smarthire_app/features/recruiter/messages/recruiter_messages_screen.dart';
import 'package:smarthire_app/features/recruiter/company/company_profile_screen.dart';
import 'package:smarthire_app/features/recruiter/jobs/job_details_screen_for_recruiter.dart';
import 'package:smarthire_app/features/recruiter/applications/applicants_screen.dart';
import 'package:smarthire_app/features/recruiter/messages/chat_screen.dart';
import 'package:smarthire_app/features/recruiter/applications/candidate_search_screen.dart';
import 'package:smarthire_app/features/recruiter/jobs/job_success_screen.dart';
import 'package:smarthire_app/features/recruiter/company/settings_screen.dart';
import 'package:smarthire_app/features/recruiter/company/edit_company_screen.dart';
import 'package:smarthire_app/features/recruiter/jobs/edit_job_screen.dart';
import 'package:smarthire_app/features/recruiter/jobs/candidate_profile_for_recruiter.dart';
import 'package:smarthire_app/features/recruiter/search_candidate_screen.dart';    

/// ==============================
/// ADMIN
/// ==============================
import 'package:smarthire_app/features/admin/admin_stats_screen.dart';

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
      navigatorObservers: [routeObserver],

      routes: {
        /// ==============================
        /// SPLASH
        /// ==============================
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),

        /// ==============================
        /// AUTH
        /// ==============================
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
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return OtpScreen(email: args['email']);
        },

        '/success': (context) => const SuccessScreen(),
        '/role': (context) => const RoleScreen(),

        /// ==============================
        /// CANDIDATE
        /// ==============================
        '/candidate': (context) => const CandidateMainScreen(),

        '/job-details': (context) => const JobDetailsScreen(),
        '/apply': (context) => const ApplicationSubmissionScreen(),
        '/application-success': (context) => const ApplicationSuccessScreen(),
        '/application-details': (context) => const ApplicationDetailsScreen(),
        '/saved-jobs': (context) => const SavedJobsScreen(),

        '/edit-profile': (context) => const EditProfileScreen(),
        '/cv-skills': (context) => const CvSkillsScreen(),
        '/experience-education': (context) =>
            const ExperienceEducationScreen(),
        '/privacy-visibility': (context) =>
            const PrivacyVisibilityScreen(),

        '/request-decision': (context) => const RequestDecisionScreen(),
        '/direct-chat': (context) => const DirectChatThreadScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/chat_candidate': (context) => const CandidateChatScreen(),

        /// ==============================
        /// RECRUITER 🔥
        /// ==============================
        '/recruiter': (context) => const RecruiterMainScreen(),
        '/recruiter-jobs': (context) => const RecruiterJobsScreen(),
        '/recruiter-messages': (context) => const RecruiterMessagesScreen(),
        '/company-profile': (context) => const CompanyProfileScreen(),
        '/create-job': (context) => const CreateJobScreen(),
        '/job-success': (context) => const JobSuccessScreen(),
        '/recruiter-job-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;

          return RecruiterJobDetailsScreenRecruiter(
           jobId: args["jobId"], // 🔥 هذا هو المهم
         );
        },
        '/candidate-profile-recruiter': (context) {
         final args = ModalRoute.of(context)!.settings.arguments as Map;

         return CandidateProfileForRecruiterScreen(
           
          );
        },
        '/recruiter-notifications': (context) =>
            const RecruiterNotificationsScreen(),
        "/edit-job": (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map;

  return EditJobScreen(
    job: args["job"],
  );
},
        '/recruiter-applicants': (context) {
         final args = ModalRoute.of(context)!.settings.arguments as Map;
         return ApplicantsScreen(jobId: args['jobId']);
       },
       '/chat': (context) {
         
         return const ChatScreen();
        },
        
        
        '/settings': (context) => const SettingsScreen(),
        '/edit-company': (context) => const EditCompanyProfileScreen(),
        '/search-candidates': (context) => const SearchCandidatesScreen(),
        /// ==============================
        /// ADMIN
        /// ==============================
        '/admin': (context) => const AdminStatsScreen(),
      },
    );
  }
}

/// ==============================
/// SPLASH SCREEN
/// ==============================
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
                      width: MediaQuery.of(context).size.width *
                          0.55 *
                          progress,
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