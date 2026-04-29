import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/models/user.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/services/biometric_service.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final user = Rx<User?>(null);
  final isBiometricEnabled = false.obs;
  final isBiometricSupported = false.obs;
  final BiometricService _biometricService = BiometricService();

  // --- Observable Profile Data ---
  final name = ''.obs;
  final title = ''.obs;
  final dob = ''.obs;
  final phone = ''.obs;
  final email = ''.obs;
  final address = ''.obs;
  final cnic = ''.obs;
  final gender = ''.obs;
  final imagePath = ''.obs;

  // --- Read-only data ---
  final sapCode = ''.obs;
  final department = ''.obs;
  final designation = ''.obs;
  final region = ''.obs;
  final circle = ''.obs;
  final division = ''.obs;
  final subDivision = ''.obs;
  final feeder = ''.obs;
  final isActive = ''.obs;
  final dateOfJoining = ''.obs;
  final effectiveFrom = ''.obs;
  final effectiveTo = ''.obs;

  // --- TextEditingControllers for the Edit Screen ---
  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController cnicController;
  late TextEditingController sapCodeController;
  late TextEditingController departmentController;
  late TextEditingController designationController;
  late TextEditingController regionController;
  late TextEditingController circleController;
  late TextEditingController divisionController;
  late TextEditingController subDivisionController;
  late TextEditingController feederController;
  late TextEditingController isActiveController;
  late TextEditingController dateOfJoiningController;
  late TextEditingController effectiveFromController;
  late TextEditingController effectiveToController;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _checkBiometricSupport();
    fetchUserProfile();
  }

  Future<void> _checkBiometricSupport() async {
    isBiometricSupported.value = await _biometricService.isBiometricSupported();
    isBiometricEnabled.value = await _biometricService.isBiometricEnabled();
  }

  Future<void> toggleBiometric(bool value) async {
    if (value) {
      bool authenticated = await _biometricService.authenticate();
      if (authenticated) {
        await _biometricService.setBiometricEnabled(true);
        isBiometricEnabled.value = true;
        SnackbarHelper.showSuccess(title: 'Success', message: 'Biometric enabled successfully');
      } else {
        isBiometricEnabled.value = false;
      }
    } else {
      await _biometricService.setBiometricEnabled(false);
      isBiometricEnabled.value = false;
      SnackbarHelper.showSuccess(title: 'Success', message: 'Biometric disabled successfully');
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    dobController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    addressController = TextEditingController();
    cnicController = TextEditingController();
    sapCodeController = TextEditingController();
    departmentController = TextEditingController();
    designationController = TextEditingController();
    regionController = TextEditingController();
    circleController = TextEditingController();
    divisionController = TextEditingController();
    subDivisionController = TextEditingController();
    feederController = TextEditingController();
    isActiveController = TextEditingController();
    dateOfJoiningController = TextEditingController();
    effectiveFromController = TextEditingController();
    effectiveToController = TextEditingController();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  String _formatApiString(String? value) => (value != null && value.isNotEmpty) ? value : 'N/A';

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        isLoading.value = false;
        return;
      }

      // --- CACHE BUSTING ADDED ---
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/profile?t=$timestamp");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _updateLocalUserData(User.fromJson(data['data']));
      } else if (response.statusCode == 401) {
        logout();
      } else {
        SnackbarHelper.showError(title: 'Error',message: 'Failed to load profile data. Status: ${response.statusCode}');
      }
    } catch (e) {
      SnackbarHelper.showError(title: 'Error',message:  'An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateLocalUserData(User updatedUser) {
    user.value = updatedUser;

    name.value = _formatApiString(updatedUser.name);
    dob.value = _formatApiString(updatedUser.dateOfBirth);
    phone.value = _formatApiString(updatedUser.phone);
    email.value = _formatApiString(updatedUser.email);
    address.value = _formatApiString(updatedUser.address);
    cnic.value = _formatApiString(updatedUser.cnic);
    gender.value = _formatApiString(updatedUser.gender);
    imagePath.value = updatedUser.avatarUrl ?? '';
    isActive.value = updatedUser.isActive ? 'Yes' : 'No';

    sapCode.value = _formatApiString(updatedUser.sapCode);
    department.value = _formatApiString(updatedUser.department?.name);
    dateOfJoining.value = _formatApiString(updatedUser.dateOfJoining);

    title.value = _formatApiString(updatedUser.designation?.name);
    designation.value = _formatApiString(updatedUser.designation?.name);

    region.value = _formatApiString(updatedUser.currentPosting?.region?.name);
    circle.value = _formatApiString(updatedUser.currentPosting?.circle?.name);
    division.value = _formatApiString(updatedUser.currentPosting?.division?.name);
    subDivision.value = _formatApiString(updatedUser.currentPosting?.subDivision?.name);
    feeder.value = _formatApiString(updatedUser.currentPosting?.feeder?.name);
    effectiveFrom.value = _formatApiString(updatedUser.currentPosting?.effectiveFrom);
    effectiveTo.value = _formatApiString(updatedUser.currentPosting?.effectiveTo);

    _updateAllControllers();
  }

  void _updateAllControllers() {
    nameController.text = name.value;
    dobController.text = dob.value;
    phoneController.text = phone.value;
    emailController.text = email.value;
    addressController.text = address.value;
    cnicController.text = cnic.value;
    sapCodeController.text = sapCode.value;
    departmentController.text = department.value;
    designationController.text = designation.value;
    regionController.text = region.value;
    circleController.text = circle.value;
    divisionController.text = division.value;
    subDivisionController.text = subDivision.value;
    feederController.text = feeder.value;
    isActiveController.text = isActive.value;
    dateOfJoiningController.text = dateOfJoining.value;
    effectiveFromController.text = effectiveFrom.value;
    effectiveToController.text = effectiveTo.value;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
      if (croppedFile != null) {
        imagePath.value = croppedFile.path;
      }
    }
  }

  Future<void> updateProfile() async {
    isLoading.value = true;

    try {
      if (kDebugMode) {
        print("--- Sending Profile Update Request ---");
        print("URL: ${ApiConstants.baseUrl}/api/v1/profile-update");
        print("Name: ${nameController.text}");
        print("Gender: ${gender.value}");
        print("DOB: ${dobController.text}");
        print("Phone: ${phoneController.text}");
        print("Address: ${addressController.text}");
        print("CNIC: ${cnicController.text}");
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(title: 'Error',message:'Authentication token not found.');
        isLoading.value = false;
        return;
      }

      final uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/profile-update");

      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['_method']= 'PATCH';

      request.fields['name'] = nameController.text == 'N/A' ? '' : nameController.text;
      request.fields['gender'] = gender.value == 'N/A' ? '' : gender.value;
      request.fields['date_of_birth'] = dobController.text == 'N/A' ? '' : dobController.text;
      request.fields['phone'] = phoneController.text == 'N/A' ? '' : phoneController.text;
      request.fields['address'] = addressController.text == 'N/A' ? '' : addressController.text;
      request.fields['cnic'] = cnicController.text == 'N/A' ? '' : cnicController.text;

      final bool hasNewImage = imagePath.value.isNotEmpty && !imagePath.value.startsWith('http') && !imagePath.value.startsWith('assets');
      if (hasNewImage) {
        request.files.add(await http.MultipartFile.fromPath('avatar', imagePath.value));
      }

      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print("--- Received Backend Response ---");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        await fetchUserProfile();

        Get.back();
        SnackbarHelper.showSuccess( title: 'Success',  message: 'Profile updated successfully!');
      } else {
        final errorData = jsonDecode(response.body);
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Failed to update profile: ${errorData['message'] ?? 'Unknown error'}'
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("--- An error occurred ---");
        print(e.toString());
      }
      SnackbarHelper.showError( title:'Error',  message: 'An error occurred: $e' );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      SnackbarHelper.showError(title: 'Error', message: 'New passwords do not match');
      return;
    }

    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(title: 'Error', message: 'Authentication token not found.');
        isLoading.value = false;
        return;
      }

      final uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/profile/pass");

      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'current_password': currentPasswordController.text,
          'password': newPasswordController.text,
          'password_confirmation': confirmPasswordController.text,
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.back();
        SnackbarHelper.showSuccess(title: 'Success',message:  responseData['message'] );
      } else {
        SnackbarHelper.showError(
          title: 'Error',
          message: responseData['message'] ?? 'Failed to update password',
        );
      }
    } catch (e) {
      SnackbarHelper.showError(title: 'Error', message: 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> logout() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      // Backend logout API call
      if (token != null) {
        try {
          final uri = Uri.parse("${ApiConstants.baseUrl}/api/v1/auth/logout");

          final response = await http.post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

          // if (kDebugMode) {
          //   print("Logout Response: ${response.statusCode}");
          //   print("Logout Body: ${response.body}");
          // }

          // Handle different status codes
          if (response.statusCode == 200) {
            // Success - proceed with logout
            final data = jsonDecode(response.body);
            if (data['message'] != null) {
              SnackbarHelper.showSuccess(
                title: 'Success',
                message: data['message'],
              );
            }

            // Local data cleanup
            await prefs.remove(StorageKeys.authToken);
            await prefs.remove(StorageKeys.userData);

            Get.delete<ProfileController>(force: true);
            Get.offAllNamed(AppRoutes.login);

          } else if (response.statusCode == 409) {
            // Conflict - Cannot logout due to active PTWs
            final data = jsonDecode(response.body);
            SnackbarHelper.showError(
              title: 'Cannot Logout',
              message: data['message'] ?? 'You have active PTWs. Please complete them first.',
            );
            // Do NOT clear token or navigate away
            return;

          } else {
            // Other error codes
            final data = jsonDecode(response.body);
            SnackbarHelper.showError(
              title: 'Error',
              message: data['message'] ?? 'Failed to logout',
            );
            return;
          }

        } catch (e) {
          if (kDebugMode) {
            print("Logout API error: $e");
          }
          SnackbarHelper.showError(
            title: 'Error',
            message: 'Failed to connect to server',
          );
          return;
        }
      }

    } catch (e) {
      if (kDebugMode) {
        print("Logout error: $e");
      }
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An error occurred during logout',
      );
    } finally {
      isLoading.value = false;
    }
  }
  // Future<void> logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(StorageKeys.authToken);
  //   await prefs.remove(StorageKeys.userData);
  //
  //   Get.delete<ProfileController>(force: true);
  //
  //   Get.offAllNamed(AppRoutes.login);
  // }

  @override
  void onClose() {
    nameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    cnicController.dispose();
    sapCodeController.dispose();
    departmentController.dispose();
    designationController.dispose();
    regionController.dispose();
    circleController.dispose();
    divisionController.dispose();
    subDivisionController.dispose();
    feederController.dispose();
    isActiveController.dispose();
    dateOfJoiningController.dispose();
    effectiveFromController.dispose();
    effectiveToController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();

    confirmPasswordController.dispose();
    super.onClose();
  }
}
