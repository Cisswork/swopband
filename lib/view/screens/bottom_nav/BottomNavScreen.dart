import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/controller/nav_controller/NavController.dart';
import '../FeedbackScreen.dart';
import '../EditLinksScreen.dart';
import '../HubScreen.dart';
import '../RecentSwoppersScreen.dart';
import '../SettingScreen.dart';
import '../swopband_webview_screen.dart';

class BottomNavScreen extends StatelessWidget {
  BottomNavScreen({super.key});

  final NavController navController = Get.put(NavController());

  final List<Widget> screens = [
    const EditLinksScreen(),
    const RecentSwoppersScreen(),
    // HubScreen(),
    SwopbandWebViewScreen(url: '',),
    Container(), // Placeholder for feedback - will be handled by navigation
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() => screens[navController.selectedIndex.value]),
      bottomNavigationBar: Obx(
            () => Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory, // Ripple effect disable
              highlightColor: Colors.transparent,   // Press highlight disable
            ),
            child: BottomNavigationBar(
              currentIndex: navController.selectedIndex.value,
              onTap: (index) {
                if (index == 3) { // Feedback tab
                  showDialog(
                    context: context,
                    builder: (context) => FeedbackPopup(),
                  );
                } else {
                  navController.changeIndex(index);
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.link),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group_outlined),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star_border),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}