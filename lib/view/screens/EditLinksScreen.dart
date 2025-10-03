import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swopband/controller/user_controller/UserController.dart';
import 'package:swopband/view/network/ApiService.dart';
import 'package:swopband/view/utils/app_constants.dart';
import 'package:swopband/view/utils/shared_pref/SharedPrefHelper.dart';
import 'package:swopband/view/widgets/custom_button.dart';
import 'package:swopband/view/widgets/custom_textfield.dart';
import 'package:swopband/view/widgets/custom_snackbar.dart';
import '../../controller/link_controller/LinkController.dart';
import '../utils/images/iamges.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_colors.dart';
import '../translations/app_strings.dart';

class EditLinksScreen extends StatefulWidget {
  const EditLinksScreen({super.key});

  @override
  State<EditLinksScreen> createState() => _EditLinksScreenState();
}

class _EditLinksScreenState extends State<EditLinksScreen> {
  final List<TextEditingController> _linkControllers = [];
  final List<String> _linkTypes = [];
  int _linkCount = 0;
  final controller = Get.put(LinkController());
  final userController = Get.put(UserController());

  late Worker _linksWorker;
  String imageUrl = "";

  // Method to launch URLs
  Future<void> _launchUrl(String url) async {
    try {
      // Ensure URL has proper scheme
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(finalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        SnackbarUtil.showError('Could not launch $finalUrl');
      }
    } catch (e) {
      SnackbarUtil.showError('Error launching URL: $e');
    }
  }

  final Map<String, String> _platformImages = {
    'instagram': MyImages.insta,
    'snapchat': MyImages.tiktok,
    'linkedin': MyImages.snapchat,
    'x': MyImages.linkedId,
    'spotify': MyImages.xmaster,
    'facebook': MyImages.spotify,
    'strava': MyImages.facebook,
    'youtube': MyImages.strava,
    'tiktok': MyImages.youtube,
    'discord': MyImages.discord,
  };

  final Map<String, Map<String, dynamic>> _supportedLinks = {
    'instagram': {'name': 'Instagram', 'icon': MyImages.insta},
    'snapchat': {'name': 'Snapchat', 'icon': MyImages.snapchat},
    'linkedin': {'name': 'LinkedIn', 'icon': MyImages.linkedId},
    'x': {'name': 'Twitter', 'icon': MyImages.xmaster},
    // Changed from 'twitter' to 'x'
    'spotify': {'name': 'Spotify', 'icon': MyImages.spotify},
    'facebook': {'name': 'Facebook', 'icon': MyImages.facebook},
    'strava': {'name': 'Strava', 'icon': MyImages.strava},
    'youtube': {'name': 'YouTube', 'icon': MyImages.youtube},
    'tiktok': {'name': 'TikTok', 'icon': MyImages.tiktok},
    'discord': {'name': 'Discord', 'icon': MyImages.discord},
     // 'custom': {'name': 'Website', 'icon': MyImages.website},
    'phone': {'name': 'Phone', 'icon': MyImages.phone},
    // Added Website
    'email': {'name': 'Email', 'icon': MyImages.email},
    // A
  };  final Map<String, Map<String, dynamic>> _supportedLinksReadOnly = {
    'instagram': {'name': 'Instagram', 'icon': MyImages.insta},
    'snapchat': {'name': 'Snapchat', 'icon': MyImages.snapchat},
    'linkedin': {'name': 'LinkedIn', 'icon': MyImages.linkedId},
    'x': {'name': 'Twitter', 'icon': MyImages.xmaster},
    // Changed from 'twitter' to 'x'
    'spotify': {'name': 'Spotify', 'icon': MyImages.spotify},
    'facebook': {'name': 'Facebook', 'icon': MyImages.facebook},
    'strava': {'name': 'Strava', 'icon': MyImages.strava},
    'youtube': {'name': 'YouTube', 'icon': MyImages.youtube},
    'tiktok': {'name': 'TikTok', 'icon': MyImages.tiktok},
    'discord': {'name': 'Discord', 'icon': MyImages.discord},
    'custom': {'name': 'Website', 'icon': MyImages.website},
    'phone': {'name': 'Phone', 'icon': MyImages.phone},
    // Added Website
    'email': {'name': 'Email', 'icon': MyImages.email},
    // A
  };

