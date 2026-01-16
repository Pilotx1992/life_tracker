import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/core/services/feedback_service.dart';

void main() {
  group('FeedbackService', () {
    Widget buildTestWidget(void Function(BuildContext) onPressed) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => onPressed(context),
              child: const Text('Test'),
            ),
          ),
        ),
      );
    }

    testWidgets('showSuccess displays snackbar with check icon',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          (context) => FeedbackService.showSuccess(context, 'Success message'),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pump();

      expect(find.text('Success message'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('showError displays snackbar with error icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          (context) => FeedbackService.showError(context, 'Error message'),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pump();

      expect(find.text('Error message'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('showInfo displays snackbar with info icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          (context) => FeedbackService.showInfo(context, 'Info message'),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pump();

      expect(find.text('Info message'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('showWarning displays snackbar with warning icon',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          (context) => FeedbackService.showWarning(context, 'Warning message'),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pump();

      expect(find.text('Warning message'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('showSnackBar clears existing snackbars before showing new one',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          (context) {
            FeedbackService.showSuccess(context, 'First');
            FeedbackService.showError(context, 'Second');
          },
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pump();

      // Only the second snackbar should be visible
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('First'), findsNothing);
    });
  });
}
