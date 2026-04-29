import 'package:flutter/material.dart';

import 'package:mepco_esafety_app/widgets/black_gradient_button.dart';
import 'package:mepco_esafety_app/widgets/gradient_button.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';

class BottomNavigationButtons extends StatelessWidget {
  final VoidCallback? onNextPressed;
  final VoidCallback? onBackPressed;
  final String nextText;
  final String backText;
  final bool isSubmitting;
  final bool showBackButton;

  const BottomNavigationButtons({
    super.key,
    required this.onNextPressed,
    this.onBackPressed,
    this.nextText = 'Next',
    this.backText = 'Back',
    this.isSubmitting = false,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton)
          Expanded(
            child: SizedBox(
              height: 50,
              child: BlackGradientButton(
                text: backText,
                onPressed: isSubmitting ? () {} : onBackPressed ?? () {},
              ),
            ),
          ),
        if (showBackButton) const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GradientButton(
                  text: nextText,
                  onPressed: isSubmitting ? null : onNextPressed,
                ),
                if (isSubmitting)
                  SizedBox(
                      child: LoadingWidget())
                  // const CircularProgressIndicator(
                  //   color: AppColors.primaryBlue,
                  // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
