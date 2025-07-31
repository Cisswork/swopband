import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swopband/controller/user_controller/UserController.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import '../utils/images/iamges.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_colors.dart';
import '../translations/app_strings.dart';
import 'bottom_nav/PurchaseScreen.dart';
import 'connect_swopband_screen.dart';
import 'package:swopband/view/widgets/custom_snackbar.dart';

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

  final TextEditingController bioController = TextEditingController();
  final controller = Get.put(UserController());

  File? _profileImage;
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = widget.name;
    emailController.text = widget.email;
  }


  @override
  Widget build(BuildContext context) {
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
                      ImagePickerExample(profileImage:widget.userImage,),
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
                        hintText: "janedoe",
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
                              decoration: BoxDecoration(
                                color: MyColors.textBlack,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              height: 30,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  "$username.swop",
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
                        hintText: "Name",
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
                          hintText: AppStrings.bioHint.tr,
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
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Obx(() => controller.isLoading.value?
                            Center(child: CircularProgressIndicator(color: Colors.black,)):
                            CustomButton(
                              text: AppStrings.connectSwopband.tr,
                              onPressed: ()async{
                                // final prefs = await SharedPreferences.getInstance();
                                //
                                //  final userId = prefs.getString("backend_user_id") ?? "";

                                if(controller.usernameMessage.value == "Username is available") {
                                  await controller.createUser(
                                    username: "${swopUserNameController.text}.swop",
                                    name: nameController.text,
                                    email: emailController.text,
                                    bio: bioController.text,
                                    profileUrl: widget.userImage,
                                    onSuccess: () {
                                      Get.to(() => ConnectSwopbandScreen());
                                    },
                                  );
                                }
                                },
                            ),)
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            flex: 1,
                            child: CustomButton(
                              buttonColor: MyColors.textWhite,
                              textColor: MyColors.textBlack,
                              text: AppStrings.purchaseSwopband.tr,
                              onPressed: ()async{
                                 Get.to(()=>PurchaseScreen());
                              },
                            ),
                          ),
                        ],
                      ),
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
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //onTap: () => _showImageSourceSheet(context),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: MyColors.primaryColor.withOpacity(0.1),
        backgroundImage: NetworkImage(widget.profileImage.toString())
        /*_profileImage != null
            ? FileImage(_profileImage!) as ImageProvider
            : AssetImage('assets/images/profile_placeholder.png'),
        child: Stack(
          children: [
            if (_profileImage == null)
              Center(
                child: Icon(
                  Icons.camera_alt,
                  color: MyColors.primaryColor,
                  size: 32,
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MyColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),*/
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
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
              onTap: () => _checkPermissionAndPickImage(ImageSource.camera),
            ),
            Divider(height: 1, indent: 20, endIndent: 20),
            _buildOptionButton(
              context,
              icon: Icons.photo_library,
              text: 'Choose from Gallery',
              onTap: () => _checkPermissionAndPickImage(ImageSource.gallery),
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

  Future<void> _checkPermissionAndPickImage(ImageSource source) async {
    Navigator.pop(context); // Close the bottom sheet

    try {
      if (source == ImageSource.camera) {
        // Handle camera permission
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          _showPermissionDeniedDialog('Camera');
          return;
        }
      } else {
        // Handle gallery permission (photos on iOS, storage on Android)
        PermissionStatus status;
        if (Platform.isAndroid) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            status = await Permission.photos.request();
          }
        } else {
          status = await Permission.photos.request();
        }

        if (!status.isGranted) {
          _showPermissionDeniedDialog('Gallery');
          return;
        }
      }

      // Now pick the image
      await _pickImage(source);
    } catch (e) {
      _showErrorSnackbar('Failed to access image: ${e.toString()}');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          //profileImage = File(pickedFile.path);
        });
        // Here you can upload the image to your server if needed
        _showSuccessSnackbar('Image selected successfully');
      }
    } catch (e) {
      _showErrorSnackbar('Error selecting image: ${e.toString()}');
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(
            'Please grant $permissionType permission in settings to continue'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings'),
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