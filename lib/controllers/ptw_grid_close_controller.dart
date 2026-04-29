import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:native_exif/native_exif.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async' show unawaited;
import '../routes/app_routes.dart';
import 'package:mepco_esafety_app/utils/image_processor.dart';

class PtwGridCloseController extends GetxController {
  var isLoading = false.obs;
  final RxList<XFile> images = <XFile>[].obs;

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

  // ===========================================================
  //                 📌 LOCATION HANDLING
  // ===========================================================
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

  // ===========================================================
  //            📌 PICK IMAGE → INSTANT SHOW → PROCESS
  // ===========================================================
  Future<void> pickImages() async {
    final rawImage = await ImageProcessor.pickImage();

    if (rawImage != null) {
      images.add(rawImage);
      unawaited(determinePosition());
      unawaited(_processAndReplaceImage(rawImage));
    }
  }

  Future<void> _processAndReplaceImage(XFile rawImage) async {
    try {
      final processedImage = await ImageProcessor.processImage(rawImage, currentLocation, currentAddress);

      int index = images.indexWhere((img) => img.path == rawImage.path);
      if (index != -1) {
        images[index] = processedImage;
        images.refresh();
      }
    } catch (e) {
      log("⚠️ Image processing failed: $e");
    }
  }

  void removeImage(XFile image) {
    images.remove(image);
  }

  // ===========================================================
  //                📌 SUBMIT GRID CLOSE
  // ===========================================================
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
            title: 'Error', message: 'Authentication token missing.');
        isLoading.value = false;
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/mark-restored-and-closed'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['notes'] = notes;
      request.fields['current_lat'] =
          currentLocation.value?.latitude.toString() ?? '';
      request.fields['current_lng'] =
          currentLocation.value?.longitude.toString() ?? '';

      for (int i = 0; i < checklistItems.length; i++) {
        request.fields['checklist[$i][checklist_item_id]'] =
            checklistItems[i].id.toString();
        request.fields['checklist[$i][value]'] =
        checklistItems[i].value ? 'YES' : 'NO';
      }

      for (int i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'evidences[$i][file]',
            images[i].path,
          ),
        );

        request.fields['evidences[$i][type]'] = 'PTW_CANCEL_BY_GRID';
      }

      var response = await request.send();
      final respBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(
            title: 'Success', message: 'PTW Closed successfully!');
        Get.offAllNamed(AppRoutes.home);
      } else {
        final decoded = jsonDecode(respBody);
        SnackbarHelper.showError(
          title: 'Error',
          message: decoded['message'] ?? 'Failed to close PTW.',
        );
      }
    } catch (e, st) {
      log("⚠️ Error submitting closing PTW: $e", stackTrace: st);
      SnackbarHelper.showError(
          title: 'Error',
          message: 'An error occurred while submitting PTW.');
    } finally {
      isLoading.value = false;
    }
  }
}
