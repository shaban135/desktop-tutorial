import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../widgets/error_feedback_dialog.dart';

class SnackbarHelper {
  /// Shows a success popup dialog in the center of the screen.
  static void showSuccess({required String title, required String message}) {
    if (Get.context == null) {
      debugPrint(
        '⚠️ SnackbarHelper.showSuccess: Get.context is null, skipping dialog',
      );
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) return;

      final displayMessage = _applyTranslation(message) ?? message;

      Get.dialog(
        _SuccessDialog(title: title, message: displayMessage),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
      );
    });
  }

  /// Shows a warning popup dialog in the center of the screen.
  static void showWarning({required String title, required String message}) {
    if (Get.context == null) {
      debugPrint(
        '⚠️ SnackbarHelper.showWarning: Get.context is null, skipping dialog',
      );
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) return;

      Get.dialog(
        _WarningDialog(title: title, message: message),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
      );
    });
  }

  /// Shows an error popup dialog in the center of the screen.
  static void showError({
    required String title,
    required String message,
    bool showFeedback = true,
  }) {
    debugPrint('🔴 SnackbarHelper.showError CALLED: $title -> $message');

    if (Get.context == null) {
      debugPrint(
        '⚠️ SnackbarHelper.showError: Get.context is null, skipping dialog',
      );
      return;
    }

    // Handle Network/Internet Connection Errors specifically
    if (message.contains('SocketException') ||
        message.contains('Failed host lookup') ||
        message.contains('HandshakeException') ||
        message.contains('Connection timed out') ||
        message.contains('ClientException')) {
      final connectionErrorMessage =
          'Internet connection issue. Please check your network.\nانٹرنیٹ کنکشن میں مسئلہ ہے۔ براہِ کرم اپنا نیٹ ورک چیک کریں۔';

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (Get.context == null) return;

        Get.dialog(
          _ErrorDialog(
            title: 'Connection Error',
            message: connectionErrorMessage,
            backendError: message,
            showFeedback:
                false, // Don't show feedback for simple internet issues
          ),
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
        );
      });
      return;
    }

    // Suppress "not found" error, which is handled by forcing a logout.
    if (message.contains('Authentication Token not found.') &&
        !message.contains('host lookup')) {
      debugPrint(
        '🙈 "Not found" (credentials) error suppressed from UI. Logout is expected.',
      );
      return;
    }

    // Suppress technical Flutter errors and ignored image load errors from being shown in the UI.
    if (message.contains('package:flutter/') ||
        message.contains('Failed assertion') ||
        message.contains('image/tile load error') ||
        message.contains('default-male.png') ||
        message.contains('statusCode: 404')) {
      debugPrint('🪲 Technical or Image error suppressed from UI: $message');
      return;
    }

    final displayMessage = _translateError(message);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) return;

      Get.dialog(
        _ErrorDialog(
          title: title,
          message: displayMessage,
          backendError: message,
          showFeedback: showFeedback,
        ),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
      );
    });
  }

  static String? _applyTranslation(String message) {
    const translations = {
      'Connection failed':
          'Internet connection issue. Please check your network.\nانٹرنیٹ کنکشن میں مسئلہ ہے۔ براہِ کرم اپنا نیٹ ورک چیک کریں۔',
      'Invalid credentials':
          'The username or password you entered is incorrect.\nجو صارف نام یا پاس ورڈ آپ نے درج کیا ہے وہ غلط ہے۔',
      'Token expired':
          'Your session has expired. Please log in again.\nآپ کا سیشن ختم ہو گیا ہے۔ براہ کرم دوبارہ لاگ ان کریں۔',
      //'not found': 'Credentials not found. You are logged out. Please log in\nکریڈینشلز نہیں ملے۔ آپ لاگ آؤٹ ہو چکے ہیں، براہِ کرم لاگ اِن کریں۔',
      'Failed to load PTW Context':
          'PTW context not loaded due to cancellation or network issue\nپی ٹی ڈبلیو کانٹیکسٹ کینسل یا نیٹ ورک مسئلے کی وجہ سے لوڈ نہیں ہوا۔',
      'Authentication token not found.':
          'Authentication token not found.\nتوثیقی ٹوکن نہیں ملا۔',
      'PTW action completed successfully!':
          'PTW action completed successfully!\nپی ٹی ڈبلیو کا عمل کامیابی سے مکمل ہو گیا ہے۔',
      'The password field must be at least 8 characters.':
          'The password field must be at least 8 characters.\nپاس ورڈ کم از کم 8 حروف پر مشتمل ہونا چاہیے۔',
      'PTW created successfully.':
          'PTW created successfully.\nکامیابی کے ساتھ تخلیق کر دیا گیا۔',
      'Checklist submitted successfully':
          'Checklist submitted successfully\nچیک لسٹ کامیابی کے ساتھ جمع کر دی گئی۔',
      'PTW marked as ISSUED!':
          'PTW marked as ISSUED!\nپی ٹی ڈبلیو جاری شدہ کے طور پر نشان زد کیا گیا۔',
      'Please confirm the information is correct.':
          'Check the box to confirm.\nتصدیق کرنے کے لیے باکس کو چیک کریں۔',
      'PTW execution started successfully.':
          'Check the box to confirm.\nپی ٹی ڈبلیو کا عمل کامیابی سے شروع ہو گیا۔ ',
      'PTW completion submitted successfully.':
          'PTW completion submitted successfully.\nپی ٹی ڈبلیو کی تکمیل کامیابی سے جمع کر دی گئی۔ ',
      'Please confirm that the feeder information is accurate by checking the consent checkbox.':
          'Please confirm that the feeder information is accurate by checking the consent checkbox.\nبراہ کرم رضامندی کے چیک باکس کو چیک کر کے یہ تصدیق کریں کہ فیڈر کی معلومات درست ہیں۔ ',
      'PTW Closed successfully!':
          'PTW Closed successfully!\n پی ٹی ڈبلیو کامیابی کے ساتھ بند ہو گیا',
      'OTP sent successfully to your email.':
          'OTP sent successfully to your email.\n آپ کے ای میل پر او ٹی پی کامیابی سے بھیج دیا گیا ہے۔',
      'Identity verified successfully.':
          'Identity verified successfully.\nشناخت کامیابی کے ساتھ تصدیق ہو گئی۔',
      'Password reset successfully':
          'Password reset successfully.\nپاس ورڈ کامیابی کے ساتھ ری سیٹ ہو گیا۔',
      'Failed to send OTP. Please check the email and try again.':
          'Failed to send OTP. Please check the email and try again.\nاو ٹی پی بھیجنے میں ناکامی ہوئی ہے۔ براہِ کرم ای میل چیک کریں اور دوبارہ کوشش کریں۔',
      'Another user is already logged in on this grid':
          'Another user is already logged in on this grid.\n اس گرڈ پر پہلے ہی ایک اور صارف لاگ ان ہے',
      'Another PDC user is already logged in':
          'Another PDC user role is already logged in\nپی ڈی سی کے ایک اور صارف کا کردار پہلے ہی لاگ اِن ہو چکا ہے۔',
      'No PDC currently active':
          'No PDC currently active\nفی الحال کوئی پی ڈی سی دستیاب نہیں ہے۔',
      'Cannot logout: You have active PTWs and no other PDC is online to handle them':
          'لاگ آؤٹ نہیں ہو سکتے: آپ کے پاس فعال PTWs ہیں اور کوئی دوسرا PDC آن لائن نہیں ہے',
      'You have active PTWs. Please delegate them to another PDC before logging out.':
          'You have active PTWs. Please delegate them to another PDC before logging out.\nآپ کے پاس فعال پی ٹی ڈبلیوز ہیں۔ براہ کرم لاگ آؤٹ کرنے سے پہلے انہیں کسی دوسرے پی ڈی سی کو سونپ دیں۔',
      'Location services are disabled.':
          'Location services are disabled.\n مقام کی خدمات غیر فعال ہیں۔',
      'Grid posting not Found': 'Grid posting not Found.\nگرڈ پوسٹنگ نہیں ملی۔',
      'SDO Not Found. Please contact admin.':
          'SDO Not Found. Please contact admin.\nگرڈ پوسٹنگ نہیں ملی۔',
    };
    for (var entry in translations.entries) {
      if (message == entry.key) {
        return entry.value;
      }
    }
    if (message.startsWith('Already logged in on') &&
        message.contains('Please logout first')) {
      final match = RegExp(
        r'Already logged in on (.+)\. Please logout first\.',
      ).firstMatch(message);
      if (match != null) {
        final deviceInfo = match.group(1);
        return 'Already logged in on $deviceInfo. Please logout first.\n$deviceInfo پر پہلے سے لاگ ان ہے۔ پہلے لاگ آؤٹ کریں۔';
      }
    }
    if (message.contains('is already logged in on this grid')) {
      final match = RegExp(
        r'(.+) is already logged in on this grid\.',
      ).firstMatch(message);
      if (match != null) {
        final userName = match.group(1);
        return '$userName is already logged in on this grid.\n$userName اس گرڈ پر پہلے سے لاگ ان ہے۔';
      }
    }
    for (var entry in translations.entries) {
      if (message.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  static String _translateError(String backendMessage) {
    const validationTranslations = {
      "The selected feeder id is invalid.": "منتخب فیڈر آئی ڈی غلط ہے۔",
      "The place of work field is required.": "کام کی جگہ کا فیلڈ درکار ہے۔",
      "The scope of work field is required.":
          "کام کے دائرہ کار کا فیلڈ درکار ہے۔",
      "The selected type is invalid.": "منتخب کردہ قسم غلط ہے۔",
    };

    try {
      final bodyIndex = backendMessage.indexOf('Body: {');
      if (bodyIndex != -1) {
        final jsonString = backendMessage.substring(bodyIndex + 5);
        final decodedJson = jsonDecode(jsonString) as Map<String, dynamic>;
        if (decodedJson.containsKey('errors')) {
          final errors = decodedJson['errors'] as Map<String, dynamic>;
          final allErrorMessages = errors.values
              .expand((e) => e as List)
              .map((e) {
                final englishError = e.toString();
                final urduTranslation = validationTranslations[englishError];
                if (urduTranslation != null) {
                  return '- $englishError\n  $urduTranslation';
                }
                return '- $englishError';
              })
              .join('\n');
          if (allErrorMessages.isNotEmpty) {
            return allErrorMessages;
          }
        }
      }
    } catch (e) {
      debugPrint('Could not parse error JSON from backend message: $e');
    }

    final simpleTranslation = _applyTranslation(backendMessage);
    if (simpleTranslation != null) {
      return simpleTranslation;
    }

    debugPrint(
      'Unknown error, showing original backend message: $backendMessage',
    );
    return backendMessage;
  }
}

// Success Dialog Widget
class _SuccessDialog extends StatefulWidget {
  final String title;
  final String message;

  const _SuccessDialog({required this.title, required this.message});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon with animation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Warning Dialog Widget
class _WarningDialog extends StatefulWidget {
  final String title;
  final String message;

  const _WarningDialog({required this.title, required this.message});

  @override
  State<_WarningDialog> createState() => _WarningDialogState();
}

class _WarningDialogState extends State<_WarningDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF59E0B),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Error Dialog Widget
class _ErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final String backendError;
  final bool showFeedback;

  const _ErrorDialog({
    required this.title,
    required this.message,
    required this.backendError,
    this.showFeedback = true,
  });

  @override
  State<_ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<_ErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEA580C).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA580C).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_rounded,
                    color: Color(0xFFEA580C),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    if (widget.showFeedback) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                            showErrorFeedbackDialog(
                              widget.message,
                              backendError: widget.backendError,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEA580C),
                            side: const BorderSide(
                              color: Color(0xFFEA580C),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Feedback',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Keep the rest of the helper classes unchanged
class DueCountdown extends StatefulWidget {
  final String dueTime;

  const DueCountdown({super.key, required this.dueTime});

  @override
  State<DueCountdown> createState() => _DueCountdownState();
}

class _DueCountdownState extends State<DueCountdown> {
  Duration remaining = Duration.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (widget.dueTime.isEmpty) return;

    DateTime? endTime;

    try {
      final parsed = DateTime.parse(widget.dueTime);
      endTime = parsed.isUtc ? parsed.toLocal() : parsed;
    } catch (_) {
      return;
    }

    setState(() => remaining = endTime!.difference(DateTime.now()));

    if (remaining.isNegative) return;

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        remaining = endTime!.difference(DateTime.now());
      });

      if (remaining.isNegative) {
        timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = remaining.inSeconds > 0 && remaining.inMinutes < 60;
    final isOverdue = remaining.isNegative;

    Color bgColor = Colors.green.shade50;
    Color textColor = Colors.green.shade800;
    IconData icon = Icons.timer;

    if (isWarning) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.warning_amber_rounded;
    }

    if (isOverdue) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 8),
          Text(
            _formattedTime(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formattedTime() {
    if (remaining.isNegative) return "Due";

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(remaining.inHours);
    final minutes = twoDigits(remaining.inMinutes.remainder(60));
    final seconds = twoDigits(remaining.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }
}

class PtwHelper {
  static String getStatusText(String s) {
    switch (s.toUpperCase()) {
      case 'DRAFT':
        return 'Draft';
      case 'SUBMITTED':
        return 'Submitted for Review';
      case 'SDO_RETURNED':
        return 'Returned by SDO';
      case 'SDO_CANCELLED':
        return 'Cancelled by SDO';
      case 'SDO_FORWARDED_TO_XEN':
        return 'Forwarded to XEN';
      case 'XEN_RETURNED_TO_LS':
        return 'Returned by XEN';
      case 'PDC_RETURNED_TO_LS':
        return 'Returned by PDC';
      case 'XEN_REJECTED':
        return 'Rejected by XEN';
      case 'LS_RESUBMIT_TO_XEN':
        return 'Resubmitted to XEN';
      case 'XEN_APPROVED_TO_PDC':
        return 'Approved & Forwarded to PDC';
      case 'LS_RESUBMIT_TO_PDC':
        return 'Resubmitted to PDC';
      case 'PDC_DELEGATED_TO_GRID':
        return 'Delegated to Grid Station';
      case 'PDC_REJECTED':
        return 'Rejected by PDC';
      case 'GRID_PRECHECKS_DONE':
        return 'Pre-Checks Completed';
      case 'PTW_ISSUED':
        return 'Issued-PDC Pending';
      case 'IN_EXECUTION':
        return 'Work in Progress';
      case 'COMPLETION_SUBMITTED':
        return 'Completion Submitted';
      case 'GRID_RESTORED_AND_CLOSED':
        return 'Completed & Closed';
      case 'CANCELLATION_REQUESTED_BY_LS':
        return 'Cancellation Requested';
      case 'CANCELLATION_APPROVED_BY_SDO':
        return 'Cancellation Approved by SDO';
      case 'GRID_CANCELLATION_CONFIRMED_AND_CLOSED':
        return 'Cancelled & Closed';
      case 'GRID_RESOLVE_REQUIRED':
        return 'Grid Resolve Required';
      case 'PDC_CONFIRMED':
        return 'PDC Confirmed';
      case 'NO_PTW_APPROVED_BY_SDO':
        return 'No PTW Approved by SDO';
      case 'RE_SUBMITTED_TO_PDC':
        return 'Re-Submitted to PDC';
      case 'MISC':
        return 'Misc';
      default:
        return s;
    }
  }

  static Color getStatusColor(String s) {
    switch (s.toUpperCase()) {
      case 'DRAFT':
      case 'SDO_RETURNED':
      case 'XEN_RETURNED_TO_LS':
      case 'PDC_RETURNED_TO_LS':
      case 'CANCELLATION_REQUESTED_BY_LS':
      case 'CANCELLATION_APPROVED_BY_SDO':
        return Colors.orange.shade700;

      case 'LS_RESUBMIT_TO_XEN':
      case 'LS_RESUBMIT_TO_PDC':
        return Colors.deepOrange.shade600;

      case 'SUBMITTED':
      case 'NO_PTW_APPROVED_BY_SDO':
      case 'SDO_FORWARDED_TO_XEN':
      case 'XEN_APPROVED_TO_PDC':
      case 'PDC_DELEGATED_TO_GRID':
      case 'GRID_PRECHECKS_DONE':
      case 'IN_EXECUTION':
      case 'COMPLETION_SUBMITTED':
      case 'PDC_CONFIRMED':
      case 'RE_SUBMITTED_TO_PDC':
        return Colors.blue.shade700;

      case 'PTW_ISSUED':
        return Colors.deepOrangeAccent;

      case 'GRID_RESTORED_AND_CLOSED':
        return Colors.green.shade700;

      case 'SDO_CANCELLED':
      case 'XEN_REJECTED':
      case 'PDC_REJECTED':
      case 'GRID_CANCELLATION_CONFIRMED_AND_CLOSED':
        return Colors.red.shade700;

      default:
        return Colors.grey.shade600;
    }
  }

  static IconData getStatusIcon(String s) {
    switch (s.toUpperCase()) {
      case 'DRAFT':
        return Icons.edit_outlined;
      case 'SUBMITTED':
      case 'SDO_FORWARDED_TO_XEN':
      case 'XEN_APPROVED_TO_PDC':
      case 'PDC_DELEGATED_TO_GRID':
        return Icons.send_outlined;
      case 'SDO_RETURNED':
      case 'XEN_RETURNED_TO_LS':
      case 'PDC_RETURNED_TO_LS':
        return Icons.keyboard_return;
      case 'LS_RESUBMIT_TO_XEN':
      case 'LS_RESUBMIT_TO_PDC':
        return Icons.refresh;
      case 'GRID_PRECHECKS_DONE':
        return Icons.check_circle_outline;
      case 'PTW_ISSUED':
        return Icons.task_alt;
      case 'IN_EXECUTION':
        return Icons.engineering;
      case 'COMPLETION_SUBMITTED':
        return Icons.assignment_turned_in_outlined;
      case 'GRID_RESTORED_AND_CLOSED':
        return Icons.check_circle;
      case 'SDO_CANCELLED':
      case 'XEN_REJECTED':
      case 'PDC_REJECTED':
      case 'GRID_CANCELLATION_CONFIRMED_AND_CLOSED':
        return Icons.cancel;
      case 'CANCELLATION_REQUESTED_BY_LS':
      case 'CANCELLATION_APPROVED_BY_SDO':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  static String getStatusCategory(String s) {
    switch (s.toUpperCase()) {
      case 'DRAFT':
        return 'Draft';
      case 'SUBMITTED':
      case 'SDO_FORWARDED_TO_XEN':
      case 'XEN_APPROVED_TO_PDC':
      case 'PDC_DELEGATED_TO_GRID':
      case 'GRID_PRECHECKS_DONE':
        return 'Under Review';
      case 'SDO_RETURNED':
      case 'XEN_RETURNED_TO_LS':
      case 'PDC_RETURNED_TO_LS':
      case 'LS_RESUBMIT_TO_XEN':
      case 'LS_RESUBMIT_TO_PDC':
        return 'Action Required';
      case 'PTW_ISSUED':
      case 'IN_EXECUTION':
      case 'COMPLETION_SUBMITTED':
        return 'Active';
      case 'GRID_RESTORED_AND_CLOSED':
        return 'Completed';
      case 'SDO_CANCELLED':
      case 'XEN_REJECTED':
      case 'PDC_REJECTED':
      case 'GRID_CANCELLATION_CONFIRMED_AND_CLOSED':
      case 'CANCELLATION_REQUESTED_BY_LS':
      case 'CANCELLATION_APPROVED_BY_SDO':
        return 'Cancelled/Rejected';
      default:
        return 'Other';
    }
  }
}
