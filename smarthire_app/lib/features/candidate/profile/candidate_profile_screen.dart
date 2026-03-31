import 'package:flutter/material.dart';

class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  @override
  Widget build(BuildContext context) {
    final String fullName = "Candidate Name";
    final String headline = "Your professional headline";
    final String location = "Algeria";
    final String about =
        "Tell recruiters about your profile, your goals and your strengths. This section will be connected later to backend data.";

    final List<String> skills = [
      "Skill 1",
      "Skill 2",
      "Skill 3",
      "Skill 4",
    ];

    final List<Map<String, String>> experiences = [
      {
        "role": "Position title",
        "company": "Company name",
        "period": "2023 - Present",
      },
      {
        "role": "Previous role",
        "company": "Company name",
        "period": "2021 - 2023",
      },
    ];

    return Scaffold(
      backgroundColor: backgroundBottom,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundTop, backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 24),
                      _buildProfileHeader(
                        fullName: fullName,
                        headline: headline,
                        location: location,
                      ),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle("About Me"),
                      const SizedBox(height: 12),
                      _buildAboutCard(about),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Top Skills"),
                      const SizedBox(height: 12),
                      _buildSkillsCard(skills),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Experience"),
                      const SizedBox(height: 12),
                      _buildExperienceCard(experiences),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Documents"),
                      const SizedBox(height: 12),
                      _buildDocumentCard(),
                      const SizedBox(height: 26),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const Spacer(),
        const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader({
    required String fullName,
    required String headline,
    required String location,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Icon(
              Icons.person,
              size: 42,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white.withOpacity(0.45),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                location,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.48),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSmallStat(
                  title: "Applications",
                  value: "00",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallStat(
                  title: "Saved Jobs",
                  value: "00",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallStat(
                  title: "Requests",
                  value: "00",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit_outlined,
                label: "Edit Profile",
                onTap: () {
                  Navigator.pushNamed(context, '/edit-profile');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.description_outlined,
                label: "CV & Skills",
                onTap: () {
                  Navigator.pushNamed(context, '/cv-skills');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.work_outline_rounded,
                label: "Experience & Education",
                onTap: () {
                  Navigator.pushNamed(context, '/experience-education');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.visibility_outlined,
                label: "Privacy & Visibility",
                onTap: () {
                  Navigator.pushNamed(context, '/privacy-visibility');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryBlue, size: 24),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildAboutCard(String about) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        about,
        style: TextStyle(
          color: Colors.white.withOpacity(0.72),
          fontSize: 15,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildSkillsCard(List<String> skills) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: skills.map((skill) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              skill,
              style: const TextStyle(
                color: primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExperienceCard(List<Map<String, String>> experiences) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: experiences.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.work_outline_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["role"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["company"] ?? "",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.56),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["period"] ?? "",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.42),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              "candidate_resume.pdf",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "View",
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}