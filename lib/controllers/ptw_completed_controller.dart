import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:mepco_esafety_app/utils/image_processor.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../routes/app_routes.dart';

class PtwCompletedController extends GetxController {
  var isLoading = false.obs;
  final RxList<XFile> images = <XFile>[].obs;

  // ---------------------- Map ----------------------
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

  Future<void> determinePosition() async {
    isFetchingLocation.value = true;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isFetchingLocation.value = false;
      SnackbarHelper.showError(
          title: 'Location Error', message: 'Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        isFetchingLocation.value = false;
        SnackbarHelper.showError(
            title: 'Location Error', message: 'Location permissions denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      isFetchingLocation.value = false;
      SnackbarHelper.showError(
          title: 'Location Error',
          message: 'Location permanently denied.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      currentLocation.value = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value =
            "${place.street}, ${place.subLocality}, ${place.locality}";
      }
    } catch (e) {
      SnackbarHelper.showError(
          title: 'Location Error', message: 'Failed to get current location: $e');
    } finally {
      isFetchingLocation.value = false;
    }
  }

  Future<void> pickImages() async {
    final XFile? rawImage = await ImageProcessor.pickImage();
    if (rawImage != null) {
      images.add(rawImage);

      // Process in background
      unawaited(determinePosition());
      unawaited(_processAndReplaceImage(rawImage));
    }
  }

  Future<void> _processAndReplaceImage(XFile rawImage) async {
    final XFile processedImage = await ImageProcessor.processImage(
        rawImage, currentLocation, currentAddress);

    final int index = images.indexWhere((f) => f.path == rawImage.path);
    if (index != -1) {
      images[index] = processedImage;
    }
  }

  void removeImage(XFile image) {
    images.remove(image);
  }

  Future<void> submitPtwCompletion({
    required int ptwId,
    required String notes,
    required List<ChecklistItem> checklistItems,
  }) async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(
            title: 'Error', message: 'Authentication Token not found.');
        isLoading.value = false;
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/completion-submit'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Notes
      request.fields['notes'] = notes;

      // Geo
      request.fields['current_lat'] =
          currentLocation.value?.latitude.toString() ?? '';
      request.fields['current_lng'] =
          currentLocation.value?.longitude.toString() ?? '';

      // Checklist
      for (int i = 0; i < checklistItems.length; i++) {
        request.fields['checklist[$i][checklist_item_id]'] =
            checklistItems[i].id.toString();
        request.fields['checklist[$i][value]'] =
            checklistItems[i].value ? "YES" : "NO";
      }

      // IMAGES
      for (int i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'evidences[$i][file]',
            images[i].path,
          ),
        );
        request.fields['evidences[$i][type]'] =
            'PTW_CANCELATION_OF_COMPLETION_BY_LS';
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(
            title: 'Success',
            message: 'PTW completion submitted successfully.');
        Get.back(result: true);
        Get.offAllNamed(AppRoutes.ptwList);
      } else {
        final decoded = jsonDecode(responseBody);
        SnackbarHelper.showError(
          title: 'Error',
          message: decoded['message'] ?? 'Failed to submit PTW completion.',
        );
      }
    } catch (e, st) {
      log('Error submitting PTW completion: $e', stackTrace: st);
      SnackbarHelper.showError(
          title: 'Error',
          message: 'An error occurred while submitting the PTW completion.');
    } finally {
      isLoading.value = false;
    }
  }
}
