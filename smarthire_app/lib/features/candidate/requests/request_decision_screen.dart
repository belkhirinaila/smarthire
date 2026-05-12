import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestDecisionScreen extends StatefulWidget {
  final dynamic request;

  const RequestDecisionScreen({
    super.key,
    required this.request,
  });

  @override
  State<RequestDecisionScreen> createState() => _RequestDecisionScreenState();
}

class _RequestDecisionScreenState extends State<RequestDecisionScreen> {
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  static const String baseUrl = 'http://192.168.100.47:5000/api';
  static const String serverUrl = 'http://192.168.100.47:5000';

  bool isAccepting = false;
  bool isDeclining = false;

  Map<String, dynamic> getArgs() {
    final Map<String, dynamic> args = {};

    if (widget.request is Map) {
      widget.request.forEach((key, value) {
        args[key.toString()] = value;
      });
    }

    return args;
  }

  String? fixImageUrl(dynamic value) {
    if (value == null) return null;

    final image = value.toString().trim();

    if (image.isEmpty || image == "null" || image == "NULL") return null;
    if (image.startsWith("http")) return image;
    if (image.startsWith("/")) return "$serverUrl$image";

    return "$serverUrl/$image";
  }

  String? getCompanyLogo(Map<String, dynamic> args) {
    final keys = [
      "company_logo",
      "logo",
      "logo_url",
      "companyLogo",
      "company_image",
      "image",
      "profile_image",
      "profile_photo",
      "photo",
    ];

    for (final key in keys) {
      final logo = fixImageUrl(args[key]);
      if (logo != null) return logo;
    }

    return null;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFFF5A6E);
      case 'pending':
      default:
        return const Color(0xFFFFB020);
    }
  }

  Future<void> updateRequestStatus(String status) async {
    final args = getArgs();
    final requestId = args['id'] ?? args['request_id'];

    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request ID introuvable")),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token introuvable")),
        );
        return;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/requests/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Request mise à jour")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Erreur lors de la mise à jour"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion au serveur")),
      );
    }
  }

  Future<void> acceptRequest() async {
    setState(() => isAccepting = true);
    await updateRequestStatus('approved');
    if (mounted) setState(() => isAccepting = false);
  }

  Future<void> declineRequest() async {
    setState(() => isDeclining = true);
    await updateRequestStatus('rejected');
    if (mounted) setState(() => isDeclining = false);
  }

  Widget logoWidget(String? logo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 62,
        height: 62,
        color: Colors.white.withOpacity(0.06),
        child: logo == null
            ? const Icon(
                Icons.business_rounded,
                color: Colors.white54,
                size: 30,
              )
            : Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.business_rounded,
                    color: Colors.white54,
                    size: 30,
                  );
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = getArgs();

    final String recruiterName =
        args['recruiter_name']?.toString().trim().isNotEmpty == true
            ? args['recruiter_name'].toString()
            : args['company']?.toString().trim().isNotEmpty == true
                ? args['company'].toString()
                : args['full_name']?.toString().trim().isNotEmpty == true
                    ? args['full_name'].toString()
                    : "Recruiter";

    final String companyName =
        args['company_name']?.toString().trim().isNotEmpty == true
            ? args['company_name'].toString()
            : "Company";

    final String title = args['title']?.toString() ?? "Access Request";

    final String subtitle =
        args['subtitle']?.toString() ?? "$companyName wants to access your profile.";

    final String time = args['time']?.toString() ?? "Recently";

    final String status =
        args['status']?.toString() ?? args['type']?.toString() ?? "pending";

    final String type = status.toUpperCase();

    final Color badgeColor = getStatusColor(status);

    final String? logo = getCompanyLogo(args);

    final String longDescription = args['description']?.toString() ??
        "$recruiterName from $companyName sent you an access request through SmartHire. "
            "You can approve it to allow further interaction or reject it to close this request.";

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTopBar(context),
                const SizedBox(height: 24),
                buildMainCard(
                  recruiterName: recruiterName,
                  companyName: companyName,
                  title: title,
                  subtitle: subtitle,
                  time: time,
                  type: type,
                  badgeColor: badgeColor,
                  logo: logo,
                ),
                const SizedBox(height: 24),
                buildSectionTitle("Request Details"),
                const SizedBox(height: 12),
                buildDescriptionCard(longDescription),
                const SizedBox(height: 24),
                buildSectionTitle("What can you do?"),
                const SizedBox(height: 12),
                buildActionsInfoCard(),
                const SizedBox(height: 24),
                buildSectionTitle("Contact Overview"),
                const SizedBox(height: 12),
                buildContactOverviewCard(
                  recruiterName: recruiterName,
                  companyName: companyName,
                  time: time,
                  status: type,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBottomBar(status),
    );
  }

  Widget buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const Spacer(),
        const Text(
          "Request Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Icon(
            Icons.more_horiz_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget buildMainCard({
    required String recruiterName,
    required String companyName,
    required String title,
    required String subtitle,
    required String time,
    required String type,
    required Color badgeColor,
    required String? logo,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              logoWidget(logo),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recruiterName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              buildTypeBadge(
                text: type,
                color: badgeColor,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    size: 15,
                    color: Colors.white.withOpacity(0.45),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget buildDescriptionCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.72),
          fontSize: 15,
          height: 1.7,
        ),
      ),
    );
  }

  Widget buildActionsInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: const [
          ActionInfoRow(
            icon: Icons.check_circle_outline_rounded,
            title: "Accept",
            subtitle: "Approve the request and allow the recruiter to continue.",
          ),
          SizedBox(height: 16),
          ActionInfoRow(
            icon: Icons.cancel_outlined,
            title: "Decline",
            subtitle: "Reject the request and close this interaction.",
          ),
        ],
      ),
    );
  }

  Widget buildContactOverviewCard({
    required String recruiterName,
    required String companyName,
    required String time,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: "Recruiter",
            value: recruiterName,
          ),
          const SizedBox(height: 16),
          buildInfoRow(
            icon: Icons.business_center_outlined,
            label: "Company",
            value: companyName,
          ),
          const SizedBox(height: 16),
          buildInfoRow(
            icon: Icons.schedule_outlined,
            label: "Received",
            value: time,
          ),
          const SizedBox(height: 16),
          buildInfoRow(
            icon: Icons.verified_user_outlined,
            label: "Status",
            value: status,
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.78),
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTypeBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget buildBottomBar(String status) {
    final bool alreadyHandled =
        status.toLowerCase() == "approved" ||
        status.toLowerCase() == "rejected";

    return Container(
      color: backgroundBottom,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: alreadyHandled || isDeclining || isAccepting
                    ? null
                    : declineRequest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isDeclining
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.3,
                        ),
                      )
                    : const Text(
                        "Decline",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: alreadyHandled || isAccepting || isDeclining
                    ? null
                    : acceptRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isAccepting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.3,
                        ),
                      )
                    : const Text(
                        "Accept",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ActionInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E6CFF),
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}