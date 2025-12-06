import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/providers/database_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbAsync = ref.watch(databaseProvider);

    dbAsync.when(
      data: (isar) {
        // Navigate to main when ready. Delay to show splash briefly.
        Future.microtask(() {
          if (!context.mounted) return;
          Navigator.of(context).pushReplacementNamed('/');
        });
      },
      loading: () {},
      error: (e, st) {},
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            FlutterLogo(size: 96),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
