import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';

import '../utils/app_colors.dart';
import 'FaqScreen.dart';
import 'IntroducingBubbleScreen.dart';

class RingNotConnectedScreen extends StatelessWidget {
  const RingNotConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ring Image (replace with your actual asset)
              Image.asset(
                'assets/images/ringNotConnectImg.png', // Your ring image asset
                width: 200,
                height: 150,
              ),
              SizedBox(height: 32),
              // Error Message
              Text(
                'SWOPBAND could not connect.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: "Outfit",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 70),
              // Retry Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  buttonColor: MyColors.textBlack,
                  textColor: MyColors.textWhite,
                  text: "Retry",
                  onPressed: () {
                    Get.to(() => IntroducingBubbleScreen());
                  },
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  buttonColor: MyColors.textDisabledColor,
                  textColor: MyColors.textBlack,
                  text: "FAQ and Troubleshooting",
                  onPressed: () {
                    Get.to(() => FAQScreen());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
