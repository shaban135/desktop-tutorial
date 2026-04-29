import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/gradient_button.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: MainLayout(
          title: '',
          showBackButton: true,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 150 : 0,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create an Account',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Please create an account to get started.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 28),
                    const CustomTextFormField(
                      labelText: 'Name',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    const CustomTextFormField(
                      labelText: 'Email',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    const CustomTextFormField(
                      labelText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    const CustomTextFormField(
                      labelText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GradientButton(
                        text: 'Sign up',
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 75, child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('OR'),
                        ),
                        SizedBox(width: 75, child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(color: AppColors.primaryGrey),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.login);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
