import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/forgot_password_controller.dart';
import 'package:mepco_esafety_app/widgets/gradient_button.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class VerifyIdentityScreen extends StatefulWidget {
  const VerifyIdentityScreen({super.key});

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  late List<FocusNode> _focusNodes;
  late Timer _timer;
  int _start = 59;

  final ForgotPasswordController controller = Get.find();

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(6, (index) => FocusNode());
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Verification With OTP \n او ٹی پی کے ساتھ تصدیق',
      showBackButton: true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify your Identity',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '( اپنی شناخت کی تصدیق کریں۔ )',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the verification code sent to your email ${controller.email}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      height: 55,
                      child: TextFormField(
                        controller: controller.otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            _focusNodes[index].unfocus();
                            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index].unfocus();
                            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                          }
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.primaryBorder, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.primaryBorder, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't received the code? "),
                    Text(
                      "00:${_start.toString().padLeft(2, '0')}",
                      style: const TextStyle(color: AppColors.primaryBlue),
                    ),
                    TextButton(
                      onPressed: _start == 0
                          ? () async {
                              setState(() {
                                _start = 59;
                              });
                              startTimer();
                              await controller.sendOtp();
                              Get.snackbar('OTP Sent',
                                  'A new verification code has been sent to ${controller.email}');
                            }
                          : null,
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          color: _start == 0 ? AppColors.primaryBlue : Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Obx(() {
                    return controller.isVerifyingOtp.value
                        ? const LoadingWidget()
                        : GradientButton(
                            text: 'Continue',
                            onPressed: controller.verifyOtp,
                          );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
