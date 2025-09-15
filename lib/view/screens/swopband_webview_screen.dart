import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_snackbar.dart';
import '../../controller/recent_swoppers_controller/RecentSwoppersController.dart';
import '../../controller/nav_controller/NavController.dart';
import 'bottom_nav/BottomNavScreen.dart';

class SwopbandWebViewScreen extends StatefulWidget {
  final String? username;
  final String url;

  const SwopbandWebViewScreen({super.key, this.username, required this.url});

  @override
  State<SwopbandWebViewScreen> createState() => _SwopbandWebViewScreenState();
}

class _SwopbandWebViewScreenState extends State<SwopbandWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  final RecentSwoppersController _recentSwoppersController = Get.find<RecentSwoppersController>();

  @override
  void initState() {
    super.initState();
    log('🔄 SwopbandWebViewScreen initState called for @${widget.username}');
    String finalUrl;
    if (widget.url.isNotEmpty) {
      finalUrl = widget.url;
    } else {
      final username = widget.username ?? AppConst.USER_NAME;
      finalUrl = "https://srirangasai.dev/$username";
    }

    log("Loading profile: $finalUrl");

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // you can log progress here if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });

            // Force hide loader after 3 seconds even if page not fully loaded
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            });
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(finalUrl));

    // Automatically create connection when profile page opens
    if (widget.username != null) {
      log('🔄 Starting auto-connection for @${widget.username}');
      _autoConnectWithUser();
    }
  }

  @override
  void dispose() {
    log('🔄 SwopbandWebViewScreen dispose called for @${widget.username}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: widget.username != null
          ? AppBar(
        backgroundColor: MyColors.backgroundColor,
        elevation: 0,
        title: Text(
          '${widget.username}\'s Profile',
          style: AppTextStyles.large.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MyColors.textBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyColors.textBlack),
          onPressed: () => _goToRecentSwoppers(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: MyColors.textBlack),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      )
          : null,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: MyColors.textBlack,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.username != null
                          ? 'Loading ${widget.username}\'s Profile...'
                          : 'Loading Swopband Profile...',
                      style: AppTextStyles.medium.copyWith(
                        color: MyColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
     /* floatingActionButton: widget.username != null
          ? FloatingActionButton.extended(
              onPressed: _connectWithUser,
              backgroundColor: MyColors.primaryColor,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'View Connections',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,*/
    );
  }

  Future<void> _autoConnectWithUser() async {
    if (widget.username == null) return;
    
    try {
      log('🔗 Auto-connecting with @${widget.username}');
      
      // Check if already connected
      if (_recentSwoppersController.isUserConnected(widget.username!)) {
        log('ℹ️ Already connected with @${widget.username}');
        return;
      }
      
      // Create connection automatically (no user interaction needed)
      final success = await _recentSwoppersController.createConnection(widget.username!);
      
      if (success) {
        log('✅ Auto-connected with @${widget.username} successfully!');
        SnackbarUtil.showSuccess("Connected with @${widget.username}!");
        // DO NOT navigate away - stay on profile page
      } else {
        log('❌ Auto-connection failed for @${widget.username}');
        SnackbarUtil.showError("Failed to connect with @${widget.username}");
      }
    } catch (e) {
      log('❌ Error in auto-connection: $e');
      SnackbarUtil.showError("Error connecting: $e");
    }
  }

  void _goToRecentSwoppers() {
    log('🔄 Navigating to Recent Swoppers screen');
    // Navigate to BottomNavScreen and set it to Recent Swoppers tab
    Get.offAll(() => BottomNavScreen());
    
    // Set the navigation to Recent Swoppers tab (index 1)
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        final navController = Get.find<NavController>();
        navController.selectedIndex.value = 1; // Recent Swoppers tab
        log('✅ Set navigation to Recent Swoppers tab');
      } catch (e) {
        log('❌ Error setting navigation tab: $e');
      }
    });
  }

  Future<void> _connectWithUser() async {
    if (widget.username == null) return;
    
    try {
      log('🔗 Manual connect with @${widget.username}');
      
      // Check if already connected
      if (_recentSwoppersController.isUserConnected(widget.username!)) {
        SnackbarUtil.showInfo("You are already connected with @${widget.username}");
        return;
      }
      
      // Show loading
      SnackbarUtil.showInfo("Connecting with @${widget.username}...");
      
      // Create connection
      final success = await _recentSwoppersController.createConnection(widget.username!);
      
      if (success) {
        SnackbarUtil.showSuccess("Connected with @${widget.username} successfully!");
        
        // Navigate to recent swoppers to show the new connection
        Get.offAll(() => BottomNavScreen());
        
        // Set the navigation to Recent Swoppers tab (index 1)
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            final navController = Get.find<NavController>();
            navController.selectedIndex.value = 1; // Recent Swoppers tab
            log('✅ Set navigation to Recent Swoppers tab after connection');
          } catch (e) {
            log('❌ Error setting navigation tab after connection: $e');
          }
        });
      } else {
        SnackbarUtil.showError("Failed to connect with @${widget.username}. Please try again.");
      }
    } catch (e) {
      log('❌ Error connecting with user: $e');
      SnackbarUtil.showError("Error connecting: $e");
    }
  }
}