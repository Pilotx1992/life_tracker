import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Unified feedback service for showing user notifications
/// Replaces all ScaffoldMessenger.showSnackBar calls throughout the app
class FeedbackService {
  /// Show success message with light haptic feedback
  static void showSuccess(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _showSnackBar(context, message, Colors.green.shade700, Icons.check_circle);
  }

  /// Show error message with heavy haptic feedback
  static void showError(BuildContext context, String message) {
    HapticFeedback.heavyImpact();
    _showSnackBar(context, message, Colors.red.shade700, Icons.error);
  }

  /// Show info message without haptic feedback
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue.shade700, Icons.info);
  }

  /// Show warning message with medium haptic feedback
  static void showWarning(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    _showSnackBar(context, message, Colors.orange.shade700, Icons.warning);
  }

  /// Internal method to show snackbar with consistent styling
  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    // Clear any existing snackbars first
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
