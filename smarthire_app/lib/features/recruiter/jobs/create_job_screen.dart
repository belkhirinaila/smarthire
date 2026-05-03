import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color background = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  final salaryMinController = TextEditingController();
  final salaryMaxController = TextEditingController();

  final skillController = TextEditingController();
  final requirementsController = TextEditingController();
  final experienceController = TextEditingController();
  final educationController = TextEditingController();
  final languagesController = TextEditingController();
  final teamController = TextEditingController();

  String selectedType = "Full-time";
  String selectedMode = "Remote";
  String selectedCategory = "IT";

  List<String> skills = [];

  bool isLoading = false;

  // 🔥 NEW
  String status = "active";

  // ================= SKILLS =================
  void addSkill() {
    if (skillController.text.trim().isEmpty) return;
    setState(() {
      skills.add(skillController.text.trim());
      skillController.clear();
    });
  }

  void removeSkill(int i) {
    setState(() {
      skills.removeAt(i);
    });
  }

  // ================= CREATE JOB =================
  Future<void> createJob() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("http://192.168.100.47:5000/api/recruiter/jobs"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "title": titleController.text,
        "description": descriptionController.text,
        "location": locationController.text,
        "salary_min": int.tryParse(salaryMinController.text) ?? 0,
        "salary_max": int.tryParse(salaryMaxController.text) ?? 0,
        "category": selectedCategory,
        "type": selectedType,
        "work_mode": selectedMode,
        "skills": skills,
        "status": status,
        "requirements": requirementsController.text,
        "experience": experienceController.text,
        "education": educationController.text,
        "languages": languagesController.text,
        "team": teamController.text,
        
      }),
    );

    final data = jsonDecode(res.body);
    setState(() => isLoading = false);

    if (status == "draft") {
  Navigator.pop(context, true); // 🔥 يرجع مباشرة للـ jobs
} else {
  Navigator.pushNamed(context, '/job-success');
}
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Create Job",
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

                    // BASIC
                    _card(Column(
                      children: [
                        _input(titleController, "Job Title"),
                        _input(descriptionController, "Description"),
                        _input(locationController, "Location"),
                      ],
                    )),

                    const SizedBox(height: 16),

                    // SALARY
                    _card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Salary",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _input(salaryMinController, "Min")),
                            const SizedBox(width: 10),
                            Expanded(child: _input(salaryMaxController, "Max")),
                          ],
                        )
                      ],
                    )),

                    const SizedBox(height: 16),

                    // TYPE
                    _card(_dropdown("Employment Type", selectedType,
                        ["Full-time", "Part-time", "Internship"], (v) {
                      setState(() => selectedType = v!);
                    })),

                    const SizedBox(height: 16),

                    // MODE
                    _card(_dropdown("Work Mode", selectedMode,
                        ["Remote", "On-site", "Hybrid"], (v) {
                      setState(() => selectedMode = v!);
                    })),

                    const SizedBox(height: 16),

                    // CATEGORY
                    _card(_dropdown("Category", selectedCategory,
                        ["IT", "Marketing", "Finance"], (v) {
                      setState(() => selectedCategory = v!);
                    })),

                    const SizedBox(height: 16),

                    // SKILLS
                    _card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text("Skills",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: skillController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Add skill",
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: addSkill,
                              child: const Icon(Icons.add, color: primaryBlue),
                            )
                          ],
                        ),

                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 8,
                          children: List.generate(skills.length, (i) {
                            return Chip(
                              label: Text(skills[i]),
                              backgroundColor: primaryBlue.withOpacity(0.2),
                              labelStyle: const TextStyle(color: Colors.white),
                              onDeleted: () => removeSkill(i),
                            );
                          }),
                        )
                      ],
                    )),

                    const SizedBox(height: 16),
                    // REQUIREMENTS
                    _card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Requirements",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: requirementsController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: "List the job requirements here",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        )
                      ],
                    )),

                    const SizedBox(height: 16),

                    // EXPERIENCE
                    _card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Experience",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: experienceController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: "Describe the required experience",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        )
                      ],
                    )),

                    const SizedBox(height: 16),


                    // EDUCATION
                    _card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Education",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: educationController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: "Specify the educational requirements",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        )
                      ],  
                    )),

                    const SizedBox(height: 16),


                    // LANGUAGES       
                    _card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Languages",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: languagesController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: "List the required languages",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        )
                      ],  
                    )), 

                    const SizedBox(height: 16),


                    // TEAM
                    _card(  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Team",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: teamController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: "Describe the team and company culture",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        )
                      ],  
                    )), 

                    const SizedBox(height: 16),


                  ],
                ),
              ),
            ),

            // 🔥 BUTTONS (NEW)
            Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      children: [

                        // DRAFT
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              status = "draft";
                              createJob();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  "Save Draft",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // PUBLISH
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              status = "active";
                              createJob();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  "Publish Job",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _input(TextEditingController c, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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

  Widget _dropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: value,
          dropdownColor: cardColor,
          isExpanded: true,
          underline: const SizedBox(),
          style: const TextStyle(color: Colors.white),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}