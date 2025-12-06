import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

/// Error state widget that displays error information with retry option
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.title,
    this.details,
    this.showDetailsInDebug = true,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String? title;
  final String? details;
  final bool showDetailsInDebug;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppDesignTokens.iconXLarge * 1.5,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppDesignTokens.space16),
            Text(
              title ?? 'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesignTokens.space8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            // Show debug details in debug mode
            if (kDebugMode && showDetailsInDebug && details != null) ...[
              const SizedBox(height: AppDesignTokens.space16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  details!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                  textAlign: TextAlign.start,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppDesignTokens.space24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline error widget for smaller error displays
class InlineErrorWidget extends StatelessWidget {
  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppDesignTokens.space16),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: AppDesignTokens.iconMedium,
          ),
          const SizedBox(width: AppDesignTokens.space12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppDesignTokens.space12),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              iconSize: AppDesignTokens.iconMedium,
              color: colorScheme.primary,
              tooltip: 'Retry',
            ),
          ],
        ],
      ),
    );
  }
}

/// Specialized error widget for network errors
class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  final VoidCallback? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message: message ?? 'Please check your connection and try again.',
      onRetry: onRetry,
    );
  }
}

/// Specialized error widget for timeout errors
class TimeoutErrorWidget extends StatelessWidget {
  const TimeoutErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  final VoidCallback? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      icon: Icons.hourglass_empty,
      title: 'Request Timed Out',
      message:
          message ?? 'The server took too long to respond. Please try again.',
      onRetry: onRetry,
    );
  }
}

/// Specialized error widget for empty/not found states
class NotFoundErrorWidget extends StatelessWidget {
  const NotFoundErrorWidget({
    super.key,
    this.onRetry,
    this.message,
    this.title,
  });

  final VoidCallback? onRetry;
  final String? message;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      icon: Icons.search_off,
      title: title ?? 'Not Found',
      message: message ?? 'The requested item could not be found.',
      onRetry: onRetry,
    );
  }
}

/// A banner-style error that appears at the top of a screen
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignTokens.space16,
            vertical: AppDesignTokens.space12,
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: AppDesignTokens.space12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                ),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'Retry',
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  tooltip: 'Dismiss',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy alias for backward compatibility
@Deprecated('Use ErrorStateWidget instead')
class ErrorDisplayWidget extends ErrorStateWidget {
  const ErrorDisplayWidget({
    super.key,
    required super.message,
    super.onRetry,
  });
}
