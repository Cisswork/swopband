import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/controller/nav_controller/NavController.dart';
import '../EditLinksScreen.dart';
import '../FeedbackScreen.dart';
import '../HubScreen.dart';
import '../RecentSwoppersScreen.dart';
import '../SettingScreen.dart';

class BottomNavScreen extends StatelessWidget {
  BottomNavScreen({super.key});

  final NavController navController = Get.put(NavController());

  final List<Widget> screens = [
    const EditLinksScreen(),
    const RecentSwoppersScreen(),
    HubScreen(),
    FeedbackPopup(),
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
              border:
                  Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: BottomNavigationBar(
              currentIndex: navController.selectedIndex.value,
              onTap: (index) => navController.changeIndex(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              items: [
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
        )
    );
  }
}
