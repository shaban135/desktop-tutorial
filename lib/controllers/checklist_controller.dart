import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/snackbar_helper.dart';

enum ChecklistType {
  safety,
  hazard,
  issuerInstructions,
  gridPtwIssue,
  ptwCanceletionCompletion,
  ptwGridClose,
  ptwCancelByLs
}

class ChecklistController extends GetxController {
  final ChecklistType checklistType;
  final int initialPtwId;

  var isLoading = true.obs;
  var checklistItems = <ChecklistItem>[].obs;
  var checklistTitle = ''.obs;
  var isSubmitting = false.obs;
  var ptwId = 0.obs;
  var currentUserRole = ''.obs;
  var currentUserId = 0.obs; // ✅ NEW: Store current user ID

  // Key: checklist_item_id, Value: List of auto precautions
  var itemAutoPrecautions = <int, List<ChecklistItem>>{}.obs;

  // Track which dropdowns are expanded
  var expandedItems = <int>{}.obs;

  ChecklistController(
      this.checklistType, {
        this.initialPtwId = 0,
      });

  @override
  void onInit() {
    super.onInit();
    ptwId.value = initialPtwId;
    _loadUserRole();
    fetchChecklistItems();
  }

  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(StorageKeys.userData);

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);

        // ✅ NEW: Get user ID
        currentUserId.value = userData['id'] ?? 0;

        dynamic roleData = userData['role'] ?? userData['roles'];
        String role;

        if (roleData is List && roleData.isNotEmpty) {
          role = roleData.first.toString();
        } else if (roleData is String) {
          role = roleData;
        } else {
          role = 'LS';
        }
        currentUserRole.value = role.toUpperCase();

        log('Current user ID: ${currentUserId.value}, Role: ${currentUserRole.value}');
      } else {
        currentUserRole.value = 'LS';
        currentUserId.value = 0;
      }
    } catch (e, st) {
      currentUserRole.value = 'LS';
      currentUserId.value = 0;
      log('Error loading user role: $e', stackTrace: st);
    }
  }

  String _getChecklistTypeString() {
    switch (checklistType) {
      case ChecklistType.safety:
        return 'LINE_TYPE';
      case ChecklistType.hazard:
        return 'HAZARDS';
      case ChecklistType.issuerInstructions:
        return 'PRECAUTION';
      case ChecklistType.gridPtwIssue:
        return 'GRID_PTW_ISSUE';
      case ChecklistType.ptwCanceletionCompletion:
        return 'PTW_CANCELATION_OF_COMPLETION_BY_LS';
      case ChecklistType.ptwGridClose:
        return 'PTW_CANCEL_BY_GRID';
      case ChecklistType.ptwCancelByLs:
        return 'PTW_CANCEL_BY_LS';
    }
  }

  String _getSubmitEndpoint() {
    switch (checklistType) {
      case ChecklistType.safety:
        return 'step2-line';
      case ChecklistType.hazard:
        return 'step3-hazards';
      case ChecklistType.issuerInstructions:
        return 'step4-instructions';
      case ChecklistType.gridPtwIssue:
        return 'step5-grid-ptw-issue';
      case ChecklistType.ptwCanceletionCompletion:
        return 'step6-ptw-cancelation';
      case ChecklistType.ptwGridClose:
        return 'step7-ptw-cancelation';
      case ChecklistType.ptwCancelByLs:
        return 'step7-ptw-cancel-by-ls';
    }
  }

  Future<void> fetchChecklistItems() async {
    try {
      isLoading.value = true;
      await _loadMasterChecklist();

      if (ptwId.value > 0) {
        await _applySavedValuesFromPreview();
      }
    } catch (e, st) {
      log('fetchChecklistItems error: $e', stackTrace: st);
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An error occurred while loading checklist: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMasterChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.authToken);

    if (token == null) {
      SnackbarHelper.showError(
        title: 'Error',
        message: 'Authentication token not found.',
      );
      return;
    }

    final type = _getChecklistTypeString();
    final uri = Uri.parse(
      "${ApiConstants.baseUrl}/api/v1/admin/checklists?type=$type",
    );
    log("Checklist master URI: $uri");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        final checklistData = data['data'][0];
        checklistTitle.value = checklistData['title_en'] ?? '';

        final items = (checklistData['items'] as List)
            .map((itemJson) => ChecklistItem.fromJson(itemJson))
            .toList();
        checklistItems.value = items;
      }
    } else {
      SnackbarHelper.showError(
        title: 'Error',
        message: 'Failed to load checklist: ${response.statusCode}',
      );
    }
  }

  Future<void> _applySavedValuesFromPreview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) return;

      final currentPtwId = ptwId.value;
      if (currentPtwId <= 0) return;

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/v1/ptw/$currentPtwId/preview',
      );

      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('Preview status: ${res.statusCode}');

      if (res.statusCode != 200) return;

      final jsonBody = json.decode(res.body);
      final data = jsonBody['data'];
      if (data == null || data['checklists'] == null) return;

      final checklists = data['checklists'] as Map<String, dynamic>;
      final typeKey = _getChecklistTypeString();

      if (!checklists.containsKey(typeKey)) return;

      final List<dynamic> list = checklists[typeKey];
      if (list.isEmpty) return;

      // ✅ NEW: For gridPtwIssue and ptwGridClose, get user's grid_id and filter
      if (checklistType == ChecklistType.gridPtwIssue ||
          checklistType == ChecklistType.ptwGridClose) {
        await _applyGridStationFiltering(list);
      } else {
        // Normal logic for other checklist types
        final Map<int, bool> savedValues = {};
        for (final item in list) {
          final id = item['id'];
          if (id == null) continue;
          final valStr = (item['value'] ?? '').toString().toUpperCase().trim();
          savedValues[id as int] = (valStr == 'YES');
        }

        for (var i = 0; i < checklistItems.length; i++) {
          final id = checklistItems[i].id;
          if (savedValues.containsKey(id)) {
            checklistItems[i].value = savedValues[id]!;
          }
        }
      }

      checklistItems.refresh();

      // Load auto precautions for checked items
      await _loadAutoPrecautionsForCheckedItems();
    } catch (e, st) {
      log('Error applying preview checklist values: $e', stackTrace: st);
    }
  }

  // ✅ NEW: Grid station filtering logic
  Future<void> _applyGridStationFiltering(List<dynamic> savedAnswers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null || currentUserId.value == 0) {
        log('Token or user ID not available for grid filtering');
        return;
      }

      // Get user's grid_id from user_posting table
      final userGridId = await _getUserGridId(token);

      if (userGridId == null) {
        log('No grid_id found for user ${currentUserId.value}');
        return;
      }

      log('User grid_id: $userGridId');

      // Build map of saved answers with their grid_id
      final Map<int, Map<String, dynamic>> savedAnswersMap = {};
      for (final item in savedAnswers) {
        final id = item['id'];
        if (id == null) continue;

        savedAnswersMap[id as int] = {
          'value': (item['value'] ?? '').toString().toUpperCase().trim() == 'YES',
          'grid_id': item['grid_id'], // This comes from ptw_checklist_answers
        };
      }

      // Apply filtering: check only if grid_id matches
      for (var i = 0; i < checklistItems.length; i++) {
        final id = checklistItems[i].id;

        if (savedAnswersMap.containsKey(id)) {
          final answerData = savedAnswersMap[id]!;
          final answerGridId = answerData['grid_id'];

          // ✅ Check only if grid_id matches user's grid_id
          if (answerGridId != null && answerGridId == userGridId) {
            checklistItems[i].value = answerData['value'] as bool;
            log('Checked item ${checklistItems[i].id} - grid_id match: $answerGridId');
          } else {
            checklistItems[i].value = false;
            log('Unchecked item ${checklistItems[i].id} - grid_id mismatch: $answerGridId vs $userGridId');
          }
        }
      }

    } catch (e, st) {
      log('Error in grid station filtering: $e', stackTrace: st);
    }
  }

  // ✅ NEW: Get user's grid_id from user_posting table
  Future<int?> _getUserGridId(String token) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/v1/user/posting/${currentUserId.value}',
      );

      log('Fetching user posting: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('User posting status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Assuming API returns: { "data": { "grid_id": 123 } }
        final gridId = data['data']?['grid_id'];

        if (gridId != null) {
          return gridId as int;
        }
      }

      return null;
    } catch (e, st) {
      log('Error getting user grid_id: $e', stackTrace: st);
      return null;
    }
  }

  Future<void> _loadAutoPrecautionsForCheckedItems() async {
    try {
      final checkedItems = checklistItems.where((item) => item.value).toList();

      if (checkedItems.isEmpty) return;

      log('Loading auto precautions for ${checkedItems.length} checked items');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) return;

      for (final item in checkedItems) {
        try {
          final uri = Uri.parse(
            '${ApiConstants.baseUrl}/api/v1/admin/checklists/hazards/${item.id}/precautions',
          );

          final response = await http.get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

          log('Draft load precautions for hazard ${item.id}: ${response.statusCode}');

          if (response.statusCode == 200) {
            final responseBody = json.decode(response.body);

            if (responseBody['precautions'] != null) {
              final precautionsList = responseBody['precautions'] as List;

              if (precautionsList.isNotEmpty) {
                final precautions = precautionsList.map((precItem) {
                  return ChecklistItem(
                    id: precItem['id'],
                    textEnglish: precItem['label_en'] ?? '',
                    textUrdu: precItem['label_ur'] ?? '',
                    value: true,
                    isAutoGenerated: true,
                  );
                }).toList();

                itemAutoPrecautions[item.id] = precautions;
                log('Draft loaded ${precautions.length} precautions for hazard ${item.id}');
              }
            }
          }

          await Future.delayed(const Duration(milliseconds: 200));

        } catch (e) {
          log('Error loading precautions for hazard ${item.id}: $e');
          continue;
        }
      }

      log('Finished loading auto precautions for all checked items');

    } catch (e, st) {
      log('Error loading auto precautions: $e', stackTrace: st);
    }
  }

  void toggleDropdown(int itemId) {
    if (expandedItems.contains(itemId)) {
      expandedItems.remove(itemId);
    } else {
      expandedItems.add(itemId);
    }
  }

  bool isDropdownExpanded(int itemId) {
    return expandedItems.contains(itemId);
  }

  Future<void> toggleItem(int id, bool value) async {
    final index = checklistItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    checklistItems[index].value = value;
    checklistItems.refresh();

    if (value) {
      await _fetchAutoPrecautionsForHazard(id);

      if (!expandedItems.contains(id)) {
        expandedItems.add(id);
      }
    } else {
      itemAutoPrecautions.remove(id);
      expandedItems.remove(id);
    }
  }

  Future<void> _fetchAutoPrecautionsForHazard(int hazardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        log('Token not found');
        return;
      }

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/v1/admin/checklists/hazards/$hazardId/precautions',
      );

      log('Fetching precautions for hazard $hazardId: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('Precautions API status: ${response.statusCode}');
      log('Precautions API body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['precautions'] != null) {
          final precautionsList = responseBody['precautions'] as List;

          if (precautionsList.isNotEmpty) {
            final precautions = precautionsList.map((item) {
              return ChecklistItem(
                id: item['id'],
                textEnglish: item['label_en'] ?? '',
                textUrdu: item['label_ur'] ?? '',
                value: true,
                isAutoGenerated: true,
              );
            }).toList();

            itemAutoPrecautions[hazardId] = precautions;
            log('Loaded ${precautions.length} precautions for hazard $hazardId');
          } else {
            itemAutoPrecautions.remove(hazardId);
            log('No precautions found for hazard $hazardId');
          }
        }
      } else {
        log('Failed to fetch precautions: ${response.statusCode}');
      }
    } catch (e, st) {
      log('Error fetching precautions for hazard $hazardId: $e', stackTrace: st);
    }
  }

  List<ChecklistItem> getAutoPrecautions(int itemId) {
    return itemAutoPrecautions[itemId] ?? [];
  }

  Future<bool> submitChecklist() async {
    isSubmitting.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);
      final currentPtwId = ptwId.value;

      if (token == null) {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Authentication token not found.',
        );
        return false;
      }

      if (currentPtwId == 0) {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'PTW ID is not available.',
        );
        return false;
      }

      final List<Map<String, dynamic>> allAnswers = [];

      for (final item in checklistItems) {
        allAnswers.add({
          'checklist_item_id': item.id,
          'value': item.value ? 'YES' : 'NO',
        });
      }

      for (final entry in itemAutoPrecautions.entries) {
        final hazardId = entry.key;
        final precautions = entry.value;

        final parentHazard = checklistItems.firstWhere(
              (item) => item.id == hazardId,
          orElse: () => ChecklistItem(id: 0, textEnglish: '', textUrdu: ''),
        );

        if (parentHazard.id != 0 && parentHazard.value) {
          for (final precaution in precautions) {
            allAnswers.add({
              'checklist_item_id': precaution.id,
              'value': 'YES',
            });
          }
        }
      }

      log('Submitting ${allAnswers.length} answers (including auto precautions)');

      final endpoint = _getSubmitEndpoint();
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/v1/ptw/$currentPtwId/$endpoint',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'answers': allAnswers}),
      );

      log('Checklist submit status: ${response.statusCode}');
      log('Checklist submit body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackbarHelper.showSuccess(
          title: 'Success',
          message: 'Checklist submitted successfully',
        );

        if (checklistType == ChecklistType.issuerInstructions) {
          Get.toNamed(
            '/ptw-review-sdo',
            arguments: {
              'ptw_id': currentPtwId,
              'user_role': currentUserRole.value,
            },
          );
        }

        return true;
      } else {
        final responseBody = json.decode(response.body);
        SnackbarHelper.showError(
          title: 'API Error',
          message:
          'Failed to submit checklist. Status: ${response.statusCode}. Message: ${responseBody['message']}',
        );
        return false;
      }
    } catch (e, st) {
      log('submitChecklist error: $e', stackTrace: st);
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An error occurred: $e',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
// import 'dart:convert';
// import 'dart:developer';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:mepco_esafety_app/constants/api_constants.dart';
// import 'package:mepco_esafety_app/constants/storage_keys.dart';
// import 'package:mepco_esafety_app/models/checklist_item.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../utils/snackbar_helper.dart';
//
// enum ChecklistType {
//   safety,
//   hazard,
//   issuerInstructions,
//   gridPtwIssue,
//   ptwCanceletionCompletion,
//   ptwGridClose,
//   ptwCancelByLs
// }
//
// class ChecklistController extends GetxController {
//   final ChecklistType checklistType;
//   final int initialPtwId;
//
//   var isLoading = true.obs;
//   var checklistItems = <ChecklistItem>[].obs;
//   var checklistTitle = ''.obs;
//   var isSubmitting = false.obs;
//   var ptwId = 0.obs;
//   var currentUserRole = ''.obs;
//   var currentUserId = 0.obs; // ✅ NEW: Store current user ID
//
//   // Key: checklist_item_id, Value: List of auto precautions
//   var itemAutoPrecautions = <int, List<ChecklistItem>>{}.obs;
//
//   // Track which dropdowns are expanded
//   var expandedItems = <int>{}.obs;
//
//   ChecklistController(
//       this.checklistType, {
//         this.initialPtwId = 0,
//       });
//
//   @override
//   void onInit() {
//     super.onInit();
//     ptwId.value = initialPtwId;
//     _loadUserRole();
//     fetchChecklistItems();
//   }
//
//   Future<void> _loadUserRole() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userDataString = prefs.getString(StorageKeys.userData);
//
//       if (userDataString != null) {
//         final userData = jsonDecode(userDataString);
//
//         // ✅ NEW: Get user ID
//         currentUserId.value = userData['id'] ?? 0;
//
//         dynamic roleData = userData['role'] ?? userData['roles'];
//         String role;
//
//         if (roleData is List && roleData.isNotEmpty) {
//           role = roleData.first.toString();
//         } else if (roleData is String) {
//           role = roleData;
//         } else {
//           role = 'LS';
//         }
//         currentUserRole.value = role.toUpperCase();
//
//         log('Current user ID: ${currentUserId.value}, Role: ${currentUserRole.value}');
//       } else {
//         currentUserRole.value = 'LS';
//         currentUserId.value = 0;
//       }
//     } catch (e, st) {
//       currentUserRole.value = 'LS';
//       currentUserId.value = 0;
//       log('Error loading user role: $e', stackTrace: st);
//     }
//   }
//
//   String _getChecklistTypeString() {
//     switch (checklistType) {
//       case ChecklistType.safety:
//         return 'LINE_TYPE';
//       case ChecklistType.hazard:
//         return 'HAZARDS';
//       case ChecklistType.issuerInstructions:
//         return 'PRECAUTION';
//       case ChecklistType.gridPtwIssue:
//         return 'GRID_PTW_ISSUE';
//       case ChecklistType.ptwCanceletionCompletion:
//         return 'PTW_CANCELATION_OF_COMPLETION_BY_LS';
//       case ChecklistType.ptwGridClose:
//         return 'PTW_CANCEL_BY_GRID';
//       case ChecklistType.ptwCancelByLs:
//         return 'PTW_CANCEL_BY_LS';
//     }
//   }
//
//   String _getSubmitEndpoint() {
//     switch (checklistType) {
//       case ChecklistType.safety:
//         return 'step2-line';
//       case ChecklistType.hazard:
//         return 'step3-hazards';
//       case ChecklistType.issuerInstructions:
//         return 'step4-instructions';
//       case ChecklistType.gridPtwIssue:
//         return 'step5-grid-ptw-issue';
//       case ChecklistType.ptwCanceletionCompletion:
//         return 'step6-ptw-cancelation';
//       case ChecklistType.ptwGridClose:
//         return 'step7-ptw-cancelation';
//       case ChecklistType.ptwCancelByLs:
//         return 'step7-ptw-cancel-by-ls';
//     }
//   }
//
//   Future<void> fetchChecklistItems() async {
//     try {
//       isLoading.value = true;
//       await _loadMasterChecklist();
//
//       if (ptwId.value > 0) {
//         await _applySavedValuesFromPreview();
//       }
//     } catch (e, st) {
//       log('fetchChecklistItems error: $e', stackTrace: st);
//       SnackbarHelper.showError(
//         title: 'Error',
//         message: 'An error occurred while loading checklist: $e',
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> _loadMasterChecklist() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(StorageKeys.authToken);
//
//     if (token == null) {
//       SnackbarHelper.showError(
//         title: 'Error',
//         message: 'Authentication token not found.',
//       );
//       return;
//     }
//
//     final type = _getChecklistTypeString();
//     final uri = Uri.parse(
//       "${ApiConstants.baseUrl}/api/v1/admin/checklists?type=$type",
//     );
//     log("Checklist master URI: $uri");
//
//     final response = await http.get(
//       uri,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['data'] != null && data['data'].isNotEmpty) {
//         final checklistData = data['data'][0];
//         checklistTitle.value = checklistData['title_en'] ?? '';
//
//         final items = (checklistData['items'] as List)
//             .map((itemJson) => ChecklistItem.fromJson(itemJson))
//             .toList();
//         checklistItems.value = items;
//       }
//     } else {
//       SnackbarHelper.showError(
//         title: 'Error',
//         message: 'Failed to load checklist: ${response.statusCode}',
//       );
//     }
//   }
//
//   Future<void> _applySavedValuesFromPreview() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(StorageKeys.authToken);
//
//       if (token == null) return;
//
//       final currentPtwId = ptwId.value;
//       if (currentPtwId <= 0) return;
//
//       final uri = Uri.parse(
//         '${ApiConstants.baseUrl}/api/v1/ptw/$currentPtwId/preview',
//       );
//
//       final res = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );
//
//       log('Preview status: ${res.statusCode}');
//
//       if (res.statusCode != 200) return;
//
//       final jsonBody = json.decode(res.body);
//       final data = jsonBody['data'];
//       if (data == null || data['checklists'] == null) return;
//
//       final checklists = data['checklists'] as Map<String, dynamic>;
//       final typeKey = _getChecklistTypeString();
//
//       if (!checklists.containsKey(typeKey)) return;
//
//       final List<dynamic> list = checklists[typeKey];
//       if (list.isEmpty) return;
//
//       // ✅ NEW: For gridPtwIssue, get user's grid_id and filter
//       if (checklistType == ChecklistType.gridPtwIssue) {
//         await _applyGridStationFiltering(list);
//       } else {
//         // Normal logic for other checklist types
//         final Map<int, bool> savedValues = {};
//         for (final item in list) {
//           final id = item['id'];
//           if (id == null) continue;
//           final valStr = (item['value'] ?? '').toString().toUpperCase().trim();
//           savedValues[id as int] = (valStr == 'YES');
//         }
//
//         for (var i = 0; i < checklistItems.length; i++) {
//           final id = checklistItems[i].id;
//           if (savedValues.containsKey(id)) {
//             checklistItems[i].value = savedValues[id]!;
//           }
//         }
//       }
//
//       checklistItems.refresh();
//
//       // Load auto precautions for checked items
//       await _loadAutoPrecautionsForCheckedItems();
//     } catch (e, st) {
//       log('Error applying preview checklist values: $e', stackTrace: st);
//     }
//   }
//
//   // ✅ NEW: Grid station filtering logic
//   Future<void> _applyGridStationFiltering(List<dynamic> savedAnswers) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(StorageKeys.authToken);
//
//       if (token == null || currentUserId.value == 0) {
//         log('Token or user ID not available for grid filtering');
//         return;
//       }
//
//       // Get user's grid_id from user_posting table
//       final userGridId = await _getUserGridId(token);
//
//       if (userGridId == null) {
//         log('No grid_id found for user ${currentUserId.value}');
//         return;
//       }
//
//       log('User grid_id: $userGridId');
//
//       // Build map of saved answers with their grid_id
//       final Map<int, Map<String, dynamic>> savedAnswersMap = {};
//       for (final item in savedAnswers) {
//         final id = item['id'];
//         if (id == null) continue;
//
//         savedAnswersMap[id as int] = {
//           'value': (item['value'] ?? '').toString().toUpperCase().trim() == 'YES',
//           'grid_id': item['grid_id'], // This comes from ptw_checklist_answers
//         };
//       }
//
//       // Apply filtering: check only if grid_id matches
//       for (var i = 0; i < checklistItems.length; i++) {
//         final id = checklistItems[i].id;
//
//         if (savedAnswersMap.containsKey(id)) {
//           final answerData = savedAnswersMap[id]!;
//           final answerGridId = answerData['grid_id'];
//
//           // ✅ Check only if grid_id matches user's grid_id
//           if (answerGridId != null && answerGridId == userGridId) {
//             checklistItems[i].value = answerData['value'] as bool;
//             log('Checked item ${checklistItems[i].id} - grid_id match: $answerGridId');
//           } else {
//             checklistItems[i].value = false;
//             log('Unchecked item ${checklistItems[i].id} - grid_id mismatch: $answerGridId vs $userGridId');
//           }
//         }
//       }
//
//     } catch (e, st) {
//       log('Error in grid station filtering: $e', stackTrace: st);
//     }
//   }
//
//   // ✅ NEW: Get user's grid_id from user_posting table
//   Future<int?> _getUserGridId(String token) async {
//     try {
//       final uri = Uri.parse(
//         '${ApiConstants.baseUrl}/api/v1/user/posting/${currentUserId.value}',
//       );
//
//       log('Fetching user posting: $uri');
//
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );
//
//       log('User posting status: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         // Assuming API returns: { "data": { "grid_id": 123 } }
//         final gridId = data['data']?['grid_id'];
//
//         if (gridId != null) {
//           return gridId as int;
//         }
//       }
//
//       return null;
//     } catch (e, st) {
//       log('Error getting user grid_id: $e', stackTrace: st);
//       return null;
//     }
//   }
//
//   Future<void> _loadAutoPrecautionsForCheckedItems() async {
//     try {
//       final checkedItems = checklistItems.where((item) => item.value).toList();
//
//       if (checkedItems.isEmpty) return;
//
//       log('Loading auto precautions for ${checkedItems.length} checked items');
//
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(StorageKeys.authToken);
//
//       if (token == null) return;
//
//       for (final item in checkedItems) {
//         try {
//           final uri = Uri.parse(
//             '${ApiConstants.baseUrl}/api/v1/admin/checklists/hazards/${item.id}/precautions',
//           );
//
//           final response = await http.get(
//             uri,
//             headers: {
//               'Authorization': 'Bearer $token',
//               'Accept': 'application/json',
//             },
//           );
//
//           log('Draft load precautions for hazard ${item.id}: ${response.statusCode}');
//
//           if (response.statusCode == 200) {
//             final responseBody = json.decode(response.body);
//
//             if (responseBody['precautions'] != null) {
//               final precautionsList = responseBody['precautions'] as List;
//
//               if (precautionsList.isNotEmpty) {
//                 final precautions = precautionsList.map((precItem) {
//                   return ChecklistItem(
//                     id: precItem['id'],
//                     textEnglish: precItem['label_en'] ?? '',
//                     textUrdu: precItem['label_ur'] ?? '',
//                     value: true,
//                     isAutoGenerated: true,
//                   );
//                 }).toList();
//
//                 itemAutoPrecautions[item.id] = precautions;
//                 log('Draft loaded ${precautions.length} precautions for hazard ${item.id}');
//               }
//             }
//           }
//
//           await Future.delayed(const Duration(milliseconds: 200));
//
//         } catch (e) {
//           log('Error loading precautions for hazard ${item.id}: $e');
//           continue;
//         }
//       }
//
//       log('Finished loading auto precautions for all checked items');
//
//     } catch (e, st) {
//       log('Error loading auto precautions: $e', stackTrace: st);
//     }
//   }
//
//   void toggleDropdown(int itemId) {
//     if (expandedItems.contains(itemId)) {
//       expandedItems.remove(itemId);
//     } else {
//       expandedItems.add(itemId);
//     }
//   }
//
//   bool isDropdownExpanded(int itemId) {
//     return expandedItems.contains(itemId);
//   }
//
//   Future<void> toggleItem(int id, bool value) async {
//     final index = checklistItems.indexWhere((item) => item.id == id);
//     if (index == -1) return;
//
//     checklistItems[index].value = value;
//     checklistItems.refresh();
//
//     if (value) {
//       await _fetchAutoPrecautionsForHazard(id);
//
//       if (!expandedItems.contains(id)) {
//         expandedItems.add(id);
//       }
//     } else {
//       itemAutoPrecautions.remove(id);
//       expandedItems.remove(id);
//     }
//   }
//
//   Future<void> _fetchAutoPrecautionsForHazard(int hazardId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(StorageKeys.authToken);
//
//       if (token == null) {
//         log('Token not found');
//         return;
//       }
//
//       final uri = Uri.parse(
//         '${ApiConstants.baseUrl}/api/v1/admin/checklists/hazards/$hazardId/precautions',
//       );
//
//       log('Fetching precautions for hazard $hazardId: $uri');
//
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );
//
//       log('Precautions API status: ${response.statusCode}');
//       log('Precautions API body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//
//         if (responseBody['precautions'] != null) {
//           final precautionsList = responseBody['precautions'] as List;
//
//           if (precautionsList.isNotEmpty) {
//             final precautions = precautionsList.map((item) {
//               return ChecklistItem(
//                 id: item['id'],
//                 textEnglish: item['label_en'] ?? '',
//                 textUrdu: item['label_ur'] ?? '',
//                 value: true,
//                 isAutoGenerated: true,
//               );
//             }).toList();
//
//             itemAutoPrecautions[hazardId] = precautions;
//             log('Loaded ${precautions.length} precautions for hazard $hazardId');
//           } else {
//             itemAutoPrecautions.remove(hazardId);
//             log('No precautions found for hazard $hazardId');
//           }
//         }
//       } else {
//         log('Failed to fetch precautions: ${response.statusCode}');
//       }
//     } catch (e, st) {
//       log('Error fetching precautions for hazard $hazardId: $e', stackTrace: st);
//     }
//   }
//
//   List<ChecklistItem> getAutoPrecautions(int itemId) {
//     return itemAutoPrecautions[itemId] ?? [];
//   }
//
//   Future<bool> submitChecklist() async {
//     isSubmitting.value = true;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(StorageKeys.authToken);
//       final currentPtwId = ptwId.value;
//
//       if (token == null) {
//         SnackbarHelper.showError(
//           title: 'Error',
//           message: 'Authentication token not found.',
//         );
//         return false;
//       }
//
//       if (currentPtwId == 0) {
//         SnackbarHelper.showError(
//           title: 'Error',
//           message: 'PTW ID is not available.',
//         );
//         return false;
//       }
//
//       final List<Map<String, dynamic>> allAnswers = [];
//
//       for (final item in checklistItems) {
//         allAnswers.add({
//           'checklist_item_id': item.id,
//           'value': item.value ? 'YES' : 'NO',
//         });
//       }
//
//       for (final entry in itemAutoPrecautions.entries) {
//         final hazardId = entry.key;
//         final precautions = entry.value;
//
//         final parentHazard = checklistItems.firstWhere(
//               (item) => item.id == hazardId,
//           orElse: () => ChecklistItem(id: 0, textEnglish: '', textUrdu: ''),
//         );
//
//         if (parentHazard.id != 0 && parentHazard.value) {
//           for (final precaution in precautions) {
//             allAnswers.add({
//               'checklist_item_id': precaution.id,
//               'value': 'YES',
//             });
//           }
//         }
//       }
//
//       log('Submitting ${allAnswers.length} answers (including auto precautions)');
//
//       final endpoint = _getSubmitEndpoint();
//       final response = await http.post(
//         Uri.parse(
//           '${ApiConstants.baseUrl}/api/v1/ptw/$currentPtwId/$endpoint',
//         ),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({'answers': allAnswers}),
//       );
//
//       log('Checklist submit status: ${response.statusCode}');
//       log('Checklist submit body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         SnackbarHelper.showSuccess(
//           title: 'Success',
//           message: 'Checklist submitted successfully',
//         );
//
//         if (checklistType == ChecklistType.issuerInstructions) {
//           Get.toNamed(
//             '/ptw-review-sdo',
//             arguments: {
//               'ptw_id': currentPtwId,
//               'user_role': currentUserRole.value,
//             },
//           );
//         }
//
//         return true;
//       } else {
//         final responseBody = json.decode(response.body);
//         SnackbarHelper.showError(
//           title: 'API Error',
//           message:
//           'Failed to submit checklist. Status: ${response.statusCode}. Message: ${responseBody['message']}',
//         );
//         return false;
//       }
//     } catch (e, st) {
//       log('submitChecklist error: $e', stackTrace: st);
//       SnackbarHelper.showError(
//         title: 'Error',
//         message: 'An error occurred: $e',
//       );
//       return false;
//     } finally {
//       isSubmitting.value = false;
//     }
//   }
// }