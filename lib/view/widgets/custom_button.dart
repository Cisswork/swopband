import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color? buttonColor;
  final Color? textColor;
  final Color? border;
  final Widget? widget;
  final VoidCallback onPressed;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.buttonColor,
    this.textColor,
    super.key,
    this.widget,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveButtonColor = buttonColor ?? Colors.black;
    final Color effectiveTextColor = textColor ?? Colors.white;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveButtonColor,
        foregroundColor: effectiveTextColor,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: border ?? Colors.transparent)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget ?? SizedBox(),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
                fontSize: 15,
                color: effectiveTextColor,
                fontFamily: "Chromatica"),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
