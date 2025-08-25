import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_intl_phone_field/countries.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:flutter_intl_phone_field/phone_number.dart';
import 'package:swopband/view/utils/app_colors.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Widget myFieldAdvance({
  required BuildContext context,
  required TextEditingController controller,
  required String hintText,
  required TextInputType inputType,
  required TextInputAction textInputAction,
  required Color fillColor,
  required Color textBack,
  List<String>? autofillHints,
  List<TextInputFormatter>? inputFormatters,
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
  bool? readOnly,
  bool showPasswordToggle = false, // Optional parameter for password toggle
  Function(String)? onChanged,
}) {
  final FocusNode internalFocusNode = FocusNode();
  final readOnlyMain = false;
  bool obscureText = showPasswordToggle; // Initially obscure if it's a password field

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        height: 43,
        width: MediaQuery.of(context).size.width,
        child: StatefulBuilder(
          builder: (context, setState) {
            return TextFormField(
              inputFormatters: inputFormatters,
              readOnly: readOnly ?? readOnlyMain,
              onChanged: onChanged,
              controller: controller,
              autofillHints: autofillHints,
              textInputAction: textInputAction,
              keyboardType: inputType,
              obscureText: showPasswordToggle ? obscureText : false,
              focusNode: focusNode ?? internalFocusNode,
              onFieldSubmitted: (value) {
                if (nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(nextFocusNode);
                } else {
                  FocusScope.of(context).unfocus(); // This dismisses the keyboard
                }
              },
              decoration: InputDecoration(
                label: Text(
                  hintText,
                  style: TextStyle(
                    backgroundColor: textBack,
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                contentPadding:
                const EdgeInsets.only(top: 3, left: 20, right: 12),
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 12,
                  fontFamily: "Chromatica",
                  color: Colors.grey,
                  decoration: TextDecoration.none,
                  wordSpacing: 1.2,
                ),
                filled: true,
                fillColor: fillColor,
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.2),
                    borderRadius: BorderRadius.all(Radius.circular(28))),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
                suffixIcon: showPasswordToggle
                    ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                )
                    : null,
              ),
            );
          },
        ),
      ),
    ],
  );
}


// Example color constants (replace with your own)
class MyColors1 {
  static const Color textBlack = Colors.black;
  static const Color textWhite = Colors.white;
}

Widget customPhoneField({
  required TextEditingController controller,
  String? hintText,
  TextInputAction? textInputAction,
  Function(PhoneNumber)? onChanged,
  Function(Country)? onCountryChanged,
  String? initialCountryCode,
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
  bool readOnly = false,
}) {
  return SizedBox(
    height: 45,
    width: double.infinity,
    child: IntlPhoneField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      initialCountryCode: initialCountryCode ?? 'US',
      onChanged: onChanged,
      validator: (value) => null, // disables error display
      decoration: InputDecoration(
        counterText: "",
        label: hintText != null
            ? Text(
          hintText,
          style: TextStyle(
            backgroundColor: Colors.white,
            color: MyColors.textBlack.withOpacity(0.8),
            fontSize: 14,
          ),
        )
            : null,
        contentPadding: const EdgeInsets.only(top: 3, left: 20, right: 12),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 12,
          fontFamily: "Chromatica",
          color: Colors.grey,
          decoration: TextDecoration.none,
          wordSpacing: 1.2,
        ),
        filled: true,
        fillColor: MyColors.textWhite,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.2),
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.2),
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        errorBorder:  const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28))),

      ),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      dropdownTextStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      dropdownIcon: const Icon(
        Icons.arrow_drop_down,
        color: Colors.black,
      ),
      flagsButtonPadding: const EdgeInsets.only(left: 10),
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction ?? TextInputAction.next,
      onCountryChanged: onCountryChanged,
      disableLengthCheck: true,
    ),
  );
}
