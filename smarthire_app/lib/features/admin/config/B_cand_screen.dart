import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BlockedCandidatesScreen extends StatefulWidget {
  const BlockedCandidatesScreen({super.key});

  @override
  State<BlockedCandidatesScreen> createState() =>
      _BlockedCandidatesScreenState();
}

class _BlockedCandidatesScreenState
    extends State<BlockedCandidatesScreen> {

  static const Color primaryBlue =
      Color(0xFF1E6CFF);

  static const Color backgroundTop =
      Color(0xFF08162D);

  static const Color backgroundBottom =
      Color(0xFF050A12);

  static const Color cardColor =
      Color(0xFF121C31);

  static const String baseUrl =
      "http://192.168.100.47:5000/api";

  List candidates = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBlockedCandidates();
  }

  /// ================= TOKEN =================
  Future<String?> getToken() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString("token");
  }

  /// ================= LOAD BLOCKED =================
  Future<void> loadBlockedCandidates() async {

    setState(() {
      isLoading = true;
    });

    final token = await getToken();

    final response = await http.get(

      Uri.parse(
        "$baseUrl/admin/candidates/blocked",
      ),

      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {

      setState(() {

        candidates =
            jsonDecode(response.body);

        isLoading = false;
      });

    } else {

      setState(() {
        isLoading = false;
      });
    }
  }

  /// ================= UNBLOCK =================
  Future<void> unblockCandidate(
    int id,
  ) async {

    final token = await getToken();

    final response = await http.put(

      Uri.parse(
        "$baseUrl/admin/users/$id/block",
      ),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "is_blocked": false,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Candidate unblocked ✅",
          ),
        ),
      );

      loadBlockedCandidates();
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

          child: Column(

            children: [

              /// ================= HEADER =================
              Padding(

                padding: const EdgeInsets.all(16),

                child: Row(

                  children: [

                    IconButton(

                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),

                    const Text(

                      "Blocked Candidates",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= BODY =================
              Expanded(

                child: isLoading

                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )

                    : candidates.isEmpty

                        ? const Center(

                            child: Text(

                              "No blocked candidates",

                              style: TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                          )

                        : RefreshIndicator(

                            onRefresh:
                                loadBlockedCandidates,

                            child: ListView.builder(

                              padding:
                                  const EdgeInsets.all(16),

                              itemCount:
                                  candidates.length,

                              itemBuilder:
                                  (context, index) {

                                final candidate =
                                    candidates[index];

                                return Container(

                                  margin:
                                      const EdgeInsets.only(
                                    bottom: 12,
                                  ),

                                  padding:
                                      const EdgeInsets.all(14),

                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                  ),

                                  child: Row(

                                    children: [

                                      /// 👤 AVATAR
                                      const CircleAvatar(

                                        backgroundColor:
                                            Colors.red,

                                        child: Icon(
                                          Icons.person,
                                          color:
                                              Colors.white,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 12,
                                      ),

                                      /// 📄 INFO
                                      Expanded(

                                        child: Column(

                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          children: [

                                            Text(

                                              candidate[
                                                      "full_name"] ??
                                                  "Candidate",

                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.white,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(
                                              height: 4,
                                            ),

                                            Text(

                                              candidate[
                                                      "email"] ??
                                                  "",

                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.white54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// 🔓 BUTTON
                                      ElevatedButton(

                                        onPressed: () {

                                          unblockCandidate(
                                            candidate["id"],
                                          );
                                        },

                                        style:
                                            ElevatedButton.styleFrom(

                                          backgroundColor:
                                              primaryBlue,

                                          shape:
                                              RoundedRectangleBorder(

                                            borderRadius:
                                                BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),

                                        child: const Text(

                                          "Unblock",

                                          style: TextStyle(
                                            color:
                                                Colors.white,
                                          ),
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