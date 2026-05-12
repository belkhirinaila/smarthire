import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  static const String baseUrl = "https://smarthire-1-xe6v.onrender.com";

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color background = Color(0xFF050A12);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color cardColor = Color(0xFF121C31);

  Map<String, dynamic>? company;
  List jobs = [];
  bool isLoading = true;

  String getImageUrl(dynamic path) {
    if (path == null) return "";
    final p = path.toString();
    if (p.isEmpty) return "";
    if (p.startsWith("http")) return p;
    return "$baseUrl/$p";
  }

  Future<void> fetchCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/api/recruiter/company-profile/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        company = data["company"];
        jobs = data["jobs"] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompany();
  }

  Future<void> shareCompanyProfile() async {
    final companyName = company?['name'] ?? 'Company';
    final description = company?['description'] ?? 'No description available.';
    final website = company?['website'] ?? 'https://smarthire.com';
    final companyId = company?['id']?.toString() ?? '0';

    await Share.share(
      'Company: $companyName\nDescription: $description\nWebsite: $website\nProfile: https://smarthire.com/company/$companyId',
      subject: 'Discover $companyName on SmartHire',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundTop, background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: fetchCompany,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 18),
                  _profileCard(),
                  const SizedBox(height: 18),
                  _actions(),
                  const SizedBox(height: 22),
                  _sectionTitle("About Company"),
                  const SizedBox(height: 10),
                  _card(
                    Text(
                      company?["description"] ?? "No description",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _infoCard(
                        Icons.people,
                        "${company?["company_size"] ?? 0}",
                        "Employees",
                      ),
                      const SizedBox(width: 10),
                      _infoCard(
                        Icons.calendar_today,
                        company?["created_at"] != null
                            ? company!["created_at"].toString().substring(0, 4)
                            : "----",
                        "Founded",
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle("Jobs"),
                  const SizedBox(height: 10),
                  jobs.isEmpty
                      ? _card(
                          const Text(
                            "No jobs posted yet",
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : Column(
                          children: jobs.map((job) => _jobCard(job)).toList(),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Text(
          "Company Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: fetchCompany,
          icon: const Icon(Icons.refresh, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _profileCard() {
    final cover = company?["cover_image"];
    final logo = company?["logo"];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              image: cover != null && cover.toString().isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(getImageUrl(cover)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: cover == null || cover.toString().isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.white38,
                      size: 38,
                    ),
                  )
                : null,
          ),

          Transform.translate(
            offset: const Offset(0, -40),
            child: CircleAvatar(
              radius: 47,
              backgroundColor: background,
              child: CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white12,
                backgroundImage: logo != null && logo.toString().isNotEmpty
                    ? NetworkImage(getImageUrl(logo))
                    : null,
                child: logo == null || logo.toString().isEmpty
                    ? const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 36,
                      )
                    : null,
              ),
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -28),
            child: Column(
              children: [
                Text(
                  company?["name"] ?? "Company",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white54,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      company?["location"] ?? "",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _verificationBadge(),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _smallActionCard(Icons.edit, "Edit", () async {
                final result =
                    await Navigator.pushNamed(context, "/edit-company");
                if (result == true) fetchCompany();
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _smallActionCard(Icons.settings, "Settings", () {
                Navigator.pushNamed(context, "/settings");
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child:
                  _smallActionCard(Icons.share, "Share", shareCompanyProfile),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _smallActionCard(Icons.work, "Jobs", () async {
                await Navigator.pushNamed(context, "/recruiter-jobs");
                fetchCompany();
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _smallActionCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryBlue, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verificationBadge() {
    String status = company?["verification_status"] ?? "pending";

    Color color;
    IconData icon;
    String text;

    if (status == "approved") {
      color = Colors.green;
      icon = Icons.verified;
      text = "Verified";
    } else if (status == "rejected") {
      color = Colors.red;
      icon = Icons.cancel;
      text = "Rejected";
    } else {
      color = Colors.orange;
      icon = Icons.hourglass_top;
      text = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryBlue, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _jobCard(dynamic job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.work, color: primaryBlue, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              job["title"] ?? "Job",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 13, color: Colors.white38),
        ],
      ),
    );
  }
}