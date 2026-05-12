import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BlockedCompaniesScreen extends StatefulWidget {
  const BlockedCompaniesScreen({super.key});

  @override
  State<BlockedCompaniesScreen> createState() => _BlockedCompaniesScreenState();
}

class _BlockedCompaniesScreenState extends State<BlockedCompaniesScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = "https://smarthire-1-xe6v.onrender.com/api";

  List companies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBlockedCompanies();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> loadBlockedCompanies() async {
    setState(() => isLoading = true);

    final token = await getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/admin/companies/blocked"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      setState(() {
        companies = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> unblockCompany(int id) async {
    final token = await getToken();

    final res = await http.put(
      Uri.parse("$baseUrl/admin/companies/$id/unblock"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Company unblocked ✅")),
      );
      loadBlockedCompanies();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur unblock")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundTop, backgroundBottom],
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Text(
                      "Blocked Companies",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : companies.isEmpty
                        ? const Center(
                            child: Text(
                              "No blocked companies",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: loadBlockedCompanies,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: companies.length,
                              itemBuilder: (context, i) {
                                final c = companies[i];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.business, color: Colors.white),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c["name"] ?? c["companyName"] ?? "Company",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              c["website"] ?? "",
                                              style: const TextStyle(color: Colors.white54),
                                            ),
                                          ],
                                        ),
                                      ),

                                      ElevatedButton(
                                        onPressed: () => unblockCompany(c["id"]),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: const Text(
                                          "Unblock",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}