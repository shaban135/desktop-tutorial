import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import '../services/email_service.dart';

class ErrorFeedbackDialog extends StatefulWidget {
  final String errorMessage;
  final String? backendError;

  const ErrorFeedbackDialog({
    super.key,
    required this.errorMessage,
    this.backendError,
  });

  @override
  State<ErrorFeedbackDialog> createState() => _ErrorFeedbackDialogState();
}

class _ErrorFeedbackDialogState extends State<ErrorFeedbackDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  // User information variables
  String? _sapCode;
  String? _userName;
  String? _userEmail;
  String? _designation;
  String? _department;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(StorageKeys.userData);

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        setState(() {
          _sapCode = userData['sap_code']?.toString() ?? 'Unknown';
          _userName = userData['name']?.toString();
          _userEmail = userData['email']?.toString();
          _designation = userData['designation']?.toString();
          _department = userData['department']?.toString();
        });

        debugPrint('✅ User data loaded: SAP=$_sapCode, Name=$_userName, Email=$_userEmail');
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      setState(() {
        _sapCode = 'Unknown';
      });
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please describe what happened before submitting.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFDCE7FF),
        colorText: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFF3B82F6)),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Send email with complete user information and backend error
      final success = await EmailService.sendFeedbackEmail(
        sapCode: _sapCode ?? 'Unknown',
        userName: _userName,
        userEmail: _userEmail,
        designation: _designation,
        department: _department,
        errorMessage: widget.errorMessage,
        backendError: widget.backendError,
        userFeedback: _feedbackController.text.trim(),
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        Get.back();

        if (success) {
          Get.snackbar(
            'Feedback Sent!',
            'Your feedback has been emailed successfully. We\'ll review it shortly.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFD1FAE5),
            colorText: const Color(0xFF065F46),
            icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Sending Failed',
            'Could not send email. Please try again or contact support.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFFEE2E2),
            colorText: const Color(0xFF991B1B),
            icon: const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Get.snackbar(
          'Error',
          'An unexpected error occurred: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFEE2E2),
          colorText: const Color(0xFF991B1B),
          icon: const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF2563EB),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.feedback_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Help Us Improve',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _sapCode != null
                                  ? 'SAP ID: $_sapCode'
                                  : 'Loading...',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We detected an unexpected error. Please share what you were doing so we can fix it.',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error details card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF4B5563)
                                : const Color(0xFFFECACA),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 18,
                                  color: isDark
                                      ? Colors.red.shade300
                                      : Colors.red.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Error Details',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.red.shade300
                                        : Colors.red.shade700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.errorMessage,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade800,
                                fontFamily: 'monospace',
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Feedback input
                      Text(
                        'What were you doing?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _feedbackController,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g., I was trying to save my work when...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF374151)
                              : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF4B5563)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _isSubmitting ? null : () => Get.back(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitFeedback,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey.shade400,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Send Feedback',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.send_rounded, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

void showErrorFeedbackDialog(String errorMessage, {String? backendError}) {
  Get.dialog(
    ErrorFeedbackDialog(
      errorMessage: errorMessage,
      backendError: backendError,
    ),
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
  );
}
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../constants/storage_keys.dart';
// import '../services/email_service.dart';
//
// class ErrorFeedbackDialog extends StatefulWidget {
//   final String errorMessage;
//   final String? backendError;
//
//   const ErrorFeedbackDialog({
//     super.key,
//     required this.errorMessage,
//     this.backendError,
//   });
//
//   @override
//   State<ErrorFeedbackDialog> createState() => _ErrorFeedbackDialogState();
// }
//
// class _ErrorFeedbackDialogState extends State<ErrorFeedbackDialog> with SingleTickerProviderStateMixin {
//   final TextEditingController _feedbackController = TextEditingController();
//   bool _isSubmitting = false;
//
//   // User information variables
//   String? _sapCode;
//   String? _userName;
//   String? _userEmail;
//   String? _designation;
//   String? _department;
//
//   late AnimationController _animController;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _scaleAnimation = CurvedAnimation(
//       parent: _animController,
//       curve: Curves.easeOutBack,
//     );
//     _animController.forward();
//   }
//
//   Future<void> _loadUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userDataString = prefs.getString(StorageKeys.userData);
//
//       if (userDataString != null) {
//         final userData = jsonDecode(userDataString);
//         setState(() {
//           _sapCode = userData['sap_code']?.toString() ?? 'Unknown';
//           _userName = userData['name']?.toString();
//           _userEmail = userData['email']?.toString();
//           _designation = userData['designation']?.toString();
//           _department = userData['department']?.toString();
//         });
//
//         debugPrint('✅ User data loaded: SAP=$_sapCode, Name=$_userName, Email=$_userEmail');
//       }
//     } catch (e) {
//       debugPrint('❌ Error loading user data: $e');
//       setState(() {
//         _sapCode = 'Unknown';
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _feedbackController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }
//
//   void _submitFeedback() async {
//     if (_feedbackController.text.trim().isEmpty) {
//       Get.snackbar(
//         'Required',
//         'Please describe what happened before submitting.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: const Color(0xFFDCE7FF),
//         colorText: const Color(0xFF1E3A8A),
//         icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFF3B82F6)),
//         margin: const EdgeInsets.all(16),
//         borderRadius: 12,
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       // Send email with complete user information and backend error
//       final success = await EmailService.sendFeedbackEmail(
//         sapCode: _sapCode ?? 'Unknown',
//         userName: _userName,
//         userEmail: _userEmail,
//         designation: _designation,
//         department: _department,
//         errorMessage: widget.errorMessage,
//         backendError: widget.backendError,
//         userFeedback: _feedbackController.text.trim(),
//       );
//
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//         Get.back();
//
//         if (success) {
//           Get.snackbar(
//             'Feedback Sent!',
//             'Your feedback has been emailed successfully. We\'ll review it shortly.',
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: const Color(0xFFD1FAE5),
//             colorText: const Color(0xFF065F46),
//             icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
//             margin: const EdgeInsets.all(16),
//             borderRadius: 12,
//             duration: const Duration(seconds: 3),
//           );
//         } else {
//           Get.snackbar(
//             'Sending Failed',
//             'Could not send email. Please try again or contact support.',
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: const Color(0xFFFEE2E2),
//             colorText: const Color(0xFF991B1B),
//             icon: const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
//             margin: const EdgeInsets.all(16),
//             borderRadius: 12,
//             duration: const Duration(seconds: 4),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//         Get.snackbar(
//           'Error',
//           'An unexpected error occurred: ${e.toString()}',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: const Color(0xFFFEE2E2),
//           colorText: const Color(0xFF991B1B),
//           icon: const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
//           margin: const EdgeInsets.all(16),
//           borderRadius: 12,
//           duration: const Duration(seconds: 4),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Dialog(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 500),
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1F2937) : Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 40,
//                 offset: const Offset(0, 20),
//               ),
//             ],
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header with gradient
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF3B82F6),
//                         Color(0xFF2563EB),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(24),
//                       topRight: Radius.circular(24),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(
//                           Icons.feedback_rounded,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Help Us Improve',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 letterSpacing: -0.5,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               _sapCode != null
//                                   ? 'SAP ID: $_sapCode'
//                                   : 'Loading...',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.white70,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Content
//                 Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'We detected an unexpected error. Please share what you were doing so we can fix it.',
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
//                           height: 1.5,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Error details card
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: isDark
//                               ? const Color(0xFF374151)
//                               : const Color(0xFFFEF2F2),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: isDark
//                                 ? const Color(0xFF4B5563)
//                                 : const Color(0xFFFECACA),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.error_outline_rounded,
//                                   size: 18,
//                                   color: isDark
//                                       ? Colors.red.shade300
//                                       : Colors.red.shade700,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Error Details',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     color: isDark
//                                         ? Colors.red.shade300
//                                         : Colors.red.shade700,
//                                     letterSpacing: 0.3,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               widget.errorMessage,
//                               maxLines: 3,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: isDark
//                                     ? Colors.grey.shade300
//                                     : Colors.grey.shade800,
//                                 fontFamily: 'monospace',
//                                 height: 1.4,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Feedback input
//                       Text(
//                         'What were you doing?',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: isDark ? Colors.white : Colors.grey.shade900,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextField(
//                         controller: _feedbackController,
//                         maxLines: 4,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: isDark ? Colors.white : Colors.black87,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'E.g., I was trying to save my work when...',
//                           hintStyle: TextStyle(
//                             color: isDark
//                                 ? Colors.grey.shade500
//                                 : Colors.grey.shade400,
//                           ),
//                           filled: true,
//                           fillColor: isDark
//                               ? const Color(0xFF374151)
//                               : Colors.grey.shade50,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide(
//                               color: isDark
//                                   ? const Color(0xFF4B5563)
//                                   : Colors.grey.shade200,
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF3B82F6),
//                               width: 2,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.all(16),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//
//                       // Action buttons
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextButton(
//                               onPressed: _isSubmitting ? null : () => Get.back(),
//                               style: TextButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(vertical: 16),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Skip',
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w600,
//                                   color: isDark
//                                       ? Colors.grey.shade400
//                                       : Colors.grey.shade600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             flex: 2,
//                             child: ElevatedButton(
//                               onPressed: _isSubmitting ? null : _submitFeedback,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF3B82F6),
//                                 foregroundColor: Colors.white,
//                                 elevation: 0,
//                                 padding: const EdgeInsets.symmetric(vertical: 16),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 disabledBackgroundColor: Colors.grey.shade400,
//                               ),
//                               child: _isSubmitting
//                                   ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2.5,
//                                 ),
//                               )
//                                   : const Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     'Send Feedback',
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   SizedBox(width: 8),
//                                   Icon(Icons.send_rounded, size: 18),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// void showErrorFeedbackDialog(String errorMessage, {String? backendError}) {
//   Get.dialog(
//     ErrorFeedbackDialog(
//       errorMessage: errorMessage,
//       backendError: backendError,
//     ),
//     barrierDismissible: true,
//     barrierColor: Colors.black.withOpacity(0.5),
//   );
// }
