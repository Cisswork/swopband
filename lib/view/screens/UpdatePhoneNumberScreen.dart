import 'dart:io';
import 'package:flutter/material.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import '../utils/app_text_styles.dart';
import '../utils/images/iamges.dart';
import '../utils/app_colors.dart';

class UpdatePhoneNumberScreen extends StatefulWidget {

  const UpdatePhoneNumberScreen({super.key});

  @override
  State<UpdatePhoneNumberScreen> createState() => _UpdatePhoneNumberScreenState();
}

class _UpdatePhoneNumberScreenState extends State<UpdatePhoneNumberScreen> {
  final TextEditingController swopHandleController = TextEditingController();

  final TextEditingController bioController = TextEditingController();
  File? _profileImage;

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
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Update Phone Number",
                            style: AppTextStyles.large.copyWith(
                              color: MyColors.textWhite, // Dummy secondary color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 20,),
                          customPhoneField(
                            controller: TextEditingController(),
                            hintText: 'Phone Number',
                            initialCountryCode: 'IN',
                            // Optional - defaults to 'US'
                            textInputAction: TextInputAction.next,
                            onChanged: (phone) {
                              print(phone
                                  .completeNumber); // Get complete number with country code
                            },
                            onCountryChanged: (country) {
                              print('Country changed to: ${country.code}');
                            },
                          ),
                          SizedBox(height: 8,),
                          customPhoneField(
                            controller: TextEditingController(),
                            hintText: 'New Phone Number',
                            initialCountryCode: 'IN',
                            // Optional - defaults to 'US'
                            textInputAction: TextInputAction.next,
                            onChanged: (phone) {
                              print(phone
                                  .completeNumber); // Get complete number with country code
                            },
                            onCountryChanged: (country) {
                              print('Country changed to: ${country.code}');
                            },
                          ),
                          SizedBox(height: 8,),
                          customPhoneField(
                            controller: TextEditingController(),
                            hintText: 'Confirm Phone Number',
                            initialCountryCode: 'IN',
                            // Optional - defaults to 'US'
                            textInputAction: TextInputAction.next,
                            onChanged: (phone) {
                              print(phone
                                  .completeNumber); // Get complete number with country code
                            },
                            onCountryChanged: (country) {
                              print('Country changed to: ${country.code}');
                            },
                          ),
                          SizedBox(height: 15,),

                          CustomButton(
                            buttonColor: Colors.white,
                            textColor: Colors.black,
                            text: "Change Phone Number",
                            onPressed: () {

                            },
                          ),
                        ],
                      ),
                    )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}