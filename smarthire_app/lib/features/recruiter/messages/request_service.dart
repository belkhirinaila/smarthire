import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestService {
  static const String baseUrl = "https://smarthire-fpa1.onrender.com";

  static Future<bool> sendRequest(int candidateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("$baseUrl/api/requests"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "candidate_id": candidateId
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}