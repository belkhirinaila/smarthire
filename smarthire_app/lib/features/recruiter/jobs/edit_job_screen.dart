import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditJobScreen extends StatefulWidget {
  final Map job;

  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color background = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedWilaya = "16 - Algiers";
  String selectedType = "Full-time";
  String selectedMode = "Remote";

  bool isActive = true;

  // 🔥 58 WILAYAS
  final List<String> wilayas = [
    "01 - Adrar","02 - Chlef","03 - Laghouat","04 - Oum El Bouaghi",
    "05 - Batna","06 - Béjaïa","07 - Biskra","08 - Béchar",
    "09 - Blida","10 - Bouira","11 - Tamanrasset","12 - Tébessa",
    "13 - Tlemcen","14 - Tiaret","15 - Tizi Ouzou","16 - Algiers",
    "17 - Djelfa","18 - Jijel","19 - Sétif","20 - Saïda",
    "21 - Skikda","22 - Sidi Bel Abbès","23 - Annaba","24 - Guelma",
    "25 - Constantine","26 - Médéa","27 - Mostaganem","28 - M’Sila",
    "29 - Mascara","30 - Ouargla","31 - Oran","32 - El Bayadh",
    "33 - Illizi","34 - Bordj Bou Arreridj","35 - Boumerdès",
    "36 - El Tarf","37 - Tindouf","38 - Tissemsilt","39 - El Oued",
    "40 - Khenchela","41 - Souk Ahras","42 - Tipaza","43 - Mila",
    "44 - Aïn Defla","45 - Naâma","46 - Aïn Témouchent","47 - Ghardaïa",
    "48 - Relizane","49 - Timimoun","50 - Bordj Badji Mokhtar",
    "51 - Ouled Djellal","52 - Béni Abbès","53 - In Salah",
    "54 - In Guezzam","55 - Touggourt","56 - Djanet",
    "57 - El M’Ghair","58 - El Meniaa"
  ];

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    titleController.text = widget.job["title"] ?? "";
    descriptionController.text = widget.job["description"] ?? "";

    selectedType = widget.job["type"] ?? "Full-time";
    selectedMode = widget.job["work_mode"] ?? "Remote";

    // 🔥 FIX wilaya
    String loc = widget.job["location"] ?? "";

    selectedWilaya = wilayas.firstWhere(
      (w) => w.toLowerCase().contains(loc.toLowerCase()),
      orElse: () => "16 - Algiers",
    );

    isActive = widget.job["status"] == "active";
  }

  // ================= SAVE =================
  Future<void> updateJob() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.put(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/jobs/${widget.job["id"]}"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "title": titleController.text,
        "description": descriptionController.text,
        "location": selectedWilaya,
        "type": selectedType,
        "work_mode": selectedMode,
        "status": isActive ? "active" : "closed",
      }),
    );

    debugPrint(res.body);

    if (res.statusCode == 200) {
      Navigator.pop(context, true); // 🔥 مهم
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${res.body}")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Edit Job"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // STATUS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    isActive ? "Active" : "Closed",
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
                  )
                ],
              ),
            ),

            const SizedBox(height: 15),

            _input(titleController, "Job Title"),
            const SizedBox(height: 15),

            _input(descriptionController, "Description", maxLines: 4),
            const SizedBox(height: 15),

            _dropdown(),
            const SizedBox(height: 15),

            _chips(["Full-time", "Part-time", "Contract"], selectedType,
                (v) => setState(() => selectedType = v)),

            const SizedBox(height: 15),

            _chips(["Remote", "Hybrid", "Onsite"], selectedMode,
                (v) => setState(() => selectedMode = v)),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: updateJob,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text("Save Changes",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _input(TextEditingController c, String hint, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<String>(
        value: selectedWilaya,
        dropdownColor: cardColor,
        isExpanded: true,
        underline: Container(),
        style: const TextStyle(color: Colors.white),
        items: wilayas.map((w) {
          return DropdownMenuItem(
            value: w,
            child: Text(w),
          );
        }).toList(),
        onChanged: (val) {
          setState(() => selectedWilaya = val!);
        },
      ),
    );
  }

  Widget _chips(List items, String selected, Function onTap) {
    return Row(
      children: items.map((item) {
        final active = item == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(item),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? primaryBlue : cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}