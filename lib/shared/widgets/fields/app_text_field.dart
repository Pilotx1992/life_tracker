import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

/// Custom text field with consistent styling
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.inputFormatters,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppDesignTokens.space8),
        ],
        Semantics(
          label: label ?? hint,
          hint: hint != null && label != null ? hint : null,
          textField: true,
          enabled: enabled,
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            maxLength: maxLength,
            validator: validator,
            onChanged: onChanged,
            enabled: enabled,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefix,
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}
