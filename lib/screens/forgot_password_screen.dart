import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/forgot_password_controller.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/gradient_button.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller = Get.find();

    return MainLayout(
      title: 'Password Recovery\n پاس ورڈ کی بازیابی',
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
                  'Forgot your Password',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '(پاس ورڈ بھول گئے)',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Enter your email to reset your password.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Text(
                  'اپنا پاس ورڈ دوبارہ ترتیب دینے کے لیے اپنا ای میل درج کریں۔',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),

                // Email or Mobile Number Field
                CustomTextFormField(
                  controller: controller.emailController,
                  labelText: 'Email or Mobile Number',
                  prefixIcon: Icons.email_outlined,
                ),

                const SizedBox(height: 32),

                Center(
                  child: Obx(() {
                    return controller.isSendingOtp.value
                        ? const LoadingWidget()
                        : GradientButton(
                            text: 'Get OTP',
                            onPressed: controller.sendOtp,
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
