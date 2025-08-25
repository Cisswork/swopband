import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swopband/controller/user_controller/UserController.dart';
import 'package:swopband/view/screens/AddLinkScreen.dart';
import 'package:swopband/view/utils/permission_handler.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import '../utils/images/iamges.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_colors.dart';
import '../translations/app_strings.dart';
import 'bottom_nav/PurchaseScreen.dart';
import 'package:swopband/view/widgets/custom_snackbar.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:swopband/services/nfc_background_service.dart';

class CreateProfileScreen extends StatefulWidget {
  final userImage,name,email;
  CreateProfileScreen({Key? key, this.userImage, this.name, this.email}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController swopUserNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController bioController = TextEditingController();
  final controller = Get.put(UserController());
  final NfcBackgroundService _nfcBackgroundService = NfcBackgroundService();

  // Global key to access ImagePickerExample methods
  final GlobalKey<_ImagePickerExampleState> _imagePickerKey = GlobalKey<_ImagePickerExampleState>();

  File? _profileImage;
  bool _nfcInProgress = false;
  String _nfcStatus = '';


  @override
  void dispose() {
    // Ensure background NFC operations are resumed if screen is disposed during NFC operation
    if (_nfcInProgress) {
      _nfcBackgroundService.resumeBackgroundOperations();
    }
    super.dispose();
  }

  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      await GoogleSignIn().signOut();

      print("✅ User successfully signed out.");

      // Navigate to login screen or initial screen
    } catch (e) {
      print("❌ Error signing out: $e");
    }
  }

  // Method to check if NFC is available on the device
  Future<bool> _isNfcAvailable() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      log("[NFC] NFC available: $isAvailable");
      return isAvailable;
    } catch (e) {
      log("[NFC] Error checking NFC availability: $e");
      return false;
    }
  }

  // Enhanced NFC connection method with availability check
  Future<void> _connectAndWriteToNfc() async {
    if(controller.usernameMessage.value != "Username is available") {
      SnackbarUtil.showError("Please enter a valid username");
      return;
    }

    // Check NFC availability first
    bool nfcAvailable = await _isNfcAvailable();
    if (!nfcAvailable) {
      SnackbarUtil.showError("NFC is not available on this device. Please enable NFC in your device settings.");
      return;
    }

    setState(() {
      _nfcInProgress = true;
      _nfcStatus = 'Creating profile...';
    });

    // First create user profile
    try {
      _writeSwopHandleToNfc();
    } catch (e) {
      setState(() {
        _nfcInProgress = false;
        _nfcStatus = 'Failed to create profile';
      });
      SnackbarUtil.showError('Failed to create profile: $e');
    }
  }

  Future<void> _writeSwopHandleToNfc() async {
    setState(() {
      _nfcStatus = 'Ready to connect to Swopband...';
    });

    log("[NFC] Starting manual NFC write operation...");
    
    // Pause background NFC operations to avoid conflicts
    _nfcBackgroundService.pauseBackgroundOperations();
    log("[NFC] Background NFC operations paused");

    // Show NFC connection dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Connect to Swopband'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nfc, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text('Hold your device near the Swopband ring.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              log("[NFC] User cancelled NFC operation");
              NfcManager.instance.stopSession();
              Navigator.of(context).pop();
              setState(() {
                _nfcInProgress = false;
                _nfcStatus = '';
              });
              // Resume background operations when cancelled
              _nfcBackgroundService.resumeBackgroundOperations();
              log("[NFC] Background NFC operations resumed after cancellation");
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
    
    try {
      log("[NFC] Starting NFC session for writing...");
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          log("[NFC] Tag discovered during write operation: $tag");
          var ndef = Ndef.from(tag);
          if (ndef == null) {
            log("[NFC] Tag is not NDEF compatible");
            NfcManager.instance.stopSession(errorMessage: 'Tag not NDEF compatible');
            Navigator.of(context).pop();
            setState(() {
              _nfcStatus = 'This tag is not NDEF compatible. Use a blank NFC tag.';
              _nfcInProgress = false;
            });
            SnackbarUtil.showError('This tag is not NDEF compatible. Use a blank NFC tag.');
            // Resume background operations on error
            _nfcBackgroundService.resumeBackgroundOperations();
            log("[NFC] Background NFC operations resumed after NDEF error");
            return;
          }
          if (!ndef.isWritable) {
            log("[NFC] Tag is not writable");
            NfcManager.instance.stopSession(errorMessage: 'Tag not writable');
            Navigator.of(context).pop();
            setState(() {
              _nfcStatus = 'This tag is not writable. Use a blank NFC tag.';
              _nfcInProgress = false;
            });
            SnackbarUtil.showError('This tag is not writable. Use a blank NFC tag.');
            // Resume background operations on error
            _nfcBackgroundService.resumeBackgroundOperations();
            log("[NFC] Background NFC operations resumed after writable error");
            return;
          }
          try {
            String swopHandleUrl = "https://srirangasai.dev/${swopUserNameController.text}";
            log("[NFC] Writing URL to tag: $swopHandleUrl");
            await ndef.write(NdefMessage([
              NdefRecord.createUri(Uri.parse(swopHandleUrl))
            ]));
            log("[NFC] Successfully wrote to NFC tag");
            NfcManager.instance.stopSession();
            Navigator.of(context).pop();
            setState(() {
              _nfcStatus = 'Successfully connected!';
              _nfcInProgress = false;
            });
            SnackbarUtil.showSuccess('Swopband connected successfully!');
            await Future.delayed(Duration(seconds: 1));
            // Prefer file upload via multipart when available
            File? selectedFile = _imagePickerKey.currentState?.getSelectedImageFile();
            String profileImage = await _getCurrentProfileImage();
            await controller.createUser(
              username: swopUserNameController.text,
              name: nameController.text,
              email: emailController.text,
              bio: bioController.text,
              profileFile: selectedFile,
              profileUrl: selectedFile == null ? profileImage : null,
              onSuccess: () {
                log("[NFC] User profile created successfully");
                // Resume background operations after successful operation
                _nfcBackgroundService.resumeBackgroundOperations();
                log("[NFC] Background NFC operations resumed after successful operation");
                Get.to(() => AddLinkScreen());
              },
            );
          } catch (e) {
            log("[NFC] Error writing to tag: $e");
            NfcManager.instance.stopSession(errorMessage: e.toString());
            Navigator.of(context).pop();
            setState(() {
              _nfcStatus = 'Failed to write: $e';
              _nfcInProgress = false;
            });
            String errorMsg = e.toString();
            if (errorMsg.contains('capacity')) {
              SnackbarUtil.showError('Tag memory too small. Use a bigger NFC tag.');
            } else {
              SnackbarUtil.showError('Failed to write to tag: $e');
            }
            print('NFC write error: $e');
            // Resume background operations on error
            _nfcBackgroundService.resumeBackgroundOperations();
            log("[NFC] Background NFC operations resumed after write error");
          }
        },
        onError: (error) async {
          log("[NFC] NFC session error: $error");
          Navigator.of(context).pop();
          setState(() {
            _nfcStatus = 'NFC session error: $error';
            _nfcInProgress = false;
          });
          SnackbarUtil.showError('NFC session error: $error');
          // Resume background operations on error
          _nfcBackgroundService.resumeBackgroundOperations();
          log("[NFC] Background NFC operations resumed after session error");
        },
      );
    } catch (e) {
      log("[NFC] Failed to start NFC session: $e");
      Navigator.of(context).pop();
      setState(() {
        _nfcStatus = 'Failed to connect: $e';
        _nfcInProgress = false;
      });
      SnackbarUtil.showError('Failed to connect: $e');
      print('NFC session error: $e');
      // Resume background operations on error
      _nfcBackgroundService.resumeBackgroundOperations();
      log("[NFC] Background NFC operations resumed after start session error");
    }
  }

  Future<void> _readFromNfc() async {
    setState(() {
      _nfcStatus = 'Reading from Swopband...';
    });

    // Pause background NFC operations to avoid conflicts
    _nfcBackgroundService.pauseBackgroundOperations();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Read from Swopband'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nfc, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text('Hold your device near the Swopband ring.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              NfcManager.instance.stopSession();
              Navigator.of(context).pop();
              setState(() {
                _nfcStatus = '';
              });
              // Resume background operations when cancelled
              _nfcBackgroundService.resumeBackgroundOperations();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          Ndef? ndef = Ndef.from(tag);
          if (ndef == null || ndef.cachedMessage == null) {
            NfcManager.instance.stopSession(errorMessage: 'No data found');
            Navigator.of(context).pop();
            setState(() {
              _nfcStatus = 'No data found on this tag.';
            });
            SnackbarUtil.showError('No data found on this tag.');
            // Resume background operations on error
            _nfcBackgroundService.resumeBackgroundOperations();
            return;
          }
          
          NfcManager.instance.stopSession();
          Navigator.of(context).pop();
          
          final records = ndef.cachedMessage!.records;
          if (records.isNotEmpty) {
            String data = '';
            String extractedUsername = '';
            
            for (var record in records) {
              if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
                String uriData = NdefRecord.URI_PREFIX_LIST[record.payload[0]] + String.fromCharCodes(record.payload.sublist(1));
                data += '$uriData\n';
                
                // Extract username from srirangasai.dev URLs for display only
                if (uriData.contains('srirangasai.dev')) {
                  try {
                    final uri = Uri.parse(uriData);
                    if (uri.host == 'srirangasai.dev' && uri.pathSegments.isNotEmpty) {
                      extractedUsername = uri.pathSegments.first;
                    }
                  } catch (e) {
                    print('Error parsing URI: $e');
                  }
                }
              } else {
                data += '${String.fromCharCodes(record.payload)}\n';
              }
            }
            
            setState(() {
              if (extractedUsername.isNotEmpty) {
                _nfcStatus = 'Read: @$extractedUsername (Profile Preview)';
              } else {
                _nfcStatus = 'Data read: ${data.trim()}';
              }
            });
            
            // Resume background operations after successful read
            _nfcBackgroundService.resumeBackgroundOperations();
            
            // Show enhanced data dialog with username info
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Swopband Data Read'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (extractedUsername.isNotEmpty) ...[
                      Text(
                        'Username: @$extractedUsername',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This is a profile preview. No connection will be created.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Divider(),
                    ],
                    Text(
                      'Raw Data:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.trim(),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            setState(() {
              _nfcStatus = 'No records found on this tag.';
            });
            SnackbarUtil.showError('No records found on this tag.');
            // Resume background operations on error
            _nfcBackgroundService.resumeBackgroundOperations();
          }
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      setState(() {
        _nfcStatus = 'Failed to read: $e';
      });
      SnackbarUtil.showError('Failed to read: $e');
      // Resume background operations on error
      _nfcBackgroundService.resumeBackgroundOperations();
    }
  }

  bool _validateForm() {
    if (swopUserNameController.text.trim().isEmpty) {
      SnackbarUtil.showError('Please enter a username');
      return false;
    }
    
    if (nameController.text.trim().isEmpty) {
      SnackbarUtil.showError('Please enter your name');
      return false;
    }
    
    if (emailController.text.trim().isEmpty) {
      SnackbarUtil.showError('Please enter your email');
      return false;
    }
    
    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
      SnackbarUtil.showError('Please enter a valid email address');
      return false;
    }
    
    // Age validation (optional but if provided, should be valid)
    if (ageController.text.trim().isNotEmpty) {
      int? age = int.tryParse(ageController.text.trim());
      if (age == null || age < 1 || age > 120) {
        SnackbarUtil.showError('Please enter a valid age (1-120)');
        return false;
      }
    }
    
    // Phone validation (optional but if provided, should be valid)
    if (phoneController.text.trim().isNotEmpty) {
      if (!RegExp(r'^[\+]?[1-9][\d]{0,15}$').hasMatch(phoneController.text.trim().replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
        SnackbarUtil.showError('Please enter a valid phone number');
        return false;
      }
    }
    
    return true;
  }

  Future<void> _startNfcSessionAndWrite() async {
    // Validate form first
    if (!_validateForm()) {
      return;
    }
    
    log("[NFC] Starting NFC session and write process...");
    setState(() {
      _nfcStatus = "Hold your iPhone near the Swopband ring...";
      _nfcInProgress = true;
    });

    // Pause background NFC operations to avoid conflicts
    _nfcBackgroundService.pauseBackgroundOperations();

    // Show beautiful dialog with Cancel button while waiting for NFC connection
   Platform.isAndroid? showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated NFC icon with gradient
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.nfc, size: 48, color: Colors.white),
                ),

                SizedBox(height: 24),

                // Title with custom styling
                Text(
                  "Connect to Swopband",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 16),

                // Description text
                Text(
                  "Hold your device near the Swopband ring to connect...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                SizedBox(height: 24),

                // Custom animated progress indicator
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CupertinoActivityIndicator(
                    color: MyColors.primaryColor,
                  ),
                ),

                SizedBox(height: 24),

                // Cancel button with nice styling
                OutlinedButton(
                  onPressed: () {
                    log("[NFC] User cancelled NFC session.");
                    NfcManager.instance.stopSession();
                    Navigator.of(context).pop();  // Close dialog
                    setState(() {
                      _nfcStatus = "";
                      _nfcInProgress = false;
                    });
                    // Resume background operations when cancelled
                    _nfcBackgroundService.resumeBackgroundOperations();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ):SizedBox();

    try {
      log("[NFC] Calling NfcManager.instance.startSession()");
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443}, // You can also specify iso18092 and iso15693.
        alertMessage: "Hold your device near the Swopband ring to connect",
        onDiscovered: (NfcTag tag) async {
          log("[NFC] Tag detected: $tag");

          var ndef = Ndef.from(tag);
          if (ndef == null) {
            log("[NFC] Tag is NOT NDEF compatible.");
            NfcManager.instance.stopSession(errorMessage: 'This tag is not NDEF compatible.');

            setState(() {
              _nfcStatus = "Tag not NDEF compatible.";
              _nfcInProgress = false;
            });
            SnackbarUtil.showError("Tag is not NDEF compatible.");
            Platform.isAndroid?  Navigator.of(context).pop():null; // close dialog
            // Resume background operations on error
            _nfcBackgroundService.resumeBackgroundOperations();
            return;
          }

          log("[NFC] Tag is NDEF compatible.");
          if (!ndef.isWritable) {
            log("[NFC] Tag is NOT writable.");
            NfcManager.instance.stopSession(errorMessage: 'This tag is not writable.');
            setState(() {
              _nfcStatus = "Tag is not writable.";
              _nfcInProgress = false;
            });
            SnackbarUtil.showError("Tag is not writable.");
            Platform.isAndroid?  Navigator.of(context).pop():null; // close dialog
            // Resume background operations on error
            _nfcBackgroundService.resumeBackgroundOperations();
            return;
          }

          log("[NFC] Tag is writable. Preparing to write...");
          try {
            String swopHandleUrl = "https://srirangasai.dev/${swopUserNameController.text}";
            log("[NFC] Writing URL to tag: $swopHandleUrl");
            await ndef.write(NdefMessage([
              NdefRecord.createUri(Uri.parse(swopHandleUrl))
            ]));
            log("[NFC] Write successful, stopping NFC session.");
            NfcManager.instance.stopSession();
            setState(() {
              _nfcStatus = "Successfully connected and written!";
              _nfcInProgress = false;
            });
            SnackbarUtil.showSuccess("Swopband connected successfully!");

            Platform.isAndroid?  Navigator.of(context).pop():null; // close dialog

            log("[NFC] Calling controller.createUser()");
            File? selectedFile = _imagePickerKey.currentState?.getSelectedImageFile();
            String profileImage = await _getCurrentProfileImage();
            await controller.createUser(
              username: swopUserNameController.text,
              name: nameController.text,
              email: emailController.text,
              bio: bioController.text,
              age: ageController.text.trim().isNotEmpty ? int.tryParse(ageController.text.trim()) : null,
              phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
              profileFile: selectedFile,
              profileUrl: selectedFile == null ? profileImage : null,
              onSuccess: () {
                log("[NFC] User created successfully, navigating to AddLinkScreen.");
                // Resume background operations after successful operation
                _nfcBackgroundService.resumeBackgroundOperations();
                Get.offAll(() => AddLinkScreen());
              },
            );
          } catch (e) {
            log("[NFC] Error during write: $e");
            NfcManager.instance.stopSession(errorMessage: e.toString());
            setState(() {
              _nfcStatus = "Write failed: $e";
              _nfcInProgress = false;
            });
            SnackbarUtil.showError("Failed to write to tag: $e");
            Platform.isAndroid?  Navigator.of(context).pop():null; // close dialog
            // Resume background operations on error
            _nfcBackgroundService.resumeBackgroundOperations();
          }
        },
      );
    } catch (e) {
      log("[NFC] Failed to start NFC session: $e");
      setState(() {
        _nfcStatus = "Failed to start NFC session: $e";
        _nfcInProgress = false;
      });
      SnackbarUtil.showError("Failed to start NFC session: $e");
      Platform.isAndroid?  Navigator.of(context).pop():null; // close dialog
      // Resume background operations on error
      _nfcBackgroundService.resumeBackgroundOperations();
    }
  }

  // Method to get current profile image (selected file or auth image)
  Future<String> _getCurrentProfileImage() async {
    print("=== _getCurrentProfileImage called ===");
    
    // ALWAYS prioritize auth image URL to avoid API size limits
    if (widget.userImage != null && widget.userImage.isNotEmpty) {
      print("✅ Using auth image URL (most reliable): ${widget.userImage}");
      return widget.userImage;
    }
    
    if (_imagePickerKey.currentState != null) {
      File? selectedFile = _imagePickerKey.currentState!.getSelectedImageFile();
      String? selectedUrl = _imagePickerKey.currentState!.getCurrentImageUrl();
      
      // Only use picked file if auth image is not available AND file is very small
      if (selectedFile != null) {
        try {
          int fileSize = await selectedFile.length();
          print("Selected file size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)");
          
          // Only use base64 for very small files (< 30KB to stay well under API limit)
          if (fileSize <= 30 * 1024) {
            String? base64Image = await _imagePickerKey.currentState!.getCurrentImageAsBase64();
            if (base64Image != null && base64Image.isNotEmpty) {
              print("✅ Sending small picked image as base64 (${base64Image.length} chars)");
              return base64Image;
            }
          } else {
            print("⚠️ File too large for base64 (${(fileSize / 1024).toStringAsFixed(2)} KB), skipping picked image");
          }
        } catch (e) {
          print("❌ Error processing picked file: $e");
        }
      }
      
      // Use selected URL if available
      if (selectedUrl != null && selectedUrl.isNotEmpty) {
        print("✅ Using selected URL: $selectedUrl");
        return selectedUrl;
      }
    }
    
    // Final fallback
    print("⚠️ No suitable image available, sending empty string");
    return "";
  }

  // Method to test NFC functionality
  Future<void> _testNfcFunctionality() async {
    log("[NFC] Testing NFC functionality...");
    
    try {
      // Check NFC availability
      bool nfcAvailable = await _isNfcAvailable();
      if (!nfcAvailable) {
        SnackbarUtil.showError("NFC is not available on this device");
        return;
      }
      
      // Check background service health
      bool serviceHealthy = _nfcBackgroundService.isHealthy;
      log("[NFC] Background service health: $serviceHealthy");
      
      // Test pause/resume functionality
      _nfcBackgroundService.pauseBackgroundOperations();
      log("[NFC] Background operations paused for testing");
      
      await Future.delayed(Duration(seconds: 2));
      
      _nfcBackgroundService.resumeBackgroundOperations();
      log("[NFC] Background operations resumed after testing");
      
      SnackbarUtil.showSuccess("NFC test completed successfully!");
      log("[NFC] NFC test completed successfully");
      
    } catch (e) {
      log("[NFC] NFC test failed: $e");
      SnackbarUtil.showError("NFC test failed: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name ?? "";
    emailController.text = widget.email ?? "";
    
    // Pre-fill username if available
    if (widget.name != null && widget.name.isNotEmpty) {
      String username = widget.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      swopUserNameController.text = username;
      // Check username availability
      if (username.isNotEmpty) {
        controller.checkUsernameAvailability(username);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log("user image>>>>>>>>${widget.userImage}");
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MyImages.background1,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(MyImages.nameLogo, height: 40),
                      SizedBox(height: 10),
                      Text(
                        AppStrings.createProfile.tr,
                        style: AppTextStyles.large.copyWith(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      ImagePickerExample(
                        key: _imagePickerKey,
                        profileImage: widget.userImage ?? "",
                      ),
                      SizedBox(height: 24),
                      Text(
                        AppStrings.createSwopHandle.tr,
                        style: AppTextStyles.large.copyWith(fontSize: 13,fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      myFieldAdvance(
                        onChanged: (username) {
                          controller.checkUsernameAvailability(username.trim());
                        },
                        context: context,
                        controller: swopUserNameController,
                        hintText: "Enter username",
                        inputType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        fillColor: MyColors.textWhite,
                        textBack: MyColors.textWhite,
                      ),

                      SizedBox(height: 8),
                      Obx(() {
                        final username = controller.swopUsername.value.trim();
                        if (username.isEmpty) return const SizedBox(); // Hide when empty

                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: MyColors.textBlack,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              //height: 30,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  username,
                                  style: AppTextStyles.small.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.textWhite,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.usernameMessage.value,
                              style: AppTextStyles.small.copyWith(
                                color: controller.isUsernameAvailable.value ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 8),
                      myFieldAdvance(
                        context: context,
                        controller: nameController,
                        hintText: "Enter Full Name",
                        inputType: TextInputType.text,
                        textInputAction: TextInputAction.next, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                      ),
                      SizedBox(height: 20),
                      myFieldAdvance(
                        context: context,
                        controller: emailController,
                        hintText: "Email",
                        inputType: TextInputType.text,
                        textInputAction: TextInputAction.next, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                      ),
                      SizedBox(height: 8),
                      myFieldAdvance(
                        context: context,
                        controller: ageController,
                        hintText: "Age",
                        inputType: TextInputType.number,
                        textInputAction: TextInputAction.next, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                      ),
                      SizedBox(height: 8),
                      myFieldAdvance(
                        context: context,
                        controller: phoneController,
                        hintText: "Phone Number",
                        inputType: TextInputType.phone,
                        textInputAction: TextInputAction.next, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                      ),
                      SizedBox(height: 8),

                      Text(
                        AppStrings.addYourBio.tr,
                        style: AppTextStyles.medium.copyWith(
                          color: MyColors.textBlack,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 8),

                      TextFormField(
                        maxLength: 100,
                        onTap: () async{
                        // await signOut();
                        },
                        maxLines: 4,

                        controller: bioController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.only(
                            top: 40,
                            left: 20,
                          ),
                          hintText: "Enter a bio",
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            fontFamily: "Chromatica",
                            color: MyColors.textBlack,
                            decoration: TextDecoration.none,
                            wordSpacing: 1.2,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),
                      
                      // NFC Status display
                      if (_nfcStatus.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _nfcStatus,
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      _nfcInProgress
                          ? Center(child: CircularProgressIndicator(color: Colors.black))
                          : CustomButton(
                          text: AppStrings.connectSwopband.tr,
                          onPressed:_startNfcSessionAndWrite// _connectAndWriteToNfc,
                      ),

                      SizedBox(height:10),
                      
                      // NFC Read Button for testing
                      CustomButton(
                        buttonColor: MyColors.textWhite,
                        textColor: MyColors.textBlack,
                        text: "Read NFC Tag",
                        onPressed: _readFromNfc,
                      ),

                      SizedBox(height:10),
                      
                      // NFC Test Button for debugging
                      CustomButton(
                        buttonColor: Colors.orange,
                        textColor: Colors.white,
                        text: "Test NFC",
                        onPressed: _testNfcFunctionality,
                      ),

                      SizedBox(height:10),
                      CustomButton(
                        buttonColor: MyColors.textWhite,
                        textColor: MyColors.textBlack,
                        text: AppStrings.purchaseSwopband.tr,
                        onPressed: ()async{
                          Get.to(()=>PurchaseScreen());
                        },
                      ),

                      SizedBox(height: 16),
                    ],
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

class ImagePickerExample extends StatefulWidget {
  final String? profileImage;

  ImagePickerExample({super.key,required this.profileImage});

  @override
  _ImagePickerExampleState createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {

  File? _selectedImageFile;
  String? _selectedImageUrl;
  bool _isImageFromAuth = true;
  bool _isLoadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with auth image if available
    if (widget.profileImage != null && widget.profileImage!.isNotEmpty) {
      _selectedImageUrl = widget.profileImage;
      _isImageFromAuth = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(context),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: MyColors.primaryColor.withOpacity(0.1),
            backgroundImage: _isLoadingImage ? null : _getBackgroundImage(),
            onBackgroundImageError: _isLoadingImage ? null : (exception, stackTrace) {
              print('Error loading profile image: $exception');
              // Fallback to default image on error
              setState(() {
                _selectedImageUrl = null;
                _selectedImageFile = null;
              });
            },
            child: _isLoadingImage
                ? CircularProgressIndicator(
                    color: MyColors.primaryColor,
                    strokeWidth: 3,
                  )
                : null,
          ),
          // Camera icon overlay to indicate it's clickable
          if (!_isLoadingImage)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: MyColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider _getBackgroundImage() {
    // Priority: Selected file > Auth URL > Default image
    if (_selectedImageFile != null) {
      return FileImage(_selectedImageFile!);
    } else if (_selectedImageUrl != null && _selectedImageUrl!.isNotEmpty) {
      return NetworkImage(_selectedImageUrl!);
    } else {
      return AssetImage("assets/images/img.png") as ImageProvider;
    }
  }

  // Method to get the current image (for parent widget)
  String? getCurrentImageUrl() {
    return _selectedImageUrl;
  }

  // Method to get the selected file (for parent widget)
  File? getSelectedImageFile() {
    return _selectedImageFile;
  }

  // Method to get the current image as base64 (for API calls)
  Future<String?> getCurrentImageAsBase64() async {
    if (_selectedImageFile != null) {
      try {
        List<int> imageBytes = await _selectedImageFile!.readAsBytes();
        return base64Encode(imageBytes);
      } catch (e) {
        print('Error converting image to base64: $e');
        return null;
      }
    }
    return null;
  }

  void _showImageSourceSheet(BuildContext context) async {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Change Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

              _buildOptionButton(
                context,
                icon: Icons.camera_alt,
                text: 'Take Photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage1(ImageSource.camera);
                },
              ),
              Divider(height: 1, indent: 20, endIndent: 20),
              _buildOptionButton(
                context,
                icon: Icons.photo_library,
                text: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage1(ImageSource.gallery);
                },
              ),
            SizedBox(height: 8),
            // Only show remove option if there's an image
            if (_selectedImageFile != null || (_selectedImageUrl != null && _selectedImageUrl!.isNotEmpty))
              Column(
                children: [
                  Divider(height: 1, indent: 20, endIndent: 20),
                  _buildOptionButton(
                    context,
                    icon: Icons.delete,
                    text: 'Remove Photo',
                    onTap: _removeImage,
                  ),
                ],
              ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: MyColors.accentColor),
      title: Text(text),
      onTap: onTap,
    );
  }

  void _removeImage() {
    Navigator.pop(context);
    setState(() {
      _selectedImageFile = null;
      _selectedImageUrl = null;
      _isImageFromAuth = false;
    });
    _showSuccessSnackbar('Profile photo removed');
  }



  Future<void> _pickImage1(ImageSource source) async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      // Check permissions based on source
      if (source == ImageSource.camera) {
        var cameraStatus = await Permission.camera.request();
        if (cameraStatus != PermissionStatus.granted) {
          _showPermissionDialog('Camera permission is required to take photos.');
          return;
        }
      } else {
        var storageStatus = await Permission.storage.request();
        if (storageStatus != PermissionStatus.granted) {
          _showPermissionDialog('Storage permission is required to access photos.');
          return;
        }
      }
      
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 30, // Very low quality for minimal file size
        maxWidth: 200,    // Very small max width
        maxHeight: 200,   // Very small max height
      );

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        
        // Validate file size (allow up to 5MB for multipart upload)
        int fileSize = await file.length();
        print('Selected image size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)');
        if (fileSize > 5 * 1024 * 1024) {
          _showErrorSnackbar('Image too large. Maximum allowed size is 5MB.');
          return;
        }

        setState(() {
          _selectedImageFile = file;
          _selectedImageUrl = null; // Clear URL since we have a file
          _isImageFromAuth = false;
        });

        _showSuccessSnackbar('Profile photo updated successfully');
        print('✅ Image selected and stored: ${pickedFile.path}');
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorSnackbar('Failed to pick image: $e');
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }


  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    SnackbarUtil.showError(message);
  }

  void _showSuccessSnackbar(String message) {
    SnackbarUtil.showSuccess(message);
  }
}

