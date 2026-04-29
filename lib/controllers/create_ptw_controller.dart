
import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:http/http.dart' as http;
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/utils/image_processor.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'package:mepco_esafety_app/widgets/planned_schedule_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RoutineEmergency {
  PLANNED,
  EMERGENCY,
  MISC,
}

enum CircuitType {
  SINGLE,
  MULTI,
}

class Feeder {
  final int id;
  final String name;
  final String code;

  Feeder({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Feeder.fromJson(Map<String, dynamic> json) {
    return Feeder(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class TeamMember {
  final int id;
  final String name;
  TeamMember({required this.id, required this.name});
  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      TeamMember(id: json['id'], name: json['name']);
}

class Transformer {
  final int id;
  final String transformerId;
  final String address;
  Transformer({required this.id, required this.transformerId, required this.address});
  factory Transformer.fromJson(Map<String, dynamic> json) =>
      Transformer(id: json['id'], transformerId: json['transformer_id'], address: json['address']);
}

class ExistingEvidence {
  final int id;
  final String url;

  ExistingEvidence({required this.id, required this.url});
}

class CreatePtwController extends GetxController {
  // NEW:
  final bool isEdit;
  final int? ptwId;

  CreatePtwController({
    this.isEdit = false,
    this.ptwId,
  });

  // ---------------------- States ----------------------
  var selectedOption = Rxn<RoutineEmergency>(); // Changed to nullable, no default selection
  var selectedCircuitType = CircuitType.SINGLE.obs;
  final List<String> miscOptions = ['MCO', 'RCO','SCO', 'ERO', 'SJO', 'COMPLAINT'];
  var selectedMiscOption = RxnString();
  var isSubmitting = false.obs;
  var isDropdownOpen = false.obs;
  var isPtwRequired = true.obs; // For PTW Required Yes/No
  var primaryFeeders = <Feeder>[].obs;  // Changed from feeders
  var secondaryFeeders = <Feeder>[].obs;
  // NEW: Schedule variables for PLANNED
  var scheduleFromDate = Rxn<DateTime>();
  var scheduleToDate = Rxn<DateTime>();
  var scheduleDates = <DateTime>[].obs;
  var scheduleStartTimes = <String>[].obs;
  var scheduleEndTimes = <String>[].obs;

  // ---------------------- Text Controllers ----------------------
  final dateController = TextEditingController();
  final subDivisionController = TextEditingController();
  final subDivisionIdController = TextEditingController();
  final scheduledStartAtController = TextEditingController();
  final switchOffTimeController = TextEditingController();
  final restoreTimeController = TextEditingController();
  final estimatedDurationMinController = TextEditingController();
  final feederInchargeController = TextEditingController();
  final placeOfWorkController = TextEditingController();
  final assetController = TextEditingController();
  final closeFeederController = TextEditingController();
  final descriptionController = TextEditingController();
  final safetyArrangementsController = TextEditingController();
  final alternateFeederController = TextEditingController();
  final referenceNumberController = TextEditingController();

  // ---------------------- API Data ----------------------
  var subDivision = ''.obs;
  var subDivisionId = 0.obs;
  var feeders = <Feeder>[].obs;
  var teamMembers = <TeamMember>[].obs;
  var transformers = <Transformer>[].obs;
  var selectedFeederId = RxnInt();
  var selectedSecondaryFeederIds = <int>[].obs;
  var selectedTeamMemberIds = <int>[].obs;
  var selectedTransformerId = RxnInt();

  // ---------------------- Attachments ----------------------
  var sitePhotos = <XFile>[].obs;

  // ---------------------- Map & Location ----------------------
  GoogleMapController? googleMapController;
  var isFetchingLocation = true.obs;
  var isFetchingContext = true.obs;
  var isFetchingTransformers = false.obs;
  var currentLocation = Rxn<LatLng>();
  var currentAddress = RxnString();

  // ---------------------- Existing evidences for EDIT ----------------------
  var existingEvidenceUrls = <String>[].obs;
  var existingEvidences = <ExistingEvidence>[].obs;
  var deletedEvidenceIds = <int>[].obs;

  // ---------------------- Lifecycle ----------------------
  @override
  void onInit() {
    super.onInit();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    determinePosition();
    _initForm();

    // Listen to selectedOption changes and update isPtwRequired accordingly
    ever(selectedOption, (value) {
      if (value == RoutineEmergency.PLANNED || value == RoutineEmergency.EMERGENCY) {
        isPtwRequired.value = true;
      }
      // For MISC, keep the user's selection (don't auto-change)
    });
  }

  void removeExistingEvidence(int evidenceId) {
    existingEvidences.removeWhere((e) => e.id == evidenceId);

    if (!deletedEvidenceIds.contains(evidenceId)) {
      deletedEvidenceIds.add(evidenceId);
    }
  }

  /// Create vs Edit dono ke liye initial load
  Future<void> _initForm() async {
    isFetchingContext.value = true;
    try {
      await fetchPtwContext(); // feeders, teamMembers, sub-division etc. load

      // Agar edit hai to preview se values load karo
      if (isEdit && ptwId != null) {
        await loadPreviewAndFill(ptwId!);
      }
    } finally {
      isFetchingContext.value = false;
    }
  }

  @override
  void onClose() {
    dateController.dispose();
    subDivisionController.dispose();
    subDivisionIdController.dispose();
    scheduledStartAtController.dispose();
    switchOffTimeController.dispose();
    restoreTimeController.dispose();
    estimatedDurationMinController.dispose();
    feederInchargeController.dispose();
    placeOfWorkController.dispose();
    assetController.dispose();
    closeFeederController.dispose();
    descriptionController.dispose();
    safetyArrangementsController.dispose();
    alternateFeederController.dispose();
    referenceNumberController.dispose();
    googleMapController?.dispose();
    super.onClose();
  }

  // ---------------------- Schedule Methods (NEW) ----------------------
  Future<void> showPlannedScheduleDialog(BuildContext context) async {
    final result = await Get.to(
          () => PlannedScheduleDialog(controller: this),
      fullscreenDialog: true,
      transition: Transition.downToUp,
      preventDuplicates: true, // Add this
    );

    // If user cancelled, revert selection
    if (result == null || result == false) {
      selectedOption.value = null;
    }
  }


  void generateScheduleDates() {
    if (scheduleFromDate.value == null || scheduleToDate.value == null) {
      return;
    }

    scheduleDates.clear();
    scheduleStartTimes.clear();
    scheduleEndTimes.clear();

    DateTime current = scheduleFromDate.value!;
    final DateTime end = scheduleToDate.value!;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      scheduleDates.add(current);
      scheduleStartTimes.add('');
      scheduleEndTimes.add('');
      current = current.add(Duration(days: 1));
    }
  }

  void setTimeToAll() {
    if (scheduleStartTimes.isEmpty || scheduleEndTimes.isEmpty) return;

    final firstStartTime = scheduleStartTimes[0];
    final firstEndTime = scheduleEndTimes[0];

    if (firstStartTime.isEmpty || firstEndTime.isEmpty) {
      SnackbarHelper.showError(
        title: 'Validation',
        message: 'Please select start and end time for the first date.',
      );
      return;
    }

    for (int i = 1; i < scheduleStartTimes.length; i++) {
      scheduleStartTimes[i] = firstStartTime;
      scheduleEndTimes[i] = firstEndTime;
    }
  }

  Future<void> selectScheduleTime(
      BuildContext context,
      int index,
      bool isStartTime
      ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      final timeString = DateFormat('HH:mm').format(dt);

      if (isStartTime) {
        scheduleStartTimes[index] = timeString;
      } else {
        scheduleEndTimes[index] = timeString;
      }
    }
  }
  void saveSchedule() {
    // Validate from and to dates
    if (scheduleFromDate.value == null || scheduleToDate.value == null) {
      SnackbarHelper.showError(
        title: 'Validation',
        message: 'Please select From and To dates.',
      );
      return;
    }

    // Validate all times are selected
    for (int i = 0; i < scheduleDates.length; i++) {
      if (scheduleStartTimes[i].isEmpty || scheduleEndTimes[i].isEmpty) {
        SnackbarHelper.showError(
          title: 'Validation',
          message: 'Please select start and end time for all dates.',
        );
        return;
      }
    }

    // Format the schedule data
    final scheduleData = scheduleDates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      return {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'start_time': scheduleStartTimes[index],
        'end_time': scheduleEndTimes[index],
      };
    }).toList();

    print('Schedule Data: $scheduleData');

    // Set PLANNED as selected
    selectedOption.value = RoutineEmergency.PLANNED;

    // Show success
    Get.snackbar(
      'Success',
      'Schedule saved successfully.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );

    // Close the dialog - try both methods
    Future.delayed(const Duration(milliseconds: 500), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      // Fallback
      Navigator.of(Get.context!).pop(true);
    });
  }
  // ---------------------- Image Pickers ----------------------
  Future<void> pickImages() async {
    final XFile? rawImage = await ImageProcessor.pickImage();
    if (rawImage != null) {
      sitePhotos.add(rawImage);

      // Process in background
      unawaited(determinePosition());
      unawaited(_processAndReplaceImage(rawImage));
    }
  }

  Future<void> _processAndReplaceImage(XFile rawImage) async {
    final XFile processedImage = await ImageProcessor.processImage(rawImage, currentLocation, currentAddress);

    final int index = sitePhotos.indexWhere((f) => f.path == rawImage.path);
    if (index != -1) {
      sitePhotos[index] = processedImage;
    }
  }

  void removeImage(XFile photo) => sitePhotos.remove(photo);

// ---------------------- API: Context ----------------------
  Future<void> fetchPtwContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/context'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        // ✅ Load data (SDO check already done in home screen)
        subDivision.value = data['sub_division']['name'];
        subDivisionId.value = data['sub_division']['id'];
        subDivisionController.text = subDivision.value;
        subDivisionIdController.text = subDivisionId.value.toString();

        // Load feeders
        primaryFeeders.value = (data['primary_feeders'] as List)
            .map((feeder) => Feeder.fromJson(feeder))
            .toList();

        secondaryFeeders.value = (data['secondary_feeders'] as List)
            .map((feeder) => Feeder.fromJson(feeder))
            .toList();

        teamMembers.value = (data['team_members'] as List)
            .map((member) => TeamMember.fromJson(member))
            .toList();

      } else {
        // ❌ Unexpected error (shouldn't happen if pre-check passed)
        SnackbarHelper.showError(
          title: 'API Error',
          message: 'Failed to load PTW context. Code: ${response.statusCode}',
        );

        // Go back to prevent broken state
        Get.back();
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: 'Error',
        message: 'Failed to load PTW context: $e',
      );

