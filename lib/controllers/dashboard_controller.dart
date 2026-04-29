

// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:mepco_esafety_app/constants/api_constants.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../constants/storage_keys.dart';
// import '../models/ptw_card_data.dart';
//
// class HomeController extends GetxController {
//   var isLoading = true.obs;
//   var totalPtws = '0'.obs;
//   var activePtws = '0'.obs;
//   var closedPtws = '0'.obs;
//   var cancelledPtws = '0'.obs;
//   var ptwList = <PtwCardData>[].obs;
//   var isSelfSelected = true.obs;
//   var selectedIndex = 0.obs;
//
//   // Filter variables
//   var selectedFilterType = 'all_times'.obs;
//   var startDate = Rx<DateTime?>(null);
//   var endDate = Rx<DateTime?>(null);
//
//   // 🆕 NEW FEATURES
//   // What's New Section
//   var recentActivities = <ActivityItem>[].obs;
//   var showWhatsNew = true.obs;
//   var draftsCount = 0.obs;
//   var pendingTasksCount = 0.obs;
//
//   // Insights Carousel
//   var currentInsightIndex = 0.obs;
//   var weeklyTrends = <FlSpot>[].obs;
//   var slaMetrics = <String, int>{}.obs;
//   var performanceMetrics = <String, dynamic>{}.obs;
//
//   // Search
//   var searchQuery = ''.obs;
//   var filteredPtwList = <PtwCardData>[].obs;
//
//   // View Mode
//   var isGridView = true.obs;
//
//   var user = {}.obs;
//   final currentUserRole = ''.obs;
//
//   List<PtwCardData> get mainPtws {
//     if (ptwList.length <= 4) return [];
//     return ptwList.sublist(4);
//   }
//
//   void onItemTapped(int index) {
//     selectedIndex.value = index;
//     if (index != 0) {
//       fetchDashboard();
//     }
//   }
//
//   // 🆕 TOGGLE VIEW MODE
//   void toggleViewMode() {
//     isGridView.value = !isGridView.value;
//   }
//
//   // 🆕 TOGGLE WHAT'S NEW SECTION
//   void toggleWhatsNew() {
//     showWhatsNew.value = !showWhatsNew.value;
//   }
//
//   // 🆕 DISMISS ACTIVITY
//   void dismissActivity(ActivityItem activity) {
//     recentActivities.remove(activity);
//   }
//
//   // 🆕 SEARCH PTWs
//   void searchPTWs(String query) {
//     searchQuery.value = query;
//     if (query.isEmpty) {
//       filteredPtwList.value = ptwList;
//     } else {
//       filteredPtwList.value = ptwList.where((ptw) {
//         return ptw.ptwId.toLowerCase().contains(query.toLowerCase()) ||
//             ptw.feeder.toLowerCase().contains(query.toLowerCase()) ||
//             ptw.status.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     }
//   }
//
//   // 🆕 CLEAR SEARCH
//   void clearSearch() {
//     searchQuery.value = '';
//     filteredPtwList.value = ptwList;
//   }
//
//   // Generate FCM token and send it to Laravel backend
//   Future<void> _generateFCMTokenAndSendToBackend() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     String? fcmToken = await messaging.getToken();
//
//     if (fcmToken != null) {
//       await _sendTokenToBackend(fcmToken);
//     }
//   }
//
//   Future<void> _sendTokenToBackend(String token) async {
//     final String apiUrl = '${ApiConstants.baseUrl}/api/device-token';
//     final prefs = await SharedPreferences.getInstance();
//     final authToken = prefs.getString(StorageKeys.authToken);
//
//     if (authToken == null) {
//       return;
//     }
//
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {
//         'Authorization': 'Bearer $authToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'token': token,
//         'device_type': Platform.isAndroid ? 'android' : 'ios',
//         'platform': 'flutter',
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       log("FCM Token sent successfully");
//     } else {
//       log("Failed to send FCM token: ${response.body}");
//     }
//   }
//
//   Future<void> loadUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userData = prefs.getString(StorageKeys.userData);
//     if (userData != null) {
//       user.value = jsonDecode(userData);
//     }
//   }
//
//   Future<void> loadUserRole() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userDataString = prefs.getString(StorageKeys.userData);
//
//       if (userDataString != null) {
//         final userData = jsonDecode(userDataString);
//         dynamic roleData = userData['role'] ?? userData['roles'];
//         String role;
//
//         if (roleData is List && roleData.isNotEmpty) {
//           role = roleData.first.toString();
//         } else if (roleData is String) {
//           role = roleData;
//         } else {
//           role = 'SDO';
//         }
//
//         currentUserRole.value = role.toUpperCase();
//       } else {
//         currentUserRole.value = 'SDO';
//       }
//     } catch (e, st) {
//       currentUserRole.value = 'SDO';
//       log('Error loading user role: $e', stackTrace: st);
//     }
//   }
//
//   Future<void> loadCachedDashboard() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedData = prefs.getString(StorageKeys.dashboardData);
//       if (cachedData != null) {
//         await _parseAndSetDashboardData(jsonDecode(cachedData));
//       }
//     } catch (e) {
//       log("Error loading cached dashboard: $e");
//     }
//   }
//
//   Future<void> _parseAndSetDashboardData(dynamic data) async {
//     if (data['user'] != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(StorageKeys.userData, jsonEncode(data['user']));
//
//       user.value = data['user'];
//
//       dynamic roleData = data['user']['role'] ?? data['user']['roles'];
//       String role;
//
//       if (roleData is List && roleData.isNotEmpty) {
//         role = roleData.first.toString();
//       } else if (roleData is String) {
//         role = roleData;
//       } else {
//         role = 'SDO';
//       }
//
//       currentUserRole.value = role.toUpperCase();
//       log("✅ User role updated to: ${currentUserRole.value}");
//     }
//
//     final summary = data['summary'] ?? {};
//     totalPtws.value = summary['total_ptws']?.toString() ?? '0';
//     activePtws.value = summary['active_ptws']?.toString() ?? '0';
//     closedPtws.value = summary['closed_ptws']?.toString() ?? '0';
//     cancelledPtws.value = summary['cancelled_ptws']?.toString() ?? '0';
//
//     final recentPtws = data['recent_ptws'] as List<dynamic>? ?? [];
//     final mappedList = recentPtws.map<PtwCardData>((ptw) {
//       return PtwCardData(
//         id: ptw['id'],
//         ptwId: ptw['ptw_code'] ?? ptw['misc_code'] ?? '',
//         status: ptw['status'] ?? '',
//         feeder: ptw['feeder'] ?? '',
//         date: ptw['date'] ?? '',
//         dueTime: ptw['due_time']?.toString() ?? '',
//       );
//     }).toList();
//
//     ptwList.assignAll(mappedList);
//     filteredPtwList.assignAll(mappedList);
//
//     // 🆕 Parse additional data
//     _parseInsightsData(data);
//   }
//
//   // 🆕 PARSE INSIGHTS DATA
//   void _parseInsightsData(dynamic data) {
//     // Parse Weekly Trends
//     if (data['weekly_trends'] != null) {
//       final trends = data['weekly_trends'] as List<dynamic>;
//       weeklyTrends.value = trends.asMap().entries.map((entry) {
//         return FlSpot(
//           entry.key.toDouble(),
//           (entry.value as num).toDouble(),
//         );
//       }).toList();
//     } else {
//       // Generate sample data for demo
//       weeklyTrends.value = [
//         FlSpot(0, 3),
//         FlSpot(1, 5),
//         FlSpot(2, 4),
//         FlSpot(3, 7),
//         FlSpot(4, 6),
//         FlSpot(5, 8),
//         FlSpot(6, 5),
//       ];
//     }
//
//     // Parse SLA Metrics
//     if (data['sla_metrics'] != null) {
//       slaMetrics.value = Map<String, int>.from(data['sla_metrics']);
//     } else {
//       // Sample SLA data
//       final total = int.tryParse(totalPtws.value) ?? 0;
//       slaMetrics.value = {
//         'on_time': (total * 0.7).round(),
//         'at_risk': (total * 0.2).round(),
//         'breached': (total * 0.1).round(),
//         'total': total,
//       };
//     }
//
//     // Parse Performance Metrics
//     if (data['performance_metrics'] != null) {
//       performanceMetrics.value = data['performance_metrics'];
//     } else {
//       // Sample performance data
//       performanceMetrics.value = {
//         'completion_rate': 85,
//         'avg_time': 4,
//       };
//     }
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadUser();
//     loadUserRole();
//     loadCachedDashboard();
//     fetchDashboard();
//     fetchWhatsNew(); // 🆕
//     _generateFCMTokenAndSendToBackend();
//   }
//
//   bool canCreatePtw() {
//     return currentUserRole.value == "LS";
//   }
//
//   // 🆕 FETCH WHAT'S NEW DATA
//   Future<void> fetchWhatsNew() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(StorageKeys.authToken);
//
//       final response = await http.get(
//         Uri.parse("${ApiConstants.baseUrl}/api/v1/dashboard/whats-new"),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _parseWhatsNewData(data);
//       }
//     } catch (e) {
//       log("What's New API error: $e");
//       // Generate sample data for demo
//       _generateSampleWhatsNew();
//     }
//   }
//
//   void _parseWhatsNewData(dynamic data) {
//     final activities = <ActivityItem>[];
//
//     // Parse drafts
//     if (data['drafts'] != null && (data['drafts'] as List).isNotEmpty) {
//       final drafts = data['drafts'] as List;
//       draftsCount.value = drafts.length;
//
//       for (var draft in drafts) {
//         activities.add(ActivityItem(
//           type: 'draft',
//           title: 'Draft PTW awaiting completion',
//           description: 'PTW ${draft['ptw_code']} - ${draft['feeder']}',
//           timestamp: DateTime.parse(draft['updated_at']),
//           ptwId: draft['id'],
//           icon: Icons.edit_note_rounded,
//           color: Colors.orange,
//           actionLabel: 'Resume',
//         ));
//       }
//     }
//
//     // Parse pending tasks
//     if (data['pending_tasks'] != null && (data['pending_tasks'] as List).isNotEmpty) {
//       final pending = data['pending_tasks'] as List;
//       pendingTasksCount.value = pending.length;
//
//       for (var task in pending) {
//         activities.add(ActivityItem(
//           type: 'pending',
//           title: 'Pending review required',
//           description: 'PTW ${task['ptw_code']} awaiting your approval',
//           timestamp: DateTime.parse(task['updated_at']),
//           ptwId: task['id'],
//           icon: Icons.pending_actions_rounded,
//           color: Colors.blue,
//           actionLabel: 'Review',
//         ));
//       }
//     }
//
//     // Parse new assignments
//     if (data['new_assignments'] != null && (data['new_assignments'] as List).isNotEmpty) {
//       final assignments = data['new_assignments'] as List;
//
//       for (var assignment in assignments) {
//         activities.add(ActivityItem(
//           type: 'assigned',
//           title: 'New PTW assigned to you',
//           description: 'PTW ${assignment['ptw_code']} - ${assignment['feeder']}',
//           timestamp: DateTime.parse(assignment['created_at']),
//           ptwId: assignment['id'],
//           icon: Icons.assignment_ind_rounded,
//           color: Colors.green,
//           actionLabel: 'View',
//         ));
//       }
//     }
//
//     // Parse recent updates
//     if (data['recent_updates'] != null && (data['recent_updates'] as List).isNotEmpty) {
//       final updates = data['recent_updates'] as List;
//
//       for (var update in updates) {
//         activities.add(ActivityItem(
//           type: 'updated',
//           title: 'PTW updated',
//           description: 'PTW ${update['ptw_code']} - ${update['activity']}',
//           timestamp: DateTime.parse(update['updated_at']),
//           ptwId: update['id'],
//           icon: Icons.update_rounded,
//           color: Colors.purple,
//           actionLabel: 'View',
//         ));
//       }
//     }
//
//     // Sort by timestamp (newest first)
//     activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//
//     recentActivities.value = activities.take(10).toList();
//   }
//
//   void _generateSampleWhatsNew() {
//     // Sample data for demonstration
//     final now = DateTime.now();
//
//     recentActivities.value = [
//       ActivityItem(
//         type: 'draft',
//         title: 'Draft PTW awaiting completion',
//         description: 'PTW-202602-055 - Feeder 000805',
//         timestamp: now.subtract(Duration(minutes: 30)),
//         ptwId: 1,
//         icon: Icons.edit_note_rounded,
//         color: Colors.orange,
//         actionLabel: 'Resume',
//       ),
//       ActivityItem(
//         type: 'assigned',
//         title: 'New PTW assigned to you',
//         description: 'PTW-202602-053 - Feeder 000805',
//         timestamp: now.subtract(Duration(hours: 2)),
//         ptwId: 2,
//         icon: Icons.assignment_ind_rounded,
//         color: Colors.green,
//         actionLabel: 'View',
//       ),
//       ActivityItem(
//         type: 'updated',
//         title: 'PTW updated',
//         description: 'PTW-202602-040 - Status changed to In Progress',
//         timestamp: now.subtract(Duration(hours: 5)),
//         ptwId: 3,
//         icon: Icons.update_rounded,
//         color: Colors.purple,
//         actionLabel: 'View',
//       ),
//     ];
//
//     draftsCount.value = 1;
//     pendingTasksCount.value = 0;
//   }
//
//   Future<void> fetchDashboard() async {
//     try {
//       isLoading.value = true;
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(StorageKeys.authToken);
//
//       final uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/dashboard")
//           .replace(queryParameters: {'filter': 'all_times'});
//
//       final response = await http.get(
//         uri,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       log("Dashboard API response: ${response.body}");
//
//       if (response.statusCode == 200) {
//         await prefs.setString(StorageKeys.dashboardData, response.body);
//         final data = jsonDecode(response.body);
//         await _parseAndSetDashboardData(data);
//       }
//     } catch (e) {
//       log("Dashboard API error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> fetchDashboardWithFilter() async {
//     try {
//       isLoading.value = true;
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(StorageKeys.authToken);
//
//       Uri uri;
//
//       if (selectedFilterType.value == 'custom_range' &&
//           startDate.value != null &&
//           endDate.value != null) {
//         uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/dashboard").replace(
//           queryParameters: {
//             'filter': 'custom_range',
//             'start_date': startDate.value!.toIso8601String().split('T')[0],
//             'end_date': endDate.value!.toIso8601String().split('T')[0],
//           },
//         );
//       } else {
//         uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/dashboard").replace(
//           queryParameters: {
//             'filter': selectedFilterType.value,
//           },
//         );
//       }
//
//       log("API Call: $uri");
//
//       final response = await http.get(
//         uri,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.statusCode == 200) {
//         if (selectedFilterType.value == 'all_times') {
//           await prefs.setString(StorageKeys.dashboardData, response.body);
//         }
//
//         final data = jsonDecode(response.body);
//         _parseAndSetDashboardData(data);
//       }
//     } catch (e) {
//       log("Dashboard API error with filter: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void applyFilter(String filterType, {DateTime? start, DateTime? end}) {
//     selectedFilterType.value = filterType;
//     if (filterType == 'custom_range') {
//       startDate.value = start;
//       endDate.value = end;
//     } else {
//       startDate.value = null;
//       endDate.value = null;
//     }
//     fetchDashboardWithFilter();
//   }
//
//   void resetFilter() {
//     selectedFilterType.value = 'all_times';
//     startDate.value = null;
//     endDate.value = null;
//     fetchDashboard();
//   }
//
//   void toggleSelection(bool isSelf) {
//     isSelfSelected.value = isSelf;
//   }
// }
//
// // 🆕 ACTIVITY ITEM MODEL
// class ActivityItem {
//   final String type;
//   final String title;
//   final String description;
//   final DateTime timestamp;
//   final int? ptwId;
//   final IconData icon;
//   final Color color;
//   final String? actionLabel;
//
//   ActivityItem({
//     required this.type,
//     required this.title,
//     required this.description,
//     required this.timestamp,
//     this.ptwId,
//     required this.icon,
//     required this.color,
//     this.actionLabel,
//   });
// }
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/storage_keys.dart';
import '../models/ptw_card_data.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var totalPtws = '0'.obs;
  var activePtws = '0'.obs;
  var closedPtws = '0'.obs;
  var cancelledPtws = '0'.obs;
  var ptwList = <PtwCardData>[].obs;
  var isSelfSelected = true.obs;
  var selectedIndex = 0.obs;

  // Filter variables
  var selectedFilterType = 'all_times'.obs; // 'all_times', 'last_week', 'last_month', 'last_3_months', 'last_6_months', 'custom_range'
  var startDate = Rx<DateTime?>(null);
  var endDate = Rx<DateTime?>(null);

  void onItemTapped(int index) {
    selectedIndex.value = index;
    // print(selectedIndex.value);

    // Refresh dashboard when Home tab is selected
    if (index != 0) {
      fetchDashboard();
    }
  }

  var user = {}.obs;
  final currentUserRole = ''.obs;
  List<PtwCardData> get mainPtws {
    if (ptwList.length <= 4) return [];
    return ptwList.sublist(4); // remove first 4 shown in recent
  }

  // Generate FCM token and send it to Laravel backend
  Future<void> _generateFCMTokenAndSendToBackend() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Generate FCM token
    String? fcmToken = await messaging.getToken();
    // print("FCM Token: $fcmToken");

    if (fcmToken != null) {
      await _sendTokenToBackend(fcmToken);  // Send the token to your backend
    }
  }

  // HTTP POST request to send the token to Laravel backend
  Future<void> _sendTokenToBackend(String token) async {
    final String apiUrl = '${ApiConstants.baseUrl}/api/device-token';  // Replace with your Laravel API URL
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString(StorageKeys.authToken);  // Get the auth token

    if (authToken == null) {
      // print("Authorization token is missing.");
      return;
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $authToken',  // Use the logged-in user token
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
        'platform': 'flutter',
      }),
    );

    if (response.statusCode == 200) {
      // print("Token sent to backend successfully!");
    } else {
      // print("Failed to send token: ${response.body}");
    }
  }

  // Load user info from SharedPreferences
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(StorageKeys.userData);
    if (userData != null) {
      user.value = jsonDecode(userData);
    }
  }

  // Load user role and other related data
  Future<void> loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(StorageKeys.userData);
      // print("Testing: User Role: $userDataString");

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        dynamic roleData = userData['role'] ?? userData['roles'];
        String role;

        if (roleData is List && roleData.isNotEmpty) {
          role = roleData.first.toString();
        } else if (roleData is String) {
          role = roleData;
        } else {
          role = 'SDO'; // fallback
        }

        currentUserRole.value = role.toUpperCase();
      } else {
        currentUserRole.value = 'SDO';
      }
    } catch (e, st) {
      currentUserRole.value = 'SDO';
      log('Error loading user role: $e', stackTrace: st);
    }
  }

  // Load cached dashboard data
  Future<void> loadCachedDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(StorageKeys.dashboardData);
      if (cachedData != null) {
        await _parseAndSetDashboardData(jsonDecode(cachedData)); // await add karo
      }
    } catch (e) {
      log("Error loading cached dashboard: $e");
    }
  }
  Future<void> _parseAndSetDashboardData(dynamic data) async {
    // Update user data if present in response
    if (data['user'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userData, jsonEncode(data['user']));

      // Update user observable
      user.value = data['user'];

      // Reload user role immediately
      dynamic roleData = data['user']['role'] ?? data['user']['roles'];
      String role;

      if (roleData is List && roleData.isNotEmpty) {
        role = roleData.first.toString();
      } else if (roleData is String) {
        role = roleData;
      } else {
        role = 'SDO';
      }

      currentUserRole.value = role.toUpperCase();
      print("✅ User role updated to: ${currentUserRole.value}");
    }

    final summary = data['summary'] ?? {};
    totalPtws.value = summary['total_ptws']?.toString() ?? '0';
    activePtws.value = summary['active_ptws']?.toString() ?? '0';
    closedPtws.value = summary['closed_ptws']?.toString() ?? '0';
    cancelledPtws.value = summary['cancelled_ptws']?.toString() ?? '0';

    final recentPtws = data['recent_ptws'] as List<dynamic>? ?? [];
    final mappedList = recentPtws.map<PtwCardData>((ptw) {
      return PtwCardData(
        id: ptw['id'],
        ptwId: ptw['ptw_code'] ?? ptw['misc_code'] ?? '',
        status: ptw['status'] ?? '',
        feeder: ptw['feeder'] ?? '',
        date: ptw['date'] ?? '',
        dueTime: ptw['due_time']?.toString() ?? '',
      );
    }).toList();

    ptwList.assignAll(mappedList);
  }
  @override
  void onInit() {
    super.onInit();
    loadUser();
    loadUserRole();
    loadCachedDashboard(); // Load cached data first
    fetchDashboard();
    _generateFCMTokenAndSendToBackend();  // Generate and send the FCM token when the controller is initialized
  }

  bool canCreatePtw() {
    return currentUserRole.value == "LS";  // only LS can create PTW
  }

  // Fetch live dashboard from API (without filter - All Times)
  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);
      final existingData = prefs.getString(StorageKeys.dashboardData);

      if (existingData != null && existingData.isNotEmpty) {
        try {
          final parsedData = jsonDecode(existingData);
          print("Parsed dashboard data: $parsedData");
        } catch (e) {
          print("Error parsing existing data: $e");
        }
      } else {
        print("No data stored");
      }
      // For all_times, use filter=all_times
      final uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/dashboard")
          .replace(queryParameters: {'filter': 'all_times'});

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      print("Dashboard API response: ${response.body}");
      if (response.statusCode == 200) {
        // Update local storage
        await prefs.setString(StorageKeys.dashboardData, response.body);

        final data = jsonDecode(response.body);
        await _parseAndSetDashboardData(data); // await add karo
      }
      // if (response.statusCode == 200) {
      //   // Update local storage
      //   await prefs.setString(StorageKeys.dashboardData, response.body);
      //
      //   final data = jsonDecode(response.body);
      //   _parseAndSetDashboardData(data);
      // }
    } catch (e) {
      log("Dashboard API error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch dashboard with filter
  Future<void> fetchDashboardWithFilter() async {
    print("this is the custom filter");
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      Uri uri;

      // Build different URLs based on filter type
      if (selectedFilterType.value == 'custom_range' &&
          startDate.value != null &&
          endDate.value != null) {
        // For custom_range: filter=custom_range&start_date=2025-12-02&end_date=2025-12-22
        uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/dashboard").replace(
          queryParameters: {
            'filter': 'custom_range',
            'start_date': startDate.value!.toIso8601String().split('T')[0],
            'end_date': endDate.value!.toIso8601String().split('T')[0],
          },
        );
        print("Testing if: $uri");
      } else {
        // For other filters: filter=last_week, filter=last_month, etc.
        uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/dashboard").replace(
          queryParameters: {
            'filter': selectedFilterType.value,
          },
        );

        print("Testing eLSE: $uri");
      }

      log("API Call: $uri");

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Update local storage for non-custom filters (optional choice, but usually good for 'all_times')
        if (selectedFilterType.value == 'all_times') {
          await prefs.setString(StorageKeys.dashboardData, response.body);
        }

        final data = jsonDecode(response.body);
        _parseAndSetDashboardData(data);
      }
    } catch (e) {
      log("Dashboard API error with filter: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Method to apply filter
  void applyFilter(String filterType, {DateTime? start, DateTime? end}) {
    selectedFilterType.value = filterType;
    if (filterType == 'custom_range') {
      startDate.value = start;
      endDate.value = end;
    } else {
      // Clear dates for preset filters
      startDate.value = null;
      endDate.value = null;
    }
    fetchDashboardWithFilter();
  }

  // Method to reset filter
  void resetFilter() {
    selectedFilterType.value = 'all_times';
    startDate.value = null;
    endDate.value = null;
    fetchDashboard();
  }

  void toggleSelection(bool isSelf) {
    isSelfSelected.value = isSelf;
  }
}
