import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EditCompanyProfileScreen extends StatefulWidget {
  const EditCompanyProfileScreen({super.key});

  @override
  State<EditCompanyProfileScreen> createState() =>
      _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  static const String baseUrl = "http://192.168.100.47:5000";

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color bgTop = Color(0xFF08162D);
  static const Color bgBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  final nameController = TextEditingController();
  final websiteController = TextEditingController();
  final descriptionController = TextEditingController();
  final companySizeController = TextEditingController();

  String industry = "Information Technology";
  String selectedWilaya = "Alger";

  bool hasCompany = false;
  bool isLoading = true;
  bool isSaving = false;

  File? logoFile;
  File? coverFile;
  File? registreFile;
  File? nifFile;
  File? fiscaleFile;

  String? logoUrl;
  String? coverUrl;
  String? registreUrl;
  String? nifUrl;
  String? fiscaleUrl;

  final List<String> industries = [
    "Information Technology",
    "Marketing",
    "Finance",
    "Education",
    "Health",
    "Construction",
    "Engineering",
    "Commerce",
    "Other",
  ];

  final List<String> wilayas = [
    "Adrar", "Chlef", "Laghouat", "Oum El Bouaghi", "Batna", "Béjaïa",
    "Biskra", "Béchar", "Blida", "Bouira", "Tamanrasset", "Tébessa",
    "Tlemcen", "Tiaret", "Tizi Ouzou", "Alger", "Djelfa", "Jijel",
    "Sétif", "Saïda", "Skikda", "Sidi Bel Abbès", "Annaba", "Guelma",
    "Constantine", "Médéa", "Mostaganem", "M’Sila", "Mascara", "Ouargla",
    "Oran", "El Bayadh", "Illizi", "Bordj Bou Arréridj", "Boumerdès",
    "El Tarf", "Tindouf", "Tissemsilt", "El Oued", "Khenchela",
    "Souk Ahras", "Tipaza", "Mila", "Aïn Defla", "Naâma",
    "Aïn Témouchent", "Ghardaïa", "Relizane"
  ];

  @override
  void initState() {
    super.initState();
    fetchCompany();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchCompany() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/api/recruiter/company-profile/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final c = data["company"];

      hasCompany = c != null;

      if (c != null) {
        nameController.text = c["name"] ?? "";
        websiteController.text = c["website"] ?? "";
        descriptionController.text = c["description"] ?? "";
        companySizeController.text = (c["company_size"] ?? "").toString();

        industry = industries.contains(c["industry"])
            ? c["industry"]
            : "Information Technology";

        final loc = c["location"] ?? "Alger";
        selectedWilaya = wilayas.contains(loc) ? loc : "Alger";

        logoUrl = c["logo"];
        coverUrl = c["cover_image"];
        registreUrl = c["registre_commerce"];
        nifUrl = c["nif_nis"];
        fiscaleUrl = c["carte_fiscale"];
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() => logoFile = File(picked.path));
    }
  }

  Future<void> pickCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() => coverFile = File(picked.path));
    }
  }

  Future<File?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf"],
    );

    if (result == null || result.files.single.path == null) return null;

    return File(result.files.single.path!);
  }

  Future<void> pickRegistre() async {
    final file = await pickPdf();
    if (file != null) setState(() => registreFile = file);
  }

  Future<void> pickNif() async {
    final file = await pickPdf();
    if (file != null) setState(() => nifFile = file);
  }

  Future<void> pickFiscale() async {
    final file = await pickPdf();
    if (file != null) setState(() => fiscaleFile = file);
  }

  String fileUrl(String? path) {
    if (path == null || path.isEmpty) return "";

    String p = path.trim();
    p = p.replaceAll("\\", "/");

    if (p.startsWith("http")) return p;

    return "$baseUrl/$p";
  }

  String imageUrl(String? path) {
    return fileUrl(path);
  }

  String fileName(String? path) {
    if (path == null || path.isEmpty) return "No file selected";
    String p = path.replaceAll("\\", "/");
    return p.split("/").last;
  }

  String localFileName(File? file) {
    if (file == null) return "";
    String p = file.path.replaceAll("\\", "/");
    return p.split("/").last;
  }

  Future<void> openPdf(String? path) async {
    if (path == null || path.isEmpty) {
      showMsg("No PDF found");
      return;
    }

    final uri = Uri.parse(fileUrl(path));

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      showMsg("Cannot open PDF");
    }
  }

  Future<void> saveCompany() async {
    if (nameController.text.trim().isEmpty) {
      showMsg("Company name is required");
      return;
    }

    setState(() => isSaving = true);

    try {
      final token = await getToken();

      final request = http.MultipartRequest(
        hasCompany ? "PUT" : "POST",
        Uri.parse("$baseUrl/api/recruiter/company-profile"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["name"] = nameController.text.trim();
      request.fields["website"] = websiteController.text.trim();
      request.fields["description"] = descriptionController.text.trim();
      request.fields["location"] = selectedWilaya;
      request.fields["industry"] = industry;
      request.fields["company_size"] =
          (int.tryParse(companySizeController.text.trim()) ?? 0).toString();

      if (logoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("logo", logoFile!.path),
        );
      }

      if (coverFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("cover_image", coverFile!.path),
        );
      }

      if (registreFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "registre_commerce",
            registreFile!.path,
          ),
        );
      }

      if (nifFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("nif_nis", nifFile!.path),
        );
      }

      if (fiscaleFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "carte_fiscale",
            fiscaleFile!.path,
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        showMsg(
          hasCompany
              ? "Company profile updated successfully ✅"
              : "Company profile created successfully ✅",
        );

        Navigator.pop(context, true);
      } else {
        final data = jsonDecode(response.body);
        showMsg(data["message"] ?? "Update failed");
      }
    } catch (e) {
      showMsg("Erreur serveur");
    } finally {
      if (!mounted) return;
      setState(() => isSaving = false);
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: bgBottom,
        body: Center(
          child: CircularProgressIndicator(color: primaryBlue),
        ),
      );
    }

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
              _header(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _coverAndLogo(),

                      const SizedBox(height: 24),

                      _input("Company Name", Icons.business, nameController),

                      _dropdown("Industry", industry, industries, (v) {
                        setState(() => industry = v!);
                      }),

                      _input("Website", Icons.language, websiteController),

                      _dropdown("Location", selectedWilaya, wilayas, (v) {
                        setState(() => selectedWilaya = v!);
                      }),

                      _input(
                        "Company Size",
                        Icons.people,
                        companySizeController,
                        keyboardType: TextInputType.number,
                      ),

                      _textarea(
                        "About Company",
                        Icons.description,
                        descriptionController,
                      ),

                      const SizedBox(height: 10),

                      _sectionTitle("Legal Documents"),

                      const SizedBox(height: 12),

                      _pdfPicker(
                        title: "Registre de commerce",
                        subtitle: registreFile != null
                            ? localFileName(registreFile)
                            : fileName(registreUrl),
                        existingPath: registreUrl,
                        selectedFile: registreFile,
                        onPick: pickRegistre,
                      ),

                      _pdfPicker(
                        title: "NIF / NIS",
                        subtitle: nifFile != null
                            ? localFileName(nifFile)
                            : fileName(nifUrl),
                        existingPath: nifUrl,
                        selectedFile: nifFile,
                        onPick: pickNif,
                      ),

                      _pdfPicker(
                        title: "Carte fiscale",
                        subtitle: fiscaleFile != null
                            ? localFileName(fiscaleFile)
                            : fileName(fiscaleUrl),
                        existingPath: fiscaleUrl,
                        selectedFile: fiscaleFile,
                        onPick: pickFiscale,
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveCompany,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            hasCompany ? "Save Changes" : "Create Company",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
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

          Expanded(
            child: Text(
              hasCompany ? "Edit Company Profile" : "Create Company Profile",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverAndLogo() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: pickCover,
          child: Container(
            height: 155,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              image: coverFile != null
                  ? DecorationImage(
                      image: FileImage(coverFile!),
                      fit: BoxFit.cover,
                    )
                  : coverUrl != null && coverUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl(coverUrl)),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black.withOpacity(0.25),
              ),
              child: const Center(
                child: Text(
                  "Tap to change cover image",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -42,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: pickLogo,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: bgBottom,
                    child: CircleAvatar(
                      radius: 43,
                      backgroundColor: cardColor,
                      backgroundImage: logoFile != null
                          ? FileImage(logoFile!)
                          : logoUrl != null && logoUrl!.isNotEmpty
                              ? NetworkImage(imageUrl(logoUrl)) as ImageProvider
                              : null,
                      child: logoFile == null &&
                              (logoUrl == null || logoUrl!.isEmpty)
                          ? const Icon(
                              Icons.business,
                              color: Colors.white,
                              size: 36,
                            )
                          : null,
                    ),
                  ),

                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: bgBottom, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _pdfPicker({
    required String title,
    required String subtitle,
    required String? existingPath,
    required File? selectedFile,
    required VoidCallback onPick,
  }) {
    final bool hasPdf =
        selectedFile != null ||
        (existingPath != null && existingPath.isNotEmpty);

    return GestureDetector(
      onTap: () {
        if (selectedFile != null) {
          showMsg("PDF selected. Click Save to upload it.");
        } else if (existingPath != null && existingPath.isNotEmpty) {
          openPdf(existingPath);
        } else {
          onPick();
        }
      },
      child: Container(
        height: 76,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.redAccent,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onPick,
              icon: Icon(
                hasPdf ? Icons.edit : Icons.upload_file,
                color: primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _textarea(
    String label,
    IconData icon,
    TextEditingController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: cardColor,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
        style: const TextStyle(color: Colors.white),
        items: items.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}