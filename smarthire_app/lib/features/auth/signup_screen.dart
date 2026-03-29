import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool agreeTerms = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void goToRoleScreen() {
    final fullName = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Remplis tous les champs")),
      );
      return;
    }

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tu dois accepter les Terms & Conditions"),
        ),
      );
      return;
    }

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

                const Text(
                  "Full Name",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                _inputField(
                  "Enter your full name",
                  controller: nameController,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Email Address",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                _inputField(
                  "name@example.dz",
                  controller: emailController,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Password",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
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