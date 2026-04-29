import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/utils/image_processor.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
enum PtwActionType {
  approve_no_ptw,
  forward,
  returnBack,
  cancel,
  submit,
  delegateGrid,
  prechecksDone,
  //FOR SDO CANCEL REQUEST TO GRID
  cancelSDO,
  // FOR XEN
  xenReject,
  xenReturnLS,
  pdcReturnsLS,
  pdcReject,
delegatePDC,
  pdcIssue,
  returnGrid,
}

const Map<String, Map<PtwActionType, String>> ptwActionMatrix = {
  'LS': {PtwActionType.submit: 'submit'},
  'SDO': {
    PtwActionType.approve_no_ptw: 'approve-no-ptw',
    PtwActionType.forward: 'forward-xen',
    PtwActionType.cancelSDO: 'approve-cancellation',
    PtwActionType.returnBack: 'return',
    PtwActionType.cancel: 'cancel',
  },
  'XEN': {
    PtwActionType.forward: 'xen/approve-pdc',
    PtwActionType.xenReject: 'xen/reject',
    PtwActionType.xenReturnLS: 'xen/return-ls',
  },
  'PDC': {

    PtwActionType.delegateGrid: 'delegate-grid',
    PtwActionType.delegatePDC: 'delegate-to-pdc',
    PtwActionType.pdcIssue: 'pdc/confirm-feeder-status',
    PtwActionType.returnGrid: 'pdc/return-to-grid-for-resolution',
    PtwActionType.pdcReject: 'pdc/reject',
    PtwActionType.pdcReturnsLS: 'pdc/return-ls',
  },
  'GRIDOPERATOR': {PtwActionType.prechecksDone: 'prechecks-done'},
};

class PtwReviewSdoController extends GetxController {
  // -------------------- OBSERVABLES --------------------
  final currentUserGridId = Rxn<int>();
  var hideBottomBar = false.obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var ptwData = {}.obs;
  var checklists = {}.obs;
  final feederStatusOptions = ['NORMAL', 'ABNORMAL', 'UNDER_MAINTENANCE'].obs;
  final currentUserRole = ''.obs;
  final currentUserId = 0.obs;
  final RxList<XFile> images = <XFile>[].obs;
  GoogleMapController? googleMapController;
  var isFetchingLocation = true.obs;
  var currentLocation = Rxn<LatLng>();
  var currentAddress = RxnString();
  final RxBool showDelegationSection = false.obs;
  //------------------------------------------------------
  // ✅ PDC DELEGATION OBSERVABLES
  final RxList<Map<String, dynamic>> pdcList = <Map<String, dynamic>>[].obs;
  final Rxn<int> selectedDelegatedPdcId = Rxn<int>();
  //---------------------------------------------------------

  // ✅ FEEDER SELECTION OBSERVABLES
  final selectedFeeders = <int>[].obs;
  final RxList<Map<String, dynamic>> allFeeders = <Map<String, dynamic>>[].obs;
  final turnedOffFeeders = <int>[].obs;
  final feederConfirmationConsent = false.obs;
  int? _ptwId;

  bool get isBottomBarVisible {
    final status = ptwData['current_status']?.toString().toUpperCase() ?? '';
    switch (currentUserRole.value.toUpperCase()) {
      case 'LS':
        return !(status == 'SUBMITTED' ||
            status == 'IN_EXECUTION' ||
            status == 'PTW_ISSUED');
      case 'SDO':
        return !(status == 'SDO_FORWARDED_TO_XEN');
      case 'XEN':
        return !(status == 'XEN_APPROVED_TO_PDC');
      case 'PDC':
        return !(status == 'PDC_DELEGATED_TO_GRID');
      case 'GRIDOPERATOR':
        return !(status == 'PTW_ISSUED');
      default:
        return true;
    }
  }

  // -------------------- INIT --------------------
  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    handleArguments();
    // determinePosition();
    final args = Get.arguments ?? {};
    final int ptwId = args['ptw_id'] ?? 0;

