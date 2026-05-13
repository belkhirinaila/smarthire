import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminCompanyDetailsScreen extends StatefulWidget {
  const AdminCompanyDetailsScreen({super.key});

  @override
  State<AdminCompanyDetailsScreen> createState() =>
      _AdminCompanyDetailsScreenState();
}

class _AdminCompanyDetailsScreenState extends State<AdminCompanyDetailsScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color bgTop = Color(0xFF08162D);
  static const Color bgBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String serverUrl = "https://smarthire-fpa1.onrender.com";
  static const String baseUrl = "https://smarthire-fpa1.onrender.com/api";

  late Map<String, dynamic> company;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      company = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      setState(() {});
    });
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  String fileUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    String p = path.replaceAll("\\", "/");
    if (p.startsWith("http")) return p;
    return "$serverUrl/$p";
  }

  Future<void> openPdf(String? path) async {
    if (path == null || path.isEmpty) {
      showMsg("No PDF found");
      return;
    }

    final uri = Uri.parse(fileUrl(path));
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened) showMsg("Cannot open PDF");
  }

  Future<void> updateStatus(String status) async {
    setState(() => isLoading = true);

    final token = await getToken();

    final res = await http.put(
      Uri.parse("$baseUrl/admin/companies/${company['id']}/status"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"status": status}),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res.statusCode == 200) {
      showMsg(status == "approved" ? "Company approved ✅" : "Company rejected ❌");
      Navigator.pop(context, true);
    } else {
      showMsg("Erreur serveur");
    }
  }

  Future<void> blockCompany() async {
    setState(() => isLoading = true);

    final token = await getToken();

    final res = await http.put(
      Uri.parse("$baseUrl/admin/companies/${company['id']}/block"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res.statusCode == 200) {
      showMsg("Company blocked 🚫");
      Navigator.pop(context, true);
    } else {
      showMsg("Erreur serveur");
    }
  }


  Future<void> unblockCompany() async {

  setState(() => isLoading = true);

  final token = await getToken();

  final res = await http.put(
    Uri.parse(
      "$baseUrl/admin/companies/${company['id']}/unblock",
    ),

    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (!mounted) return;

  setState(() => isLoading = false);

  if (res.statusCode == 200) {

    setState(() {
      company["is_blocked"] = 0;
    });

    showMsg("Company unblocked ✅");

  } else {

    showMsg("Erreur serveur");
  }
}

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    company = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final logo = fileUrl(company["logo"]);
    final cover = fileUrl(company["cover_image"]);
    final status = company["status"] ?? "pending";

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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
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
                      "Company Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          image: cover.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(cover),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          backgroundImage:
                              logo.isNotEmpty ? NetworkImage(logo) : null,
                          child: logo.isEmpty
                              ? const Icon(Icons.business,
                                  color: Colors.white, size: 42)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Center(
                        child: Text(
                          company["name"] ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: status == "approved"
                                ? Colors.green.withOpacity(0.15)
                                : status == "rejected"
                                    ? Colors.red.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toString().toUpperCase(),
                            style: TextStyle(
                              color: status == "approved"
                                  ? Colors.green
                                  : status == "rejected"
                                      ? Colors.red
                                      : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      _sectionTitle("Company Information"),
                      const SizedBox(height: 14),

                      _infoCard(Icons.category, "Industry", company["industry"] ?? "-"),
                      _infoCard(Icons.location_on, "Location", company["location"] ?? "-"),
                      _infoCard(Icons.people, "Company Size",
                          company["company_size"]?.toString() ?? "-"),
                      _infoCard(Icons.language, "Website", company["website"] ?? "-"),
                      _infoCard(Icons.description, "Description",
                          company["description"] ?? "-"),

                      const SizedBox(height: 28),

                      _sectionTitle("Legal Documents"),
                      const SizedBox(height: 14),

                      _pdfCard("Registre de commerce", company["registre_commerce"]),
                      _pdfCard("NIF / NIS", company["nif_nis"]),
                      _pdfCard("Carte fiscale", company["carte_fiscale"]),

                      const SizedBox(height: 30),

                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (status == "approved")

                        company["is_blocked"] == 1

                            ? _fullButton(
                                text: "Unblock Company",
                                color: Colors.green,

                                onTap: unblockCompany,
                              )

                            : _fullButton(
                                text: "Block Company",
                                color: Colors.red,

                                onTap: blockCompany,
                              )
                      else if (status == "pending")
                        Row(
                          children: [
                            Expanded(
                              child: _fullButton(
                                text: "Approve",
                                color: Colors.green,
                                onTap: () => updateStatus("approved"),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _fullButton(
                                text: "Reject",
                                color: Colors.red,
                                onTap: () => updateStatus("rejected"),
                              ),
                            ),
                          ],
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryBlue),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text(value,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pdfCard(String title, String? path) {
    final exists = path != null && path.isNotEmpty;

    return GestureDetector(
      onTap: () => openPdf(path),
      child: Container(
        height: 78,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    exists ? "Tap to open PDF" : "No document",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, color: primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _fullButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(0, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}