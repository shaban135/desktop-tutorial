import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/controllers/notifications_controller.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/services/biometric_service.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final BiometricService _biometricService = BiometricService();

  final isLoading = false.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;
  
  final version = ''.obs;
  final buildNumber = ''.obs;
  final isBiometricEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _loadPackageInfo();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    isBiometricEnabled.value = await _biometricService.isBiometricEnabled();
  }

  Future<void> loginWithBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.authToken);

    if (token == null || token.isEmpty) {
      SnackbarHelper.showError(
        title: 'Authentication Required',
        message: 'Please login with your credentials first to enable biometric login.',
      );
      return;
    }

    bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      Get.offAllNamed(AppRoutes.home);
      // Fetch notifications in background
      Future.delayed(const Duration(milliseconds: 300), () {
        final notiController = Get.find<NotificationsController>();
        notiController.fetchNotifications();
      });
    }
  }

  Future<void> _loadPackageInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      version.value = packageInfo.version;
      buildNumber.value = packageInfo.buildNumber;
    } catch (e) {
      print('Error loading package info: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// ✅ GET DEVICE INFO - New method
  Future<Map<String, String>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'device_name': 'Mobile',
          'device_model': androidInfo.model ?? 'Android Device',
          'os': 'Android ${androidInfo.version.release}',
          'device_id': androidInfo.id ?? 'unknown',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'device_name': 'Mobile',
          'device_model': iosInfo.model ?? 'iPhone',
          'os': 'iOS ${iosInfo.systemVersion}',
          'device_id': iosInfo.identifierForVendor ?? 'unknown',
        };
      } else {
        return {
          'device_name': 'Mobile',
          'device_model': 'Flutter App',
          'os': 'Unknown',
          'device_id': 'unknown',
        };
      }
    } catch (e) {
      print('Error getting device info: $e');
      return {
        'device_name': 'Mobile',
        'device_model': 'Flutter App',
        'os': 'Unknown',
        'device_id': 'error',
      };
    }
  }

  Future<void> login() async {
    emailError.value = '';
    passwordError.value = '';

    if (emailController.text.isEmpty) emailError.value = 'Email is required';
    if (passwordController.text.isEmpty) passwordError.value = 'Password is required';
    if (emailError.isNotEmpty || passwordError.isNotEmpty) return;

    isLoading.value = true;

    try {
      // ✅ GET DEVICE INFO
      final deviceData = await getDeviceInfo();
      print('Device Info: $deviceData');

      // ✅ CREATE DEVICE INFO HEADER
      final deviceHeader = jsonEncode({
        'device_name': deviceData['device_name'],
        'device_model': deviceData['device_model'],
        'os': deviceData['os'],
        'device_id': deviceData['device_id'],
      });

      // ✅ SEND REQUEST WITH DEVICE HEADER
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/v1/auth/login"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Device-Info': deviceHeader, // ✅ ADD DEVICE HEADER
        },
        body: jsonEncode({
          'username': emailController.text,
          'password': passwordController.text,
        }),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];

        if (token != null && user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(StorageKeys.authToken, token);
          await prefs.setString(StorageKeys.userData, jsonEncode(user));

          // Navigate FIRST
          Get.offAllNamed(AppRoutes.home);

          // Fetch notifications in background AFTER login
          Future.delayed(const Duration(milliseconds: 300), () {
            final notiController = Get.find<NotificationsController>();
            notiController.fetchNotifications();
          });
        }
      } else if (response.statusCode == 409) {
        // ✅ HANDLE DEVICE/GRID CONFLICT
        final errorData = jsonDecode(response.body);
        final errorCode = errorData['error_code'];
        final errorMessage = errorData['message'];

        if (errorCode == 'ALREADY_LOGGED_IN_ANOTHER_DEVICE') {
          // Device conflict error
          final currentSession = errorData['current_session'];
          final deviceName = currentSession['device_name'] ?? 'Unknown Device';
          final deviceModel = currentSession['device_model'] ?? 'Unknown';

          SnackbarHelper.showError(
            title: 'Device Conflict',
            message: 'Already logged in on $deviceName ($deviceModel). Please logout first.',
            showFeedback: false,
          );
        } else if (errorCode == 'GRID_SESSION_ACTIVE') {
          // Grid conflict error
          final activeUser = errorData['active_user'];
          final userName = activeUser['name'] ?? 'Unknown User';

          SnackbarHelper.showError(
            title: 'Grid Already In Use',
            message: '$userName is already logged in on this grid.',
            showFeedback: false,
          );
        }
        else {
          SnackbarHelper.showError(
            title: 'Login Failed',
            message: errorMessage ?? 'Login failed',
            showFeedback: false,
          );
        }
      } else if(response.statusCode == 422){
        final errorData = jsonDecode(response.body);
        final errorCode = errorData['error_code'];
        final errorMessage = errorData['message'];
      if(errorCode == 'GRID_POSTING_NOT_FOUND') {
        SnackbarHelper.showError(
          title: 'Grid Posting Not Found',
          message: errorMessage ?? 'Grid posting not found.',
          showFeedback: false,
        );
      } else if(errorCode == 'INVALID') {  //ADD THIS
        SnackbarHelper.showError(
          title: 'Invalid Credentials',
          message: errorMessage ?? 'Invalid credentials.',
          showFeedback: false,
        );
      } else {  //ADD THIS - handle any other 422 errors
        SnackbarHelper.showError(
          title: 'Login Failed',
          message: errorMessage ?? 'Login failed',
          showFeedback: false,
        );
      }
      }
      else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Login failed';
        SnackbarHelper.showError(
          title: 'Login Failed',
          message: errorMessage,
          showFeedback: false,
        );
      }
    } catch (e) {
      isLoading.value = false;
      print('Login error: $e');
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An unexpected error occurred: $e',
        showFeedback: false,
      );
    }
  }
}
