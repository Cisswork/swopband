import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/network/ApiUrls.dart';
import '../../view/network/ApiService.dart';
import '../../view/utils/shared_pref/SharedPrefHelper.dart';
import 'package:swopband/view/widgets/custom_snackbar.dart';
import 'package:swopband/view/screens/bottom_nav/BottomNavScreen.dart';
import 'package:http/http.dart' as http;

class UserController extends GetxController {
  var isLoading = false.obs;
  var isUsernameAvailable = false.obs;
  var usernameMessage = ''.obs;
  var swopUsername = ''.obs;

  Future<void> createUser({required String username, required String name,
    required String email, required String bio, required String profileUrl, VoidCallback? onSuccess,}) async {
    isLoading.value = true;

    final userData = {
      "username": username,
      "name": name,
      "email": email,
      "bio": bio,
      "profile_url": profileUrl,
    };
    print("PARAMETER------>$userData");
    var response = await ApiService.post(ApiUrls.createUser, userData);

    isLoading.value = false;
    print("RESPONSE------>${response?.body}");

    if (response == null) {
      SnackbarUtil.showError("No response from server");
      return;
    }

    try {
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userId = body['id'].toString();
        final message = body['message'] ?? "User created";

        if (userId != null) {
          await SharedPrefService.saveString('backend_user_id', userId);
          SnackbarUtil.showSuccess(message);
          if (onSuccess != null) onSuccess(); // callback e.g. navigation
        } else {
          SnackbarUtil.showError("User ID not found in response");
        }
      } else {
        final error = body['error'] ?? body['message'] ?? "Something went wrong";
        SnackbarUtil.showError(error);
        // If user already exists, navigate to BottomNavScreen
        if (error.toString().toLowerCase().contains('firebase id or email id already exist')) {
          // Optionally save backend_user_id if present
          final userId = body['id']?['id'];
          if (userId != null) {
            await SharedPrefService.saveString('backend_user_id', userId);
          }
          // Navigate to BottomNavScreen
          Get.offAll(() => BottomNavScreen());
        }
      }
    } catch (e) {
      print("❌ JSON parsing error: $e");
      SnackbarUtil.showError("Invalid response format");
    }
  }

  Future<void> checkUsernameAvailability(String username) async {
    swopUsername.value = username; // Update instantly

    if (username.isEmpty) {
      isUsernameAvailable.value = false;
      usernameMessage.value = '';
      return;
    }

    final url = "${ApiUrls.baseUrl}/users/check_username/$username";

    final response = await ApiService.get(url);
    if (response != null && response.statusCode == 200) {
      final body = jsonDecode(response.body);
      isUsernameAvailable.value = body['status'] == true;
      usernameMessage.value = body['message'] ?? '';
    } else {
      isUsernameAvailable.value = false;
      usernameMessage.value = 'Something went wrong';
    }
  }

  Future<Map<String, dynamic>?> fetchUserByFirebaseId(String firebaseId) async {
    final url = Uri.parse('https://srirangasai.dev/users/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'firebase_id': firebaseId,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log("Exist User Data---------------${data['user']}");

        return data['user'];
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user: $e');
      return null;
    }
  }
}
