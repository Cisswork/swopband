import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/images/iamges.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_colors.dart';
import 'package:nfc_manager/nfc_manager.dart';

class HubScreen extends StatefulWidget {

  HubScreen({Key? key}) : super(key: key);

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  final TextEditingController swopHandleController = TextEditingController();

  final TextEditingController bioController = TextEditingController();
  File? _profileImage;

  void _readNfcTag() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Ready to Scan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nfc, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text('Hold your device near the NFC tag.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              NfcManager.instance.stopSession();
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          Ndef? ndef = Ndef.from(tag);
          if (ndef == null || ndef.cachedMessage == null) {
            NfcManager.instance.stopSession(errorMessage: 'No NDEF data found');
            Navigator.of(context).pop();
            _showNfcDataDialog('No data found on this tag.');
            return;
          }
          NfcManager.instance.stopSession();
          Navigator.of(context).pop();
          final records = ndef.cachedMessage!.records;
          if (records.isEmpty) {
            _showNfcDataDialog('No records found on this tag.');
            return;
          }
          String data = '';
          for (var record in records) {
            if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
              data += NdefRecord.URI_PREFIX_LIST[record.payload[0]] + String.fromCharCodes(record.payload.sublist(1)) + '\n';
            } else {
              data += String.fromCharCodes(record.payload) + '\n';
            }
          }
          _showNfcDataDialog(data.trim());
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showNfcDataDialog('Failed to read tag: $e');
    }
  }

  void _showNfcDataDialog(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('NFC Tag Data'),
        content: Text(data),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MyImages.background6,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 40),
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: MyColors.primaryColor.withOpacity(0.1),
                        backgroundImage:AssetImage('assets/images/profileImage.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.question_mark,color: Colors.black,),
                            ),
                            SizedBox(height: 10,),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.black,
                              child: Icon(Icons.language,color: Colors.white),
                            ),
                          ],
                        ),
                      )

                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Toby Reberts",
                    style: AppTextStyles.large.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textBlack,
                    ),),
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(color: MyColors.textBlack,borderRadius: BorderRadius.all(Radius.circular(20))),
                    height: 30,child:    Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      "janedoe.swop ",
                      style: AppTextStyles.small.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textWhite,
                      ),),
                  ),),
                  SizedBox(height: 10),
                  Text(
                    "Design Director and CreativePartner at SWOPBAND",
                    style: AppTextStyles.large.copyWith(fontSize: 13,fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  
                  Image.asset("assets/images/groupImage.png",width: double.infinity,),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.nfc),
                    label: Text('Read from Swopband'),
                    onPressed: _readNfcTag,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      minimumSize: Size(200, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