      // Go back
      Get.back();
    }
  }
  Future<void> loadPreviewAndFill(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/$id/preview');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode != 200) {
        SnackbarHelper.showError(
          title: 'Preview Error',
          message: 'Failed to load PTW preview. Code: ${res.statusCode}',
        );
        return;
      }

      final jsonBody = json.decode(res.body);
      final ptw = jsonBody['data']['ptw'];

      // TYPE + MISC
      final type = ptw['type'];
      final miscType = ptw['misc_type'];

      if (type == 'MISC') {
        selectedOption.value = RoutineEmergency.MISC;
        selectedMiscOption.value = miscType;

        // Load reference number and PTW required status
        referenceNumberController.text = ptw['reference_number'] ?? '';
        final isPtwReqValue = ptw['is_ptw_required'];
        if (isPtwReqValue is int) {
          isPtwRequired.value = isPtwReqValue == 1;
        } else if (isPtwReqValue is bool) {
          isPtwRequired.value = isPtwReqValue;
        } else {
          isPtwRequired.value = true;
        }
      } else if (type == 'PLANNED') {
        selectedOption.value = RoutineEmergency.PLANNED;
        isPtwRequired.value = true;
      } else if (type == 'EMERGENCY') {
        selectedOption.value = RoutineEmergency.EMERGENCY;
        isPtwRequired.value = true;
      }

      // PRIMARY FEEDER
      final feeder = ptw['feeder'];
      if (feeder != null) {
        final feederId = feeder['id'] as int;
        selectedFeederId.value = feederId;

        await fetchTransformers(feederId);
      }

      // SECONDARY FEEDERS
      final secFeeders = (ptw['secondary_feeders'] as List<dynamic>? ?? []);
      selectedSecondaryFeederIds.value =
          secFeeders.map<int>((f) => f['id'] as int).toList();

      // TRANSFORMER
      final transformerName = ptw['transformer_name'];
      if (transformerName != null && transformers.isNotEmpty) {
        final match = transformers.firstWhere(
              (t) => t.transformerId == transformerName,
          orElse: () => transformers.first,
        );
        selectedTransformerId.value = match.id;
      }

      // TIME & DURATION
      switchOffTimeController.text = ptw['switch_off_time'] ?? '';
      restoreTimeController.text = ptw['restore_time'] ?? '';
      estimatedDurationMinController.text =
          (ptw['estimated_duration_min'] ?? '').toString();

      // TEXT FIELDS
      feederInchargeController.text = ptw['feeder_incharge_name'] ?? '';
      placeOfWorkController.text = ptw['place_of_work'] ?? '';
      descriptionController.text = ptw['scope_of_work'] ?? '';
      safetyArrangementsController.text = ptw['safety_arrangements'] ?? '';

      // TEAM MEMBERS
      final teamMembersJson = (ptw['team_members'] as List<dynamic>? ?? []);
      selectedTeamMemberIds.value =
          teamMembersJson.map<int>((m) => m['id'] as int).toList();

      // EVIDENCES
      final evidencesJson = ptw['evidences'] as List? ?? [];
      existingEvidences.value = evidencesJson.map((e) {
        final filePath = e['file_path'] as String;
        final fullUrl = '${ApiConstants.baseUrl}/storage/$filePath';
        return ExistingEvidence(
          id: e['id'] as int,
          url: fullUrl,
        );
      }).toList();

      deletedEvidenceIds.clear();
      sitePhotos.clear();
    } catch (e) {
      SnackbarHelper.showError(
        title: 'Preview Error',
        message: 'Failed to parse PTW preview: $e',
      );
    }
  }

  // ---------------------- API: Transformers ----------------------
  Future<void> fetchTransformers(int feederId) async {
    try {
      isFetchingTransformers.value = true;
      transformers.clear();
      selectedTransformerId.value = null;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/meta/related?feeder_id=$feederId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['lists'];
        transformers.value = (data['transformers'] as List)
            .map((t) => Transformer.fromJson(t))
            .toList();
      } else {
        SnackbarHelper.showError(title: 'API Error', message: 'Failed to load transformers. Code: ${response.statusCode}');
      }
    } catch (e) {
      SnackbarHelper.showError(title: 'API Error', message: 'Failed to load transformers: $e');
    } finally {
      isFetchingTransformers.value = false;
    }
  }

  // ---------------------- Location ----------------------
  Future<void> determinePosition() async {
    isFetchingLocation.value = true;

    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      isFetchingLocation.value = false;
      SnackbarHelper.showError(
          title: 'Location Error',
          message: 'Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        isFetchingLocation.value = false;
        SnackbarHelper.showError(
            title: "Location Error",
            message: "Location permissions denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      isFetchingLocation.value = false;
      SnackbarHelper.showError(
          title: "Location Error",
          message: "Location permanently denied.");
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition();
      currentLocation.value = LatLng(pos.latitude, pos.longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value = "${place.street}, ${place.subLocality}, ${place.locality}";
      }
    } catch (e) {
      SnackbarHelper.showError(
          title: "Location Error", message: "Failed to get location: $e");
    } finally {
      isFetchingLocation.value = false;
    }
  }

  // ---------------------- Date/Time Pickers ----------------------
  void selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      controller.text = DateFormat('HH:mm').format(dt);
      _calculateDuration();
    }
  }

  Future<void> selectScheduledStartAt(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final DateTime combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        scheduledStartAtController.text =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(combined);
      }
    }
  }

  void _calculateDuration() {
    if (switchOffTimeController.text.isNotEmpty &&
        restoreTimeController.text.isNotEmpty) {
      try {
        final timeFormat = DateFormat('HH:mm');
        final switchOffTime = timeFormat.parse(switchOffTimeController.text);
        final restoreTime = timeFormat.parse(restoreTimeController.text);
        int minutes = restoreTime.difference(switchOffTime).inMinutes;

        if (minutes < 0) {
          minutes += 24 * 60;
        }
        estimatedDurationMinController.text = minutes.toString();
      } catch (e) {
        estimatedDurationMinController.text = 'Invalid Time';
      }
    } else {
      estimatedDurationMinController.text = '';
    }
  }

  // ---------------------- Submit PTW ----------------------
  Future<void> submitPtw() async {
    print('_submitted');
    isSubmitting.value = true;
    try {
      // Check if MISC type with "No" PTW Required
      if (selectedOption.value == RoutineEmergency.MISC && !isPtwRequired.value) {
        await _forwardToSdo();
        return;
      }

      if (isEdit && ptwId != null) {
        await _updateStep1();
      } else {
        await _createPtw();
      }

      // After successful save, check if PLANNED → route to review SDO
      if (selectedOption.value == RoutineEmergency.PLANNED) {
        final prefs = await SharedPreferences.getInstance();
        final ptwId = prefs.getInt('ptw_id');
        final ptwCode = prefs.getString('ptw_code');
        final workOrderNo = prefs.getString('work_order_no');

        Get.toNamed(
          AppRoutes.safetyChecklistLineLoad,
          arguments: {
            'ptw_id': ptwId,
            'ptw_code': ptwCode,
            'work_order_no': workOrderNo,
          },
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  // Forward to SDO for MISC without PTW
  Future<void> _forwardToSdo() async {
    print('_forwardToSDO');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(
          title: 'Auth Error',
          message: 'Authentication token not found.',
        );
        return;
      }

      // Validate required fields
      if (selectedMiscOption.value == null || selectedMiscOption.value!.isEmpty) {
        SnackbarHelper.showError(
          title: 'Validation Error',
          message: 'Please select MISC type.',
        );
        return;
      }

      if (referenceNumberController.text.trim().isEmpty) {
        SnackbarHelper.showError(
          title: 'Validation Error',
          message: 'Please enter reference number.',
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/init'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields.addAll({
        'sub_division_id': subDivisionId.value.toString(),
        'type': 'MISC',
        'misc_type': selectedMiscOption.value!,
        'reference_number': referenceNumberController.text.trim(),
        'is_ptw_required': '0',
        'feeder_id': selectedFeederId.value.toString(),
        'transformer_id': selectedTransformerId.value?.toString() ?? '',
        'place_of_work': placeOfWorkController.text,
        'scope_of_work': descriptionController.text,
      });
      for (var i = 0; i < selectedTeamMemberIds.length; i++) {
        request.fields['team_member_ids[$i]'] = selectedTeamMemberIds[i].toString();
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackbarHelper.showSuccess(
          title: 'Success',
          message: 'Request forwarded to SDO successfully.',
        );
        Get.offAllNamed(
          AppRoutes.ptwList,
        );
      } else {
        final decoded = json.decode(body);
        SnackbarHelper.showError(
          title: 'Submission Error',
          message: decoded['message'] ?? 'Failed to forward to SDO.',
        );
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: 'Submission Error',
        message: 'An error occurred: $e',
      );
    }
  }
  Future<void> _createPtw() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(
          title: 'Auth Error',
          message: 'Authentication token not found.',
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/init'),
      );

      request.fields.addAll({
        'sub_division_id': subDivisionId.value.toString(),
        'type': selectedOption.value.toString().split('.').last,
        'misc_type': selectedMiscOption.value ?? '',
        'feeder_id': selectedFeederId.value.toString(),
        'scheduled_start_at': scheduledStartAtController.text,
        'feeder_incharge_name': feederInchargeController.text,
        'place_of_work': placeOfWorkController.text,
        'scope_of_work': descriptionController.text,
        'close_feeder': closeFeederController.text,
        'safety_arrangements': safetyArrangementsController.text,
        'alternate_feeder': alternateFeederController.text,
        'switch_off_time': switchOffTimeController.text,
        'restore_time': restoreTimeController.text,
        'estimated_duration_min': estimatedDurationMinController.text,
        'transformer_id': selectedTransformerId.value?.toString() ?? '',
        'location_lat': currentLocation.value?.latitude.toString() ?? '',
        'location_lng': currentLocation.value?.longitude.toString() ?? '',
        'circuit_type': selectedCircuitType.value.toString().split('.').last,
        'is_ptw_required': isPtwRequired.value ? '1' : '0',
      });

      // Add reference number for MISC
      if (selectedOption.value == RoutineEmergency.MISC) {
        request.fields['reference_number'] = referenceNumberController.text.trim();
      }

      // NEW: Add planned schedule data
      if (selectedOption.value == RoutineEmergency.PLANNED && scheduleDates.isNotEmpty) {
        // Add from and to dates
        request.fields['planned_from_date'] = DateFormat('yyyy-MM-dd').format(scheduleFromDate.value!);
        request.fields['planned_to_date'] = DateFormat('yyyy-MM-dd').format(scheduleToDate.value!);

        // Add schedule array data
        for (int i = 0; i < scheduleDates.length; i++) {
          request.fields['planned_schedule[$i][date]'] = DateFormat('yyyy-MM-dd').format(scheduleDates[i]);
          request.fields['planned_schedule[$i][start_time]'] = scheduleStartTimes[i];
          request.fields['planned_schedule[$i][end_time]'] = scheduleEndTimes[i];
        }
      }

      // team members
      for (var i = 0; i < selectedTeamMemberIds.length; i++) {
        request.fields['team_member_ids[$i]'] = selectedTeamMemberIds[i].toString();
      }

      // secondary feeders
      if (selectedCircuitType.value == CircuitType.MULTI) {
        for (var i = 0; i < selectedSecondaryFeederIds.length; i++) {
          request.fields['secondary_feeder_ids[$i]'] = selectedSecondaryFeederIds[i].toString();
        }
      }

      // evidences
      for (var i = 0; i < sitePhotos.length; i++) {
        final file = sitePhotos[i];
        request.files.add(
          await http.MultipartFile.fromPath(
            'evidences[$i][file]',
            file.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        request.fields['evidences[$i][type]'] = 'SITE_BEFORE_SHUTDOWN';
      }

      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      final body = await response.stream.bytesToString();

      final decoded = json.decode(body);
      final message = decoded['message'] as String?;
      final data = decoded['data'];

      if (response.statusCode == 201) {
        final ptwId = data['id'] as int;
        final ptwCode = data['ptw_code'] as String;
        final workOrderNo = data['work_order_no'] as String;

        await prefs.setInt('ptw_id', ptwId);
        await prefs.setString('ptw_code', ptwCode);
        await prefs.setString('work_order_no', workOrderNo);

        SnackbarHelper.showSuccess(
          title: 'Success',
          message: 'PTW created successfully.',
        );

        // final nextRoute = selectedOption.value == RoutineEmergency.PLANNED
        //     ? AppRoutes.ptwReviewSdo
        //     : AppRoutes.safetyChecklistLineLoad;

        Get.toNamed(
          AppRoutes.safetyChecklistLineLoad,
          arguments: {
            'ptw_id': ptwId,
            'ptw_code': ptwCode,
            'work_order_no': workOrderNo,
          },
        );
      } else if (response.statusCode == 200 && message == 'Draft already exists') {
        final ptwId = data['id'] as int;
        final ptwCode = data['ptw_code'] as String;
        final workOrderNo = data['work_order_no'] as String;

        await prefs.setInt('ptw_id', ptwId);
        await prefs.setString('ptw_code', ptwCode);
        await prefs.setString('work_order_no', workOrderNo);

        SnackbarHelper.showWarning(
          title: 'Draft Found',
          message: 'A draft for this feeder already exists. Resuming it.',
        );

        // final nextRoute = selectedOption.value == RoutineEmergency.PLANNED
        //     ? AppRoutes.ptwReviewSdo
        //     : AppRoutes.safetyChecklistLineLoad;

        Get.toNamed(
          AppRoutes.safetyChecklistLineLoad,
          arguments: {
            'ptw_id': ptwId,
            'ptw_code': ptwCode,
            'work_order_no': workOrderNo,
          },
        );
      } else {
        SnackbarHelper.showError(
          title: 'Submission Error',
          message: 'Failed to submit PTW. Status: ${response.statusCode}\nBody: $body',
        );
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: 'Submission Error',
        message: 'An error occurred: $e',
      );
    }
  }

  Future<void> _updateStep1() async {
    if (ptwId == null) {
      SnackbarHelper.showError(
        title: 'Update Error',
        message: 'PTW ID not found for update.',
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(
          title: 'Auth Error',
          message: 'Authentication token not found.',
        );
        return;
      }

      String? _normalizeTime(String? input) {
        if (input == null) return null;
        final t = input.trim();
        if (t.isEmpty) return null;

        if (t.length >= 5) {
          return t.substring(0, 5);
        }
        return t;
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/step1');

      final switchOff = _normalizeTime(switchOffTimeController.text);
      final restore = _normalizeTime(restoreTimeController.text);

      if (switchOff == null || restore == null) {
        SnackbarHelper.showError(
          title: 'Validation',
          message: 'Please select both Switch-off Time and Restore Time.',
        );
        return;
      }

      final scheduledRaw = scheduledStartAtController.text.trim();

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'sub_division_id': subDivisionId.value.toString(),
        'type': selectedOption.value.toString().split('.').last,
        'feeder_id': (selectedFeederId.value ?? '').toString(),
        'feeder_incharge_name': feederInchargeController.text,
        'place_of_work': placeOfWorkController.text,
        'scope_of_work': descriptionController.text,
        'close_feeder': closeFeederController.text,
        'safety_arrangements': safetyArrangementsController.text,
        'alternate_feeder': alternateFeederController.text,
        'switch_off_time': switchOff,
        'restore_time': restore,
        'estimated_duration_min': estimatedDurationMinController.text,
        'circuit_type': selectedCircuitType.value.toString().split('.').last,
        'is_ptw_required': isPtwRequired.value ? '1' : '0',
      });

      // Add reference number for MISC
      if (selectedOption.value == RoutineEmergency.MISC) {
        request.fields['misc_type'] = selectedMiscOption.value ?? '';
        request.fields['reference_number'] = referenceNumberController.text.trim();
      }

      // NEW: Add planned schedule data for UPDATE
      if (selectedOption.value == RoutineEmergency.PLANNED && scheduleDates.isNotEmpty) {
        request.fields['planned_from_date'] = DateFormat('yyyy-MM-dd').format(scheduleFromDate.value!);
        request.fields['planned_to_date'] = DateFormat('yyyy-MM-dd').format(scheduleToDate.value!);

        for (int i = 0; i < scheduleDates.length; i++) {
          request.fields['planned_schedule[$i][date]'] = DateFormat('yyyy-MM-dd').format(scheduleDates[i]);
          request.fields['planned_schedule[$i][start_time]'] = scheduleStartTimes[i];
          request.fields['planned_schedule[$i][end_time]'] = scheduleEndTimes[i];
        }
      }

      if (selectedTransformerId.value != null) {
        request.fields['transformer_id'] = selectedTransformerId.value.toString();
      }

      if (currentLocation.value != null) {
        request.fields['location_lat'] = currentLocation.value!.latitude.toString();
        request.fields['location_lng'] = currentLocation.value!.longitude.toString();
      }

      if (scheduledRaw.isNotEmpty) {
        request.fields['scheduled_start_at'] = scheduledRaw;
      }

      // team members
      for (var i = 0; i < selectedTeamMemberIds.length; i++) {
        request.fields['team_member_ids[$i]'] = selectedTeamMemberIds[i].toString();
      }

      // secondary feeders
      for (var i = 0; i < selectedSecondaryFeederIds.length; i++) {
        request.fields['secondary_feeder_ids[$i]'] = selectedSecondaryFeederIds[i].toString();
      }

      // deleted evidences
      for (var i = 0; i < deletedEvidenceIds.length; i++) {
        request.fields['deleted_evidence_ids[$i]'] = deletedEvidenceIds[i].toString();
      }

      // new evidences
      if (sitePhotos.isNotEmpty) {
        for (var i = 0; i < sitePhotos.length; i++) {
          final file = sitePhotos[i];
          request.files.add(
            await http.MultipartFile.fromPath(
              'evidences[$i][file]',
              file.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          request.fields['evidences[$i][type]'] = 'SITE_BEFORE_SHUTDOWN';
        }
      }

      final streamedRes = await request.send();
      final body = await streamedRes.stream.bytesToString();

      if (streamedRes.statusCode == 200) {
        SnackbarHelper.showSuccess(
          title: 'Updated',
          message: 'PTW Step 1 updated successfully.',
        );

        deletedEvidenceIds.clear();
        sitePhotos.clear();

        if (ptwId != null) {
          await loadPreviewAndFill(ptwId!);
        }

        Get.toNamed(
          AppRoutes.safetyChecklistLineLoad,
          arguments: {
            'ptw_id': ptwId,
          },
        );
      } else {
        SnackbarHelper.showError(
          title: 'Update Error',
          message: 'Failed to update PTW Step 1. Code: ${streamedRes.statusCode}\nBody: $body',
        );
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: 'Update Error',
        message: 'An error occurred: $e',
      );
    }
  }
}
