import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/screens/splash_screen/SplashScreen.dart';
import 'package:swopband/view/screens/welcome_screen.dart';
import 'package:swopband/view/translations/app_strings.dart';
import 'package:swopband/view/utils/app_text_styles.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(); // Required for Firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Showpband NFC',
      translations: AppStrings(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        fontFamily: AppTextStyles.fontFamily,
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
      ],
    );
  }
}