import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';
  static const String serverUrl = 'http://192.168.100.47:5000';

  List candidates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCandidates();
  }

  String fileUrl(dynamic path) {
    if (path == null) return "";

    String p = path.toString().trim();

    if (p.isEmpty || p == "null") return "";

    p = p.replaceAll("\\", "/");

    if (p.startsWith("http")) return p;

    return "$serverUrl/$p";
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> loadCandidates() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/admin/candidates'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      setState(() {
        candidates = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(int id) async {
    final token = await getToken();

    await http.delete(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    loadCandidates();
  }

  Future<void> toggleBlock(int id, bool value) async {
    final token = await getToken();

    await http.put(
      Uri.parse('$baseUrl/admin/users/$id/block'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"is_blocked": value}),
    );

    loadCandidates();
  }

  void openCandidate(dynamic candidate) {
    Navigator.pushNamed(
      context,
      "/admin-candidate-details",
      arguments: candidate,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundTop, backgroundBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadCandidates,
          child: candidates.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 250),
                    Center(
                      child: Text(
                        "📭 No candidates found",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: candidates.length,
                  itemBuilder: (context, i) {
                    final candidate = candidates[i];

                    final String avatar =
                        fileUrl(candidate['profile_photo']);

                    return GestureDetector(
                      onTap: () => openCandidate(candidate),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  Colors.white.withOpacity(0.08),
                              backgroundImage: avatar.isNotEmpty
                                  ? NetworkImage(avatar)
                                  : null,
                              child: avatar.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    candidate['full_name'] ??
                                        candidate['email'] ??
                                        "Candidate",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    candidate['email'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "candidate",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: Icon(
                                candidate['is_blocked'] == 1
                                    ? Icons.lock
                                    : Icons.lock_open,
                                color: candidate['is_blocked'] == 1
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              onPressed: () {
                                toggleBlock(
                                  candidate['id'],
                                  candidate['is_blocked'] == 1
                                      ? false
                                      : true,
                                );
                              },
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                deleteUser(candidate['id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}