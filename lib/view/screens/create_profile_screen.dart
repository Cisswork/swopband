import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
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

import 'connect_swopband_screen.dart';

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

  final FocusNode usernameFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode ageFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode bioFocus = FocusNode();



  final controller = Get.put(UserController());
  final NfcBackgroundService _nfcBackgroundService = NfcBackgroundService();

  // Global key to access ImagePickerExample methods
  final GlobalKey<_ImagePickerExampleState> _imagePickerKey = GlobalKey<_ImagePickerExampleState>();

  File? _profileImage;
  bool _nfcInProgress = false;
  String _nfcStatus = '';
  Timer? _nfcTimeoutTimer;


  @override
  void dispose() {
    // Cancel timeout timer if running


      usernameFocus.dispose();
      nameFocus.dispose();
      emailFocus.dispose();
      ageFocus.dispose();
      phoneFocus.dispose();
      bioFocus.dispose();

    _nfcTimeoutTimer?.cancel();
    _nfcTimeoutTimer = null;
    
    // Ensure background NFC operations are resumed if screen is disposed during NFC operation
    if (_nfcInProgress) {
      try {
        NfcManager.instance.stopSession();
      } catch (e) {
        log("[NFC] Error stopping session in dispose: $e");
      }
      _nfcBackgroundService.resumeBackgroundOperations();
      log("[NFC] Background NFC operations resumed in dispose");
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

  // COMMENTED: This function moved to ConnectSwopbandScreen
  /*Future<void> _startNfcSessionAndWrite() async {
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
    
    // Set a timeout to automatically stop loading if NFC session doesn't start
    _nfcTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_nfcInProgress) {
        log("[NFC] Timeout reached, stopping NFC session");
        setState(() {
          _nfcStatus = "NFC connection timeout. Please try again.";
          _nfcInProgress = false;
        });
        try {
          NfcManager.instance.stopSession();
        } catch (e) {
          log("[NFC] Error stopping session on timeout: $e");
        }
        // Close custom dialog if open
        if (Platform.isAndroid && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        // Resume background operations
        _nfcBackgroundService.resumeBackgroundOperations();
        log("[NFC] Background NFC operations resumed after timeout");
      }
    });

    // Show beautiful dialog with Cancel button while waiting for NFC connection
   Platform.isAndroid? showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated NFC icon with gradient
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.nfc, size: 48, color: Colors.white),
                ),

                const SizedBox(height: 24),

                // Title with custom styling
                const Text(
                  "Connect to Swopband",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // Description text
                const Text(
                  "Hold your device near the Swopband ring to connect...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 24),

                // Custom animated progress indicator
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CupertinoActivityIndicator(
                    color: MyColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Cancel button with nice styling
                OutlinedButton(
                  onPressed: () {
                    log("[NFC] User cancelled NFC session.");
                    try {
                      NfcManager.instance.stopSession();
                    } catch (e) {
                      log("[NFC] Error stopping session: $e");
                    }
                    Navigator.of(context).pop();  // Close dialog
                    setState(() {
                      _nfcStatus = "";
                      _nfcInProgress = false;
                    });
                    // Resume background operations when cancelled
                    _nfcBackgroundService.resumeBackgroundOperations();
                    log("[NFC] Background NFC operations resumed after user cancellation");
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text(
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
    ):const SizedBox();

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
            String swopHandleUrl = "https://profile.swopband.com/${swopUserNameController.text}";
            log("[NFC] Writing URL to tag: $swopHandleUrl");
            await ndef.write(NdefMessage([
              NdefRecord.createUri(Uri.parse(swopHandleUrl))
            ]));
            log("[NFC] Write successful, stopping NFC session.");
            // Cancel timeout timer
            _nfcTimeoutTimer?.cancel();
            _nfcTimeoutTimer = null;
            
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
                Get.offAll(() => const AddLinkScreen());
              },
            );
          } catch (e) {
            log("[NFC] Error during write: $e");
            // Cancel timeout timer
            _nfcTimeoutTimer?.cancel();
            _nfcTimeoutTimer = null;
            
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
        onError: (error) async {
          log("[NFC] NFC session error: $error");
          
          // Handle user cancellation of default NFC popup
          if (error.toString().contains('cancelled') || 
              error.toString().contains('canceled') ||
              error.toString().contains('user') ||
              error.toString().contains('User')) {
            log("[NFC] User cancelled default NFC popup");
            setState(() {
              _nfcStatus = "NFC connection cancelled by user";
              _nfcInProgress = false;
            });
            // Close custom dialog if open
            if (Platform.isAndroid && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            // Resume background operations
            _nfcBackgroundService.resumeBackgroundOperations();
            log("[NFC] Background NFC operations resumed after user cancellation");
            return;
          }
          
          // Handle other NFC errors
          log("[NFC] Other NFC error: $error");
          setState(() {
            _nfcStatus = "NFC error: $error";
            _nfcInProgress = false;
          });
          SnackbarUtil.showError("NFC error: $error");
          
          // Close custom dialog if open
          if (Platform.isAndroid && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          // Resume background operations on error
          _nfcBackgroundService.resumeBackgroundOperations();
          log("[NFC] Background NFC operations resumed after NFC error");
        },
      );
    } catch (e) {
      log("[NFC] Failed to start NFC session: $e");
      setState(() {
        _nfcStatus = "Failed to start NFC session: $e";
        _nfcInProgress = false;
      });
      SnackbarUtil.showError("Failed to start NFC session: $e");
      // Close dialog if it's open
      if (Platform.isAndroid && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Resume background operations on error
      _nfcBackgroundService.resumeBackgroundOperations();
      log("[NFC] Background NFC operations resumed after session start error");
    }
  }*/

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),

                  Image.asset(MyImages.nameLogo, height: 40),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.createProfile.tr,
                    style: AppTextStyles.large.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  ImagePickerExample(
                    key: _imagePickerKey,
                    profileImage: widget.userImage ?? "",
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.createSwopHandle.tr,
                    style: AppTextStyles.large.copyWith(fontSize: 13,fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  myFieldAdvance(
                    focusNode: usernameFocus,
                    nextFocusNode: nameFocus,
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

                  const SizedBox(height: 8),
                  Obx(() {
                    final username = controller.swopUsername.value.trim();
                    if (username.isEmpty) return const SizedBox(); // Hide when empty

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
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
                  const SizedBox(height: 8),
                  myFieldAdvance(
focusNode: nameFocus,
                    nextFocusNode: emailFocus,
                    context: context,
                    controller: nameController,
                    hintText: "Enter Full Name",
                    inputType: TextInputType.text,
                    textInputAction: TextInputAction.next, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                  ),
                  const SizedBox(height: 15),
                  myFieldAdvance(
                    focusNode: emailFocus,
                    nextFocusNode: ageFocus,
                    context: context,
                    controller: emailController,
                    hintText: "Email",
                    inputType: TextInputType.text,
                    textInputAction: TextInputAction.next, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                  ),
                  const SizedBox(height: 15),
                  myFieldAdvance(
                    focusNode: ageFocus,
                    nextFocusNode: phoneFocus,
                    context: context,
                    controller: ageController,
                    hintText: "Age",
                    inputType: TextInputType.number,
                    textInputAction: TextInputAction.next, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                  ),
                  const SizedBox(height: 15),
                  myFieldAdvance(
                    focusNode: phoneFocus,
                    nextFocusNode: bioFocus,
                    context: context,
                    controller: phoneController,
                    hintText: "Phone Number",
                    inputType: TextInputType.phone,
                    textInputAction: TextInputAction.next, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                  ),
                  const SizedBox(height: 15),


                  TextFormField(
                    focusNode: bioFocus,
                    maxLength: 100,
                    controller: bioController,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      counterText: '', // default counter hatane ke liye
                      counter: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: bioController,
                        builder: (context, value, child) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0, top: 8),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "${value.text.length}/100",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFamily: "Chromatica",
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // contentPadding: const EdgeInsets.only(
                      //   top: 40,
                      //   left: 20,
                      //   right: 20,
                      //   bottom: 20,
                      // ),
                      hintText: "Add your bio",

                      hintStyle: const TextStyle(
                        fontSize: 14,
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

                  const SizedBox(height: 24),

                  // NFC Status display
                  if (_nfcStatus.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _nfcStatus,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  _nfcInProgress
                      ? const Center(child: CircularProgressIndicator(color: Colors.black))
                      : CustomButton(
                      text: AppStrings.connectSwopband.tr,
                      //onPressed:_startNfcSessionAndWrite// _connectAndWriteToNfc,
                    onPressed: () {
                      // Pass all create profile data to ConnectSwopbandScreen
                      Get.to(() => ConnectSwopbandScreen(
                        username: swopUserNameController.text,
                        name: nameController.text,
                        email: emailController.text,
                        bio: bioController.text,
                        age: ageController.text.trim().isNotEmpty ? int.tryParse(ageController.text.trim()) : null,
                        phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                        userImage: widget.userImage,
                        imagePickerKey: _imagePickerKey,
                      ));
                    },
                  ),

                  const SizedBox(height:10),
                  CustomButton(
                    border: Colors.black,
                    buttonColor: MyColors.textWhite,
                    textColor: MyColors.textBlack,
                    text: AppStrings.purchaseSwopband.tr,
                    onPressed: ()async{
                      Get.to(()=>const PurchaseScreen());
                    },
                  ),

                  const SizedBox(height: 16),

                ],
              ),
            ),
          ),
        ),
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
                ? const CircularProgressIndicator(
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
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: MyColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
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
      return const AssetImage("assets/images/img.png") as ImageProvider;
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

              _buildOptionButton(
                context,
                icon: Icons.camera_alt,
                text: 'Take Photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage1(ImageSource.camera);
                },
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _buildOptionButton(
                context,
                icon: Icons.photo_library,
                text: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage1(ImageSource.gallery);
                },
              ),
            const SizedBox(height: 8),
            // Only show remove option if there's an image
            if (_selectedImageFile != null || (_selectedImageUrl != null && _selectedImageUrl!.isNotEmpty))
              Column(
                children: [
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildOptionButton(
                    context,
                    icon: Icons.delete,
                    text: 'Remove Photo',
                    onTap: _removeImage,
                  ),
                ],
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
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