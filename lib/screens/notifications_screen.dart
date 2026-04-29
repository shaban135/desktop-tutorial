import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/notifications_controller.dart';
import 'package:mepco_esafety_app/controllers/ptw_list_controller.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class NotificationsScreen extends StatefulWidget {  // 🆕 StatefulWidget
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsController controller;
  late ScrollController _scrollController; // 🆕

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationsController());

    // 🆕 Scroll listener — jab bottom pe pahunche toh aur load karo
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // List ke end se 200px pehle trigger
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!controller.isLoadingMore.value && controller.hasMore) {
          controller.fetchNotifications();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 🆕 Memory leak se bachao
    super.dispose();
  }

  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy EEEE hh:mm a').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainLayout(
        title: 'Notifications',
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: LoadingWidget());
          }

          if (controller.notificationsList.isEmpty) {
            return const Center(
              child: Text(
                'No notifications found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator( // 🆕 Pull to refresh
            onRefresh: controller.refreshNotifications,
            child: ListView.separated(
              controller: _scrollController, // 🆕 Scroll controller attach
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),

              // 🆕 +1 for loader at bottom
              itemCount: controller.notificationsList.length +
                  (controller.isLoadingMore.value ? 1 : 0),

              separatorBuilder: (context, index) =>
              const Divider(height: 30, color: Color(0xFFEEEEEE)),

              itemBuilder: (context, index) {
                // 🆕 Last item = loading spinner
                if (index == controller.notificationsList.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: LoadingWidget()),
                  );
                }

                final notification = controller.notificationsList[index];
                final message = notification['data']?['message'] ??
                    notification['message'] ??
                    'No message';
                final createdAt = notification['created_at'];
                final isReadRaw =
                    notification['data']?['is_read'] ?? notification['is_read'];
                final isRead = isReadRaw.toString() == '1';

                String formattedTime = '';
                if (createdAt != null) {
                  try {
                    final dt = DateTime.parse(createdAt).toLocal();
                    formattedTime =
                        DateFormat('dd MMM yyyy EEEE hh:mm a').format(dt);
                  } catch (e) {
                    formattedTime = createdAt.toString();
                  }
                }

                return InkWell(
                  onTap: () {
                    _showNotificationDetails(context, controller, notification);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: _buildNotificationItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    message: message,
                    time: formattedTime,
                    isRead: isRead,
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
  Widget _buildNotificationItem({
    required IconData icon,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: const BoxDecoration(
            color: Color(0xFF0D38AC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF333333),
                  fontWeight: isRead ? FontWeight.w400 : FontWeight.bold,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNotificationDetails(
      BuildContext context,
      NotificationsController controller,
      Map<String, dynamic> notification,
      ) {
    final data = notification['data'] as Map<String, dynamic>?;

    final message = data?['message'] ??
        notification['message'] ??
        'No message';

    final createdAt = notification['created_at'] ?? 'N/A';
    final ptwId = data?['ptw_code'] ?? notification['ptw_code'] ?? 'N/A';
    final notificationId = data?['id'] ?? notification['id'];
    final ptwController = Get.put(PtwListController());
    final role = ptwController.currentUserRole.value;
    final ptwIdInt = notification['ptw_id'];

    /// NEW: get is_read flag
    final isRead = notification['is_read'] == 1;

    debugPrint("is_read: $isRead");

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Notification Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 20),

            _buildDetailRow('PTW ID', '$ptwId'),
            const SizedBox(height: 12),

            _buildDetailRow('Date', formatDate(createdAt)),
            const SizedBox(height: 12),

            _buildDetailRow('Message', message),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF0D38AC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close',
                        style: TextStyle(color: Color(0xFF0D38AC))),
                  ),
                ),

                const SizedBox(width: 16),

                /// NEW: VIEW BUTTON ONLY IF is_read == 0
                //if (!isRead)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Mark as read
                        if (notificationId != null) {
                          try {
                            await controller.markAsRead(
                              notificationId.toString(),
                              ptwIdInt, role
                            );
                          } catch (e) {
                            debugPrint('Error: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D38AC),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }


  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF555555),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}
