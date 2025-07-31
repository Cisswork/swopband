import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/images/iamges.dart';
import 'HubScreen.dart';
class RecentSwoppersScreen extends StatefulWidget {
  const RecentSwoppersScreen({super.key});

  @override
  State<RecentSwoppersScreen> createState() => _RecentSwoppersScreenState();
}

class _RecentSwoppersScreenState extends State<RecentSwoppersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40,),
            Text(
              "Recent SWOPPERS",
              style: AppTextStyles.large.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MyColors.textBlack,
              ),),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: 10,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    tileColor: MyColors.textDisabledColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    selectedTileColor: Colors.orange[100],
                    onTap: () {
                      Get.to(()=>HubScreen());
                    },
                    leading: Image.asset(MyImages.profileImage),
                    title: Text("Jenny Mackintosh"),
                    trailing: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.arrow_forward,color: Colors.white,),
                    ),
                  ),
                );
              },),
            ),
          ],
        ),
      ),
    );
  }
}
