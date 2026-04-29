import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/utils/image_processor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/snackbar_helper.dart';


class LsPtwExecutionController extends GetxController {
  final ptwId = Get.arguments as int;
  
  final attachments = {
    'Crew Pictures': <XFile>[].obs,
    'T&P/PPE Picture': <XFile>[].obs,
    'HT/LT Earthing Pictures': <XFile>[].obs,
    'Additional Pictures (Optional)': <XFile>[].obs,
  };

  final Map<String, String> attachmentTypes = {
    'Crew Pictures': 'EXEC_CREW_PHOTO',
    'T&P/PPE Picture': 'EXEC_TP_PPE_PICTURE',
    'HT/LT Earthing Pictures': 'EXEC_HT_LT_EARTHING_PICTURE',
    'Additional Pictures (Optional)': 'EXEC_ADDITIONAL_PICTURE',
  };

  final notes = ''.obs;
  final isConfirmed = false.obs;
  final isLoading = false.obs;
  // ---------------------- Map & Location ----------------------
  GoogleMapController? googleMapController;
  var isFetchingLocation = true.obs;
  var currentLocation = Rxn<LatLng>();
  var currentAddress = RxnString();

  @override
  void onInit() {
    super.onInit();
    determinePosition();
  }

  @override
  void onClose() {
    googleMapController?.dispose();
    super.onClose();
  }

  Future<void> pickImage(String key) async {
    final XFile? rawImage = await ImageProcessor.pickImage();
    if (rawImage != null) {
      attachments[key]?.add(rawImage);
      // Process in background
      unawaited(determinePosition());
      unawaited(_processAndReplaceImage(key, rawImage));
    }
  }

  Future<void> _processAndReplaceImage(String key, XFile rawImage) async {
    final XFile processedImage = await ImageProcessor.processImage(rawImage, currentLocation, currentAddress);

    final list = attachments[key];
    if (list != null) {
      final int index = list.indexWhere((f) => f.path == rawImage.path);
      if (index != -1) {
        list[index] = processedImage;
      }
    }
  }


  void removeImage(String key, XFile image) {
    attachments[key]?.remove(image);
  }

  // ---------------------- Location ----------------------
  Future<void> determinePosition() async {
    isFetchingLocation.value = true;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isFetchingLocation.value = false;
      SnackbarHelper.showError(title: 'Location Error',message:  'Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        isFetchingLocation.value = false;
        SnackbarHelper.showError(title: 'Location Error', message: 'Location permissions denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      isFetchingLocation.value = false;
      SnackbarHelper.showError(title: 'Location Error',message:  'Location permanently denied.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      currentLocation.value = LatLng(position.latitude, position.longitude);

      // Added address fetching
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value = "${place.street}, ${place.subLocality}, ${place.locality}";
      }

    } catch (e) {
      SnackbarHelper.showError(title: 'Location Error', message: 'Failed to get current location: $e');
    } finally {
      isFetchingLocation.value = false;
    }
  }


  Future<void> startExecution() async {
    if (isLoading.value) return;
    isLoading.value = true;

    final requiredAttachments = attachments.entries
        .where((entry) => !entry.key.contains('Optional') && entry.value.isEmpty);

    if (requiredAttachments.isNotEmpty) {
      SnackbarHelper.showError(title: 'Error',message: 'Please upload all mandatory attachments.');
      isLoading.value = false;
      return;
    }

    if (!isConfirmed.value) {
      SnackbarHelper.showError(title: 'Error',message: 'Please confirm the information is correct.');
      isLoading.value = false;
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(title: 'Error:',message: 'Authentication token not found.');
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/start-execution');
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['notes'] = notes.value;
      request.fields['current_lat'] = currentLocation.value?.latitude.toString() ?? '';
      request.fields['current_lng'] = currentLocation.value?.longitude.toString() ?? '';

      int evidenceIndex = 0;
      for (var entry in attachments.entries) {
        if (entry.value.isNotEmpty) {
          final type = attachmentTypes[entry.key]!;
          for (final file in entry.value) {
            request.files.add(await http.MultipartFile.fromPath(
              'evidences[$evidenceIndex][file]',
              file.path,
              filename: file.name,
            ));
            request.fields['evidences[$evidenceIndex][type]'] = type;
            evidenceIndex++;
          }
        }
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(
          title: 'Success',
          message: 'PTW execution started successfully.',
        );
		isLoading.value = false;
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAllNamed(AppRoutes.ptwList);
        });

      }else {
        final responseBody = await response.stream.bytesToString();
        final errorData = json.decode(responseBody);
        SnackbarHelper.showError(
          title: 'Error:', message: "Failed to start PTW execution: ${errorData['message'] ?? 'Unknown error'}",
        );

        isLoading.value = false;
      }
    } catch (e) {
      SnackbarHelper.showError(title: 'Error:',message: 'An error occurred: $e');
       isLoading.value = false;
    }
  }
}
