import 'package:flutter/material.dart';

class AdminCandidateDetailsScreen extends StatelessWidget {
  const AdminCandidateDetailsScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color bgTop = Color(0xFF08162D);
  static const Color bgBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String serverUrl = "https://smarthire-1-xe6v.onrender.com";

  String fileUrl(String? path) {
    if (path == null || path.isEmpty) return "";

    String p = path.replaceAll("\\", "/");

    if (p.startsWith("http")) return p;

    return "$serverUrl/$p";
  }

  @override
  Widget build(BuildContext context) {
    final candidate =
        ModalRoute.of(context)!.settings.arguments
            as Map<String, dynamic>;

    final String image =
        fileUrl(candidate["profile_photo"]);

    return Scaffold(
      backgroundColor: bgBottom,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              /// ================= HEADER =================
              Padding(
                padding: const EdgeInsets.all(16),

                child: Row(
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
                      "Candidate Details",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= CONTENT =================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [

                      /// ================= PHOTO =================
                      CircleAvatar(
                        radius: 58,
                        backgroundColor:
                            Colors.white.withOpacity(0.08),

                        backgroundImage:
                            image.isNotEmpty
                                ? NetworkImage(image)
                                : null,

                        child: image.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 50,
                              )
                            : null,
                      ),

                      const SizedBox(height: 18),

                      /// ================= NAME =================
                      Text(
                        candidate["full_name"] ??
                            "Candidate",

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// ================= ROLE =================
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color: primaryBlue
                              .withOpacity(0.15),

                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: Text(
                          candidate["role"] ??
                              "candidate",

                          style: const TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// ================= INFOS =================
                      _sectionTitle(
                        "Personal Information",
                      ),

                      const SizedBox(height: 14),

                      _infoCard(
                        icon: Icons.email,
                        title: "Email",
                        value:
                            candidate["email"] ?? "-",
                      ),

                      _infoCard(
                        icon: Icons.phone,
                        title: "Phone Number",
                        value:
                            candidate["phone_number"] ??
                                "-",
                      ),

                      _infoCard(
                        icon: Icons.work,
                        title:
                            "Professional Headline",
                        value: candidate[
                                "professional_headline"] ??
                            "-",
                      ),

                      _infoCard(
                        icon: Icons.location_on,
                        title: "Location",
                        value:
                            candidate["location"] ??
                                "-",
                      ),

                      _infoCard(
                        icon: Icons.person_outline,
                        title: "Bio",
                        value:
                            candidate["bio"] ?? "-",
                      ),

                      _infoCard(
                        icon: Icons.link,
                        title: "GitHub",
                        value: candidate[
                                "github_link"] ??
                            "-",
                      ),

                      _infoCard(
                        icon: Icons.palette,
                        title: "Behance",
                        value: candidate[
                                "behance_link"] ??
                            "-",
                      ),

                      _infoCard(
                        icon: Icons.language,
                        title: "Website",
                        value: candidate[
                                "personal_website"] ??
                            "-",
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Text(
        title,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// ================= INFO CARD =================
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: primaryBlue,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value.isEmpty ? "-" : value,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}