    if (ptwId != 0) {
      fetchPtwDetails(ptwId);
    }
    ever(currentUserRole, (role) {
      if (role == 'PDC' && ptwData.isNotEmpty) {
        populatePdcListFromPtwData();
      }
    });
  }

  // ✅ POPULATE PDC LIST FROM PTW DATA (active_pdc_users)
  void populatePdcListFromPtwData() {
    log('🔍 populatePdcListFromPtwData called');
    log('Current Role: ${currentUserRole.value}');
    log('ptwData keys: ${ptwData.keys.toList()}');

    try {
      final activePdcUsers = ptwData['active_pdc_users'];

      log('active_pdc_users type: ${activePdcUsers.runtimeType}');
      log('active_pdc_users value: $activePdcUsers');

      if (activePdcUsers != null && activePdcUsers is List && activePdcUsers.isNotEmpty) {
        pdcList.value = activePdcUsers.map((user) {
          return {
            'id': user['id'],
            'name': user['name'],
            'sap_code': user['sap_code'],
            'is_current_user': user['is_current_user'] ?? false,
            'active_ptw_count': user['active_ptw_count'] ?? 0,
            'last_activity_at': user['last_activity_at'],
            'device_name': user['device_name'],
            'device_model': user['device_model'],
          };
        }).toList();

        log('✅ PDC list populated: ${pdcList.length} PDCs found');
        for (var pdc in pdcList) {
          log('  - ${pdc['name']} (${pdc['sap_code']}) - Current: ${pdc['is_current_user']}');
        }
      } else {
        log('⚠️ No active PDC users found or list is empty');
        log('  - Is null: ${activePdcUsers == null}');
        log('  - Is List: ${activePdcUsers is List}');
        log('  - Is empty: ${activePdcUsers is List ? activePdcUsers.isEmpty : "N/A"}');
      }
    } catch (e, stackTrace) {
      log('❌ Error populating PDC list: $e', stackTrace: stackTrace);
    }
  }

  // ✅ POPULATE FEEDERS FROM PTW DATA
  void populateFeedersFromPtw() {
    allFeeders.clear();
    turnedOffFeeders.clear();
    feederConfirmationConsent.value = false;

    // Get primary_feeders map from API
    final primaryFeedersMap = ptwData['primary_feeders'] as Map<String, dynamic>?;

    if (primaryFeedersMap == null) return;

    // Loop through each grid
    primaryFeedersMap.forEach((gridKey, gridData) {
      final gridInfo = gridData as Map<String, dynamic>;
      final gridId = gridInfo['grid_id'];
      final gridCode = gridInfo['grid_code'] ?? '';
      final operator = gridInfo['operator'] as Map<String, dynamic>?;
      final operatorName = operator?['name'] ?? '';
      final feedersData = gridInfo['feeders'] as Map<String, dynamic>?;

      if (feedersData == null) return;

      // Add PRIMARY feeders
      final primaryFeeders = feedersData['primary'] as List?;
      if (primaryFeeders != null) {
        for (var feeder in primaryFeeders) {
          final feederId = feeder['id'];
          final isOn = feeder['is_on'] ?? true;

          allFeeders.add({
            'id': feederId,
            'name': feeder['name'],
            'code': feeder['code'],
            'type': 'Primary',
            'grid_id': gridId,
            'grid_name': 'Grid $gridCode',
            'grid_code': gridCode,
            'operator_name': operatorName,
          });

          // ✅ Add to turnedOffFeeders if is_on = false
          if (!isOn) {
            turnedOffFeeders.add(feederId);
          }
        }
      }

      // Add SECONDARY feeders
      final secondaryFeeders = feedersData['secondary'] as List?;
      if (secondaryFeeders != null) {
        for (var feeder in secondaryFeeders) {
          final feederId = feeder['id'];
          final isOn = feeder['is_on'] ?? true;

          allFeeders.add({
            'id': feederId,
            'name': feeder['name'],
            'code': feeder['code'],
            'type': 'Secondary',
            'grid_id': gridId,
            'grid_name': 'Grid $gridCode',
            'grid_code': gridCode,
            'operator_name': operatorName,
          });

          // ✅ Add to turnedOffFeeders if is_on = false
          if (!isOn) {
            turnedOffFeeders.add(feederId);
          }
        }
      }
    });
  }
