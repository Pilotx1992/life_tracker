import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/app_startup.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/features/health/presentation/screens/weight_screen.dart';

/// App initializer that waits for database to be ready
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarState = ref.watch(isarProvider);

    return isarState.when(
      data: (_) {
        // Database is ready, show main app
        return const WeightScreen();
      },
      loading: () {
        // Database is loading, show splash screen
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: Builder(
            builder: (context) {
              final colorScheme = Theme.of(context).colorScheme;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.track_changes,
                      size: 80,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Life Tracker',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Initializing...',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      error: (error, stack) {
        // Database initialization failed
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Failed to Initialize Database',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Retry initialization by invalidating provider
                      ref.invalidate(isarProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
