import 'package:flutter/material.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

enum AppButtonType { primary, secondary, outlined, text }

/// Custom app button with consistent styling
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppDesignTokens.space8),
              ],
              Text(text),
            ],
          );

    Widget button;
    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          child: child,
        );
        break;
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: child,
        );
        break;
      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: child,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: loading ? null : onPressed,
          child: child,
        );
        break;
    }

    // Wrap with Semantics for accessibility
    final accessibleButton = Semantics(
      label: text,
      button: true,
      enabled: onPressed != null && !loading,
      child: button,
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: accessibleButton,
      );
    }

    return accessibleButton;
  }
}
