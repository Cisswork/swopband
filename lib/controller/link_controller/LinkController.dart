import 'dart:convert';
import 'dart:developer';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:swopband/view/widgets/custom_snackbar.dart';
import '../../model/FetchAllLinksModel.dart';
import '../../view/network/ApiService.dart';
import '../../view/network/ApiUrls.dart';
import '../../view/utils/shared_pref/SharedPrefHelper.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/material.dart';

class LinkController extends GetxController {

  var isLoading = false.obs;
  var links = <Link>[].obs;
  var fetchLinkLoader = false.obs;

  // NFC Write Logic
  var nfcWriteInProgress = false.obs;
  var nfcWriteStatus = ''.obs;
  List<NdefRecord> nfcRecords = [];

  void addNfcRecord(NdefRecord record) {
    nfcRecords.add(record);
    update();
  }

  void removeNfcRecord(int index) {
    if (index >= 0 && index < nfcRecords.length) {
      nfcRecords.removeAt(index);
      update();
    }
  }

  Future<void> createLink({required String name, required String type, required String url,required VoidCallback call}) async {
    log("api start");
    isLoading.value = true;
    try {
      final userId = await SharedPrefService.getString('backend_user_id');
      if (userId == null) {
        SnackbarUtil.showError("User ID not found");
        return;
      }

      final body = {
        "user_id": userId,
        "name": name,
        "type": type,
        "url": url,
      };

      log("body---->$body");

      final response = await ApiService.post(ApiUrls.createLink, body);
      log("create link response---->${response?.body}");
      if (response == null) {
        SnackbarUtil.showError("No response from server");
        return;
      }

      final data = jsonDecode(response.body);
      log("status code----->1${response.statusCode}");
      if (response.statusCode == 200) {
        log("status code----->2${response.statusCode}");
        log("response body${response.body}");
        final message = data['message'] ?? 'Link created';
        call();

        SnackbarUtil.showSuccess(message);
      } else {
        // Check for field-specific errors first
        if (data['errors'] != null && data['errors']['fieldErrors'] != null) {
          final fieldErrors = data['errors']['fieldErrors'] as Map<String, dynamic>;
          
          // Check for URL field error
          if (fieldErrors['url'] != null && fieldErrors['url'] is List && fieldErrors['url'].isNotEmpty) {
            final urlError = fieldErrors['url'][0];
            log("URL field error: $urlError");
            SnackbarUtil.showError(urlError);
            return;
          }
          
          // Check for other field errors
          for (String field in fieldErrors.keys) {
            if (fieldErrors[field] is List && fieldErrors[field].isNotEmpty) {
              final fieldError = fieldErrors[field][0];
              log("Field error for $field: $fieldError");
              SnackbarUtil.showError(fieldError);
              return;
            }
          }
        }
        
        // Check for specific error messages and provide better user feedback
        final error = data['error'] ?? data['message'] ?? "Something went wrong";
        log("error-->$error");
        
        // Handle specific error cases with better user guidance
        final errorString = error.toString().toLowerCase();
        if (errorString.contains('duplicate')) {
          SnackbarUtil.showError("This link already exists. Please try a different URL or check your existing links.");
        } else if (errorString.contains('invalid') || errorString.contains('url')) {
          SnackbarUtil.showError("Please enter a valid URL for this link type.");
        } else if (errorString.contains('required') || errorString.contains('missing')) {
          SnackbarUtil.showError("Please fill in all required fields.");
        } else if (response.statusCode == 409) {
          SnackbarUtil.showError("This link already exists in your profile. Please use a different URL.");
        } else {
          SnackbarUtil.showError(error);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }




  Future<void> writeNfcTagAndSaveLink({
    required BuildContext context,
    required String name,
    required String type,
    required String url,
  }) async {
    if (nfcRecords.isEmpty) {
      SnackbarUtil.showError('No NFC data to write!');
      return;
    }
    nfcWriteInProgress.value = true;
    nfcWriteStatus.value = 'Waiting for NFC tag...';
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          NfcManager.instance.stopSession(errorMessage: 'Tag not writable');
          nfcWriteStatus.value = 'This tag is not writable';
          nfcWriteInProgress.value = false;
          SnackbarUtil.showError('This tag is not writable');
          return;
        }
        try {
          await ndef.write(NdefMessage(nfcRecords));
          NfcManager.instance.stopSession();
          nfcWriteStatus.value = 'Write successful!';
          nfcWriteInProgress.value = false;
          SnackbarUtil.showSuccess('NFC write successful!');
          // Call backend API to save link
          await createLink(name: name, type: type, url: url, call: () {  });
        } catch (e) {
          NfcManager.instance.stopSession(errorMessage: e.toString());
          nfcWriteStatus.value = 'Write failed: $e';
          nfcWriteInProgress.value = false;
          SnackbarUtil.showError('Write failed: $e');
        }
      },
    );
  }


  Future<void> fetchLinks() async {
    fetchLinkLoader.value = true;

    final userId = await SharedPrefService.getString('backend_user_id');
    if (userId == null) {
      Get.snackbar("Error", "User ID not found in storage");
      fetchLinkLoader.value = false;
      return;
    }

    final response = await ApiService.get("https://srirangasai.dev/links/");
    print("Response Fetch Link--->${response?.body}");

    fetchLinkLoader.value = false;

    if (response != null && response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final List linksJson = data['links'] ?? [];

        // Safely assign after frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          links.value = linksJson.map((e) => Link.fromJson(e)).toList();
        });
      } catch (e) {
        Get.snackbar("Error", "Failed to parse links");
        print("❌ JSON decode error: $e");
      }
    }


  }

  Future<void> deleteLink(String id) async {
    isLoading.value = true;
    try {
      final response = await ApiService.delete('https://srirangasai.dev/links/$id');
      if (response != null && response.statusCode == 200) {
        SnackbarUtil.showSuccess('Link deleted successfully');
        await fetchLinks();
      } else {
        SnackbarUtil.showError('Failed to delete link');
      }
    } catch (e) {
      SnackbarUtil.showError('Failed to delete link: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLink({required String id, required String type, required String url}) async {
    isLoading.value = true;
    try {
      final userId = await SharedPrefService.getString('backend_user_id');
      if (userId == null) {
        SnackbarUtil.showError('User ID not found');
        return;
      }
      final body = {
        'user_id': userId,
        'type': type,
        'url': url,
      };
      final response = await ApiService.put('https://srirangasai.dev/links/$id', body);
      if (response != null && response.statusCode == 200) {
        SnackbarUtil.showSuccess('Link updated successfully');
        await fetchLinks();
      } else {
        SnackbarUtil.showError('Failed to update link');
      }
    } catch (e) {
      SnackbarUtil.showError('Failed to update link: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }


}
