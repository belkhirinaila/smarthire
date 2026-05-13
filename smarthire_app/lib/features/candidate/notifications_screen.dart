import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Écran des notifications du candidat.
// Il affiche les notifications reçues, permet de les marquer comme lues,
// et présente un résumé du nombre de notifications non lues.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Couleurs utilisées dans l'interface notifications.
  static const Color primaryBlue = Color(0xFF1E6CFF);
  static const Color backgroundTop = Color(0xFF08162D);
  static const Color backgroundBottom = Color(0xFF050A12);
  static const Color cardColor = Color(0xFF121C31);

  // URL de base vers l'API backend.
  static const String baseUrl = 'https://smarthire-fpa1.onrender.com/api';

  // Données des notifications et états de chargement / marquage.
  List<dynamic> notifications = [];
  bool isLoading = true;
  bool isMarkingAll = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Charge les notifications dès que l'écran est initialisé.
    fetchNotifications();
  }

  // Récupère le token d'authentification stocké localement.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Charge les notifications depuis l'API pour l'utilisateur connecté.
  Future<void> fetchNotifications() async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        // Si le token est absent, on affiche un message d'erreur.
        setState(() {
          isLoading = false;
          errorMessage = "Token introuvable. Veuillez vous reconnecter.";
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Si la requête réussit, on stocke les notifications et on désactive
        // l'état de chargement.
        setState(() {
          notifications = data['notifications'] ?? [];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        // Si l'API renvoie une erreur, on affiche le message renvoyé.
        setState(() {
          isLoading = false;
          errorMessage =
              data['message'] ?? 'Erreur lors du chargement des notifications';
        });
      }
    } catch (e) {
      // En cas d'erreur réseau, on affiche un message générique.
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de connexion au serveur';
      });
    }
  }

  // Marque une notification comme lue côté serveur, puis met à jour la
  // notification correspondante localement si l'appel réussit.
  Future<void> markAsRead(int id) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          final index =
              notifications.indexWhere((item) => item['id'] == id);
          if (index != -1) {
            notifications[index]['is_read'] = 1;
          }
        });
      }
    } catch (_) {}
  }

  // Marque toutes les notifications comme lues en appelant l'API.
  // Cette méthode affiche également un indicateur de chargement temporaire.
  Future<void> markAllAsRead() async {
    try {
      setState(() {
        isMarkingAll = true;
      });

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          isMarkingAll = false;
        });
        return;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          for (final item in notifications) {
            item['is_read'] = 1;
          }
          isMarkingAll = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Toutes les notifications sont lues"),
          ),
        );
      } else {
        setState(() {
          isMarkingAll = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isMarkingAll = false;
      });
    }
  }

  // Calcule le nombre de notifications non lues.
  int get unreadCount {
    return notifications.where((item) {
      final value = item['is_read'];
      return value == false || value == 0 || value == null;
    }).length;
  }

  // Retourne une icône selon le type de notification.
  IconData _iconForType(String type) {
    switch (type) {
      case 'job':
        return Icons.work_outline_rounded;
      case 'request':
        return Icons.lock_open_outlined;
      case 'message':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  // Retourne une couleur d'accentuation en fonction du type de notification.
  Color _colorForType(String type) {
    switch (type) {
      case 'job':
        return primaryBlue;
      case 'request':
        return Colors.orangeAccent;
      case 'message':
        return Colors.greenAccent;
      default:
        return Colors.white70;
    }
  }

  // Formate la date/heure reçue en chaîne lisible.
  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    final text = raw.toString();
    if (text.length >= 16) {
      return text.substring(0, 16).replaceFirst('T', ' ');
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    // Construction de l'interface principale avec barre supérieure,
    // carte de résumé et contenu dynamique.
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
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 24),
                      _buildSummaryCard(),
                      const SizedBox(height: 22),
                      _buildBody(),
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

  // Barre supérieure avec retour et action 'Marquer tout comme lu'.
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context, true),
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
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: (notifications.isEmpty || isMarkingAll) ? null : markAllAsRead,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: isMarkingAll
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.done_all_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
        ),
      ],
    );
  }

  // Affiche le résumé du nombre de notifications non lues.
  Widget _buildSummaryCard() {
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
              color: primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: primaryBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Stay updated",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount == 0
                      ? "You have no unread notifications"
                      : "You have $unreadCount unread notification(s)",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Corps principal de l'écran, qui gère les différents états.
  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                fetchNotifications();
              },
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 38,
              color: Colors.white.withOpacity(0.45),
            ),
            const SizedBox(height: 12),
            const Text(
              "No notifications yet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "When a recruiter sends a request or a new job is posted, you will see it here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: notifications.map((item) {
        final String type = (item['type'] ?? 'general').toString();
        final bool isRead = item['is_read'] == true || item['is_read'] == 1;
        final Color accent = _colorForType(type);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () async {
              if (!isRead && item['id'] != null) {
                await markAsRead(item['id']);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isRead
                      ? Colors.white.withOpacity(0.04)
                      : accent.withOpacity(0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _iconForType(type),
                      color: accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['message'] ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.62),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatDate(item['created_at']),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.40),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}