import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:country_picker/country_picker.dart';
import 'package:swopband/controller/user_controller/UserController.dart';

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
  final userImage, name, email;
  CreateProfileScreen({Key? key, this.userImage, this.name, this.email})
      : super(key: key);

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

  // Phone number variables
  String _phoneNumber = '';
  Country _selectedCountry = Country.parse('GB');

  final FocusNode usernameFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode ageFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode bioFocus = FocusNode();

  final controller = Get.put(UserController());
  final NfcBackgroundService _nfcBackgroundService = NfcBackgroundService();

  // Global key to access ImagePickerExample methods
  final GlobalKey<_ImagePickerExampleState> _imagePickerKey =
      GlobalKey<_ImagePickerExampleState>();

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
    // Username is required
    if (swopUserNameController.text.trim().isEmpty) {
      SnackbarUtil.showError('Please enter a username');
      return false;
    }

    // Name is required
    if (nameController.text.trim().isEmpty) {
      SnackbarUtil.showError('Please enter your name');
      return false;
    }

    // Email is required
    if (emailController.text.trim().isEmpty) {
      SnackbarUtil.showError('Please enter your email');
      return false;
    }

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      SnackbarUtil.showError('Please enter a valid email address');
      return false;
    }

    // Age validation (optional but if provided, should be valid)
    if (ageController.text.trim().isNotEmpty) {
      int? age = int.tryParse(ageController.text.trim());
      if (age == null || age < 1 || age > 99) {
        SnackbarUtil.showError('Please enter a valid age (1-99)');
        return false;
      }
    }

    // Phone validation (required)
    if (_phoneNumber.isEmpty) {
      SnackbarUtil.showError('Please enter your phone number');
      return false;
    }

    if (_phoneNumber.length < 7) {
      SnackbarUtil.showError('Please enter a valid phone number');
      return false;
    }

    // Bio is optional - no validation needed
    // Image is optional - no validation needed

    return true;
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name ?? "";
    emailController.text = widget.email ?? "";

    // Pre-fill username if available
    if (widget.name != null && widget.name.isNotEmpty) {
      String username =
          widget.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
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
                  const SizedBox(height: 35),

                  Image.asset(MyImages.nameLogo, height: 38),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.createProfile.tr,
                    style: AppTextStyles.large.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  ImagePickerExample(
                    key: _imagePickerKey,
                    profileImage: widget.userImage ?? "",
                  ),
                  const SizedBox(height: 24),
                  // Text(
                  //   AppStrings.createSwopHandle.tr,
                  //   style: AppTextStyles.large
                  //       .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  //   textAlign: TextAlign.center,
                  // ),
                  const SizedBox(height: 5),
                  myFieldAdvance(
                    focusNode: usernameFocus,
                    nextFocusNode: nameFocus,
                    onChanged: (username) {
                      controller.checkUsernameAvailability(username.trim());
                    },
                    context: context,
                    controller: swopUserNameController,
                    hintText: "Enter your Swop Handle",
                    inputType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    fillColor: MyColors.textWhite,
                    textBack: MyColors.textWhite,
                  ),

                  const SizedBox(height: 8),
                  Obx(() {
                    final username = controller.swopUsername.value.trim();
                    if (username.isEmpty)
                      return const SizedBox(); // Hide when empty

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
                          controller.isUsernameAvailable.value
                              ? controller.usernameMessage.value
                              : "Swop already taken",
                          style: AppTextStyles.small.copyWith(
                            color: controller.isUsernameAvailable.value
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  myFieldAdvance(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z ]")),
                      LengthLimitingTextInputFormatter(25),
                    ],
                    focusNode: nameFocus,
                    nextFocusNode: emailFocus,
                    context: context,
                    controller: nameController,
                    hintText: "Enter Full Name",
                    inputType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    fillColor: MyColors.textWhite,
                    textBack: MyColors.textWhite,
                  ),
                  const SizedBox(height: 15),
                  myFieldAdvance(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Z0-9@._-]"),
                      ),
                    ],
                    focusNode: emailFocus,
                    nextFocusNode: ageFocus,
                    context: context,
                    controller: emailController,
                    hintText: "Email Address",
                    inputType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    fillColor: MyColors.textWhite,
                    textBack: MyColors.textWhite,
                  ),
                  const SizedBox(height: 15),
                  myFieldAdvance(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2), // max 2 digits

                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    focusNode: ageFocus,
                    nextFocusNode: phoneFocus,
                    context: context,
                    controller: ageController,
                    hintText: "Age",
                    inputType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    fillColor: MyColors.textWhite,
                    textBack: MyColors.textWhite,
                  ),
                  const SizedBox(height: 15),
                  // Phone number field with separated country code and phone number
                  Row(
                    children: [
                      // Country code field with flag
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              onSelect: (Country country) {
                                setState(() {
                                  _selectedCountry = country;
                                });
                              },
                              showPhoneCode: true,
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: MyColors.textWhite,
                              border: Border.all(
                                color: Colors.black,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedCountry.flagEmoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '+${_selectedCountry.phoneCode}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Chromatica",
                                      color: MyColors.textBlack,
                                    ),
                                  ),
                                  const Icon(
                                    size: 20,
                                    Icons.arrow_drop_down,
                                    color: MyColors.textBlack,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      // Phone number field
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: phoneController,
                          focusNode: phoneFocus,
                          decoration: const InputDecoration(
                            hintText: "Phone Number",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Chromatica",
                              color: MyColors.textBlack,
                              decoration: TextDecoration.none,
                              wordSpacing: 1.2,
                            ),
                            filled: true,
                            fillColor: MyColors.textWhite,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.2,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(28)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: MyColors.textBlack,
                                width: 1.2,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(28)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(28)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length < 7) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _phoneNumber = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    focusNode: bioFocus,
                    maxLength: 100,
                    controller: bioController,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Chromatica",
                        color: MyColors.textBlack,
                        decoration: TextDecoration.none,
                        wordSpacing: 1.2,
                      ),
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

                      hintText: "Add your bio",
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
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.black))
                      : CustomButton(
                          text: AppStrings.connectSwopband.tr,
                          //onPressed:_startNfcSessionAndWrite// _connectAndWriteToNfc,
                          onPressed: () {
                            // Validate form before proceeding
                            if (!_validateForm()) {
                              return;
                            }

                            // Pass all create profile data to ConnectSwopbandScreen
                            Get.to(() => ConnectSwopbandScreen(
                                  username: swopUserNameController.text,
                                  name: nameController.text,
                                  email: emailController.text,
                                  bio: bioController.text,
                                  age: ageController.text.trim().isNotEmpty
                                      ? int.tryParse(ageController.text.trim())
                                      : null,
                                  phone: _phoneNumber.isNotEmpty
                                      ? _phoneNumber
                                      : null,
                                  countryCode:
                                      _selectedCountry.phoneCode.isNotEmpty
                                          ? '+${_selectedCountry.phoneCode}'
                                          : null,
                                  userImage: widget.userImage,
                                  imagePickerKey: _imagePickerKey,
                                ));
                          },
                        ),

                  const SizedBox(height: 10),
                  CustomButton(
                    border: Colors.black,
                    buttonColor: MyColors.textWhite,
                    textColor: MyColors.textBlack,
                    text: AppStrings.purchaseSwopband.tr,
                    onPressed: () async {
                      Get.to(() => const PurchaseScreen());
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

  ImagePickerExample({super.key, required this.profileImage});

  @override
  _ImagePickerExampleState createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  File? _selectedImageFile;
  String? _selectedImageUrl;
  bool _isLoadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with auth image if available
    if (widget.profileImage != null && widget.profileImage!.isNotEmpty) {
      _selectedImageUrl = widget.profileImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(context),
      child: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xffFFFAFA),
            radius: 60,
            backgroundImage: _isLoadingImage ? null : _getBackgroundImage(),
            onBackgroundImageError: _isLoadingImage
                ? null
                : (exception, stackTrace) {
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
                padding: const EdgeInsets.all(7),
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
      return const AssetImage(
        "assets/images/img.png",
      ) as ImageProvider;
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
            if (_selectedImageFile != null ||
                (_selectedImageUrl != null && _selectedImageUrl!.isNotEmpty))
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
          _showPermissionDialog(
              'Camera permission is required to take photos.');
          return;
        }
      } else {
        var storageStatus = await Permission.storage.request();
        if (storageStatus != PermissionStatus.granted) {
          _showPermissionDialog(
              'Storage permission is required to access photos.');
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 30, // Very low quality for minimal file size
        maxWidth: 200, // Very small max width
        maxHeight: 200, // Very small max height
      );

      if (pickedFile != null) {
        File file = File(pickedFile.path);

        // Validate file size (allow up to 5MB for multipart upload)
        int fileSize = await file.length();
        print(
            'Selected image size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)');
        if (fileSize > 5 * 1024 * 1024) {
          _showErrorSnackbar('Image too large. Maximum allowed size is 5MB.');
          return;
        }

        setState(() {
          _selectedImageFile = file;
          _selectedImageUrl = null; // Clear URL since we have a file
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
