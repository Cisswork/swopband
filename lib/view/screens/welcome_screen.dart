import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:swopband/view/screens/bottom_nav/BottomNavScreen.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import '../../controller/user_controller/UserController.dart';
import '../utils/app_colors.dart';
import '../utils/images/iamges.dart';
import '../utils/shared_pref/SharedPrefHelper.dart';
import 'create_profile_screen.dart';

class WelcomeScreen extends StatefulWidget {

  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final String _error = '';
  bool _loading = false;
  bool _loadingApple = false;
  User? _user;



  Future<void> signInWithGoogle() async {
    setState(() {
      _loading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print("❌ Google sign-in canceled.");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("googleAuth.idToken--------->${googleAuth.idToken}");
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user;

      if (user != null) {

        await SharedPrefService.saveString("firebase_id", user.uid);
        print("✅ Firebase sign-in successful");
        print("👤 UID: ${user.uid}");  
         
        print("📧 Email: ${user.email}");
        print("🧑‍💼 Display Name: ${user.displayName}");
        print("📷 Photo URL: ${user.photoURL}");
        print("📞 Phone Number: ${user.phoneNumber}");
        print("🕒 Creation Time: ${user.metadata.creationTime}");
        print("⏱️ Last Sign-In Time: ${user.metadata.lastSignInTime}");
        print("🔐 Provider ID: ${user.providerData.map((e) => e.providerId).join(', ')}");
      } //ce

      final userController = Get.put(UserController());
      final firebaseId = user?.uid; // from FirebaseAuth

      final userData = await userController.fetchUserByFirebaseId(firebaseId!);

      if (userData != null) {
        await SharedPrefService.saveString('backend_user_id', userData['id']);
        Get.off(() => BottomNavScreen());
      } else {
        Get.to(() => CreateProfileScreen(
          email: user?.email.toString(),
          name: user?.displayName,
          userImage: user?.photoURL,
        ));
      }
    } catch (e) {
      print("❌ Error signing in with Google: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Dummy background color
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MyImages.background6,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 50,),

                      Image.asset(
                        height: 40,
                        MyImages.nameLogo,
                      ),
                      SizedBox(height: 90,),
                      Image.asset(
                        MyImages.welcomeLogo,
                        height: 220,
                        width: double.infinity,
                      ),
                      SizedBox(height: 33,),

                      _loadingApple
                          ?  CupertinoActivityIndicator(color: Colors.black,)
                          : CustomButton(
                        border: Colors.black,
                        widget: Icon(Icons.apple,color: Colors.white,size: 28,),
                        text: 'Sign up with Apple',
                        onPressed: () {
                          signInWithApple();
                        },
                      ),
                      SizedBox(height: 16),
                      _loading
                          ? const CircularProgressIndicator(color: Colors.black,)
                          : CustomButton(
                        buttonColor: Colors.white,
                        textColor: Colors.black,
                        border: MyColors.primaryColor,
                        widget: Image.asset("assets/images/google.png"),
                        text: 'Sign up with Google',
                        onPressed: ()async{
                          await signInWithGoogle();
                        },
                      ),
                      SizedBox(height: 120,),

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

  Future<void> signInWithApple() async {
    print("🚀 Starting Apple sign-in...");
    setState(() {
      _loadingApple = true;
    });

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Save email and name locally if returned (only available on first login)
      if (appleCredential.email != null) {
        await SharedPrefService.saveString("apple_email", appleCredential.email!);
      }

      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final fullName = "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}".trim();
        await SharedPrefService.saveString("apple_name", fullName);
      }

      // Create Firebase credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCred = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final user = userCred.user;

      if (user != null) {
        print("✅ Firebase sign-in successful");
        print("👤 UID: ${user.uid}");
        print("📧 Email: ${user.email}");
        print("🧑‍💼 Display Name: ${user.displayName}");

        await SharedPrefService.saveString("firebase_id", user.uid);

        final userController = Get.put(UserController());
        final userData = await userController.fetchUserByFirebaseId(user.uid);

        if (userData != null) {
          print("userData['id']${userData['id']}");
          await SharedPrefService.saveString('backend_user_id', userData['id']);
          Get.off(() => BottomNavScreen());
        } else {

          final savedEmail = await SharedPrefService.getString("apple_email");
          final savedName = await SharedPrefService.getString("apple_name");

          Get.to(() => CreateProfileScreen(
            email: user.email ?? savedEmail ?? "",
            name: user.displayName ?? savedName ?? "",
            userImage: user.photoURL??"",
          ));
        }
      }
    } catch (e) {
      print("❌ Apple Sign-In failed: $e");
    } finally {
      setState(() {
        _loadingApple = false;
      });
    }
  }
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    await SharedPrefService.clear(); // ya at least remove 'firebase_id'
  }

  @override
  void initState() {
    super.initState();
    //_checkLogin();
  }

  void _checkLogin() async {
    final firebaseId = await SharedPrefService.getString('firebase_id');
    final user = FirebaseAuth.instance.currentUser;
    if (firebaseId != null && user != null) {
      // User is logged in, go to home/profile
      Get.offAll(() => BottomNavScreen());
    } else {
      // User not logged in, stay on welcome/login
    }
  }

}
