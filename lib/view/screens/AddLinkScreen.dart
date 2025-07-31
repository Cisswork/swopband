import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/controller/link_controller/LinkController.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_snackbar.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import '../translations/app_strings.dart';
import '../utils/images/iamges.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_colors.dart';
import 'bottom_nav/BottomNavScreen.dart';
import 'package:nfc_manager/nfc_manager.dart';

class AddLinkScreen extends StatefulWidget {
  const AddLinkScreen({super.key});

  @override
  State<AddLinkScreen> createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends State<AddLinkScreen> {

  final controller = Get.put(LinkController());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _linkControllers = [TextEditingController()];
  final List<String> _linkTypes = ['spotify']; // Default first link type
  int _linkCount = 1;

  // Supported link types with their display names and icons
  final Map<String, Map<String, dynamic>> _supportedLinks = {
    'instagram': {'name': 'Instagram', 'icon': MyImages.insta},
    'music': {'name': 'Music', 'icon': MyImages.music},
    'reddit': {'name': 'Reddit', 'icon': MyImages.reddit},
    'linkedin': {'name': 'LinkedIn', 'icon': MyImages.linkedId},
    'twitter': {'name': 'Twitter', 'icon': MyImages.xmaster},
    'spotify': {'name': 'Spotify', 'icon': MyImages.spotify},
    'facebook': {'name': 'Facebook', 'icon': MyImages.facebook},
    'github': {'name': 'GitHub', 'icon': MyImages.github},
    'youtube': {'name': 'YouTube', 'icon': MyImages.youtube},
    'tinder': {'name': 'Tinder', 'icon': MyImages.tindi},
  };

  bool _nfcInProgress = false;
  String _nfcStatus = '';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    for (var controller in _linkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitLinks() async {
    // Validate all links
    for (int i = 0; i < _linkControllers.length; i++) {
      if (_linkControllers[i].text.isEmpty || _linkTypes[i].isEmpty) {
        SnackbarUtil.showError("Please select a link type and provide the link for item  ${i + 1}");
        return;
      }
    }

    setState(() {
      _nfcInProgress = true;
      _nfcStatus = 'Waiting for NFC tag...';
    });

    // Prepare NDEF records for all links
    List<NdefRecord> records = [];
    for (int i = 0; i < _linkControllers.length; i++) {
      final url = _linkControllers[i].text;
      if (url.isNotEmpty) {
        records.add(NdefRecord.createUri(Uri.parse(url)));
      }
    }

    // Start NFC write session
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          NfcManager.instance.stopSession(errorMessage: 'Tag not writable');
          setState(() {
            _nfcStatus = 'This tag is not writable';
            _nfcInProgress = false;
          });
          SnackbarUtil.showError('This tag is not writable');
          return;
        }
        try {
          await ndef.write(NdefMessage(records));
          NfcManager.instance.stopSession();
          setState(() {
            _nfcStatus = 'Write successful!';
            _nfcInProgress = false;
          });
          SnackbarUtil.showSuccess('NFC write successful!');
          // Now save links to backend
          for (int i = 0; i < _linkControllers.length; i++) {
            await controller.createLink(
              name: _linkTypes[i],
              type: _linkTypes[i],
              url: _linkControllers[i].text,
            );
          }
          // Clear form
          _emailController.clear();
          _phoneController.clear();
          _linkControllers.forEach((c) => c.clear());
          setState(() {
            _linkTypes.clear();
            _linkTypes.add('spotify');
            _linkControllers.clear();
            _linkControllers.add(TextEditingController());
          });
          SnackbarUtil.showSuccess("Links submitted successfully!");
          Get.off(() =>  BottomNavScreen());
        } catch (e) {
          NfcManager.instance.stopSession(errorMessage: e.toString());
          setState(() {
            _nfcStatus = 'Write failed: $e';
            _nfcInProgress = false;
          });
          SnackbarUtil.showError('Write failed: $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(MyImages.background5, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.addLinks.tr,
                        style: AppTextStyles.extraLarge.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.addLinksDescription.tr,
                        style: AppTextStyles.extraLarge.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(MyImages.insta),
                                Image.asset(MyImages.music),
                                Image.asset(MyImages.reddit),
                                Image.asset(MyImages.linkedId),
                                Image.asset(MyImages.xmaster),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(MyImages.spotify),
                                Image.asset(MyImages.facebook),
                                Image.asset(MyImages.github),
                                Image.asset(MyImages.youtube),
                                Image.asset(MyImages.tindi),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              AppStrings.supportedLinks.tr,
                              style: AppTextStyles.extraLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      myFieldAdvance(
                        autofillHints: [AutofillHints.email],
                        context: context,
                        controller: _emailController,
                        hintText: 'email'.tr,
                        inputType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        fillColor: Colors.transparent,
                        textBack: Colors.transparent,
                      ),
                      const SizedBox(height: 10),
                      myFieldAdvance(
                        autofillHints: [AutofillHints.telephoneNumber],
                        context: context,
                        controller: _phoneController,
                        hintText: AppStrings.phoneNumber.tr,
                        inputType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        fillColor: Colors.transparent,
                        textBack: Colors.transparent,
                      ),
                      const SizedBox(height: 20),
                      ..._linkControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: DropdownButtonFormField<String>(
                                    value: _linkTypes[index],
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.grey),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    items: _supportedLinks.entries.map((entry) {
                                      return DropdownMenuItem<String>(
                                        value: entry.key,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              entry.value['icon'],
                                              width: 24,
                                              height: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                entry.value['name'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _linkTypes[index] = newValue!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 7,
                                  child: myFieldAdvance(
                                    context: context,
                                    controller: controller,
                                    hintText: 'Enter ${_supportedLinks[_linkTypes[index]]!['name']} URL or ID',
                                    inputType: TextInputType.text,
                                    textInputAction: index < _linkControllers.length - 1
                                        ? TextInputAction.next
                                        : TextInputAction.done,
                                    fillColor: Colors.transparent,
                                    textBack: Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonColor: MyColors.textBlack,
                          textColor: MyColors.textWhite,
                          text: AppStrings.addAnotherLink.tr,
                          onPressed: () {
                            setState(() {
                              _linkControllers.add(TextEditingController());
                              _linkTypes.add('spotify'); // Default type for new link
                              _linkCount++;
                            });
                          },
                        ),
                      ),
                      _nfcInProgress
                          ? Center(child: Column(children: [
                              CircularProgressIndicator(color: Colors.black),
                              SizedBox(height: 8),
                              Text(_nfcStatus, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ]))
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomButton(
                                buttonColor: MyColors.textBlack,
                                textColor: MyColors.textWhite,
                                text: AppStrings.goToHub.tr,
                                onPressed: _submitLinks,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}