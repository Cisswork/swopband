import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import '../utils/images/iamges.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_colors.dart';
import '../translations/app_strings.dart';
import 'AddLinkScreen.dart';

class IntroducingBubbleScreen extends StatefulWidget {
  const IntroducingBubbleScreen({super.key});

  @override
  State<IntroducingBubbleScreen> createState() => _IntroducingBubbleScreenState();
}

class _IntroducingBubbleScreenState extends State<IntroducingBubbleScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(MyImages.background4, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30,),
                      const SizedBox(height: 20),
                      Text(
                        "Introducing SocialBubble",
                        style: AppTextStyles.extraLarge.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Your SocialBubble combines all of your social links into one, sharable combination of bubbles",
                        style: AppTextStyles.extraLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonColor: MyColors.textBlack,
                          textColor: MyColors.textWhite,
                          text: "Add your Links",
                          onPressed: () {
                            Get.to(()=>AddLinkScreen());
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
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
  void showNfcScanDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Ready to Scan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              Icon(
                Icons.nfc,
                size: 48,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Hold your device near the NFC tag.',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Widget _buildInstructionItem(String text,String image) {
    return ListTile(
      visualDensity: VisualDensity.comfortable,
      contentPadding: EdgeInsets.all(0),
      leading:   Image(image: AssetImage(image),height: 55,alignment: Alignment.center,),
      title: Text(
        text,
        style: AppTextStyles.medium.copyWith(
          fontSize: 14,
        ),
        textAlign: TextAlign.left,
      ),
    );

  }

}