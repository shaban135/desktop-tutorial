import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/controllers/notifications_controller.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  Future<void> _handleProfileTap() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(StorageKeys.userData);

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      final List<dynamic> permissions = userData['permissions'] ?? [];

      if (permissions.contains('users.view.self')) {
        onItemTapped(4);
        Get.toNamed(AppRoutes.profile);
      } else {
        Get.snackbar(
          'Permission Denied',
          'You do not have permission to view this page.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar('Error', 'User data not found.');
    }
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: bottomInset,
          child: Container(color: Colors.white),
        ),

        SafeArea(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _buildAppBar(),
              Positioned(
                top: -30,
                child: _buildFab(context),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildAppBar() {
    const unselectedColor = Color(0xFFa0a8b1);
    const selectedColor = Color(0xFF0D38AC);

    final notificationController = Get.find<NotificationsController>();

    return Container(
      height: 60,
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.format_list_bulleted,
                color: selectedIndex == 0 ? selectedColor : unselectedColor,
              ),
              onPressed: () {
                onItemTapped(0);
                Get.toNamed(AppRoutes.ptwList);
                // Get.toNamed(AppRoutes.listBulletedIcon);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person_outline,
                color: selectedIndex == 4 ? selectedColor : unselectedColor,
              ),
              onPressed: _handleProfileTap,
            ),

            const SizedBox(width: 48), // gap for FAB

            // -------------------------
            // 🔔 Notifications with Badge
            // -------------------------
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: selectedIndex == 3 ? selectedColor : unselectedColor,
                  ),
                  onPressed: () {
                    onItemTapped(3);
                    //Open the screen WITHOUT waiting
                    Get.toNamed(AppRoutes.notifications);
                    //Fetch the notifications in background
                    notificationController.fetchNotifications();
                  },
                ),

                //Badge
                Positioned(
                  right: 5,
                  top: 0,
                  child: Obx(() {
                    final count = notificationController.unreadCount.value;

                    if (count == 0) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: selectedIndex == 1 ? selectedColor : unselectedColor,
              ),
              onPressed: () {
                onItemTapped(0);
                // Get.toNamed(AppRoutes.ptwList);
                Get.toNamed(AppRoutes.listBulletedIcon);
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFab(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // White background circle with shadow
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, -1),
              ),
            ],
          ),
        ),
        // The FAB Container
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF002171),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D47A1).withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              onItemTapped(2);
              Get.offAllNamed(AppRoutes.home);

            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.home, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }
}
