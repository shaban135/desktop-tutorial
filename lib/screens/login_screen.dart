import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/login_controller.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/gradient_button.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: MainLayout(
        title: 'MEPCO E-Safety  \n  میپکو ای-سیفٹی',
        showBackButton: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 0),
          child: Obx(
            () => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '(لاگ ان)',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontFamily: 'Jameel Noori Nastaleeq',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Text('Please enter a valid account'),
                  const Text(
                    'براہ کرم ایک درست اکاؤنٹ درج کریں۔',
                    style: TextStyle(fontFamily: 'Jameel Noori Nastaleeq'),
                  ),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    controller: controller.emailController,
                    labelText: 'Email / Mobile / SAP Code',
                    prefixIcon: Icons.email_outlined,
                    borderColor: controller.emailError.isNotEmpty
                        ? Colors.red
                        : Colors.grey,
                    onChanged: (_) {
                      if (controller.emailError.isNotEmpty) {
                        controller.emailError.value = '';
                      }
                    },
                  ),
                  if (controller.emailError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        controller.emailError.value,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: controller.passwordController,
                    labelText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    borderColor: controller.passwordError.isNotEmpty
                        ? Colors.red
                        : Colors.grey,
                    onChanged: (_) {
                      if (controller.passwordError.isNotEmpty) {
                        controller.passwordError.value = '';
                      }
                    },
                  ),
                  if (controller.passwordError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        controller.passwordError.value,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.forgotPassword);
                      },
                      child: const Text(
                        'Forgot Password? / پاس ورڈ بھول گئے؟',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontFamily: 'Jameel Noori Nastaleeq',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: controller.isLoading.value
                        ? const LoadingWidget()
                        : Column(
                            children: [
                              GradientButton(
                                text: 'Login',
                                onPressed: controller.login,
                              ),
                              if (controller.isBiometricEnabled.value)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InkWell(
                                    onTap: controller.loginWithBiometric,
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.fingerprint,
                                          size: 50,
                                          color: AppColors.primaryBlue,
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'Biometric Login',
                                          style: TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                   SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3, // 20% of screen height
                  ),
                  Center(
                    child: Text(
                      'Version ${controller.version.value}+${controller.buildNumber.value}',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
