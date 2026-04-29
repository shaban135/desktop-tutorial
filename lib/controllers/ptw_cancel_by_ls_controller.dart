
import 'dart:async';
import 'dart:convert';

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

class PtwCancelByLsController extends GetxController {
  final isSubmitting = false.obs;
  final images = <XFile>[].obs;
  final isConfirmed = false.obs;
  final decisionController = TextEditingController();

  // Map & Location
  GoogleMapController? googleMapController;
  final isFetchingLocation = true.obs;
  final currentLocation = Rxn<LatLng>();
  final currentAddress = RxnString();

  @override
  void onInit() {
    super.onInit();
    determinePosition();
  }

  @override
  void onClose() {
    decisionController.dispose();
    googleMapController?.dispose();
    super.onClose();
  }

  void toggleConfirmation(bool? value) {
    isConfirmed.value = value ?? false;
  }

  Future<void> pickImage() async {
    final XFile? rawImage = await ImageProcessor.pickImage();
    if (rawImage != null) {
      images.add(rawImage);

      // Process in background
      unawaited(determinePosition());
      unawaited(_processAndReplaceImage(rawImage));
    }
  }

  Future<void> _processAndReplaceImage(XFile rawImage) async {
    final XFile processedImage = await ImageProcessor.processImage(rawImage, currentLocation, currentAddress);

    final int index = images.indexWhere((f) => f.path == rawImage.path);
    if (index != -1) {
      images[index] = processedImage;
    }
  }

  void removeImage(XFile image) {
    images.remove(image);
  }

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


  Future<void> submitCancelByLs({
    required int ptwId,
    required List<ChecklistItem> checklistItems,
  }) async {
    if (isSubmitting.value) return;

    if (!isConfirmed.value) {
      Get.snackbar('Error', 'Please confirm all information is correct.',
          backgroundColor: const Color(0xFF002997), colorText: Colors.white);
      return;
    }

    if (currentLocation.value == null) {
      Get.snackbar('Error', 'Could not determine your current location.',
          backgroundColor: const Color(0xFF002997), colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found.');
        isSubmitting.value = false;
        return;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/cancel-by-ls');
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add fields
      request.fields['notes'] = decisionController.text;
      request.fields['current_lat'] = currentLocation.value!.latitude.toString();
      request.fields['current_lng'] = currentLocation.value!.longitude.toString();
      
      // Add checklist items
      for (int i = 0; i < checklistItems.length; i++) {
        request.fields['checklist[$i][checklist_item_id]'] = checklistItems[i].id.toString();
        request.fields['checklist[$i][value]'] = checklistItems[i].value ? 'YES' : 'NO';
      }

      // Add images
      for (int i = 0; i < images.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'evidences[$i][file]',
          images[i].path,
          filename: images[i].name,
        ));
        request.fields['evidences[$i][type]'] = 'PTW_CANCEL_BY_LS'; // Example type
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'PTW Cancellation request submitted to SDO successfully.',
            backgroundColor: Colors.green, colorText: Colors.white);

        Future.delayed(const Duration(seconds: 1), () {
           Get.offAllNamed(AppRoutes.ptwList); 
        });

      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = json.decode(responseBody);
        Get.snackbar('Error', "Submission failed: ${errorData['message'] ?? 'Unknown error'}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}