// Add this method to PtwReviewSdoController class

  /// ✅ Delegate PTW to another PDC
  Future<void> delegateToPdc(int ptwId, int toPdcId, String reason) async {
    isSubmitting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Authentication token not found.',
        );
        isSubmitting.value = false;
        return;
      }

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/delegate-to-pdc',
      );

      final body = {
        'to_pdc_id': toPdcId,
        'reason': reason,
      };

      log('🚀 Delegating PTW $ptwId to PDC $toPdcId');
      log('📦 Body: $body');

      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      log('📡 Response Status: ${response.statusCode}');
      log('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(
          title: 'Success',
          message: 'PTW delegated successfully!',
        );

        // ✅ Reset delegation fields
        selectedDelegatedPdcId.value = null;
        showDelegationSection.value = false;
        decisionNotesController.clear();

        // ✅ Navigate back to PTW list
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(AppRoutes.ptwList);
      } else {
        final responseData = jsonDecode(response.body);
        SnackbarHelper.showError(
          title: 'Failed',
          message: responseData['message'] ?? 'Failed to delegate PTW',
        );
      }
    } catch (e, stackTrace) {
      log('❌ Error delegating PTW: $e', stackTrace: stackTrace);
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An error occurred: $e',
      );
    } finally {
      isSubmitting.value = false;
    }
  }
  // -------------------- LOAD USER ROLE --------------------
  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(StorageKeys.userData);

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        dynamic roleData = userData['role'] ?? userData['roles'];
        String role;

        if (roleData is List && roleData.isNotEmpty) {
          role = roleData.first.toString();
        } else if (roleData is String) {
          role = roleData;
        } else {
          role = 'SDO';
        }

        currentUserRole.value = role.toUpperCase();

        // ✅ Store current user ID
        final userId = userData['id'];
        if (userId != null) {
          currentUserId.value = userId is int
              ? userId
              : int.tryParse(userId.toString()) ?? 0;
          log('✅ Current user ID loaded: ${currentUserId.value}');
        } else {
          currentUserId.value = 0;
          log('⚠️ User ID not found in userData');
        }

        // ✅ Load grid ID for GridOperator from postings
        if (role.toUpperCase() == 'GRIDOPERATOR') {
          final postings = userData['postings'];
          if (postings != null) {
            final gridId = postings['grid_id'];
            if (gridId != null) {
              currentUserId.value = gridId is int
                  ? gridId
                  : int.tryParse(gridId.toString()) ?? 0;

              log('✅ Grid ID loaded from postings: ${currentUserId.value}');
              return;
            }

            final grid = postings['grid'];
            if (grid != null && grid is Map) {
              final gridIdFromGrid = grid['id'];
              if (gridIdFromGrid != null) {
                currentUserId.value = gridIdFromGrid is int
                    ? gridIdFromGrid
                    : int.tryParse(gridIdFromGrid.toString()) ?? 0;
                log('✅ Grid ID loaded from postings.grid: ${currentUserId.value}');
                return;
              }
            }
          }

          log('⚠️ Grid ID not found in postings for GridOperator');
        }

      } else {
        currentUserRole.value = 'SDO';
        currentUserId.value = 0;
      }
    } catch (e, st) {
      currentUserRole.value = 'SDO';
      currentUserId.value = 0;
      log('❌ Error loading user role: $e', stackTrace: st);
    }
  }

  /// ✅ Check if current user is the assigned operator for this PTW
  bool isCurrentUserAssignedOperator() {
    try {
      if (currentUserRole.value != 'GRIDOPERATOR') {
        log('❌ User is not a GRIDOPERATOR');
        return false;
      }

      final status = ptwData['current_status']?.toString().toUpperCase() ?? '';

      if (status == 'PDC_DELEGATED_TO_GRID') {
        log('✅ Status is PDC_DELEGATED_TO_GRID - allowing access');
        return true;
      }

      if (status == 'GRID_RESOLVE_REQUIRED') {
        log('🔍 Checking GRID_RESOLVE_REQUIRED access');
        return _isCurrentGridHasResolveRequired();
      }

      log('⚠️ Status not eligible: $status');
      return false;
    } catch (e, stackTrace) {
      log('❌ Error in isCurrentUserAssignedOperator: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// ✅ Check if current user's GRID has RESOLVE_REQUIRED status
  bool _isCurrentGridHasResolveRequired() {
    try {
      final primaryFeedersMap = ptwData['primary_feeders'];

      if (primaryFeedersMap == null || primaryFeedersMap is! Map) {
        log('⚠️ primary_feeders is null or not a Map');
        return false;
      }

      final currentUserGridId = currentUserId.value;

      for (var entry in primaryFeedersMap.entries) {
        final gridData = entry.value;

        if (gridData is Map) {
          final operators = gridData['operators'] as List?;

          if (operators != null && operators.isNotEmpty) {
            for (var operator in operators) {
              if (operator is Map) {
                final operatorStatus = operator['status']?.toString().toUpperCase() ?? '';
                final operatorGridId = gridData['grid_id'];

                if (operatorStatus == 'RESOLVE_REQUIRED') {
                  if (_isCurrentUserInThisGrid(operatorGridId)) {
                    log('✅ Current user\'s grid has RESOLVE_REQUIRED status');
                    return true;
                  }
                }
              }
            }
          }
        }
      }

      log('❌ Current user\'s grid does NOT have RESOLVE_REQUIRED status');
      return false;
    } catch (e, stackTrace) {
      log('❌ Error in _isCurrentGridHasResolveRequired: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// Helper to check if current user belongs to given grid
  bool _isCurrentUserInThisGrid(int gridId) {
    final primaryFeedersMap = ptwData['primary_feeders'];
    if (primaryFeedersMap == null) return false;

    for (var entry in primaryFeedersMap.entries) {
      final gridData = entry.value;
      if (gridData is Map && gridData['grid_id'] == gridId) {
        final operators = gridData['operators'] as List?;
        if (operators != null) {
          for (var op in operators) {
            if (op is Map && op['id'] == currentUserId.value) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  // -------------------- HANDLE ROUTE ARGUMENTS --------------------
  void handleArguments() {
    final ptwIdArg = Get.arguments?['ptw_id'];
    log('Received ptw_id argument: $ptwIdArg of type ${ptwIdArg.runtimeType}');

    if (ptwIdArg != null) {
      int? ptwId;
      if (ptwIdArg is int) {
        ptwId = ptwIdArg;
      } else if (ptwIdArg is String) {
        ptwId = int.tryParse(ptwIdArg);
      }

      if (ptwId != null) {
        _ptwId = ptwId;
        fetchPtwDetails(ptwId);
      } else {
        isLoading.value = false;
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Invalid PTW ID format.',
        );
        log('Error: Invalid PTW ID format');
      }
    } else {
      isLoading.value = false;
      SnackbarHelper.showError(title: 'Error', message: 'PTW ID not found.');
      log('Error: PTW ID not found in arguments');
    }
  }

  // -------------------- FETCH PTW DETAILS --------------------
  Future<void> fetchPtwDetails(int ptwId) async {
    isLoading.value = true;
    try {
      final data = await fetchPtwPreview(ptwId);

      if (data != null && data['data'] != null) {
        ptwData.value = data['data']['ptw'] ?? {};
        checklists.value = data['data']['checklists'] ?? {};

        // ✅ Store active_pdc_users separately at DATA level, not PTW level
        final activePdcUsersData = data['data']['active_pdc_users'];

        log('📋 Fetched PTW Details:');
        log('  - PTW ID: ${ptwData['id']}');
        log('  - Status: ${ptwData['current_status']}');
        log('  - active_pdc_users count: ${activePdcUsersData is List ? activePdcUsersData.length : 0}');

        // ✅ Add active_pdc_users to ptwData for easy access
        if (activePdcUsersData != null) {
          ptwData['active_pdc_users'] = activePdcUsersData;
        }

        populateFeedersFromPtw();

        if (currentUserRole.value == 'PDC') {
          log('🔍 Populating PDC list...');
          populatePdcListFromPtwData();
        }
      } else {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Failed to load PTW details.',
        );
      }
    } catch (e, stacktrace) {
      log('❌ Error in fetchPtwDetails: $e', stackTrace: stacktrace);
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }
  // ✅ Fetch PTW Preview API
  Future<Map<String, dynamic>?> fetchPtwPreview(int ptwId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);
      if (token == null) {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Authentication token not found.',
        );
        return null;
      }

      final role = currentUserRole.value.isNotEmpty
          ? currentUserRole.value
          : 'SDO';

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/preview?role=$role',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('Response Status: ${response.statusCode}');
      log('Response Length: ${response.body.length}');
      log('Response Body: ${response.body}');


      // ✅ DON'T print full response - just decode and check
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ✅ Check specifically for active_pdc_users
        final activePdcUsers = data['data']?['active_pdc_users'];

        log('Has active_pdc_users key: ${data['data']?.containsKey("active_pdc_users")}');
        log('active_pdc_users type: ${activePdcUsers.runtimeType}');
        log('active_pdc_users length: ${activePdcUsers is List ? activePdcUsers.length : "not a list"}');

        if (activePdcUsers != null && activePdcUsers is List) {
          log('✅ active_pdc_users found with ${activePdcUsers.length} PDCs');
          for (var pdc in activePdcUsers) {
            log('  - PDC: ${pdc['name']} (ID: ${pdc['id']})');
          }
        } else {
          log('⚠️ active_pdc_users is null or empty');
        }

        return data;
      } else {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Failed to fetch preview (Status ${response.statusCode})',
        );
        return null;
      }
    } catch (e, stackTrace) {
      log('❌ Error: $e', stackTrace: stackTrace);
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An error occurred: $e',
      );
      return null;
    }
  }
  bool shouldAskForNotes(String role) {
    final normalizedRole = role.trim().toUpperCase();
    final status = (ptwData['current_status'] ?? '').toString().toUpperCase();

    switch (normalizedRole) {
      case 'LS':
        return status == 'SDO_RETURNED' ||
            status == 'XEN_RETURNED_TO_LS' ||
            status == 'PDC_RETURNED_TO_LS';
      case 'SDO':
        return status == 'SUBMITTED' ||
            status == 'XEN_RETURNED_TO_SDO' ||
            status == 'CANCELLATION_REQUESTED_BY_LS';
      case 'XEN':
        return status == 'SDO_FORWARDED_TO_XEN' ||
            status == 'LS_RESUBMIT_TO_XEN';
      case 'PDC':
        return status == 'XEN_APPROVED_TO_PDC' ||
            status == 'LS_RESUBMIT_TO_PDC' ||
            status == 'PTW_ISSUED' ||
            status == 'RE_SUBMITTED_TO_PDC';
      case 'GRIDOPERATOR':
      default:
        return false;
    }
  }

  // -------------------- SUBMIT PTW --------------------
  Future<void> submitPtw({String? notes}) async {
    if (_ptwId == null) {
      SnackbarHelper.showError(
        title: 'Error',
        message: 'PTW ID is missing. Cannot submit.',
      );
      return;
    }

    String notes = '';
    isSubmitting.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);
      if (token == null) {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Authentication Token not found.',
        );
        isSubmitting.value = false;
        return;
      }

      final body = <String, dynamic>{};

      if (notes != null && notes.trim().isNotEmpty) {
        body['notes'] = notes.trim();
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/$_ptwId/submit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(
          title: 'Success',
          message: 'PTW submitted successfully!',
        );
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAllNamed(AppRoutes.home);
        });
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Failed to submit PTW.';
        SnackbarHelper.showError(title: 'Error', message: errorMessage);
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An error occurred: $e',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // -------------------- DECISION NOTES CONTROLLER --------------------
  final TextEditingController decisionNotesController = TextEditingController();

  Future<void> forwardPTW(
      int ptwId,
      String role,
      String? notes, {
        PtwActionType action = PtwActionType.forward,
        List<ChecklistItem>? checklistItems,
        List<XFile>? attachments,
      }) async {
    isSubmitting.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);
      if (token == null) {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Authentication token not found.',
        );
        isSubmitting.value = false;
        return;
      }

      final roleKey = role.toUpperCase();

      // Matrix se endpoint nikaalo
      String? endpoint = ptwActionMatrix[roleKey]?[action];

      // Optional: backward compatibility / fallback
      if (endpoint == null) {
        switch (roleKey) {
          case 'LS':
            endpoint = 'submit';
            break;
          case 'SDO':
            endpoint = 'forward-xen';
            break;
          case 'XEN':
            endpoint = 'xen/approve-pdc';
            break;
          case 'PDC':
            endpoint = 'delegate-grid';
            break;
          case 'GRIDOPERATOR':
            endpoint = 'prechecks-done';
            break;
          default:
            endpoint = 'forward-sdo';
        }
      }

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/$endpoint',
      );
      Map<String, dynamic> body = {"notes": notes};

