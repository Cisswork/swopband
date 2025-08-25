import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/screens/splash_screen/SplashScreen.dart';
import 'package:swopband/view/screens/nfc_test_screen.dart';
import 'package:swopband/view/translations/app_strings.dart';
import 'package:swopband/view/utils/app_text_styles.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:swopband/controller/recent_swoppers_controller/RecentSwoppersController.dart';
import 'package:swopband/services/nfc_background_service.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  String? initialLink;
  try {
    final appLinks = AppLinks();
    final initialUri = await appLinks.getInitialLink();
    initialLink = initialUri?.toString();
    print('getInitialLink: $initialLink');
  } catch (e) {
    print('Error getting initial app link: $e');
  }

  runApp(MyApp(initialNfcUrl: initialLink));
}


class MyApp extends StatefulWidget {
  final String? initialNfcUrl;
  const MyApp({Key? key, this.initialNfcUrl}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<Uri>? _appLinksSubscription;
  final RecentSwoppersController recentSwoppersController = Get.put(RecentSwoppersController());
  final NfcBackgroundService _nfcService = NfcBackgroundService();
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    _initializeAppLinks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // App became active - start iOS NFC scanning
      if (Platform.isIOS) {
        log('📱 iOS: App resumed, starting NFC scanning...');
        Future.delayed(Duration(milliseconds: 500), () {
          _nfcService.startIosForegroundNfcScanning();
        });
      }
    } else if (state == AppLifecycleState.paused) {
      // App went to background - stop NFC scanning
      if (Platform.isIOS) {
        log('📱 iOS: App paused, stopping NFC scanning...');
        _nfcService.stopListening();
      }
    } else if (state == AppLifecycleState.inactive) {
      // App is inactive - pause NFC scanning
      if (Platform.isIOS) {
        log('📱 iOS: App inactive, pausing NFC scanning...');
        _nfcService.stopListening();
      }
    }
  }

  void _initializeApp() {
    // Start NFC background service after a short delay
    Future.delayed(Duration(seconds: 2), () {
      _nfcService.startListening();
      
      // For iPhone 13, also start foreground NFC scanning
      if (Platform.isIOS) {
        log('📱 iOS: Starting initial NFC scanning for iPhone 13...');
        Future.delayed(Duration(seconds: 3), () {
          _nfcService.startIosForegroundNfcScanning();
        });
      }
    });
  }

  void _initializeAppLinks() {
    // Handle app links when app is already running
    _appLinksSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        log('📱 iOS: App link received: $uri');
        _handleAppLink(uri);
      }
    }, onError: (err) {
      log('❌ App links error: $err');
    });

    // Also check for initial link when app starts
    _checkInitialAppLink();
  }

  Future<void> _checkInitialAppLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        log('📱 iOS: Initial app link found: $initialUri');
        _handleAppLink(initialUri);
      }
    } catch (e) {
      log('❌ Error checking initial app link: $e');
    }
  }

  void _handleAppLink(Uri uri) {
    log('📱 iOS: Processing app link: $uri');
    
    // Support localhost, local IP, and production domain
    if (uri.host == 'srirangasai.dev' || 
        uri.host == 'localhost' || 
        uri.host == '192.168.0.28') {
      // Extract username from URL and create connection
      final username = _extractUsernameFromUri(uri);
      if (username != null) {
        log('✅ Username extracted from NFC URL: $username');
        log('🔄 Creating connection for username: $username');
        
        // Call the connection creation method
        recentSwoppersController.handleNfcConnection(username);
        
        // Show success message
        Get.snackbar(
          'NFC Connection Detected',
          'Connecting with @$username...',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        log('❌ Could not extract username from URI: $uri');
        Get.snackbar(
          'Invalid NFC Data',
          'Could not read username from NFC tag',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } else {
      log('⚠️ App link not from supported domain: $uri');
      log('⚠️ Supported domains: srirangasai.dev, localhost, 192.168.0.28');
    }
  }

  String? _extractUsernameFromUri(Uri uri) {
    try {
      // Support localhost, local IP, and production domains
      if ((uri.host == 'srirangasai.dev' || 
           uri.host == 'localhost' || 
           uri.host == '192.168.0.28') && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    } catch (e) {
      print('Error extracting username from URI: $e');
    }
    return null;
  }

  Widget _handleInitialNfcUrl(String url) {
    // Extract username and handle the NFC connection
    try {
      final uri = Uri.parse(url);
      final username = _extractUsernameFromUri(uri);
      if (username != null) {
        print('Initial NFC URL detected for username: $username');
        // Navigate to splash screen but trigger connection creation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          recentSwoppersController.handleNfcConnection(username);
        });
      }
    } catch (e) {
      print('Error parsing initial NFC URL: $e');
    }
    return SplashScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appLinksSubscription?.cancel();
    _nfcService.stopListening();
    super.dispose();
  }

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
      home: widget.initialNfcUrl != null && (widget.initialNfcUrl!.contains('srirangasai.dev') || 
                                             widget.initialNfcUrl!.contains('localhost') ||
                                             widget.initialNfcUrl!.contains('192.168.0.28'))
          ? _handleInitialNfcUrl(widget.initialNfcUrl!)
          : SplashScreen(),
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/nfc-test', page: () => NfcTestScreen()),
        // GetPage(name: '/webview', page: () => SwopbandWebViewScreen(url: '')),
      ],
    );
  }
}