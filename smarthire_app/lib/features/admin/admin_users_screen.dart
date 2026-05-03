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

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';

  List users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ================= LOAD USERS =================
  Future<void> loadUsers() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() {
        users = jsonDecode(res.body);
        isLoading = false;
      });
    }
  }

  /// ================= DELETE =================
  Future<void> deleteUser(int id) async {
    final token = await getToken();

    await http.delete(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    loadUsers();
  }

  /// ================= BLOCK =================
  Future<void> toggleBlock(int id, bool value) async {
    final token = await getToken();

    await http.put(
      Uri.parse('$baseUrl/admin/users/$id/block'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({"is_blocked": value}),
    );

    loadUsers();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundBottom,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          child: RefreshIndicator(
            onRefresh: loadUsers,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, i) {
                final user = users[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [

                      /// 👤 Avatar
                      const CircleAvatar(
                        backgroundColor: primaryBlue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),

                      const SizedBox(width: 10),

                      /// 📄 INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['email'] ?? "",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              user['role'],
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),

                      /// 🚫 BLOCK BUTTON
                      IconButton(
                        icon: Icon(
                          user['is_blocked'] == 1
                              ? Icons.lock
                              : Icons.lock_open,
                          color: user['is_blocked'] == 1
                              ? Colors.red
                              : Colors.green,
                        ),
                        onPressed: () {
                          toggleBlock(
                              user['id'],
                              user['is_blocked'] == 1 ? false : true
                          );
                        },
                      ),

                      /// ❌ DELETE
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteUser(user['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}