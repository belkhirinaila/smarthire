import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchCandidatesScreen extends StatefulWidget {
  
  const SearchCandidatesScreen({super.key});

  @override
  State<SearchCandidatesScreen> createState() =>
      _SearchCandidatesScreenState();
}

class _SearchCandidatesScreenState
    extends State<SearchCandidatesScreen> {
      

  List candidates = [];
  List filtered = [];
  TextEditingController searchController = TextEditingController();

  final String baseUrl =
      "https://smarthire-1-xe6v.onrender.com/api/recruiter";


  // 🔑 TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  @override
  void initState() {
    super.initState();
    fetchCandidates();
  }

  Future<void> fetchCandidates() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/all"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = json.decode(res.body);

    setState(() {
      candidates = data["candidates"];
      filtered = candidates;
    });
  }

  void filter(String query) {
    final result = candidates.where((c) {
      final name = c["full_name"]?.toLowerCase() ?? "";
      final title =
          c["professional_headline"]?.toLowerCase() ?? "";

      return name.contains(query.toLowerCase()) ||
          title.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filtered = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Search Candidates"),
      ),
      body: Column(
        children: [

          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: filter,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search skills or titles...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF0F1C2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📋 LIST
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final c = filtered[index];

                final isPublic =
                    (c["is_public"] ?? 1) == 1;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1C2E),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // 🔥 HEADER
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundImage:
                                (c["profile_photo"] != null &&
                                        c["profile_photo"] != "")
                                    ? NetworkImage(
                                        "https://smarthire-1-xe6v.onrender.com/uploads/${c["profile_photo"]}")
                                    : null,
                            child: c["profile_photo"] ==
                                        null ||
                                    c["profile_photo"] ==
                                        ""
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c["full_name"] ?? "",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  c["professional_headline"] ??
                                      "",
                                  style: const TextStyle(
                                      color:
                                          Colors.blueAccent),
                                ),
                                Text(
                                  "📍 ${c["location"] ?? ""}",
                                  style: const TextStyle(
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "2h ago",
                            style: TextStyle(
                                color:
                                    Colors.white54,
                                fontSize: 12),
                          )
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 🔥 SKILLS (fake for now)
                      Wrap(
                        spacing: 6,
                        children: [
                          _chip("React"),
                          _chip("Node.js"),
                          _chip("Docker"),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 🔥 FOOTER
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [

                          Row(
                            children: [
                              Icon(
                                isPublic
                                    ? Icons.circle
                                    : Icons.lock,
                                color: isPublic
                                    ? Colors.green
                                    : Colors.orange,
                                size: 10,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPublic
                                    ? "Public CV"
                                    : "Private CV",
                                style: TextStyle(
                                  color: isPublic
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),

                          // 🔥 BUTTON
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isPublic
                                      ? const Color(
                                          0xFF1E6CFF)
                                      : Colors.grey[700],
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),
                            ),
                            onPressed: () {
                              if (isPublic) {
                                Navigator.pushNamed(
                                  context,
                                  "/candidate-profile-recruiter",
                                  arguments: {
                                    "userId": c["id"]
                                  },
                                );
                              } else {
                                // 🔒 request
                                ScaffoldMessenger.of(
                                        context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Request sent")),
                                );
                              }
                            },
                            child: Text(
                              isPublic
                                  ? "View Profile"
                                  : "Request Access",
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }
}