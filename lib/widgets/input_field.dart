import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_demo/res/palette.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.textInputFormatter,
    required this.inputType,
    required this.inputAction,
    required this.label,
    this.leading,
    this.validator,
    this.primaryColor = Palette.blueMedium,
    this.textColor = Palette.blueDark,
    this.errorColor = Colors.red,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputFormatter? textInputFormatter;
  final Widget? leading;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final String? Function(String?)? validator;
  final String label;
  final Color primaryColor;
  final Color textColor;
  final Color errorColor;
  final TextCapitalization textCapitalization;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      textCapitalization: textCapitalization,
      style: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
      ),
      decoration: InputDecoration(
        icon: leading,
        hintText: hintText,
        label: Text(
          label,
          style: TextStyle(
            color: primaryColor.withOpacity(0.8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
          ),
        ),
        hintStyle: TextStyle(
          color: primaryColor.withOpacity(0.4),
          fontWeight: FontWeight.normal,
          fontSize: 18,
          letterSpacing: 0.6,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primaryColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorStyle: TextStyle(color: errorColor),
        contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      ),
      cursorColor: primaryColor,
      keyboardType: inputType,
      textInputAction: inputAction,
      inputFormatters:
          textInputFormatter != null ? [textInputFormatter!] : null,
      validator: validator,
    );
  }
}
