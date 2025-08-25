import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swopband/controller/user_controller/UserController.dart';
import 'package:swopband/view/utils/shared_pref/SharedPrefHelper.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import '../utils/app_constants.dart';
import '../utils/images/iamges.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_colors.dart';
import '../translations/app_strings.dart';
import 'package:swopband/view/widgets/custom_snackbar.dart';
import 'profile_image_upload_webview_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
   const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController swopUserNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController bioController = TextEditingController();
  final controller = Get.put(UserController());
  String imageUrl = "";

  // Global key to access ImagePickerExample methods
  final GlobalKey<_ImagePickerExampleState> _imagePickerKey = GlobalKey<_ImagePickerExampleState>();

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
    return true;
  }


  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth()async {
    final firebaseId = await SharedPrefService.getString('firebase_id');

    log("firebaseId  : $firebaseId");

    if (firebaseId != null && firebaseId.isNotEmpty) {
      await controller.fetchUserByFirebaseId(firebaseId);
        imageUrl =  sanitizeProfileUrl(AppConst.USER_PROFILE as String?);
        nameController.text = AppConst.fullName;
        bioController.text = AppConst.BIO;
        swopUserNameController.text = AppConst.USER_NAME;
        emailController.text = AppConst.EMAIL;

    }
  }

  Future<void> _updateProfile() async {
    if (!_validateForm()) {
      return;
    }

    // Get current profile image (selected file or existing URL)
    File? selectedFile = _imagePickerKey.currentState?.getSelectedImageFile();
    String? currentProfileUrl = _imagePickerKey.currentState?.getCurrentImageUrl();
    
    // If no new file is selected, use the existing profile URL
    String? profileUrl = selectedFile == null ? currentProfileUrl : null;

    await controller.updateUser(
      username: swopUserNameController.text,
      name: nameController.text,
      email: "abc@gmail.com",
      bio: bioController.text,
      profileFile: selectedFile,
      profileUrl: profileUrl,
      onSuccess: () {
        SnackbarUtil.showSuccess("Profile updated successfully!");
        Get.back(); // Go back to previous screen
      },
    );
  }

  // Method to get current profile image (selected file or existing image)
  Future<String> _getCurrentProfileImage() async {
    print("=== _getCurrentProfileImage called ===");
    
    if (_imagePickerKey.currentState != null) {
      String? selectedUrl = _imagePickerKey.currentState!.getCurrentImageUrl();
      
      // Use selected URL if available
      if (selectedUrl != null && selectedUrl.isNotEmpty) {
        print("✅ Using selected URL: $selectedUrl");
        return selectedUrl;
      }
    }
    
    // Final fallback to existing profile
    print("⚠️ No suitable image available, sending empty string");
    return "";
  }

  String sanitizeProfileUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (kIsWeb && url.startsWith('http://srirangasai.dev')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Update Profile"),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MyImages.background1,
              fit: BoxFit.cover,
            ),
          ),
          Obx((){
            if(controller.fetchUserProfile.value){
              return Center(child: CircularProgressIndicator(color: Colors.black,));
            }
            return SafeArea(
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
                          "Update your profile",
                          style: AppTextStyles.large.copyWith(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),

                        ImagePickerExample(
                          key: _imagePickerKey,
                          profileImage: AppConst.USER_PROFILE ?? "",
                        ),
                        SizedBox(height: 24),
                        /*      Text(
                        AppStrings.createSwopHandle.tr,
                        style: AppTextStyles.large.copyWith(fontSize: 13,fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),*/
                        SizedBox(height: 5),
                        myFieldAdvance(
                          readOnly: true,
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

                        /*SizedBox(height: 8),
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
                      }),*/


                        SizedBox(height: 15),
                        myFieldAdvance(
                          context: context,
                          controller: nameController,
                          hintText: "Enter Full Name",
                          inputType: TextInputType.text,
                          textInputAction: TextInputAction.done, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                        ),
                        SizedBox(height: 20),
                        myFieldAdvance(
                          readOnly: true,
                          context: context,
                          controller: emailController,
                          hintText: "Email",
                          inputType: TextInputType.text,
                          textInputAction: TextInputAction.next, fillColor: MyColors.textWhite, textBack: MyColors.textWhite,
                        ),
                        SizedBox(height: 8),
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
                          onTap: () async{
                            // await signOut();
                          },
                          maxLines: 4,
                          controller: bioController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
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

                        CustomButton(
                          text: "Update Profile",
                          onPressed:() {
                            _updateProfile();
                          },
                        ),

                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          })
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
      onTap: () => _openWebView(context),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: MyColors.primaryColor.withOpacity(0.1),
            backgroundImage: _isLoadingImage ? null : _getBackgroundImage(),
            onBackgroundImageError: (exception, stackTrace) {
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

  // Open webview for image upload
  void _openWebView(BuildContext context) {
    Get.to(() => ProfileImageUploadWebViewScreen());
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

  void _showErrorSnackbar(String message) {
    SnackbarUtil.showError(message);
  }

  void _showSuccessSnackbar(String message) {
    SnackbarUtil.showSuccess(message);
  }
}

