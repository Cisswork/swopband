import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/screens/welcome_screen.dart';
import 'package:swopband/view/screens/bottom_nav/BottomNavScreen.dart';
import '../../utils/images/iamges.dart';
import '../../utils/shared_pref/SharedPrefHelper.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(Duration(seconds: 2)); // Optional splash delay
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final firebaseId = await SharedPrefService.getString('firebase_id');
    final backendUserId = await SharedPrefService.getString('backend_user_id');

    print(firebaseUser);
    print(firebaseId);
    print(backendUserId);

    if (firebaseUser != null && backendUserId != null && backendUserId.isNotEmpty) {//&& backendUserId != null && backendUserId.isNotEmpty
      Get.off(() => BottomNavScreen());
    } else {
      Get.off(() => WelcomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Dummy background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    MyImages.welcomeLogo,
                    height: 350,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
