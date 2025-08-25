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
  final List<String> _linkTypes = ['custom']; // Default first link type - changed from 'spotify' to 'custom'
  int _linkCount = 1;

  // Supported link types with their display names and icons
  final Map<String, Map<String, dynamic>> _supportedLinks = {
    'instagram': {'name': 'Instagram', 'icon': MyImages.insta},
    'custom': {'name': 'Music', 'icon': MyImages.music}, // Changed from 'music' to 'custom'
    'reddit': {'name': 'Reddit', 'icon': MyImages.reddit},
    'linkedin': {'name': 'LinkedIn', 'icon': MyImages.linkedId},
    'x': {'name': 'Twitter', 'icon': MyImages.xmaster}, // Changed from 'twitter' to 'x'
    'spotify': {'name': 'Spotify', 'icon': MyImages.spotify},
    'facebook': {'name': 'Facebook', 'icon': MyImages.facebook},
    'github': {'name': 'GitHub', 'icon': MyImages.github},
    'youtube': {'name': 'YouTube', 'icon': MyImages.youtube},
    'tiktok': {'name': 'TikTok', 'icon': MyImages.tiktok}, // Added TikTok
    'discord': {'name': 'Discord', 'icon': MyImages.discord}, // Added Discord
    'dribble': {'name': 'Dribbble', 'icon': MyImages.dribble}, // Added Dribbble
    'website': {'name': 'Website', 'icon': MyImages.website}, // Added Website
  };

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
        _linkTypes.add('custom'); // Changed from 'spotify' to 'custom'
        _linkControllers.clear();
        _linkControllers.add(TextEditingController());
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
                                  Icon(Icons.link, color: Colors.green, size: 20),
                                  SizedBox(width: 8),
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
                              SizedBox(height: 8),
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
                        SizedBox(height: 16),
                      ],
                      
                      /*..._linkControllers.asMap().entries.map((entry) {
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
                     controller.isLoading.value?
                     Center(child: CircularProgressIndicator(color: Colors.black,)):
                     Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonColor: MyColors.textBlack,
                          textColor: MyColors.textWhite,
                          text: AppStrings.goToHub.tr,
                          onPressed: _submitLinks,
                        ),
                      ),*/

                      ...List.generate(controller.links.length, (index) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: DropdownButtonFormField<String>(
                                  value: controller.links[index].type,
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
                                  onChanged: null, // readonly
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 7,
                                child: TextField(
                                  controller: TextEditingController(text: controller.links[index].url),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: 'Enter ${_supportedLinks[controller.links[index].type]!['name']} URL or ID',
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
                                ),
                              ),
                              PopupMenuButton<String>(
                                  color: Colors.white,
                                  icon: Icon(Icons.more_vert, color: Colors.black,size: 17),
                                  onSelected: (String value) async {
                                    final link = controller.links[index];
                                    if (value == 'edit') {
                                      //_showEditDialog(index);
                                    } else if (value == 'delete') {
                                      await controller.deleteLink(link.id);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.black,size: 17,),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
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
                          const SizedBox(height: 20),
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
                                  Icon(Icons.add_circle, color: Colors.blue, size: 20),
                                  SizedBox(width: 8),
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
                              SizedBox(height: 8),
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
                        SizedBox(height: 16),
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
                                    controller: _linkControllers[index],
                                    hintText: 'Enter ${_supportedLinks[_linkTypes[index]]!['name']} URL or ID',
                                    inputType: TextInputType.text,
                                    textInputAction: index < _linkControllers.length - 1
                                        ? TextInputAction.next
                                        : TextInputAction.done,
                                    fillColor: Colors.transparent,
                                    textBack: Colors.transparent,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      if (_linkCount > controller.links.length) {
                                        _linkControllers.removeAt(index);
                                        _linkTypes.removeAt(index);
                                        _linkCount--;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonColor: MyColors.textBlack,
                          textColor: MyColors.textWhite,
                          text: AppStrings.addAnotherLink.tr,
                          onPressed: () {
                            setState(() {
                              _linkControllers.add(TextEditingController());
                              _linkTypes.add('spotify');
                              _linkCount++;
                            });
                          },
                        ),
                      ),
                      if (_linkCount > controller.links.length)
                        Obx(() => controller.isLoading.value?
                        Center(child: CircularProgressIndicator(color: Colors.black,)):
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomButton(
                            buttonColor: MyColors.textBlack,
                            textColor: MyColors.textWhite,
                            text: AppStrings.apply.tr,
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
        ],
      ),
    );
  }
}