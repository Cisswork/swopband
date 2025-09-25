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

class AddLinkScreen extends StatefulWidget {
  const AddLinkScreen({super.key});

  @override
  State<AddLinkScreen> createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends State<AddLinkScreen> {

  final controller = Get.put(LinkController());

  @override
  void initState() {
    super.initState();
    // Load existing links when screen initializes
    controller.fetchLinks();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _linkControllers = [TextEditingController()];
  final List<String> _linkTypes = ['instagram']; // Default first link type; hide 'custom' from selection
  int _linkCount = 1;
  final List<FocusNode> _linkFocusNodes = [FocusNode()];
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  // Supported link types with their display names and icons
  final Map<String, Map<String, dynamic>> _supportedLinks = {
    'instagram': {'name': 'Instagram', 'icon': MyImages.insta},
    'snapchat': {'name': 'Snapchat', 'icon': MyImages.snapchat},
    'linkedin': {'name': 'LinkedIn', 'icon': MyImages.linkedId},
    'x': {'name': 'Twitter', 'icon': MyImages.xmaster}, // Changed from 'twitter' to 'x'
    'spotify': {'name': 'Spotify', 'icon': MyImages.spotify},
    'facebook': {'name': 'Facebook', 'icon': MyImages.facebook},
    'strava': {'name': 'Strava', 'icon': MyImages.strava},
    'youtube': {'name': 'YouTube', 'icon': MyImages.youtube},
    'tiktok': {'name': 'TikTok', 'icon': MyImages.tiktok}, // Added TikTok
    'discord': {'name': 'Discord', 'icon': MyImages.discord}, // Added Discord
    'custom': {'name': 'Website', 'icon': MyImages.website}, // Added Website
  };

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    for (var controller in _linkControllers) {
      controller.dispose();
    }
    for (var focusNode in _linkFocusNodes) {
      focusNode.dispose();
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

    try {
      for (int i = 0; i < _linkControllers.length; i++) {
        await controller.createLink(
          name: _linkTypes[i],
          type: _linkTypes[i],
          url: _linkControllers[i].text, call: () {

        },
        );
      }
      // Clear form
      _emailController.clear();
      _phoneController.clear();
      _linkControllers.forEach((c) => c.clear());
      setState(() {
        _linkTypes.clear();
        _linkTypes.add('instagram'); // Default to instagram
        _linkControllers.clear();
        _linkControllers.add(TextEditingController());
        _linkFocusNodes.clear();
        _linkFocusNodes.add(FocusNode());
      });

      SnackbarUtil.showSuccess("Links submitted successfully!");
      Get.off(() =>  BottomNavScreen());

    } catch (e) {
      SnackbarUtil.showError("Failed to submit links: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      // Add resizeToAvoidBottomInset to handle keyboard properly
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          // Hide keyboard when tapping anywhere on screen
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
            // Better keyboard padding handling
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 100,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        Text(
                          AppStrings.addLinks.tr,
                          style: AppTextStyles.extraLarge.copyWith(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.addLinksDescription.tr,
                          style: AppTextStyles.extraLarge.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(MyImages.insta, width: 30, height: 30),
                            Image.asset(MyImages.snapchat, width: 30, height: 30),
                            Image.asset(MyImages.linkedId, width: 30, height: 30),
                            Image.asset(MyImages.xmaster, width: 30, height: 30),
                            Image.asset(MyImages.spotify, width: 30, height: 30),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(MyImages.facebook, width: 30, height: 30),
                            Image.asset(MyImages.strava, width: 30, height: 30),
                            Image.asset(MyImages.youtube, width: 30, height: 30),
                            Image.asset(MyImages.tiktok, width: 30, height: 30),
                            Image.asset(MyImages.discord, width: 30, height: 30),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          AppStrings.supportedLinks.tr,
                          style: AppTextStyles.extraLarge.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Email TextField
                  SizedBox(
                    height: 43,
                    child: TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      autofillHints: [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        _phoneFocusNode.requestFocus();
                      },
                      decoration: InputDecoration(
                        label: Text(
                          'email'.tr,
                          style: TextStyle(
                            backgroundColor: Colors.transparent,
                            color: Colors.black.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(top: 3, left: 20, right: 12),
                        hintText: 'email'.tr,
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          fontFamily: "Chromatica",
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                          wordSpacing: 1.2,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.2),
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.2),
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Phone TextField
                  SizedBox(
                    height: 43,
                    child: TextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      autofillHints: [AutofillHints.telephoneNumber],
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: InputDecoration(
                        label: Text(
                          AppStrings.phoneNumber.tr,
                          style: TextStyle(
                            backgroundColor: Colors.transparent,
                            color: Colors.black.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(top: 3, left: 20, right: 12),
                        hintText: AppStrings.phoneNumber.tr,
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          fontFamily: "Chromatica",
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                          wordSpacing: 1.2,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.2),
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.2),
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Show existing links section
                  if (controller.links.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.link, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Your Existing Links',
                                style: AppTextStyles.extraLarge.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'These links are already saved to your profile:',
                            style: AppTextStyles.extraLarge.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  ...List.generate(controller.links.length, (index) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                              onTap: () {
                                // Hide keyboard when dropdown area is tapped
                                _emailFocusNode.unfocus();
                                _phoneFocusNode.unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              onTapDown: (details) {
                                // Hide keyboard when dropdown is pressed
                                _emailFocusNode.unfocus();
                                _phoneFocusNode.unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: DropdownButtonFormField<String>(
                                value: controller.links[index].type,
                                isExpanded: true,
                                menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
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
                              // Show only icon in selected item
                              selectedItemBuilder: (BuildContext context) {
                                return _supportedLinks.entries.map((entry) {
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      entry.value['icon'],
                                      width: 24,
                                      height: 24,
                                    ),
                                  );
                                }).toList();
                              },
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
                              onChanged: null, // readonly
                              onTap: () {
                                // Hide keyboard when dropdown is tapped
                                _emailFocusNode.unfocus();
                                _phoneFocusNode.unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },

                            ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 7,
                            child: myFieldAdvance(
                              context: context,
                              controller: TextEditingController(text: controller.links[index].url),
                              hintText: 'Enter ${_supportedLinks[controller.links[index].type]!['name']} URL or ID',
                              inputType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              fillColor: Colors.transparent,
                              textBack: Colors.transparent,
                              readOnly: true,
                            ),
                          ),
                          PopupMenuButton<String>(
                              color: Colors.white,
                              icon: const Icon(Icons.more_vert, color: Colors.black,size: 17),
                              onSelected: (String value) async {
                                final link = controller.links[index];
                                if (value == 'edit') {
                                  //_showEditDialog(index);
                                } else if (value == 'delete') {
                                  await controller.deleteLink(link.id);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.black,size: 17,),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.black),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ]
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ],
                  )),

                  // New links section
                  if (_linkCount > controller.links.length) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.add_circle, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Add New Links',
                                style: AppTextStyles.extraLarge.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add new social media links to your profile. Make sure the URL is unique and not already added.',
                            style: AppTextStyles.extraLarge.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Editable fields for new links
                  ...List.generate((_linkCount - controller.links.length).clamp(0, _linkCount), (i) {
                    final index = controller.links.length + i;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: GestureDetector(
                                onTap: () {
                                  // Hide keyboard when dropdown area is tapped
                                  _emailFocusNode.unfocus();
                                  _phoneFocusNode.unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                onTapDown: (details) {
                                  // Hide keyboard when dropdown is pressed
                                  _emailFocusNode.unfocus();
                                  _phoneFocusNode.unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                child: DropdownButtonFormField<String>(
                                  value: _linkTypes[index],
                                  isExpanded: true,
                                  menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
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
                                // Show only icon in the selected field (no text)
                                selectedItemBuilder: (BuildContext context) {
                                  return _supportedLinks.entries.map((entry) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        entry.value['icon'],
                                        width: 24,
                                        height: 24,
                                      ),
                                    );
                                  }).toList();
                                },
                                // All supported links are available for selection
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
                                  // Hide keyboard when dropdown value changes
                                  _emailFocusNode.unfocus();
                                  _phoneFocusNode.unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  setState(() {
                                    _linkTypes[index] = newValue!;
                                  });
                                },
                                onTap: () {
                                  // Hide keyboard when dropdown is tapped
                                  _emailFocusNode.unfocus();
                                  _phoneFocusNode.unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },

                              ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 7,
                              child: myFieldAdvance(
                                focusNode: _linkFocusNodes[index],
                                context: context,
                                controller: _linkControllers[index],
                                hintText: 'Enter ${_supportedLinks[_linkTypes[index]]!['name']} URL or ID',
                                inputType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                fillColor: Colors.transparent,
                                textBack: Colors.transparent,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  if (_linkCount > controller.links.length) {
                                    _linkControllers.removeAt(index);
                                    _linkFocusNodes.removeAt(index);
                                    _linkTypes.removeAt(index);
                                    _linkCount--;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
                    );
                  },
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomButton(
                      buttonColor: MyColors.textBlack,
                      textColor: MyColors.textWhite,
                      text: AppStrings.addAnotherLink.tr,
                      onPressed: () {
                        setState(() {
                          _linkControllers.add(TextEditingController());
                          _linkFocusNodes.add(FocusNode());
                          _linkTypes.add('instagram');
                          _linkCount++;
                        });
                      },
                    ),
                  ),
                  if (_linkCount > controller.links.length)
                    Obx(() => controller.isLoading.value?
                    const Center(child: CircularProgressIndicator(color: Colors.black,)):
                    Padding(
                      padding: const EdgeInsets.only(left: 60.0,right: 60.0,top: 10),
                      child: CustomButton(
                        buttonColor: MyColors.textBlack,
                        textColor: MyColors.textWhite,
                        text: "Go to your hub",
                        onPressed: () async {
                          bool hasEmpty = false;
                          bool hasDuplicate = false;

                          // Check for duplicates first
                          for (int i = controller.links.length; i < _linkCount; i++) {
                            final url = _linkControllers[i].text.trim();
                            if (url.isNotEmpty) {
                              // Check if this URL already exists in the user's links
                              final existingLink = controller.links.any((link) =>
                                link.url.toLowerCase() == url.toLowerCase() ||
                                link.url.toLowerCase().contains(url.toLowerCase()) ||
                                url.toLowerCase().contains(link.url.toLowerCase())
                              );

                              if (existingLink) {
                                hasDuplicate = true;
                                SnackbarUtil.showError("Link '${_linkTypes[i]}' with URL '$url' already exists in your profile.");
                                break;
                              }
                            }
                          }

                          if (hasDuplicate) return;

                          // Loop backwards to safely remove empty links while iterating
                          for (int i = _linkCount - 1; i >= controller.links.length; i--) {
                            final url = _linkControllers[i].text.trim();

                            if (url.isEmpty) {
                              // Remove empty link
                              _linkControllers.removeAt(i);
                              _linkTypes.removeAt(i);
                              _linkCount--;
                              hasEmpty = true;
                            } else {
                              // Create the link if not empty
                              await controller.createLink(
                                name: _linkTypes[i],
                                type: _linkTypes[i],
                                url: url, call: () {
                                Get.offAll(() =>  BottomNavScreen());
                              },);
                            }
                          }

                        },
                      ),
                    ),
                    ),
                ],
              ),
            ),
          ),
        ),
                  ),
      ),
    );
  }
}