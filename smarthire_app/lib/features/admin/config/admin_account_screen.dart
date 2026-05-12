import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() =>
      _AdminAccountScreenState();
}

class _AdminAccountScreenState
    extends State<AdminAccountScreen> {

  static const Color primaryBlue =
      Color(0xFF1E6CFF);

  static const Color backgroundTop =
      Color(0xFF08162D);

  static const Color backgroundBottom =
      Color(0xFF050A12);

  static const Color cardColor =
      Color(0xFF121C31);

  File? image;

  final TextEditingController nameController =
      TextEditingController(text: "Admin");

  final TextEditingController emailController =
      TextEditingController(
        text: "admin@smarthire.com",
      );

  final TextEditingController phoneController =
      TextEditingController(
        text: "+213 555 00 00 00",
      );

  final TextEditingController positionController =
      TextEditingController(
        text: "Platform Administrator",
      );

  /// ================= PICK IMAGE =================
  Future<void> pickImage() async {

    final picked =
        await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {

      setState(() {
        image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: backgroundBottom,

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            colors: [
              backgroundTop,
              backgroundBottom,
            ],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(

          child: SingleChildScrollView(

            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              40,
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                /// ================= HEADER =================
                Row(

                  children: [

                    GestureDetector(

                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: Container(

                        width: 42,
                        height: 42,

                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),

                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Text(

                      "Admin Account",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                /// ================= PROFILE IMAGE =================
                Center(

                  child: Stack(

                    children: [

                      Container(

                        width: 120,
                        height: 120,

                        decoration: BoxDecoration(

                          shape: BoxShape.circle,

                          border: Border.all(
                            color: primaryBlue,
                            width: 3,
                          ),

                          image: image != null

                              ? DecorationImage(
                                  image: FileImage(image!),
                                  fit: BoxFit.cover,
                                )

                              : const DecorationImage(
                                  image: AssetImage(
                                    "assets/images/logo.png",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),

                      Positioned(

                        bottom: 0,
                        right: 0,

                        child: GestureDetector(

                          onTap: pickImage,

                          child: Container(

                            width: 38,
                            height: 38,

                            decoration: BoxDecoration(
                              color: primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: backgroundBottom,
                                width: 3,
                              ),
                            ),

                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Center(

                  child: Text(

                    "SmartHire DZ Admin",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                const Center(

                  child: Text(

                    "Platform Administrator",

                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                /// ================= FORM =================
                _field(
                  "Full Name",
                  Icons.person,
                  nameController,
                ),

                const SizedBox(height: 18),

                _field(
                  "Email",
                  Icons.email,
                  emailController,
                ),

                const SizedBox(height: 18),

                _field(
                  "Phone Number",
                  Icons.phone,
                  phoneController,
                ),

                const SizedBox(height: 18),

                _field(
                  "Position",
                  Icons.work,
                  positionController,
                ),

                const SizedBox(height: 35),

                /// ================= SAVE BUTTON =================
                GestureDetector(

                  onTap: () {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(
                        content: Text(
                          "✅ Profile updated successfully",
                        ),
                      ),
                    );
                  },

                  child: Container(

                    height: 58,

                    decoration: BoxDecoration(

                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E6CFF),
                          Color(0xFF2D9CFF),
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color:
                              primaryBlue.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: const Center(

                      child: Text(

                        "Save Changes",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= FIELD =================
  Widget _field(
    String label,
    IconData icon,
    TextEditingController controller,
  ) {

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(

          label,

          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        Container(

          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
          ),

          child: TextField(

            controller: controller,

            style: const TextStyle(
              color: Colors.white,
            ),

            decoration: InputDecoration(

              prefixIcon: Icon(
                icon,
                color: primaryBlue,
              ),

              border: InputBorder.none,

              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}