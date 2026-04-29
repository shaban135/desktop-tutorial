import 'package:flutter/material.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final int maxLines;
  final bool readOnly;
  final bool enabled;
  final Color? borderColor;
  final Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.maxLines = 1,
    this.readOnly = false,
    this.enabled = true,
    this.borderColor,
    this.onChanged,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final Color fillColor =
        widget.readOnly ? const Color(0xFFF3F4F6) : const Color(0xFFFFFFFF);

    Widget? suffixIconWidget;
    if (widget.obscureText) {
      // If the field is a password field, show the visibility toggle icon.
      suffixIconWidget = IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          color: AppColors.primaryGrey,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      // Otherwise, show the normal suffix icon if provided.
      suffixIconWidget = Icon(widget.suffixIcon);
    }

    Widget textField = TextFormField(
      cursorColor: AppColors.primaryBlue,
      controller: widget.controller,
      obscureText: _isObscured, // Use the state variable for toggling.
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          color: AppColors.primaryGrey,
          fontSize: 14,
        ),
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        prefix: widget.prefix,
        suffixIcon: suffixIconWidget, // Use the dynamically created suffix icon.
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.maxLines > 1 ? 16.0 : 32.0),
          borderSide: const BorderSide(
            color: AppColors.primaryBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.maxLines > 1 ? 16.0 : 32.0),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.maxLines > 1 ? 16.0 : 32.0),
          borderSide: const BorderSide(color: AppColors.primaryBorder),
        ),
      ),
    );

    if (widget.readOnly) {
      return AbsorbPointer(child: textField);
    }
    return textField;
  }
}
