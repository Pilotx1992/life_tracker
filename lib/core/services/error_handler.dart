import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/services/feedback_service.dart';

/// Error types for categorization
enum ErrorType {
  network,
  database,
  validation,
  authentication,
  permission,
  notFound,
  timeout,
  unknown,
}

/// App-specific exception with user-friendly messages
class AppException implements Exception {
  final String message;
  final String? userMessage;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.userMessage,
    this.type = ErrorType.unknown,
    this.originalError,
    this.stackTrace,
  });

  /// Gets the user-friendly message to display
  String get displayMessage => userMessage ?? _getDefaultMessage();

  String _getDefaultMessage() {
    switch (type) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.database:
        return 'There was a problem saving your data. Please try again.';
      case ErrorType.validation:
        return 'Please check your input and try again.';
      case ErrorType.authentication:
        return 'Please sign in again to continue.';
      case ErrorType.permission:
        return 'You don\'t have permission to perform this action.';
      case ErrorType.notFound:
        return 'The requested item could not be found.';
      case ErrorType.timeout:
        return 'The operation took too long. Please try again.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() => 'AppException: $message (type: $type)';
}

/// Error handler for consistent error handling across the app
class ErrorHandler {
  ErrorHandler._();

  /// Handles an error and shows appropriate feedback
  static void handle(
    BuildContext context,
    dynamic error, {
    StackTrace? stackTrace,
    VoidCallback? onRetry,
    bool showSnackbar = true,
  }) {
    final appException = _parseError(error, stackTrace);

    // Log the error in debug mode
    if (kDebugMode) {
      debugPrint('Error: ${appException.message}');
      debugPrint('Type: ${appException.type}');
      if (appException.originalError != null) {
        debugPrint('Original: ${appException.originalError}');
      }
      if (appException.stackTrace != null) {
        debugPrint('Stack trace:\n${appException.stackTrace}');
      }
    }

    // Show user feedback
    if (showSnackbar && context.mounted) {
      FeedbackService.showError(
        context,
        appException.displayMessage,
      );
    }
  }

  /// Parses any error into an AppException
  static AppException _parseError(dynamic error, StackTrace? stackTrace) {
    if (error is AppException) {
      return error;
    }

    // Network errors
    if (error is SocketException) {
      return AppException(
        message: 'Network error: ${error.message}',
        type: ErrorType.network,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Timeout errors
    if (error is TimeoutException) {
      return AppException(
        message: 'Timeout: ${error.message}',
        type: ErrorType.timeout,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Format exceptions (usually validation)
    if (error is FormatException) {
      return AppException(
        message: 'Format error: ${error.message}',
        type: ErrorType.validation,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Generic exception
    return AppException(
      message: error.toString(),
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Wraps an async operation with error handling
  static Future<T?> runSafe<T>(
    BuildContext context,
    Future<T> Function() operation, {
    VoidCallback? onRetry,
    bool showLoading = false,
    String? loadingMessage,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      if (context.mounted) {
        handle(context, e, stackTrace: stackTrace, onRetry: onRetry);
      }
      return null;
    }
  }

  /// Shows an error dialog with retry option
  static Future<bool> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String retryLabel = 'Try Again',
    String cancelLabel = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          if (onRetry != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
                onRetry();
              },
              child: Text(retryLabel),
            ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Mixin for easy error handling in StatefulWidgets
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  /// Runs an async operation with error handling
  Future<R?> runSafe<R>(
    Future<R> Function() operation, {
    VoidCallback? onRetry,
  }) async {
    return ErrorHandler.runSafe(
      context,
      operation,
      onRetry: onRetry,
    );
  }

  /// Shows an error to the user
  void showError(dynamic error, {StackTrace? stackTrace}) {
    ErrorHandler.handle(context, error, stackTrace: stackTrace);
  }
}

/// Extension for easy error handling on AsyncValue
extension AsyncValueErrorExtension<T> on AsyncValue<T> {
  /// Gets a user-friendly error message
  String get errorMessage {
    if (hasError) {
      final appException = ErrorHandler._parseError(error, stackTrace);
      return appException.displayMessage;
    }
    return '';
  }
}
