import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {



  static Future<Map<String, String>> _buildHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseId = prefs.getString("firebase_id") ?? "";

    return {
      'Content-Type': 'application/json',
      'firebase_id': firebaseId,
    };
  }

  static Future<http.Response?> post(String url, Map<String, dynamic> data) async {
    try {
      final headers = await _buildHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      print("❌ POST Error: $e");
      return null;
    }
  }


  /// GET request
  static Future<http.Response?> get(String url) async {
    final headers = await _buildHeaders();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      return response;
    } catch (e) {
      print("❌ GET Error: $e");
      return null;
    }
  }

  /// PUT request
  static Future<http.Response?> put(String url, Map<String, dynamic> data) async {
    try {
      final headers = await _buildHeaders();
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      print("❌ PUT Error: $e");
      return null;
    }
  }

  /// DELETE request
  static Future<http.Response?> delete(String url,
      {Map<String, dynamic>? data}) async {
    try {
      final headers = await _buildHeaders();

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return response;
    } catch (e) {
      print("❌ DELETE Error: $e");
      return null;
    }
  }

  /*final response = await ApiService.post(ApiUrls.userEndpoint, {
  "username": "frr",
  "name": "pff",
  "email": "ranga@gmail.com",
  "bio": "about me11",
  "profile_url": "https://..."
  });

  if (response != null) {
  final statusCode = response.statusCode;

  if (statusCode == 200 || statusCode == 201) {
  final data = jsonDecode(response.body);
  print("✅ Success: ${data['message'] ?? 'User created'}");
  // Access response fields: data['id'], data['name'], etc.
  } else if (statusCode == 400) {
  final error = jsonDecode(response.body);
  print("❌ Validation error: ${error['error'] ?? 'Invalid request'}");
  } else if (statusCode == 401) {
  print("❌ Unauthorized: Please log in again.");
  } else {
  print("❌ Unexpected error: ${response.body}");
  }
  } else {
  print("❌ No response received from server.");
  }*/

}
