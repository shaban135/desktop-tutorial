import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';

class ForgotPasswordController extends GetxController {
  // Observables for loading states
  final isSendingOtp = false.obs;
  final isVerifyingOtp = false.obs;
  final isResettingPassword = false.obs;

  // Controllers for TextFields
  late TextEditingController emailController;
  late List<TextEditingController> otpControllers;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  // To store data between steps
  String email = '';
  String resetToken = ''; // This will be received after OTP verification

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    otpControllers = List.generate(6, (index) => TextEditingController());
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // 1. API Call to Send OTP
  Future<void> sendOtp() async {
    isSendingOtp.value = true;
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/v1/auth/password/otp"),
        body: {'username': emailController.text},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        email = emailController.text; // Save email for the next step
        SnackbarHelper.showSuccess(
          title: 'Success',
          message: 'OTP sent successfully to your email.',
        );
        Get.toNamed(AppRoutes.verifyIdentity);
      } else {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Failed to send OTP. Please check the email and try again.',
        );
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An unexpected error occurred: $e',
      );
    }
    isSendingOtp.value = false;
  }

  // 2. API Call to Verify OTP
  Future<void> verifyOtp() async {
    isVerifyingOtp.value = true;
    try {
      String otp = otpControllers.map((c) => c.text).join();
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/v1/auth/password/verify"),
        body: {
          'username': email,
          'otp': otp,
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        resetToken = data['reset_token']; // Save the reset token
        SnackbarHelper.showSuccess(
          title: 'Verified',
          message: data['message'] ?? 'Identity verified successfully.',
        );
        Get.toNamed(AppRoutes.createNewPassword);
      } else {
        SnackbarHelper.showError(
          title: 'Error',
          message: data['message'] ?? 'Invalid OTP',
        );
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An unexpected error occurred: $e',
      );
    }
    isVerifyingOtp.value = false;
  }

  // 3. API Call to Reset Password
  Future<void> resetPassword() async {
    isResettingPassword.value = true;
    try {
      if (newPasswordController.text != confirmPasswordController.text) {
        SnackbarHelper.showError(
          title: 'Error',
          message: 'Passwords do not match',
        );
        isResettingPassword.value = false;
        return;
      }

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/v1/auth/password/reset"),
        body: {
          'reset_token': resetToken,
          'password': newPasswordController.text,
          'password_confirmation': confirmPasswordController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(
          title: 'Success',
          message: data['message'] ?? 'Password reset successfully.',
        );
        Get.offAllNamed(AppRoutes.passwordResetSuccess);
      } else {
        SnackbarHelper.showError(
          title: 'Error',
          message: data['message'] ?? 'Failed to reset password',
        );
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: 'Error',
        message: 'An unexpected error occurred: $e',
      );
    }
    isResettingPassword.value = false;
  }
}
