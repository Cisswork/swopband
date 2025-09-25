import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/images/iamges.dart';
import '../translations/app_strings.dart';
import '../../controller/recent_swoppers_controller/RecentSwoppersController.dart';
import '../../model/RecentSwoppersModel.dart';
import 'swopband_webview_screen.dart';
import 'package:flutter/foundation.dart';

class RecentSwoppersScreen extends StatefulWidget {
  const RecentSwoppersScreen({super.key});

  @override
  State<RecentSwoppersScreen> createState() => _RecentSwoppersScreenState();
}

class _RecentSwoppersScreenState extends State<RecentSwoppersScreen> {
  final RecentSwoppersController controller = Get.put(RecentSwoppersController());
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredSwoppers = [];

  @override
  void initState() {
    super.initState();
    // Initialize filtered list with all swoppers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _filteredSwoppers = controller.recentSwoppers;
      });
    });
    
    // Listen to changes in the controller's recentSwoppers list
    ever(controller.recentSwoppers, (List<User> swoppers) {
      if (mounted) {
        setState(() {
          _filteredSwoppers = swoppers;
        });
        log("🔄 RecentSwoppersScreen: Updated filtered list with ${swoppers.length} connections");
      }
    });
  }

  @override
  void dispose() {
    // Clean up the GetX listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40,),
            Text(
              controller.connectionCount.toString(),
              style: AppTextStyles.large.copyWith(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: MyColors.textBlack,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Connections",
                  style: AppTextStyles.large.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: MyColors.textBlack,
                  ),
                ),
                SizedBox(width: 3,),

                CircleAvatar(radius: 15,backgroundColor: Colors.grey.shade300,)
              ],
            ),


            SizedBox(height: 15),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(

                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _filteredSwoppers = controller.recentSwoppers;
                      } else {
                        _filteredSwoppers = controller.recentSwoppers.where((swopper) => swopper.name.toLowerCase().contains(value.toLowerCase())
                            || swopper.username.toLowerCase().contains(value.toLowerCase())).toList();
                      }
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search Connections',
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),

            SizedBox(height: 8),



            Expanded(
              child: Obx(() {
                // Compute visible list based on current search text to avoid stale state
                final String query = _searchController.text.trim().toLowerCase();
                final List<User> visible = query.isEmpty
                    ? controller.recentSwoppers
                    : controller.recentSwoppers.where((swopper) =>
                        swopper.name.toLowerCase().contains(query) ||
                        swopper.username.toLowerCase().contains(query)
                      ).toList();
                if (controller.fetchRecentSwoppersLoader.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: MyColors.textBlack,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading connections...',
                          style: AppTextStyles.medium.copyWith(
                            color: MyColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.recentSwoppers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.nfc,
                          size: 64,
                          color: MyColors.textDisabledColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No NFC connections yet',
                          style: AppTextStyles.medium.copyWith(
                            color: MyColors.textDisabledColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'When someone touches their NFC ring to your device,\n they will appear here automatically',
                          style: AppTextStyles.small.copyWith(
                            color: MyColors.textDisabledColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        // Container(
                        //   padding: EdgeInsets.all(16),
                        //   decoration: BoxDecoration(
                        //     color: Colors.blue.withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        //   ),
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        //       SizedBox(width: 8),
                        //       Text(
                        //         'NFC is active and listening',
                        //         style: TextStyle(
                        //           color: Colors.blue,
                        //           fontWeight: FontWeight.w600,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  );
                }


                return RefreshIndicator(
                  onRefresh: () => controller.fetchRecentSwoppers(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: visible.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final user = visible[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: MyColors.textBlack,
                            borderRadius: BorderRadius.circular(40),

                          ),
                          child: ListTile(
                            // contentPadding: EdgeInsetsGeometry.all(3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)
                            ),
                            selectedTileColor: Colors.orange[100],
                            onTap: () {
                              // Navigate to the user's profile
                              Get.to(() => SwopbandWebViewScreen(
                                username: user.username,
                                url: '',
                              ));
                            },
                            onLongPress: () {
                              _showUserOptions(user);
                            },
                            leading:
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: MyColors.textBlack,
                                  backgroundImage: user.profileUrl != null && user.profileUrl!.isNotEmpty
                                      ? NetworkImage(user.profileUrl!)
                                      : null,
                                  child: user.profileUrl == null || user.profileUrl!.isEmpty
                                      ? Image.asset(
                                          MyImages.profileImage,
                                        )
                                      : null,
                                ),


                            title: Text(
                              user.name,
                              style: AppTextStyles.medium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: MyColors.textWhite,
                              ),
                            ),
                            subtitle: Text(
                              '@${user.username}',
                              style: AppTextStyles.small.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(left: 8),
                            trailing:
                                                           const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 35,
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Colors.black,
                                    size: 28,
                                  ),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickConnectDialog() {
    _usernameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Connect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter username to connect instantly:'),
            SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'e.g., ranga013',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              autofocus: true,
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  await _connectWithUsername(value.trim());
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = _usernameController.text.trim();
              if (username.isNotEmpty) {
                Navigator.of(context).pop();
                await _connectWithUsername(username);
              }
            },
            child: Text('Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectWithUsername(String username) async {
    try {
      // Show loading dialog
      Get.dialog(
        AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating connection...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Create connection
      final success = await controller.createConnection(username);
      
      // Close loading dialog
      Get.back();

      if (success) {
        Get.snackbar(
          'Success',
          'Connected with @$username',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Failed',
          'Could not connect with @$username',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to connect: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showUserOptions(User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text(
                'View Profile',
                style: AppTextStyles.medium.copyWith(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => SwopbandWebViewScreen(
                  username: user.username,
                  url: '',
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Remove Connection',
                style: AppTextStyles.medium.copyWith(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showRemoveConfirmation(user);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Connection'),
        content: Text('Are you sure you want to remove @${user.username} from your connections?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (user.connectionId != null) {
                controller.removeConnection(user.connectionId!);
                Get.snackbar(
                  'Removed',
                  'Connection with @${user.username} removed',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Connection ID not found',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(String updatedAt) {
    try {
      final DateTime updatedDate = DateTime.parse(updatedAt);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(updatedDate);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