  @override
  void initState() {
    super.initState();
    _checkAuth();
    // Register 'ever' immediately
    _linksWorker = ever(controller.links, (_) {
      if (!mounted) return;

      _linkControllers.clear();
      _linkTypes.clear();

      for (var link in controller.links) {
        _linkControllers.add(TextEditingController(text: link.url));
        _linkTypes.add(link.type);
      }

      // Clean up any invalid link types for new additions
      for (int i = 0; i < _linkTypes.length; i++) {
        if (i >= controller.links.length) {
          // Only check new links, not existing ones
          if (!_supportedLinksReadOnly.containsKey(_linkTypes[i])) {
            _linkTypes[i] = 'instagram';
          }
        }
      }

      if (_linkControllers.isEmpty) {
        _linkControllers.add(TextEditingController());
        _linkTypes.add('instagram');
      }

      setState(() {
        _linkCount = _linkControllers.length;
      });
    });

    // Fetch after setting up 'ever'
    controller.fetchLinks();
  }

  Future<void> _checkAuth() async {
    final firebaseId = await SharedPrefService.getString('firebase_id');
    final backendUserId = await SharedPrefService.getString('backend_user_id');
    log("firebaseId  : $firebaseId");

    if (firebaseId != null && firebaseId.isNotEmpty) {
      await userController.fetchUserByFirebaseId(firebaseId);
      imageUrl = sanitizeProfileUrl(AppConst.USER_PROFILE as String?);
    }
  }

  String sanitizeProfileUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (kIsWeb && url.startsWith('http://profile.swopband.com')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  @override
  void dispose() {
    _linksWorker.dispose();
    for (var controller in _linkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

/*
  void _showEditDialog(int index) {
    final link = controller.links[index];
    final TextEditingController urlController = TextEditingController(text: link.url);
    String selectedType = link.type;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _showLinkSelector(context, index),
                  child: Row(
                    children: [
                      Image.asset(
                        _linkTypes[index] == 'custom'
                            ? MyImages.website
                            : _supportedLinks[_linkTypes[index]]!['icon'],
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 6),

                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),

              // DropdownButtonFormField<String>(
              //   value: selectedType,
              //   isExpanded: true,
              //   decoration: const InputDecoration(
              //     border: OutlineInputBorder(),
              //   ),
              //   // Show only icon in selected item
              //   selectedItemBuilder: (BuildContext context) {
              //     return _supportedLinksReadOnly.entries.map((entry) {
              //       return Container(
              //         alignment: Alignment.center,
              //         child: Image.asset(
              //           entry.value['icon'],
              //           width: 24,
              //           height: 24,
              //         ),
              //       );
              //     }).toList();
              //   },
              //   items: _supportedLinks.entries.map((entry) {
              //     return DropdownMenuItem<String>(
              //       value: entry.key,
              //       child: Row(
              //         children: [
              //           Image.asset(entry.value['icon'], width: 24, height: 24),
              //           const SizedBox(width: 8),
              //           Text(entry.value['name']),
              //         ],
              //       ),
              //     );
              //   }).toList(),
              //   onChanged: (String? newValue) {
              //     if (newValue != null) {
              //       selectedType = newValue;
              //     }
              //   },
              // ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: () async {
                      await controller.updateLink(
                        id: link.id,
                        type: selectedType,
                        url: urlController.text.trim(),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  )),
          ],
        );
      },
    );
  }
*/

  void _showEditDialog(int index) {
    final link = controller.links[index];
    final TextEditingController urlController = TextEditingController(text: link.url);

    // use the same list _linkTypes
    String selectedType = _linkTypes[index];

    if (!_supportedLinks.containsKey(selectedType) && selectedType != 'custom') {
      selectedType = 'instagram'; // fallback
      _linkTypes[index] = selectedType;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final linkName = selectedType == 'custom'
                ? 'Website'
                : _supportedLinks[selectedType]!['name'];
            final linkIcon = selectedType == 'custom'
                ? MyImages.website
                : _supportedLinks[selectedType]!['icon'];

            return AlertDialog(
                  backgroundColor: MyColors.backgroundColor,

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Edit Link'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showLinkSelectorEdit(context, index, (newType) {
                            setStateDialog(() {
                              selectedType = newType;       // <- yaha local update
                              _linkTypes[index] = newType;  // <- list bhi update
                            });
                          });
                        },
                        child: Row(
                          children: [
                            Image.asset(linkIcon, width: 40, height: 40),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                            labelText:
                            'Enter $linkName ${linkName == "Phone" ? "Number" : linkName == "Email" ? "Id" : "URL"}',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType:TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Obx(() => controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : TextButton(
                  onPressed: () async {
                    await controller.updateLink(
                      id: link.id,
                      type: _linkTypes[index], // <-- abhi ka updated type
                      url: urlController.text.trim(),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                )),
              ],
            );
          },
        );
      },
    );
  }

