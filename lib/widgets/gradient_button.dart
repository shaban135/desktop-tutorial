import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 225,
      height: 50,
      child: Material(
        borderRadius: BorderRadius.circular(96.49),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(96.49),
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: onPressed == null
                  ? null
                  : const LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF002171),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              color: onPressed == null ? Colors.grey.shade300 : null,
              borderRadius: BorderRadius.circular(96.49),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (onPressed != null)
                  Positioned(
                    top: -93,
                    left: -97,
                    child: Container(
                      width: 75,
                      height: 93,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF6B00),
                            Color(0xFFD81B60),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                Text(
                  text,
                  style: TextStyle(
                    color: onPressed == null ? Colors.grey.shade600 : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
