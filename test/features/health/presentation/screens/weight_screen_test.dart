import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_provider.dart';
import 'package:life_tracker/features/health/presentation/screens/weight_screen.dart';
import 'package:life_tracker/shared/widgets/states/skeleton_widgets.dart';

void main() {
  group('WeightScreen', () {
    testWidgets('should display PageSkeleton when loading', (tester) async {
      // Create a completer to keep the future pending
      final completer = Completer<WeightEntry?>();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            latestWeightProvider.overrideWith(
              (ref) => completer.future,
            ),
          ],
          child: const MaterialApp(home: WeightScreen()),
        ),
      );

      // Pump once to start the future
      await tester.pump();
      // The screen should show PageSkeleton while loading
      expect(find.byType(PageSkeleton), findsOneWidget);
      
      // Complete the future to avoid timer warnings
      completer.complete(null);
      await tester.pump();
    });

    testWidgets('should display empty state when there is no data',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            latestWeightProvider.overrideWith(
              (ref) => Future<WeightEntry?>.value(null),
            ),
          ],
          child: const MaterialApp(home: WeightScreen()),
        ),
      );

      await tester.pump();
      await tester.pump();

      // The screen should show empty state text
      expect(find.text('No weight entries yet'), findsOneWidget);
    });

    testWidgets('should display weight details when data is available',
        (tester) async {
      final weightEntry = WeightEntry(
        id: 1,
        weight: 70.0,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            latestWeightProvider.overrideWith(
              (ref) => Future<WeightEntry?>.value(weightEntry),
            ),
          ],
          child: const MaterialApp(home: WeightScreen()),
        ),
      );

      await tester.pump();
      await tester.pump();

      // The screen should show weight details
      expect(find.text('70.0 kg'), findsOneWidget);
    });

    testWidgets('should display error message when there is an error',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            latestWeightProvider.overrideWith(
              (ref) => Future<WeightEntry?>.error('Error'),
            ),
          ],
          child: const MaterialApp(home: WeightScreen()),
        ),
      );

      await tester.pump();
      await tester.pump();

      // The screen should show error text
      expect(find.textContaining('Error'), findsOneWidget);
    });
  });
}
