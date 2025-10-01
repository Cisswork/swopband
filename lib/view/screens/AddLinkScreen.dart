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

  final List<TextEditingController> _linkControllers = [
    TextEditingController()
  ];
  final List<String> _linkTypes = [
    'instagram'
  ]; // Default first link type; hide 'custom' from selection
  int _linkCount = 1;
  final List<FocusNode> _linkFocusNodes = [FocusNode()];

  // Supported link types with their display names and icons
  final Map<String, Map<String, dynamic>> _supportedLinks = {
    'instagram': {'name': 'Instagram', 'icon': MyImages.insta},
    'snapchat': {'name': 'Snapchat', 'icon': MyImages.snapchat},
    'linkedin': {'name': 'LinkedIn', 'icon': MyImages.linkedId},
    'x': {
      'name': 'Twitter',
      'icon': MyImages.xmaster
    }, // Changed from 'twitter' to 'x'
    'spotify': {'name': 'Spotify', 'icon': MyImages.spotify},
    'facebook': {'name': 'Facebook', 'icon': MyImages.facebook},
    'strava': {'name': 'Strava', 'icon': MyImages.strava},
    'youtube': {'name': 'YouTube', 'icon': MyImages.youtube},
    'tiktok': {'name': 'TikTok', 'icon': MyImages.tiktok}, // Added TikTok
    'discord': {'name': 'Discord', 'icon': MyImages.discord}, // Added Discord
    'custom': {'name': 'Website', 'icon': MyImages.website}, // Added Website
    'phone': {'name': 'Phone', 'icon': MyImages.phone}, // Added Website
    'email': {'name': 'Email', 'icon': MyImages.email}, // Added Website
  };

  @override
  void dispose() {
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
        SnackbarUtil.showError(
            "Please select a link type and provide the link for item  ${i + 1}");
        return;
      }
    }

    try {
      for (int i = 0; i < _linkControllers.length; i++) {
        await controller.createLink(
          name: _linkTypes[i],
          type: _linkTypes[i],
          url: _linkControllers[i].text,
          call: () {},
        );
      }
      // Clear form

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
      Get.off(() => BottomNavScreen());
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
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            AppStrings.addLinks.tr,
                            style: AppTextStyles.extraLarge.copyWith(
                              color: Colors.white,
                              fontSize: 30,
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
                              Image.asset(MyImages.insta,
                                  width: 50, height: 50),
                              Image.asset(MyImages.tiktok,
                                  width: 50, height: 50),
                              Image.asset(MyImages.snapchat,
                                  width: 50, height: 50),
                              Image.asset(MyImages.linkedId,
                                  width: 50, height: 50),
                              Image.asset(MyImages.xmaster,
                                  width: 50, height: 50),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(MyImages.spotify,
                                  width: 50, height: 50),
                              Image.asset(MyImages.facebook,
                                  width: 50, height: 50),
                              Image.asset(MyImages.strava,
                                  width: 50, height: 50),
                              Image.asset(MyImages.youtube,
                                  width: 50, height: 50),
                              Image.asset(MyImages.discord,
                                  width: 50, height: 50),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppStrings.supportedLinks.tr,
                            style: AppTextStyles.extraLarge.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Email TextField

                    // Show existing links section
                    if (controller.links.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.link,
                                    color: Colors.green, size: 20),
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

                    ...List.generate(
                        controller.links.length,
                        (index) => Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        onTapDown: (details) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          isDense: false,
                                          itemHeight: null,
                                          value: controller.links[index].type,
                                          menuMaxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          // Show icon and name in selected item
                                          selectedItemBuilder:
                                              (BuildContext context) {
                                            return _supportedLinks.entries
                                                .map((entry) {
                                              return Container(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      entry.value['icon'],
                                                      width: 35,
                                                      height: 35,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text(
                                                        entry.value['name'],
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList();
                                          },
                                          items: _supportedLinks.entries
                                              .map((entry) {
                                            return DropdownMenuItem<String>(
                                              value: entry.key,
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    entry.value['icon'],
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      entry.value['name'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: null, // readonly
                                          onTap: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 7,
                                      child: myFieldAdvance(
                                        context: context,
                                        controller: TextEditingController(
                                            text: controller.links[index].url),
                                        hintText:
                                        'Enter ${_supportedLinks[_linkTypes[index]]!['name']} ${_supportedLinks[_linkTypes[index]]!['name'] == "Phone" ? 'Number' : _supportedLinks[_linkTypes[index]]!['name'] == "Email" ? "Id" : _supportedLinks[_linkTypes[index]]!['name'] == "Website" ? "URL" : "URL or ID"}',
                                        inputType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        fillColor: Colors.transparent,
                                        textBack: Colors.transparent,
                                        readOnly: true,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                        color: Colors.white,
                                        icon: const Icon(Icons.more_vert,
                                            color: Colors.black, size: 17),
                                        onSelected: (String value) async {
                                          final link = controller.links[index];
                                          if (value == 'edit') {
                                            //_showEditDialog(index);
                                          } else if (value == 'delete') {
                                            await controller
                                                .deleteLink(link.id);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      color: Colors.black,
                                                      size: 17,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        color: Colors.black),
                                                    SizedBox(width: 8),
                                                    Text('Delete'),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                  ],
                                ),
                                const SizedBox(height: 15),
                              ],
                            )),

                    // Editable fields for new links
                    ...List.generate(
                      (_linkCount - controller.links.length)
                          .clamp(0, _linkCount),
                      (i) {
                        final index = controller.links.length + i;
                        return Column(
                          children: [
                            Row(
                              children: [
                        Expanded(
                        flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              _showLinkSelector(context, index);
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  _supportedLinks[_linkTypes[index]]!['icon'],
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          ),
                        ),


                        /*     Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    onTapDown: (details) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      isDense: false,
                                      itemHeight: null,
                                      iconEnabledColor: Colors.black,
                                      value: _linkTypes[index],
                                      menuMaxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      // Show only icon in the selected field (no text)
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                        return _supportedLinks.entries
                                            .map((entry) {
                                          return SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: Image.asset(
                                              entry.value['icon'],
                                              width: 50,
                                              height: 50,
                                            ),
                                          );
                                        }).toList();
                                      },
                                      // All supported links are available for selection
                                      items:
                                          _supportedLinks.entries.map((entry) {
                                        return DropdownMenuItem<String>(
                                          value: entry.key,
                                          child: Image.asset(
                                            entry.value['icon'],
                                            width: 45,
                                            height: 45,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        setState(() {
                                          _linkTypes[index] = newValue!;
                                        });
                                      },
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                    ),
                                  ),
                                ),*/
                                Expanded(
                                  flex: 7,
                                  child: myFieldAdvance(
                                    focusNode: _linkFocusNodes[index],
                                    context: context,
                                    controller: _linkControllers[index],
                                    hintText:
                                    'Enter ${_supportedLinks[_linkTypes[index]]!['name']} ${_supportedLinks[_linkTypes[index]]!['name'] == "Phone" ? 'Number' : _supportedLinks[_linkTypes[index]]!['name'] == "Email" ? "Id" : _supportedLinks[_linkTypes[index]]!['name'] == "Website" ? "URL" : "URL or ID"}',
                                    inputType:  _supportedLinks[_linkTypes[index]]!['name'] == "Phone"?TextInputType.phone:_supportedLinks[_linkTypes[index]]!['name'] == "Email" ?TextInputType.emailAddress:TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    fillColor: Colors.transparent,
                                    textBack: Colors.transparent,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsetsGeometry.all(0),
                                  icon: const Icon(Icons.delete,
                                      size: 20,

                                      color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      if (_linkCount >
                                          controller.links.length) {
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
                      Obx(
                        () => controller.isLoading.value
                            ? const Center(
                                child: CircularProgressIndicator(
                                color: Colors.black,
                              ))
                            : Padding(
                                padding: const EdgeInsets.only(
                                    left: 60.0, right: 60.0, top: 10),
                                child: CustomButton(
                                  buttonColor: MyColors.textBlack,
                                  textColor: MyColors.textWhite,
                                  text: "Go to your hub",
                                  onPressed: () async {
                                    bool hasEmpty = false;
                                    bool hasDuplicate = false;

                                    // Check for duplicates first
                                    for (int i = controller.links.length;
                                        i < _linkCount;
                                        i++) {
                                      final url =
                                          _linkControllers[i].text.trim();
                                      if (url.isNotEmpty) {
                                        // Check if this URL already exists in the user's links
                                        final existingLink = controller.links
                                            .any((link) =>
                                                link.url.toLowerCase() ==
                                                    url.toLowerCase() ||
                                                link.url.toLowerCase().contains(
                                                    url.toLowerCase()) ||
                                                url.toLowerCase().contains(
                                                    link.url.toLowerCase()));

                                        if (existingLink) {
                                          hasDuplicate = true;
                                          SnackbarUtil.showError(
                                              "Link '${_linkTypes[i]}' with URL '$url' already exists in your profile.");
                                          break;
                                        }
                                      }
                                    }

                                    if (hasDuplicate) return;

                                    // Loop backwards to safely remove empty links while iterating
                                    for (int i = _linkCount - 1;
                                        i >= controller.links.length;
                                        i--) {
                                      final url =
                                          _linkControllers[i].text.trim();

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
                                          url: url,
                                          call: () {
                                            Get.offAll(() => BottomNavScreen());
                                          },
                                        );
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
  void _showLinkSelector(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          height: screenHeight * 0.55,
          width: screenHeight * 0.22,// 👈 only 45% of screen
          child: Column(
            children: [
              // scrollable grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // 2 icons per row
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: 1.5, // proper circle shape
                  children: _supportedLinks.entries.map((entry) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _linkTypes[index] = entry.key;
                        });
                      },
                      child: Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            entry.value['icon'],
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // Custom Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // handle custom link
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.language, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Custom",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