  /// update showLinkSelector to accept callback
  void _showLinkSelectorEdit(BuildContext context, int index, Function(String)? onSelected) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(5),
              width: screenWidth * 0.35,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 1.2,
                      children: _supportedLinks.entries.map((entry) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _linkTypes[index] = entry.key;
                            });
                            if (onSelected != null) onSelected(entry.key);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              entry.value['icon'],
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _linkTypes[index] = 'custom';
                      });
                      if (onSelected != null) onSelected('custom');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.language, color: Colors.white, size: 30),
                          SizedBox(width: 6),
                          Text(
                            "Custom",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }




  Widget _buildPlatformImage(String platform, bool isActive) {
    return Image.asset(
      _platformImages[platform] ?? MyImages.insta,
      width: 50,
      height: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: SafeArea(
        child: Obx(
          () => controller.fetchLinkLoader.value
              ? const Center(child: CircularProgressIndicator())
              : Align(
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

                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.editLinks.tr,
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
                                  style: AppTextStyles.medium.copyWith(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildPlatformImage(
                                        'instagram',
                                        controller.links.any((link) =>
                                            link.type == 'instagram')),
                                    _buildPlatformImage(
                                        'snapchat',
                                        controller.links.any(
                                            (link) => link.type == 'snapchat')),
                                    _buildPlatformImage(
                                        'linkedin',
                                        controller.links.any(
                                            (link) => link.type == 'linkedin')),
                                    _buildPlatformImage(
                                        'x',
                                        controller.links
                                            .any((link) => link.type == 'x')),
                                    _buildPlatformImage(
                                        'spotify',
                                        controller.links.any(
                                            (link) => link.type == 'spotify')),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildPlatformImage(
                                        'facebook',
                                        controller.links.any(
                                            (link) => link.type == 'facebook')),
                                    _buildPlatformImage(
                                        'strava',
                                        controller.links.any(
                                            (link) => link.type == 'strava')),
                                    _buildPlatformImage(
                                        'youtube',
                                        controller.links.any(
                                            (link) => link.type == 'youtube')),
                                    _buildPlatformImage(
                                        'tiktok',
                                        controller.links.any(
                                            (link) => link.type == 'tiktok')),
                                    _buildPlatformImage(
                                        'discord',
                                        controller.links.any(
                                            (link) => link.type == 'discord')),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  AppStrings.supportedLinks.tr,
                                  style: AppTextStyles.extraLarge.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Readonly fields for API-fetched links
                          ...List.generate(
                              controller.links.length,
                              (index) => Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child:
                                                DropdownButtonFormField<String>(
                                                  isExpanded: true,
                                                  isDense: false,
                                                  itemHeight: null,
                                              iconEnabledColor: Colors.black,
                                              iconDisabledColor: Colors.black,
                                              value:
                                                  controller.links[index].type,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                focusedErrorBorder:
                                                    InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                contentPadding: EdgeInsets.zero,
                                              ),

                                              // Show only icon in selected item
                                              selectedItemBuilder:
                                                  (BuildContext context) {
                                                return _supportedLinksReadOnly.entries
                                                    .map((entry) {
                                                  return SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Image.asset(
                                                      entry.value['icon'],

                                                    ),
                                                  );
                                                }).toList();
                                              },
                                              items: _supportedLinksReadOnly.entries
                                                  .map((entry) {
                                                return DropdownMenuItem<String>(
                                                  value: entry.key,
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
                                              }).toList(),
                                              onChanged: null, // readonly
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 7,
                                            child: GestureDetector(
                                              onTap: () => _launchUrl(
                                                  controller.links[index].url),
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    left: 7,
                                                    right: 0,
                                                    top: 0,
                                                    bottom: 0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        controller
                                                            .links[index].url,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    PopupMenuButton<String>(
                                                        color: Colors.white,
                                                        icon: const Icon(
                                                          Icons.more_vert,
                                                          color: Colors.black,
                                                          size: 20,
                                                          weight: 10,
                                                        ),
                                                        onSelected: (String
                                                            value) async {
                                                          final link =
                                                              controller
                                                                  .links[index];
                                                          if (value == 'edit') {
                                                            _showEditDialog(
                                                                index);
                                                          } else if (value ==
                                                              'delete') {
                                                            await controller
                                                                .deleteLink(
                                                                    link.id);
                                                          }
                                                        },
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context) =>
                                                                [
                                                                  const PopupMenuItem<
                                                                      String>(
                                                                    value:
                                                                        'edit',
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .edit,
                                                                          color:
                                                                              Colors.black,
                                                                          size:
                                                                              17,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                8),
                                                                        Text(
                                                                            'Edit'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const PopupMenuItem<
                                                                      String>(
                                                                    value:
                                                                        'delete',
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .delete,
                                                                            color:
                                                                                Colors.black),
                                                                        SizedBox(
                                                                            width:
                                                                                8),
                                                                        Text(
                                                                            'Delete'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ]),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  )),
                          // Editable fields for new links
                          ...List.generate(
                            (_linkCount - controller.links.length)
                                .clamp(0, _linkCount),
                            (i) {
                              final index = controller.links.length + i;
                              final linkType = _linkTypes[index];

                              final linkName = linkType == 'custom' ? 'Website' : _supportedLinks[linkType]!['name'];
                              final linkIcon = linkType == 'custom' ? MyImages.website : _supportedLinks[linkType]!['icon'];
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                    /*  Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<String>(
                                          iconEnabledColor: Colors.black,
                                          value: _supportedLinks.entries.any(
                                                  (entry) =>
                                                      entry.key ==
                                                      _linkTypes[index])
                                              ? _linkTypes[index]
                                              : 'instagram',
                                          // Fallback to 'instagram' if current value is not available
                                          isExpanded: true,
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
                                          // Show only icon in selected item
                                          selectedItemBuilder:
                                              (BuildContext context) {
                                            return _supportedLinks.entries
                                                .map((entry) {
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
                                          items: _supportedLinks.entries
                                              .map((entry) {
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
                                            if (newValue != null) {
                                              setState(() {
                                                _linkTypes[index] = newValue;
                                              });
                                            }
                                          },
                                        ),
                                      ),*/
                                      Expanded(
                                        flex: 2,
                                        child: GestureDetector(
                                          onTap: () => _showLinkSelector(context, index),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                linkIcon,
                                                width: 40,
                                                height: 40,
                                              ),
                                              const SizedBox(width: 6),

                                              const Icon(Icons.arrow_drop_down, size: 20),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 6,
                                        child: myFieldAdvance(

                                          context: context,
                                          controller: _linkControllers[index],
                                          hintText: 'Enter $linkName ${linkName == "Phone" ? "Number" : linkName == "Email" ? "Id" : "URL"}',
                                          inputType:  TextInputType.text,     textInputAction: index <
                                                  _linkControllers.length - 1
                                              ? TextInputAction.next
                                              : TextInputAction.done,
                                          fillColor: Colors.transparent,
                                          textBack: Colors.transparent,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            size: 20,
                                            color: Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            if (_linkCount >
                                                controller.links.length) {
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
                          CustomButton(
                            buttonColor: MyColors.textBlack,
                            textColor: MyColors.textWhite,
                            text: AppStrings.addAnotherLink.tr,
                            onPressed: () {
                              setState(() {
                                _linkControllers.add(TextEditingController());
                                _linkTypes.add('instagram');
                                _linkCount++;
                              });
                            },
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
                                        text: AppStrings.apply.tr,
                                        onPressed: () async {
                                          bool hasEmpty = false;

                                          // Loop backwards to safely remove empty links while iterating
                                          for (int i = _linkCount - 1;
                                              i >= controller.links.length;
                                              i--) {
                                            final url =
                                                _linkControllers[i].text.trim();

                                            if (url.isEmpty) {
                                              _linkControllers.removeAt(i);
                                              _linkTypes.removeAt(i);
                                              _linkCount--;
                                              hasEmpty = true;
                                            } else {
                                              log("body---->");

                                              // Create the link if not empty
                                              await controller.createLink(
                                                name: _linkTypes[i],
                                                type: _linkTypes[i],
                                                url: url,
                                                call: () {},
                                              );
                                            }
                                          }
                                          controller.fetchLinks();
                                        },
                                      ),
                                    ),
                            ),
                          const SizedBox(height: 80)
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
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(5),
              width: screenWidth * 0.35,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 1.2,
                      children: _supportedLinks.entries.map((entry) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _linkTypes[index] = entry.key;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              entry.value['icon'],
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _linkTypes[index] = 'custom';
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.language, color: Colors.white, size: 30),
                          SizedBox(width: 6),
                          Text(
                            "Custom",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}