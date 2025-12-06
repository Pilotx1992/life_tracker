import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/shared/widgets/states/loading_widget.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('should display loading indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: 'Loading...'),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should not display message when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should use custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(size: 60),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 60);
      expect(sizedBox.height, 60);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('should display icon and title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No items',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No items',
              subtitle: 'Add your first item',
            ),
          ),
        ),
      );

      expect(find.text('Add your first item'), findsOneWidget);
    });

    testWidgets('should display action button when provided', (tester) async {
      bool wasPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No items',
              actionLabel: 'Add Item',
              onAction: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      await tester.tap(find.text('Add Item'));
      expect(wasPressed, isTrue);
    });

    testWidgets('should not display action button when not provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No items',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('ErrorStateWidget', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(message: 'Error occurred'),
          ),
        ),
      );

      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should display custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(
              message: 'Error',
              icon: Icons.warning,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry provided',
        (tester) async {
      bool wasRetried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(
              message: 'Error',
              onRetry: () {
                wasRetried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(wasRetried, isTrue);
    });

    testWidgets('should not display retry button when onRetry not provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(message: 'Error'),
          ),
        ),
      );

      expect(find.text('Try Again'), findsNothing);
    });
  });

  group('InlineErrorWidget', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorWidget(message: 'Inline error'),
          ),
        ),
      );

      expect(find.text('Inline error'), findsOneWidget);
    });

    testWidgets('should display retry icon when onRetry provided',
        (tester) async {
      bool wasRetried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineErrorWidget(
              message: 'Error',
              onRetry: () {
                wasRetried = true;
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      expect(wasRetried, isTrue);
    });

    testWidgets('should not display retry icon when onRetry not provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorWidget(message: 'Error'),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsNothing);
    });
  });
}
