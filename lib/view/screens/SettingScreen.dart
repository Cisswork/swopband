import 'dart:developer';
import 'dart:io' show Platform;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/network/ApiService.dart';
import 'package:swopband/view/screens/PrivacyPolicyScreen.dart';
import 'package:swopband/view/screens/UpdateProfileScreen.dart';
import 'package:swopband/view/screens/nfc_test_screen.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import 'package:swopband/view/widgets/feedback_modal.dart';

import '../translations/app_strings.dart';
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

import 'bottom_nav/PurchaseScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                "Settings",
                style: AppTextStyles.large.copyWith(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textBlack,
                ),
              ),
              const SizedBox(height: 15),

              CustomButton(
                border: Colors.black,
                buttonColor: MyColors.textWhite,
                textColor: MyColors.textBlack,
                text: "Enter the SWOPSTORE",
                onPressed: ()async{
                  Get.to(()=>const PurchaseScreen());
                },
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  buttonColor: MyColors.textBlack,
                  textColor: MyColors.textWhite,
                  text: "FAQ and Troubleshooting",
                  onPressed: () {
                    Get.to(()=>const FAQScreen());
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Account Information section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.black,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Account Information'),

                    _buildTappableAccountOption(
                      title: 'Edit Profile',
                      icon: Icons.person,
                      onTap: () => Get.to(()=>const UpdateProfileScreen()),
                    ),

                    _buildTappableAccountOption(
                      title: 'FAQ',
                      icon: Icons.help_outline,
                      onTap: () => Get.to(()=>const FAQScreen()),
                    ),

                    // Feedback option
                    _buildTappableAccountOption(
                      title: 'Send Feedback',
                      icon: Icons.feedback,
                      onTap: () => FeedbackModalHelper.showFeedbackModal(context),
                    ),

                   /* // NFC Test option (for development/testing)
                    _buildTappableAccountOption(
                      title: 'NFC Test',
                      icon: Icons.nfc,
                      iconColor: Colors.blue,
                      onTap: () => Get.to(()=>NfcTestScreen()),
                    ),*/

                    // Privacy Policy option
                    _buildTappableAccountOption(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => Get.to(()=>PrivacyPolicyScreen(url: "https://profile.swopband.com/privacy_policy.html",
                        type: 'Privacy Policy',)),
                    ),

                    // Terms & Conditions option
                    _buildTappableAccountOption(
                      title: 'Term & Condition',
                      icon: Icons.description_outlined,
                      onTap: () => Get.to(()=>PrivacyPolicyScreen(url: "https://profile.swopband.com/terms_and_conditions.html",
                        type: 'Term & Condition',)),
                    ),



                  ],
                ),
              ),
              const SizedBox(height: 20),

              CustomButton(
                buttonColor: MyColors.textBlack,
                textColor: MyColors.textWhite,
                text: "Sign Out of your Account",
                onPressed: (){
                  _showSignOutDialog();
                },
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.black,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    _buildSectionTitle('Reset SWOPBAND'),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        "Resetting SWOPBAND will disconnect \nthe band and your account will be\ndeleted.",
                        style: AppTextStyles.medium.copyWith(
                            color: MyColors.textWhite,
                            fontWeight: FontWeight.w500,
                            fontSize: 15
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomButton(
                        buttonColor: MyColors.textWhite,
                        textColor: MyColors.textBlack,
                        text: "Reset SWOPBAND",
                        onPressed: () {
                          _showDeleteAccountDialog();
                        },
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0,left: 5),
        child: Text(
          title,
          style: AppTextStyles.medium.copyWith(
              color: MyColors.textWhite,
              fontWeight: FontWeight.w600,
              fontSize: 20
          ),
        ),
      ),
    );
  }

  Widget _buildTappableAccountOption({required String title, required IconData icon, required VoidCallback onTap, Color iconColor = Colors.white,}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyles.medium.copyWith(
                color: MyColors.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showSignOutDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              _signOutUser();
            },
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will permanently:'),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Delete all your data'),
                  Text('• Remove your profile'),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('This action cannot be undone.'),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAndSignOutUser1();
            },
            child: const Text('DELETE ACCOUNT'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAndSignOutUser() async {
    try {
      // Step 0: Get backend user ID
      final backendUserId = await SharedPrefService.getString('backend_user_id');

      // Step 1: Delete account from backend
      if (backendUserId != null && backendUserId.isNotEmpty) {
        final response = await ApiService.delete(
          'https://profile.swopband.com/users/$backendUserId',
        );

        if (response == null || (response.statusCode != 200 && response.statusCode != 204)) {
          SnackbarUtil.showError('Failed to delete account on server.');
          return;
        }
      }

      // Step 2: Delete Firebase user
      final user = FirebaseAuth.instance.currentUser;
      bool deleted = false;

      if (user != null) {
        try {
          // Try direct deletion first
          await user.delete();
          deleted = true;
        } catch (e) {
          log("⚠️ Direct deletion failed: $e");

          // Re-auth required
          try {
            if (Platform.isIOS) {
              // Fresh Apple sign-in
              final appleCredential = await SignInWithApple.getAppleIDCredential(
                scopes: [
                  AppleIDAuthorizationScopes.email,
                  AppleIDAuthorizationScopes.fullName
                ],
              );

              final oauthCredential = OAuthProvider("apple.com").credential(
                idToken: appleCredential.identityToken,
              );

              await user.reauthenticateWithCredential(oauthCredential);
              await user.delete();
              deleted = true;
            } else if (Platform.isAndroid) {
              // Google re-auth
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
              deleted = true;
              await GoogleSignIn().disconnect();
            }
          } catch (reauthError) {
            log("❌ Re-auth or deletion failed: $reauthError");

            // Reload user and check if already deleted
            await user.reload();
            if (FirebaseAuth.instance.currentUser == null) {
              deleted = true;
            } else {
              SnackbarUtil.showError("Account deletion failed after re-authentication.");
              return;
            }
          }
        }
      }

      if (!deleted) {
        SnackbarUtil.showError("Account deletion failed.");
        return;
      }

      // Step 3: Sign out & clear local storage
      await FirebaseAuth.instance.signOut();
      if (Platform.isAndroid) await GoogleSignIn().signOut();
      await SharedPrefService.clear();

      // Navigate to WelcomeScreen
      Get.offAll(() => const WelcomeScreen());
      SnackbarUtil.showSuccess('Account Deleted: Your account has been deleted.');
    } catch (e) {
      log('❌ Error deleting/signing out: $e');
      SnackbarUtil.showError('Failed to delete account.');
    }
  }

  Future<void> _signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (Platform.isAndroid) await GoogleSignIn().signOut();
      await SharedPrefService.clear();
      Get.offAll(() => const WelcomeScreen());
    } catch (e) {
      print('❌ Error signing out: $e');
      SnackbarUtil.showError('Failed to sign out.');
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


  Future<void> _deleteAndSignOutUser1() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Step 1: Delete account from backend
      final backendUserId = await SharedPrefService.getString('backend_user_id');
      if (backendUserId != null && backendUserId.isNotEmpty) {
        final response = await ApiService.delete(
          'https://profile.swopband.com/users/$backendUserId',
        );

        if (response == null || (response.statusCode != 200 && response.statusCode != 204)) {
          Get.back(); // Close loading dialog
          SnackbarUtil.showError('Failed to delete account on server.');
          return;
        }
      }

      // Step 2: Attempt direct Firebase user deletion
      await _attemptFirebaseAccountDeletion();

      // Step 3: Force sign out and clear data
      await _forceSignOutAndClearData();

      // Navigate to WelcomeScreen
      Get.offAll(() => const WelcomeScreen());
      SnackbarUtil.showSuccess('Account deleted successfully');
    } catch (e) {
      log('❌ Error during account deletion: $e');
      SnackbarUtil.showError('An error occurred during account deletion');
    } finally {
      if (Get.isDialogOpen!) Get.back(); // Close loading dialog
    }
  }

  Future<void> _attemptFirebaseAccountDeletion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.delete();
      log('✅ Firebase account deleted successfully');
    } catch (e) {
      log('⚠️ Firebase account deletion failed: $e');
      // Even if deletion fails, we'll proceed with sign out
      // You might want to add analytics here to track failure rates
    }
  }

  Future<void> _forceSignOutAndClearData() async {
    try {
      // Common sign out for all platforms
      await FirebaseAuth.instance.signOut();

      // Platform-specific sign out
      if (Platform.isAndroid) {
        await GoogleSignIn().signOut();
        await GoogleSignIn().disconnect();
      }

      // Clear all local data
      await SharedPrefService.clear();
      log('✅ All sessions and data cleared');
    } catch (e) {
      log('❌ Error during signout: $e');
    }
  }}