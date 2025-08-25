import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcTestScreen extends StatefulWidget {
  @override
  _NfcTestScreenState createState() => _NfcTestScreenState();
}

class _NfcTestScreenState extends State<NfcTestScreen> {
  String _nfcStatus = "Tap 'Start NFC'";

  void _startNfc() async {
    setState(() => _nfcStatus = "Waiting for NFC...");
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443}, // You can also specify iso18092 and iso15693.
      onDiscovered: (NfcTag tag) async {
        // Do something with an NfcTag instance...
        print(tag);

        // Stop the session when no longer needed.
        await NfcManager.instance.stopSession();
      },
    );

    /*await NfcManager.instance.startSession(
      alertMessage: "Hold your device near NFC tag",
      onDiscovered: (tag) async {
        print("✅ NFC TAG FOUND: $tag");
        setState(() => _nfcStatus = "Tag detected: $tag");
        await NfcManager.instance.stopSession();
      },
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NFC Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_nfcStatus),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startNfc,
              child: Text("Start NFC"),
            ),
          ],
        ),
      ),
    );
  }
}
