import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecruiterMessagesScreen extends StatefulWidget {
  const RecruiterMessagesScreen({super.key});

  @override
  State<RecruiterMessagesScreen> createState() =>
      _RecruiterMessagesScreenState();
}

class _RecruiterMessagesScreenState extends State<RecruiterMessagesScreen> {

  List conversations = [];
  bool isLoading = true;

  // ==============================
  // FETCH CONVERSATIONS
  // ==============================
  Future<void> fetchConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/messages/conversations"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      conversations = data["conversations"];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A12),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (c, i) {
                final conv = conversations[i];

                return ListTile(
                  title: Text(
                    "Candidate ${conv["candidate_id"]}",
                    style: const TextStyle(color: Colors.white),
                  ),

                  onTap: () {
                   Navigator.pushNamed(
  context,
  '/chat',
  arguments: {
    "conversationId": conv["id"],
  },
);
                  },
                );
              },
            ),
    );
  }
}