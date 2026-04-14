import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {

  Map company = {};
  bool isLoading = true;

  File? logoFile;
  File? coverFile;

  final nameController = TextEditingController();
  final websiteController = TextEditingController();
  final aboutController = TextEditingController();

  // ==============================
  // FETCH
  // ==============================
  Future<void> fetchCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/company-profile/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    if (data["profile"] != null) {
      company = data["profile"];

      nameController.text = company["name"] ?? "";
      websiteController.text = company["website"] ?? "";
      aboutController.text = company["about"] ?? "";
    }

    setState(() => isLoading = false);
  }

  // ==============================
  // PICK IMAGE
  // ==============================
  Future<void> pickImage(bool isLogo) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        if (isLogo) {
          logoFile = File(picked.path);
        } else {
          coverFile = File(picked.path);
        }
      });
    }
  }

  // ==============================
  // UPLOAD IMAGE
  // ==============================
  Future<String?> uploadImage(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("http://YOUR_IP:5000/api/upload"),
    );

    request.files.add(
      await http.MultipartFile.fromPath("image", file.path),
    );

    final res = await request.send();
    final body = await res.stream.bytesToString();
    final data = jsonDecode(body);

    return data["filename"];
  }

  // ==============================
  // SAVE
  // ==============================
  Future<void> saveCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    String? logo = company["logo"];
    String? cover = company["cover_image"];

    if (logoFile != null) {
      logo = await uploadImage(logoFile!);
    }

    if (coverFile != null) {
      cover = await uploadImage(coverFile!);
    }

    await http.post(
      Uri.parse("http://YOUR_IP:5000/api/recruiter/company-profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "name": nameController.text,
        "website": websiteController.text,
        "about": aboutController.text,
        "logo": logo,
        "cover_image": cover,
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved")),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCompany();
  }

  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Company Profile")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [

                  // 🖼️ COVER
                  GestureDetector(
                    onTap: () => pickImage(false),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey,
                      child: company["cover_image"] != null
                          ? Image.network(
                              "http://YOUR_IP:5000/${company["cover_image"]}",
                              fit: BoxFit.cover,
                            )
                          : const Center(child: Text("Add Cover")),
                    ),
                  ),

                  // 🖼️ LOGO
                  GestureDetector(
                    onTap: () => pickImage(true),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: company["logo"] != null
                          ? NetworkImage(
                              "http://YOUR_IP:5000/${company["logo"]}",
                            )
                          : null,
                      child: company["logo"] == null
                          ? const Icon(Icons.camera_alt)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ✔ VERIFICATION
                  Text(
                    "Status: ${company["verification_status"] ?? "pending"}",
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: "Name"),
                        ),

                        TextField(
                          controller: websiteController,
                          decoration: const InputDecoration(labelText: "Website"),
                        ),

                        TextField(
                          controller: aboutController,
                          decoration: const InputDecoration(labelText: "About"),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: saveCompany,
                          child: const Text("Save"),
                        )

                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}