import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/models/hse_field_check_item.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HseFieldCheckController extends GetxController {
  // ── Form Controllers ──────────────────────────────────────────────────────
  final inspectionTypeCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  final circleDivCtrl = TextEditingController();
  final supervisorCtrl = TextEditingController();
  final staffDetailCtrl = TextEditingController();
  final natureOfWorkCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final nameDesignationCtrl = TextEditingController();

  // ── Inspection Type ───────────────────────────────────────────────────────
  final RxString inspectionType = ''.obs; // 'Routine', 'Surprise', 'Follow-up'

  // ── Loading ───────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
// ── Checklist Rows (items from the performa) ────────────────────────────
  final RxList<HseChecklistRow> checklistRows = <HseChecklistRow>[
    HseChecklistRow(
      srNo: 1,
      description: 'Safety briefing / toolbox talk conducted and recorded',
    ),
    HseChecklistRow(
      srNo: 2,
      description: 'Only trained and authorized personnel working at site',
    ),
    HseChecklistRow(
      srNo: 3,
      description: 'Supervisor / Line Superintendent available and supervising',
    ),
    HseChecklistRow(
      srNo: 4,
      description: 'All required PPE available, properly worn by workers, and inspected for defects',
    ),
    HseChecklistRow(
      srNo: 5,
      description: 'Line(s) tested before work using approved LV/HT voltage detector and testing method',
    ),
    HseChecklistRow(
      srNo: 6,
      description: 'Earthing applied on both sides of work area as per approved SOP',
    ),
    HseChecklistRow(
      srNo: 7,
      description: 'Ladders used safely – poles/structures sound and free from cracks/damage',
    ),
    HseChecklistRow(
      srNo: 8,
      description: 'Crane operations (if applicable) follow all safety measures',
    ),
    HseChecklistRow(
      srNo: 9,
      description: 'Tools and equipment in safe condition and used properly',
    ),
    HseChecklistRow(
      srNo: 10,
      description: 'Weather conditions considered before and during work',
    ),
    HseChecklistRow(
      srNo: 11,
      description: 'Traffic control measures (cones, flagman, barricades) in place when working on roads/main streets',
    ),
    HseChecklistRow(
      srNo: 12,
      description: 'First aid kit available and workers aware of first aid / emergency procedures',
    ),
    HseChecklistRow(
      srNo: 13,
      description: 'Additional support arranged if site or environmental conditions change',
    ),
    HseChecklistRow(
      srNo: 14,
      description: 'Ensured that staff is confident to report any near misses / incidents immediately (if occurs)',
    ),
  ].obs;
  // // ── Checklist Rows (9 items from the performa) ────────────────────────────
  // final RxList<HseChecklistRow> checklistRows = <HseChecklistRow>[
  //   HseChecklistRow(
  //     srNo: 1,
  //     description: 'Use of PPE by all staff (helmets, gloves, etc.)',
  //   ),
  //   HseChecklistRow(srNo: 2, description: 'Work Permit available'),
  //   HseChecklistRow(
  //     srNo: 3,
  //     description: 'Safety briefing conducted before task',
  //   ),
  //   HseChecklistRow(srNo: 4, description: 'Supervisor / LS available on site'),
  //   HseChecklistRow(
  //     srNo: 5,
  //     description: 'Earthing and lockout/tagout procedures followed',
  //   ),
  //   HseChecklistRow(srNo: 6, description: 'Safe use of ladders/cranes/tools'),
  //   HseChecklistRow(
  //     srNo: 7,
  //     description: 'Weather conditions considered before work',
  //   ),
  //   HseChecklistRow(
  //     srNo: 8,
  //     description: 'Trained and authorized personnel only',
  //   ),
  //   HseChecklistRow(srNo: 9, description: 'HT Detector available and used'),
  // ].obs;

  // ── Non-Compliance Rows (Start with 1 row) ─────────────────────────────────
  final RxList<NonComplianceRow> nonComplianceRows = <NonComplianceRow>[
    NonComplianceRow(),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _setDefaultDateTime();
    _getCurrentLocation();
  }

  void _setDefaultDateTime() {
    final now = DateTime.now();
    dateCtrl.text = DateFormat('dd/MM/yyyy').format(now);
    timeCtrl.text = DateFormat('hh:mm a').format(now);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
        address = address.replaceAll(RegExp(r', ,'), ',');
        if (address.startsWith(', ')) address = address.substring(2);
        
        locationCtrl.text = address;
      } else {
        locationCtrl.text = "${position.latitude}, ${position.longitude}";
      }
    } catch (e) {
      log('Error getting location: $e');
    }
  }

  // ── Set Yes/No/NA response ────────────────────────────────────────────────
  void setResponse(int index, String value) {
    final updated = checklistRows[index];
    updated.response = value;
    checklistRows[index] = updated;
    checklistRows.refresh();
  }

  // ── Update observation text ────────────────────────────────────────────────
  void setObservation(int index, String value) {
    checklistRows[index].observations = value;
  }

  // ── Update non-compliance row fields ──────────────────────────────────────
  void setNonComplianceField(int rowIndex, String field, String value) {
    final row = nonComplianceRows[rowIndex];
    if (field == 'description') row.description = value;
    if (field == 'immediateAction') row.immediateAction = value;
    if (field == 'responsiblePerson') row.responsiblePerson = value;
  }

  void addNonComplianceRow() {
    nonComplianceRows.add(NonComplianceRow());
  }

  void removeNonComplianceRow(int index) {
    if (nonComplianceRows.length > 1) {
      nonComplianceRows.removeAt(index);
    }
  }

  // ── Date Picker ───────────────────────────────────────────────────────────
  Future<void> pickDate(BuildContext context) async {
    // Disabled as per request to make it unclickable/read-only
    return;
    /*
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
    }
    */
  }

  // ── Time Picker ───────────────────────────────────────────────────────────
  Future<void> pickTime(BuildContext context) async {
    // Disabled as per request to make it unclickable/read-only
    return;
    /*
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      timeCtrl.text = picked.format(context);
    }
    */
  }

  // ── Submit Form ───────────────────────────────────────────────────────────
  Future<void> submitForm() async {
    // Basic validation
    if (inspectionType.value.isEmpty) {
      SnackbarHelper.showWarning(
        title: 'Validation',
        message: 'Please select an inspection type.',
      );
      return;
    }
    if (locationCtrl.text.trim().isEmpty) {
      SnackbarHelper.showWarning(
        title: 'Validation',
        message: 'Please enter the location.',
      );
      return;
    }
    if (dateCtrl.text.trim().isEmpty) {
      SnackbarHelper.showWarning(
        title: 'Validation',
        message: 'Please select a date.',
      );
      return;
    }

    // Check all checklist rows have a response
    final unanswered = checklistRows.where((r) => r.response.isEmpty).toList();
    if (unanswered.isNotEmpty) {
      SnackbarHelper.showWarning(
        title: 'Validation',
        message:
        'Please answer all checklist items (Yes / No / NA) before submitting.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken) ?? '';

      final payload = {
        'inspection_type': inspectionType.value,
        'location': locationCtrl.text.trim(),
        'date': dateCtrl.text.trim(),
        'time': timeCtrl.text.trim(),
        'circle_division': circleDivCtrl.text.trim(),
        'supervisor': supervisorCtrl.text.trim(),
        'staff_detail': staffDetailCtrl.text.trim(),
        'nature_of_work': natureOfWorkCtrl.text.trim(),
        'checklist': checklistRows.map((r) => r.toJson()).toList(),
        'non_compliance': nonComplianceRows.map((r) => r.toJson()).toList(),
        'remarks': remarksCtrl.text.trim(),
        'name_designation': nameDesignationCtrl.text.trim(),
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/hse-field-check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      log('HSE Submit Response: ${response.statusCode} — ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackbarHelper.showSuccess(
          title: 'Submitted',
          message: 'HSE Field Check Performa submitted successfully.',
        );
        await Future.delayed(const Duration(seconds: 2));
        Get.back();
      } else {
        SnackbarHelper.showError(
          title: 'Submission Failed',
          message: 'Status: ${response.statusCode}\nBody: ${response.body}',
        );
      }
    } catch (e, st) {
      log('HSE Submit Error: $e', stackTrace: st);
      SnackbarHelper.showError(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    inspectionTypeCtrl.dispose();
    locationCtrl.dispose();
    dateCtrl.dispose();
    timeCtrl.dispose();
    circleDivCtrl.dispose();
    supervisorCtrl.dispose();
    staffDetailCtrl.dispose();
    natureOfWorkCtrl.dispose();
    remarksCtrl.dispose();
    nameDesignationCtrl.dispose();
    super.onClose();
  }
}
