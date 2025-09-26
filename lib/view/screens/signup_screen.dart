import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import '../translations/app_strings.dart';
import '../utils/images/iamges.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_colors.dart';
import 'create_profile_screen.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController sureNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();
  final phoneController = TextEditingController();

  // Country variables
  Country _selectedCountry = Country.parse('GB');
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(MyImages.nameLogo, height: 40),
                  SizedBox(height: 24),
                  Text(
                    AppStrings.personalDetails.tr,
                    style: AppTextStyles.large,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: myFieldAdvance(
                            autofillHints: [
                              AutofillHints.namePrefix,
                            ],
                            context: context,
                            controller: nameController,
                            hintText: AppStrings.firstName.tr,
                            inputType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            fillColor: MyColors.textWhite,
                            textBack: MyColors.textWhite),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: myFieldAdvance(
                            autofillHints: [
                              AutofillHints.familyName,
                            ],
                            context: context,
                            controller: nameController,
                            hintText: AppStrings.lastName.tr,
                            inputType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            fillColor: MyColors.textWhite,
                            textBack: MyColors.textWhite),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ageGenderField(),
                  SizedBox(height: 16),
                  // Phone number field with separated country code and phone number
                  Row(
                    children: [
                      // Country code field with flag
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              onSelect: (Country country) {
                                setState(() {
                                  _selectedCountry = country;
                                });
                              },
                              showPhoneCode: true,
                            );
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: MyColors.textWhite,
                              border: Border.all(
                                color: Colors.black,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedCountry.flagEmoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+${_selectedCountry.phoneCode}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Chromatica",
                                      color: MyColors.textBlack,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: MyColors.textBlack,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // Space between fields
                      // Phone number field
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            hintText: "Mobile Number",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Chromatica",
                              color: MyColors.textBlack,
                              decoration: TextDecoration.none,
                              wordSpacing: 1.2,
                            ),
                            filled: true,
                            fillColor: MyColors.textWhite,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.2,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(28)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: MyColors.textBlack,
                                width: 1.2,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(28)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(28)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            _phoneNumber = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  myFieldAdvance(
                      autofillHints: [
                        AutofillHints.email,
                      ],
                      context: context,
                      controller: emailController,
                      hintText: 'email'.tr,
                      inputType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      fillColor: MyColors.textWhite,
                      textBack: MyColors.textWhite),
                  SizedBox(height: 16),
                  myFieldAdvance(
                      context: context,
                      controller: passwordController,
                      hintText: 'password'.tr,
                      inputType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      showPasswordToggle: true,
                      autofillHints: [AutofillHints.password],
                      fillColor: MyColors.textWhite,
                      textBack: MyColors.textWhite),
                  SizedBox(height: 16),
                  myFieldAdvance(
                      context: context,
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      inputType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      fillColor: MyColors.textWhite,
                      textBack: MyColors.textWhite),
                  SizedBox(height: 24),
                  CustomButton(
                    text: 'sign_up'.tr,
                    onPressed: () {
                      Get.to(() => CreateProfileScreen());
                      // TODO: Sign up logic
                    },
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Text(
                      'Already have an account? Sign In',
                      style: AppTextStyles.medium.copyWith(
                        color: MyColors.textBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ageGenderField() {
    return Row(children: [
      // Age Dropdown
      Expanded(
        child: SizedBox(
          height: 43,
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              label: Text(
                'Age',
                style: TextStyle(
                  backgroundColor: Colors.white,
                  color: MyColors.textBlack.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              contentPadding: const EdgeInsets.only(top: 3, left: 20),
              filled: true,
              fillColor: MyColors.textWhite,
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.2),
                  borderRadius: BorderRadius.all(Radius.circular(28))),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
            ),
            items: List.generate(100, (index) => index + 1)
                .map((age) => DropdownMenuItem<int>(
                      value: age,
                      child: Text(age.toString()),
                    ))
                .toList(),
            onChanged: (value) {
              // Handle age selection
            },
            hint: Text(
              'Select Age',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),

      const SizedBox(width: 16), // Spacing between the two dropdowns

      // Gender Dropdown
      Expanded(
        child: SizedBox(
          height: 43,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              label: Text(
                'Gender',
                style: TextStyle(
                  backgroundColor: Colors.white,
                  color: MyColors.textBlack.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              contentPadding: const EdgeInsets.only(top: 3, left: 20),
              filled: true,
              fillColor: MyColors.textWhite,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.2),
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
            ),
            items: ['Male', 'Female', 'Other']
                .map((gender) => DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    ))
                .toList(),
            onChanged: (value) {
              // Handle gender selection
            },
            hint: Text(
              'Select Gender',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
