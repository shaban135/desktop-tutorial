import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/forgot_password_controller.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/gradient_button.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class CreateNewPasswordScreen extends StatelessWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller = Get.find();

    return MainLayout(
      title: 'Password Creation \n  پاس ورڈ بنائیں',
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
                  'Create a New Password',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '(نیا پاس ورڈ بنائیں)',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the new password and try to not forgot it',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Text(
                  'نیا پاس ورڈ درج کریں اور اسے نہ بھولنے کی کوشش کریں۔',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 15),

                // New Password Field
                CustomTextFormField(
                  controller: controller.newPasswordController,
                  labelText: 'New Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 16),

                // Re-Type New Password Field
                CustomTextFormField(
                  controller: controller.confirmPasswordController,
                  labelText: 'Re-Type New Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 32),

                Center(
                  child: Obx(() {
                    return controller.isResettingPassword.value
                        ? const LoadingWidget()
                        : GradientButton(
                            text: 'Login',
                            onPressed: controller.resetPassword,
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
