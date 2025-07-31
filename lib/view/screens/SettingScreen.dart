import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/network/ApiService.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'ChangeEmailAddressScreen.dart';
import 'FaqScreen.dart';
import 'UpdatePasswordScreen.dart';
import 'UpdatePhoneNumberScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/shared_pref/SharedPrefHelper.dart';
import 'package:swopband/view/screens/welcome_screen.dart';
import 'package:swopband/view/widgets/custom_snackbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Settings",
                style: AppTextStyles.large.copyWith(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textBlack,
                ),
              ),

              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  buttonColor: MyColors.textBlack,
                  textColor: MyColors.textWhite,
                  text: "FAQ and Troubleshooting",
                  onPressed: () {
                    Get.to(()=>FAQScreen());

                  },
                ),
              ),
             /* const SizedBox(height: 15),
              Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Notifications'),
                      _buildNotificationOption('New connections'),
                      _buildNotificationOption('Updates'),
                      _buildNotificationOption('News'),
                    ],
                  )),*/

              const SizedBox(height: 24),

              // Account Information section
              Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Account Information'),
                      //_buildAccountOption('Update SWOPHANDLE'),
                      SizedBox(height: 5,),
                      /*GestureDetector(
                          onTap: () {
                            Get.to(()=>UpdateEmailScreen());
                          },
                          child: _buildAccountOption('Update Email')),
                      SizedBox(height: 5,),
                      GestureDetector(
                          onTap: () {
                            Get.to(()=>UpdatePhoneNumberScreen());

                          },
                          child: _buildAccountOption('Update Phone Number')),
                      SizedBox(height: 5,),
                      GestureDetector(
                          onTap: () {
                            Get.to(()=>UpdatePasswordScreen());

                          },
                          child: _buildAccountOption('Update Password')),*/
                      SizedBox(height: 5,),
                      GestureDetector(
                          onTap: () {
                            Get.to(()=>FAQScreen());
                          },
                          child: _buildAccountOption('FAQ')),
                      SizedBox(height: 20),
                      // Sign Out Option
                      GestureDetector(
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Sign Out'),
                                content: Text('Are you sure you want to sign out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Sign Out'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await _signOutUser();
                            }
                          },
                      child: _buildAccountOption('Sign Out')),
                      SizedBox(height: 5),
                      // Delete Account Option
                      GestureDetector(
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Account'),
                                content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                             await reauthenticateAndDeleteUser();
                             await deleteAndSignOutUser();
                              // await _deleteAndSignOutUser();
                              // await _deleteAndSignOutUser1();
                            }
                          },
                          child: _buildAccountOption('Delete Account')),
                    ],
                  )),
              /*const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  buttonColor: MyColors.textDisabledColor,
                  textColor: MyColors.textBlack,
                  text: "Contact SWOPBAND",
                  onPressed: () {},
                ),
              ),*/
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppTextStyles.medium.copyWith(
          color: MyColors.textWhite,
          fontWeight: FontWeight.w500,
          fontSize: 24
        ),
      ),
    );
  }

  Widget _buildNotificationOption(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            option,
            style: AppTextStyles.medium.copyWith(
              color: MyColors.textWhite, // Dummy secondary color
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Switch(
              activeTrackColor: Colors.white,
              inactiveThumbColor: MyColors.textDisabledColor,
              activeColor: Colors.black,
              value: true, onChanged: (bool value) {}),
        ],
      ),
    );
  }

  Future<void> _deleteAndSignOutUser1() async {
    try {
      final backendUserId = await SharedPrefService.getString('backend_user_id');
      if (backendUserId != null && backendUserId.isNotEmpty) {
        // Call backend delete API
        final response = await ApiService.delete(
          'https://srirangasai.dev/users/$backendUserId',
        );
        if (response == null || (response.statusCode != 200 && response.statusCode != 204)) {
          SnackbarUtil.showError('Failed to delete account on server.');
          return;
        }
      } else {
        print('No backend_user_id found, skipping backend delete.');
      }
      // Delete Firebase user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.delete();
        } catch (e) {
          // Re-authenticate if needed
          final googleUser = await GoogleSignIn().signIn();
          if (googleUser == null) {
            SnackbarUtil.showError('Google sign-in canceled.');
            return;
          }
          final googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
          await user.delete();
        }
      }
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await SharedPrefService.clear();
      Get.offAll(() => WelcomeScreen());
      SnackbarUtil.showSuccess('Account Deleted: Your account has been deleted.');
    } catch (e) {
      print('❌ Error deleting/signing out: $e');
      SnackbarUtil.showError('Failed to delete account.');
    }
  }

  Widget _buildAccountOption(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            option,
            style: AppTextStyles.medium.copyWith(
              color: MyColors.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward,color: Colors.white,)
        ],
      ),
    );
  }

  Future<void> _signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await SharedPrefService.clear();
      Get.offAll(() => WelcomeScreen());
    } catch (e) {
      print('❌ Error signing out: $e');
      SnackbarUtil.showError('Failed to sign out.');
    }
  }

  Future<void> _deleteAndSignOutUser() async {
    try {
      final backendUserId = await SharedPrefService.getString('backend_user_id');
      if (backendUserId == null || backendUserId.isEmpty) {
        SnackbarUtil.showError('No backend user ID found.');
        return;
      }
      // Call backend delete API
      final response = await ApiService.delete(
        'https://srirangasai.dev/users/$backendUserId',
      );
      if (response == null || (response.statusCode != 200 && response.statusCode != 204)) {
        SnackbarUtil.showError('Failed to delete account on server.');
        return;
      }
      // Delete Firebase user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.delete();
        } catch (e) {
          // If requires recent login, reauthenticate with Google
          final googleUser = await GoogleSignIn().signIn();
          if (googleUser == null) {
            SnackbarUtil.showError('Google sign-in canceled.');
            return;
          }
          final googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
          await user.delete();
        }
      }
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await SharedPrefService.clear();
      Get.offAll(() => WelcomeScreen());
      SnackbarUtil.showSuccess('Account Deleted: Your account has been deleted.');
    } catch (e) {
      print('❌ Error deleting/signing out: $e');
      SnackbarUtil.showError('Failed to delete account.');
    }
  }

  Future<void> reauthenticateAndDeleteUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print("❌ Google sign-in canceled");
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 🔐 Re-authenticate
      await user?.reauthenticateWithCredential(credential);
      print("🔄 Re-authenticated successfully");

      // 🔥 Delete the account
      await user?.delete();
      print("✅ Account deleted");

      // 🔌 Sign out from Firebase and Google
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      print("✅ Signed out");

    } catch (e) {
      print("❌ Error: $e");
    }
  }

  Future<void> deleteAndSignOutUser() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user != null) {
        // 🔥 Delete Firebase account
        await user.delete();
        print("✅ Firebase user account deleted.");
      }

      // 🔌 Sign out from Firebase and Google
      await auth.signOut();
      await GoogleSignIn().signOut();

      print("✅ Signed out successfully.");

      // 🧼 Clear SharedPrefs if needed
      // await SharedPrefService.clearAll();  // Optional if using shared prefs
    } catch (e) {
      print("❌ Error deleting/signing out: $e");
    }
  }

}