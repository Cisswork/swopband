import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/view/network/ApiService.dart';
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

  late Worker _linksWorker;

  final Map<String, String> _platformImages = {
    'instagram': MyImages.insta,
    'music': MyImages.music,
    'reddit': MyImages.reddit,
    'linkedin': MyImages.linkedId,
    'twitter': MyImages.xmaster,
    'spotify': MyImages.spotify,
    'facebook': MyImages.facebook,
    'github': MyImages.github,
    'youtube': MyImages.youtube,
    'tinder': MyImages.tindi,
  };

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


  @override
  void initState() {
    super.initState();

    // Register 'ever' immediately
    _linksWorker = ever(controller.links, (_) {
      if (!mounted) return;

      _linkControllers.clear();
      _linkTypes.clear();

      for (var link in controller.links) {
        _linkControllers.add(TextEditingController(text: link.url));
        _linkTypes.add(link.type);
      }

      if (_linkControllers.isEmpty) {
        _linkControllers.add(TextEditingController());
        _linkTypes.add('spotify');
      }

      setState(() {
        _linkCount = _linkControllers.length;
      });
    });

    // Fetch after setting up 'ever'
    controller.fetchLinks();
  }

  @override
  void dispose() {
    _linksWorker.dispose();
    for (var controller in _linkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitLinks() async {
    // Validation: no empty, no duplicate type, no duplicate url
    final urls = <String>{};
    final types = <String>{};
    for (int i = 0; i < _linkControllers.length; i++) {
      final url = _linkControllers[i].text.trim();
      final type = _linkTypes[i];
      if (url.isEmpty || type.isEmpty) {
        SnackbarUtil.showError('Link type and URL cannot be empty.');
        return;
      }
      /*if (types.contains(type)) {
        SnackbarUtil.showError('Duplicate link type "$type" not allowed.');
        return;
      }
      if (urls.contains(url)) {
        SnackbarUtil.showError('Duplicate link URL "$url" not allowed.');
        return;
      }*/
      types.add(type);
      urls.add(url);
    }
    try {
      for (int i = 0; i < _linkControllers.length; i++) {
        await controller.createLink(
          name: _linkTypes[i],
          type: _linkTypes[i],
          url: _linkControllers[i].text.trim(),
        );
      }
      controller.fetchLinks(); // Refresh links after update
    } catch (e) {
      SnackbarUtil.showError('Failed to update links: ${e.toString()}');
    }
  }

  void _showEditDialog(int index) {
    final link = controller.links[index];
    final TextEditingController urlController = TextEditingController(text: link.url);
    String selectedType = link.type;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _supportedLinks.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Image.asset(entry.value['icon'], width: 24, height: 24),
                        SizedBox(width: 8),
                        Text(entry.value['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedType = newValue;
                  }
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            Obx(() => controller.isLoading.value
                ? CircularProgressIndicator()
                : TextButton(
                    onPressed: () async {
                      await controller.updateLink(
                        id: link.id,
                        type: selectedType,
                        url: urlController.text.trim(),
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildPlatformImage(String platform, bool isActive) {
    return Column(
      children: [
        ColorFiltered(
          colorFilter: isActive
              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
              : ColorFilter.mode(
            Colors.grey.withOpacity(0.5),
            BlendMode.saturation,
          ),
          child: Image.asset(
            _platformImages[platform] ?? MyImages.insta,
            width: 40,
            height: 40,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.textWhite,
      body: SafeArea(
        child: Obx(() => controller.fetchLinkLoader.value
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
                        Text(
                          AppStrings.editLinks.tr,
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
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildPlatformImage('instagram',
                                      controller.links.any((link) => link.type == 'instagram')),
                                  _buildPlatformImage('music',
                                      controller.links.any((link) => link.type == 'music')),
                                  _buildPlatformImage('reddit',
                                      controller.links.any((link) => link.type == 'reddit')),
                                  _buildPlatformImage('linkedin',
                                      controller.links.any((link) => link.type == 'linkedin')),
                                  _buildPlatformImage('twitter',
                                      controller.links.any((link) => link.type == 'twitter')),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildPlatformImage('spotify',
                                      controller.links.any((link) => link.type == 'spotify')),
                                  _buildPlatformImage('facebook',
                                      controller.links.any((link) => link.type == 'facebook')),
                                  _buildPlatformImage('github',
                                      controller.links.any((link) => link.type == 'github')),
                                  _buildPlatformImage('youtube',
                                      controller.links.any((link) => link.type == 'youtube')),
                                  _buildPlatformImage('tinder',controller.links.any((link) => link.type == 'tinder')),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                AppStrings.supportedLinks.tr,
                                style: AppTextStyles.extraLarge.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Readonly fields for API-fetched links
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
                                      _showEditDialog(index);
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
                        // Editable fields for new links
                        ...List.generate(
                          (_linkCount - controller.links.length).clamp(0, _linkCount),
                          (i) {
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
                                  // Only submit new (editable) links
                                  for (int i = controller.links.length; i < _linkCount; i++) {
                                    await controller.createLink(
                                      name: _linkTypes[i],
                                      type: _linkTypes[i],
                                      url: _linkControllers[i].text.trim(),
                                    );
                                  }
                                  controller.fetchLinks();
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