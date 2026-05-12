import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CompanyProfileViewScreen extends StatefulWidget {

  final int companyId;

  const CompanyProfileViewScreen({
    super.key,
    required this.companyId,
  });

  @override
  State<CompanyProfileViewScreen> createState() =>
      _CompanyProfileViewScreenState();
}

class _CompanyProfileViewScreenState
    extends State<CompanyProfileViewScreen> {

  Map<String, dynamic>? company;

  bool isLoading = true;

  // =========================================
  // GET COMPANY
  // =========================================
  Future<void> getCompany() async {

    try {

      final res = await http.get(
        Uri.parse(
          "http://192.168.100.47:5000/api/company-profile/${widget.companyId}",
        ),
      );

      final data = jsonDecode(res.body);

      setState(() {

        company = data["company"];
        isLoading = false;

      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

    }
  }

  // =========================================
  // OPEN MAPS
  // =========================================
  Future<void> openMaps(String location) async {

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$location",
    );

    if (await canLaunchUrl(url)) {

      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

    }
  }

  @override
  void initState() {
    super.initState();
    getCompany();
  }

  @override
  Widget build(BuildContext context) {

    const backgroundColor = Color(0xFF050A12);
    const cardColor = Color(0xFF08162D);
    const primaryBlue = Color(0xFF1E6CFF);

    if (isLoading) {

      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );

    }

    if (company == null) {

      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            "Company not found",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

    }

    return Scaffold(

      backgroundColor: backgroundColor,

      body: SingleChildScrollView(

        child: Column(

          children: [

            // =========================================
            // COVER IMAGE
            // =========================================
            Stack(

              children: [

                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    image: company!["cover_image"] != null
                        ? DecorationImage(
                            image: NetworkImage(
                              "http://192.168.100.47:5000${company!["cover_image"]}",
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),

                Container(
                  height: 230,
                  color: Colors.black.withOpacity(0.35),
                ),

                SafeArea(

                  child: Padding(

                    padding: const EdgeInsets.all(16),

                    child: Row(

                      children: [

                        GestureDetector(

                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: Container(

                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(

                  bottom: 0,
                  left: 0,
                  right: 0,

                  child: Column(

                    children: [

                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,

                        backgroundImage: company!["logo"] != null
                            ? NetworkImage(
                                "http://192.168.100.47:5000${company!["logo"]}",
                              )
                            : null,

                        child: company!["logo"] == null
                            ? const Icon(
                                Icons.business,
                                size: 45,
                                color: primaryBlue,
                              )
                            : null,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        company!["name"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        company!["industry"] ?? "",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                )
              ],
            ),

            Padding(

              padding: const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // =========================================
                  // ABOUT
                  // =========================================
                  const Text(
                    "About Company",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(

                    width: double.infinity,
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),

                    child: Text(
                      company!["description"] ?? "",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =========================================
                  // INFO
                  // =========================================
                  const Text(
                    "Company Information",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    title: "Email",
                    value: company!["email"] ?? "No email",
                  ),

                  const SizedBox(height: 14),

                  GestureDetector(

                    onTap: () {
                      openMaps(company!["location"] ?? "");
                    },

                    child: _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      title: "Location",
                      value: company!["location"] ?? "",
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildInfoCard(
                    icon: Icons.language_rounded,
                    title: "Website",
                    value: company!["website"] ?? "",
                  ),

                  const SizedBox(height: 14),

                  _buildInfoCard(
                    icon: Icons.groups_rounded,
                    title: "Company Size",
                    value: "${company!["company_size"]} Employees",
                  ),

                  const SizedBox(height: 14),

                  _buildInfoCard(
                    icon: Icons.work_outline_rounded,
                    title: "Published Jobs",
                    value: "${company!["total_jobs"]} Jobs",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // INFO CARD
  // =========================================
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {

    return Container(

      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF08162D),
        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF1E6CFF),
              size: 28,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
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