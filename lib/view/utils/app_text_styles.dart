import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontFamily = 'Chromatica';

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: fontFamily,
  );

  static const TextStyle medium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );

  static const TextStyle large = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
  );

  static const TextStyle extraLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
  );
}
