import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminCompaniesScreen extends StatefulWidget {
  const AdminCompaniesScreen({super.key});

  @override
  State<AdminCompaniesScreen> createState() =>
      _AdminCompaniesScreenState();
}

class _AdminCompaniesScreenState extends State<AdminCompaniesScreen> {

  /// 🎨 COLORS
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  String selected = "pending";
  List companies = [];
  bool isLoading = true;

  /// 🔥 loading button
  int? loadingId;

  @override
  void initState() {
    super.initState();
    loadCompanies();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ================= LOAD =================
  Future<void> loadCompanies() async {
    setState(() => isLoading = true);

    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/admin/companies/$selected'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() {
        companies = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  /// ================= UPDATE STATUS =================
  Future<void> updateStatus(int id, String status) async {

    setState(() {
      loadingId = id;
    });

    final token = await getToken();

    await http.put(
      Uri.parse('$baseUrl/admin/companies/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({"status": status}),
    );

    setState(() {
      loadingId = null;
    });

    loadCompanies();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == "approved"
              ? "✅ Company approved successfully"
              : "❌ Company rejected",
        ),
        backgroundColor:
            status == "approved" ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ================= CONFIRM REJECT =================
  Future<void> confirmReject(int id) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text(
          "Reject Company",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to reject this company?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              updateStatus(id, "rejected");
            },
            child: const Text(
              "Reject",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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

              /// 🔝 HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Companies",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.business, color: Colors.white)
                  ],
                ),
              ),

              /// 🔘 FILTER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filter("pending", "Pending"),
                    const SizedBox(width: 10),
                    _filter("approved", "Approved"),
                    const SizedBox(width: 10),
                    _filter("rejected", "Rejected"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 📄 LIST
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: loadCompanies,
                        child: companies.isEmpty
                            ? Center(
                                child: Text(
                                  selected == "pending"
                                      ? "📭 No pending companies"
                                      : selected == "approved"
                                          ? "✅ No approved companies"
                                          : "❌ No rejected companies",
                                  style: const TextStyle(
                                      color: Colors.white54),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: companies.length,
                                itemBuilder: (context, i) {
                                  final c = companies[i];

                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [

                                        /// INFO
                                        Row(
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor:
                                                  primaryBlue,
                                              child: Icon(
                                                  Icons.business,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    c['name'] ??
                                                        "Company",
                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          Colors.white,
                                                      fontWeight:
                                                          FontWeight
                                                              .bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    c['website'] ??
                                                        "",
                                                    style:
                                                        const TextStyle(
                                                            color: Colors
                                                                .white54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        /// ACTIONS
                                        if (selected == "pending") ...[
                                          const SizedBox(height: 12),

                                          Row(
                                            children: [

                                              /// APPROVE
                                              Expanded(
                                                child:
                                                    GestureDetector(
                                                  onTap: loadingId ==
                                                          c['id']
                                                      ? null
                                                      : () =>
                                                          updateStatus(
                                                              c['id'],
                                                              "approved"),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets
                                                                .symmetric(
                                                            vertical:
                                                                12),
                                                    decoration:
                                                        BoxDecoration(
                                                      color:
                                                          Colors.green,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  25),
                                                    ),
                                                    child: Center(
                                                      child: loadingId ==
                                                              c['id']
                                                          ? const SizedBox(
                                                              height:
                                                                  18,
                                                              width:
                                                                  18,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                                strokeWidth:
                                                                    2,
                                                              ),
                                                            )
                                                          : const Text(
                                                              "Approve",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              /// REJECT
                                              Expanded(
                                                child:
                                                    GestureDetector(
                                                  onTap: loadingId ==
                                                          c['id']
                                                      ? null
                                                      : () =>
                                                          confirmReject(
                                                              c['id']),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets
                                                                .symmetric(
                                                            vertical:
                                                                12),
                                                    decoration:
                                                        BoxDecoration(
                                                      color:
                                                          Colors.red,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  25),
                                                    ),
                                                    child:
                                                        const Center(
                                                      child: Text(
                                                        "Reject",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]
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

  /// FILTER BUTTON
  Widget _filter(String value, String label) {
    final bool active = selected == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selected = value;
        });
        loadCompanies();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? primaryBlue
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontWeight:
                active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}