// ✅ PDC DELEGATION - Include to_pdc_id if action is delegatePDC
      if (action == PtwActionType.delegatePDC && selectedDelegatedPdcId.value != null) {
        body['to_pdc_id'] = selectedDelegatedPdcId.value;
        log('✅ Delegating to PDC ID: ${selectedDelegatedPdcId.value}');
      }

// ✅ GRID DELEGATION - Include delegated_pdc_id for grid delegation
      if (roleKey == 'PDC' && action == PtwActionType.forward && selectedDelegatedPdcId.value != null) {
        body['delegated_pdc_id'] = selectedDelegatedPdcId.value;
        log('✅ Delegating to PDC ID for grid: ${selectedDelegatedPdcId.value}');
      }


      // ✅ PDC DELEGATION - Include delegated_pdc_id if selected
      // if (roleKey == 'PDC' && selectedDelegatedPdcId.value != null) {
      //   body['delegated_pdc_id'] = selectedDelegatedPdcId.value;
      //   log('✅ Delegating to PDC ID: ${selectedDelegatedPdcId.value}');
      // }

      if (roleKey == 'PDC' &&
          (action == PtwActionType.pdcIssue ||
              action == PtwActionType.returnGrid)) {

        // ✅ Validate consent checkbox if feeders are turned OFF
        if (turnedOffFeeders.isNotEmpty && !feederConfirmationConsent.value) {
          SnackbarHelper.showError(
            title: 'Consent Required',
            message: 'Please confirm that the feeder information is accurate by checking the consent checkbox.',
          );
          isSubmitting.value = false;
          return;
        }

        // ✅ Send all feeders with their is_on status
        body['feeders'] = allFeeders.map((feeder) {
          return {
            'id': feeder['id'],
            'is_on': !turnedOffFeeders.contains(feeder['id']),
          };
        }).toList();

        log('Feeders Data: ${body['feeders']}');
      }

      // GRIDOPERATOR + prechecksDone ke liye special payload
      if (roleKey == 'GRIDOPERATOR' && action == PtwActionType.prechecksDone) {
        if (checklistItems != null) {
          body['answers'] = checklistItems.map((e) {
            return {
              "checklist_item_id": e.id,
              "value": e.value == true ? "YES" : "NO",
            };
          }).toList();
        }

        if (attachments != null && attachments.isNotEmpty) {
          List<Map<String, String>> files = [];
          for (var file in attachments) {
            final bytes = await file.readAsBytes();
            files.add({"filename": file.name, "file": base64Encode(bytes)});
          }
          body['attachments'] = files;
        }
      }

      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        hideBottomBar.value = true;
        SnackbarHelper.showSuccess(
          title: 'Success',
          message: 'PTW action completed successfully!',
        );
        isSubmitting.value = false;

        // ✅ Reset delegation selection after successful action
        // ✅ Reset delegation selection after successful action
        selectedDelegatedPdcId.value = null;

        await Future.delayed(const Duration(seconds: 3));
        Get.offAllNamed(AppRoutes.ptwList);
      } else {
        final responseData = jsonDecode(response.body);
        SnackbarHelper.showError(
          title: 'Failed',
          message:
          'Error ${response.statusCode}: ${responseData['message'] ?? 'Unknown error'}',
        );
        isSubmitting.value = false;
      }
    } catch (e) {
      isSubmitting.value = false;
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An error occurred: $e',
      );
    }
  }

  Future<void> submitGridOperatorPrechecks(
      int ptwId,
      String notes,
      List<ChecklistItem> checklistItems,
      List<XFile> attachments,
      ) async {
    isSubmitting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(title: "Error", message: "Token missing");
        return;
      }

      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/prechecks-done",
      );

      final request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "Bearer $token";
      request.headers["Accept"] = "application/json";

      request.fields["notes"] = notes;

      for (int i = 0; i < checklistItems.length; i++) {
        request.fields["answers[$i][checklist_item_id]"] = checklistItems[i].id
            .toString();

        request.fields["answers[$i][value]"] = (checklistItems[i].value == true)
            ? "YES"
            : "NO";
      }

      for (int i = 0; i < attachments.length; i++) {
        final file = attachments[i];
        final fileBytes = await file.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            "evidences[$i][file]",
            fileBytes,
            filename: file.name,
          ),
        );

        request.fields["evidences[$i][type]"] = "GRID_PTW_ISSUE";
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(
          title: "Success",
          message: "PTW marked as ISSUED!",
        );

        isSubmitting.value = true;
        Get.back(result: true);
        await Future.delayed(Duration(seconds: 2));
        Get.offAllNamed(AppRoutes.home);
      } else {
        final data = jsonDecode(response.body);
        SnackbarHelper.showError(
          title: "Error",
          message: data["message"] ?? "Unknown error",
        );
        isSubmitting.value = false;
      }
    } catch (e) {
      SnackbarHelper.showError(title: "Exception", message: e.toString());
      isSubmitting.value = false;
    }
  }

  Future<void> submitCancelByLs(
      int ptwId,
      String notes,
      List<ChecklistItem> checklistItems,
      List<XFile> attachments,
      ) async {
    isSubmitting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(title: "Error", message: "Token missing");
        return;
      }

      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/cancel-by-ls",
      );

      final request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "Bearer $token";
      request.headers["Accept"] = "application/json";

      request.fields["notes"] = notes;

      for (int i = 0; i < checklistItems.length; i++) {
        request.fields["answers[$i][checklist_item_id]"] = checklistItems[i].id
            .toString();

        request.fields["answers[$i][value]"] = (checklistItems[i].value == true)
            ? "YES"
            : "NO";
      }

      for (int i = 0; i < attachments.length; i++) {
        final file = attachments[i];
        final fileBytes = await file.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            "evidences[$i][file]",
            fileBytes,
            filename: file.name,
          ),
        );

        request.fields["evidences[$i][type]"] = "PTW_CANCEL_BY_LS";
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(
          title: "Success",
          message: "PTW Cancel request forwarded to SDO",
        );

        isSubmitting.value = true;
        Get.back(result: true);
        await Future.delayed(Duration(seconds: 2));
        Get.offAllNamed(AppRoutes.home);
      } else {
        final data = jsonDecode(response.body);
        SnackbarHelper.showError(
          title: "Error",
          message: data["message"] ?? "Unknown error",
        );
        isSubmitting.value = false;
      }
    } catch (e) {
      SnackbarHelper.showError(title: "Exception", message: e.toString());
      isSubmitting.value = false;
    }
  }

  // Future<void> determinePosition() async {
  //   isFetchingLocation.value = true;
  //
  //   bool enabled = await Geolocator.isLocationServiceEnabled();
  //   if (!enabled) {
  //     isFetchingLocation.value = false;
  //     SnackbarHelper.showError(
  //       title: 'Location Error',
  //       message: 'Location services are disabled.',
  //     );
  //     return;
  //   }
  //
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       isFetchingLocation.value = false;
  //       SnackbarHelper.showError(
  //         title: "Location Error",
  //         message: "Location permissions denied.",
  //       );
  //       return;
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     isFetchingLocation.value = false;
  //     SnackbarHelper.showError(
  //       title: "Location Error",
  //       message: "Location permanently denied.",
  //     );
  //     return;
  //   }
  //
  //   try {
  //     Position pos = await Geolocator.getCurrentPosition();
  //     currentLocation.value = LatLng(pos.latitude, pos.longitude);
  //
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       pos.latitude,
  //       pos.longitude,
  //     );
  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks[0];
  //       currentAddress.value =
  //       "${place.street}, ${place.subLocality}, ${place.locality}";
  //     }
  //   } catch (e) {
  //     SnackbarHelper.showError(
  //       title: "Location Error",
  //       message: "Failed to get location: $e",
  //     );
  //   } finally {
  //     isFetchingLocation.value = false;
  //   }
  // }

  Future<void> pickImages() async {
    final XFile? rawImage = await ImageProcessor.pickImage();
    if (rawImage != null) {
      images.add(rawImage);
      unawaited(_processAndReplaceImage(rawImage));
    }
  }

  Future<void> _processAndReplaceImage(XFile rawImage) async {
    final XFile processedImage = await ImageProcessor.processImage(
      rawImage,
      currentLocation,
      currentAddress,
    );
    final int index = images.indexWhere((f) => f.path == rawImage.path);
    if (index != -1) {
      images[index] = processedImage;
    }
  }

  void removeImage(XFile image) {
    images.remove(image);
  }

  @override
  void onClose() {
    decisionNotesController.dispose();
    googleMapController?.dispose();
    super.onClose();
  }
}
