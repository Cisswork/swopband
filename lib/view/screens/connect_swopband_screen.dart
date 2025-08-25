import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_snackbar.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import '../utils/images/iamges.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_colors.dart';
import '../translations/app_strings.dart';
import 'FaqScreen.dart';
import 'AddLinkScreen.dart';

class ConnectSwopbandScreen extends StatefulWidget {
  const ConnectSwopbandScreen({Key? key}) : super(key: key);

  @override
  State<ConnectSwopbandScreen> createState() => _ConnectSwopbandScreenState();
}

class _ConnectSwopbandScreenState extends State<ConnectSwopbandScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(MyImages.background2, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30,),
                      Image.asset(
                        MyImages.nameLogo,
                        height: 40,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.connectYourSwopband.tr,
                        style: AppTextStyles.extraLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              border: Border.all(
                                color: MyColors.textBlack,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 23),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 30),
                                  Text(
                                    AppStrings.connectingYourBand.tr,
                                    style: AppTextStyles.extraLarge.copyWith(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 20),
                                  _buildInstructionItem(
                                    AppStrings.tapConnectInstruction.tr,
                                    MyImages.tr1mg,
                                  ),
                                  _buildInstructionItem(
                                    AppStrings.keepPositionInstruction.tr,
                                    MyImages.tr2mg,
                                  ),
                                  _buildInstructionItem(
                                    AppStrings.readyToScanInstruction.tr,
                                    MyImages.tr3mg,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: CustomButton(
                                      text: AppStrings.connectYourSwopbandButton.tr,
                                      onPressed: () {
                                        Get.to(() => AddLinkScreen());
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: -60,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Image.asset(
                                MyImages.ringImage,
                                height: 130,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonColor: MyColors.textWhite,
                          textColor: MyColors.textBlack,
                          text: AppStrings.faqTroubleshooting.tr,
                          onPressed: () {
                            Get.to(()=>FAQScreen());
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