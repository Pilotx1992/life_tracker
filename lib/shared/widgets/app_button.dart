import 'package:flutter/material.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(text);

    if (icon != null && !isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
      case AppButtonVariant.secondary:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        );
    }
  }
}
