import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditCompanyProfileScreen extends StatefulWidget {
  const EditCompanyProfileScreen({super.key});

  @override
  State<EditCompanyProfileScreen> createState() =>
      _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color background = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  final nameController = TextEditingController();
  final websiteController = TextEditingController();
  final descriptionController = TextEditingController();
  final companySizeController = TextEditingController();

  String industry = "Information Technology";
  String selectedWilaya = "Alger";

  bool isLoading = false;
  bool hasCompany = false;

  // ================= 58 WILAYA =================
  final List<String> wilayas = [
    "Adrar","Chlef","Laghouat","Oum El Bouaghi","Batna","Béjaïa","Biskra",
    "Béchar","Blida","Bouira","Tamanrasset","Tébessa","Tlemcen","Tiaret",
    "Tizi Ouzou","Alger","Djelfa","Jijel","Sétif","Saïda","Skikda","Sidi Bel Abbès",
    "Annaba","Guelma","Constantine","Médéa","Mostaganem","M’Sila","Mascara",
    "Ouargla","Oran","El Bayadh","Illizi","Bordj Bou Arréridj","Boumerdès",
    "El Tarf","Tindouf","Tissemsilt","El Oued","Khenchela","Souk Ahras",
    "Tipaza","Mila","Aïn Defla","Naâma","Aïn Témouchent","Ghardaïa","Relizane"
  ];

  // ================= FETCH =================
  Future<void> fetchCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/company-profile/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    if (data["company"] != null) {
      final c = data["company"];

      nameController.text = c["name"] ?? "";
      websiteController.text = c["website"] ?? "";
      descriptionController.text = c["description"] ?? "";
      companySizeController.text =
          (c["company_size"] ?? "").toString();

      String loc = c["location"] ?? "Alger";

// 🔥 fix case
selectedWilaya = wilayas.contains(loc)
    ? loc
    : wilayas.firstWhere(
        (w) => w.toLowerCase() == loc.toLowerCase(),
        orElse: () => "Alger",
      );
    }
  }

  // ================= SAVE =================
  Future<void> saveCompany() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final body = jsonEncode({
      "name": nameController.text,
      "website": websiteController.text,
      "description": descriptionController.text,
      "location": selectedWilaya,
      "industry": industry,
      "company_size":
          int.tryParse(companySizeController.text) ?? 0
    });

    final url =
        "http://192.168.100.47:5000/api/recruiter/company-profile";

    final res = hasCompany
        ? await http.put(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json"
            },
            body: body,
          )
        : await http.post(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json"
            },
            body: body,
          );

    setState(() => isLoading = false);

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.pop(context, true); // 🔥 refresh
    } else {
      final data = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Error")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompany();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Column(
          children: [

            // HEADER
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child:
                          const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Edit Company Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    _input(nameController, "Company Name"),

                    _dropdown("Industry", industry, [
                      "Information Technology",
                      "Marketing",
                      "Finance"
                    ], (v) {
                      setState(() => industry = v!);
                    }),

                    _input(websiteController, "Website"),

                    // 🔥 WILAYA
                    _dropdown("Location", selectedWilaya, wilayas, (v) {
                      setState(() => selectedWilaya = v!);
                    }),

                    _input(companySizeController, "Company Size"),

                    _textarea(descriptionController, "About Us"),
                  ],
                ),
              ),
            ),

            // SAVE BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: saveCompany,
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            "Save Changes",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _input(TextEditingController c, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _textarea(TextEditingController c, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: c,
        maxLines: 5,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: cardColor,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        items: items
            .map((e) =>
                DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}