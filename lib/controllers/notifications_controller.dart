import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsController extends GetxController {
  var isLoading = true.obs;
  var isLoadingMore = false.obs;  // 🆕 bottom loader
  var notificationsList = <Map<String, dynamic>>[].obs;
  var unreadCount = 0.obs;

  // 🆕 Pagination variables
  int _currentPage = 1;
  int _lastPage = 1;
  bool get hasMore => _currentPage <= _lastPage;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // 🆕 Reset aur fresh load
  Future<void> refreshNotifications() async {
    _currentPage = 1;
    _lastPage = 1;
    notificationsList.clear();
    await fetchNotifications();
  }

  /// Fetch notifications with pagination
  Future<void> fetchNotifications() async {
    // Agar pehle se load ho raha hai ya aur data nahi toh return
    if (isLoadingMore.value) return;
    if (_currentPage > 1 && !hasMore) return;

    try {
      // Pehli page ke liye isLoading, baad ki pages ke liye isLoadingMore
      if (_currentPage == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Authentication Token not found.',
        );
        return;
      }

      // 🆕 Page aur per_page params add karo URL mein
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/v1/notifications?page=$_currentPage&per_page=10',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('Notifications API Status: ${response.statusCode}');
      log('Notifications API Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // 🆕 Pagination info save karo
        final pagination = responseData['pagination'];
        if (pagination != null) {
          _lastPage = pagination['last_page'] ?? 1;
        }

        // Notifications parse karo
        List<Map<String, dynamic>> newItems = [];
        if (responseData['data'] != null) {
          if (responseData['data'] is List) {
            newItems = List<Map<String, dynamic>>.from(responseData['data']);
          } else if (responseData['data']['data'] is List) {
            newItems = List<Map<String, dynamic>>.from(
              responseData['data']['data'],
            );
          }
        }

        // 🆕 Existing list mein append karo (replace mat karo)
        notificationsList.addAll(newItems);

        // 🆕 Next page ke liye increment
        _currentPage++;

        // Unread count update karo
        unreadCount.value = notificationsList.where((notification) {
          final isReadRaw =
              notification['data']?['is_read'] ?? notification['is_read'];
          return isReadRaw.toString() == '0';
        }).length;
      }
    } catch (e, st) {
      log('Error fetching notifications: $e', stackTrace: st);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Mark notification as read (same as before)
  Future<void> markAsRead(
      String notificationId,
      int? ptwId,
      String role,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);
      if (token == null) return;

      final response = await http.patch(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/v1/notifications/$notificationId/read',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (ptwId != null) {
          if (Get.isBottomSheetOpen ?? false) Get.close(1);
          Get.toNamed(
            AppRoutes.ptwReviewSdo,
            arguments: {'ptw_id': ptwId, 'role': role},
          );
        }
        Future.delayed(const Duration(milliseconds: 300), () {
          refreshNotifications(); // 🆕 refresh use karo
        });
      }
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }
}