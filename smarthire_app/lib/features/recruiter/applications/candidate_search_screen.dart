import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CandidateSearchScreen extends StatefulWidget {
  const CandidateSearchScreen({super.key});

  @override
  State<CandidateSearchScreen> createState() =>
      _CandidateSearchScreenState();
}

class _CandidateSearchScreenState extends State<CandidateSearchScreen> {

  List candidates = [];
  bool isLoading = false;

  final skillController = TextEditingController();
  final locationController = TextEditingController();

  // ==============================
  // SEARCH
  // ==============================
  Future<void> searchCandidates() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final skill = skillController.text;
    final location = locationController.text;

    final res = await http.get(
      Uri.parse(
        "https://smarthire-1-xe6v.onrender.com/api/recruiter/candidates?skill=$skill&location=$location",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      candidates = data["candidates"];
      isLoading = false;
    });
  }

  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Candidates")),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [

                TextField(
                  controller: skillController,
                  decoration: const InputDecoration(labelText: "Skill"),
                ),

                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: searchCandidates,
                  child: const Text("Search"),
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (c, i) {
                      final cand = candidates[i];

                      return ListTile(
                        title: Text(cand["full_name"]),
                        subtitle: Text(cand["location"] ?? ""),

                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/candidate-profile',
                              arguments: {
                                "candidateId": cand["id"]
                              },
                            );
                          },
                          child: const Text("View"),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}