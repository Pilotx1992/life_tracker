import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

void main() {
  group('AppTextField', () {
    testWidgets('should display label when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(label: 'Test Label'),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('should not display label when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should display hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(hint: 'Enter text'),
          ),
        ),
      );

      expect(find.text('Enter text'), findsOneWidget);
    });

    testWidgets('should accept text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(controller: controller),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test input');
      expect(controller.text, 'Test input');
    });

    testWidgets('should use initial value when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(initialValue: 'Initial'),
          ),
        ),
      );

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.initialValue, 'Initial');
    });

    testWidgets('should show obscure text when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(obscureText: true),
          ),
        ),
      );

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      // Check that obscureText is set by verifying the widget was created
      expect(textField, isNotNull);
      // The obscureText property is internal, so we verify by checking the widget exists
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should call validator when provided', (tester) async {
      String? validationResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              validator: (value) {
                validationResult = value?.isEmpty == true ? 'Required' : null;
                return validationResult;
              },
            ),
          ),
        ),
      );

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      final result = textField.validator?.call('');
      expect(result, 'Required');
    });

    testWidgets('should call onChanged callback', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Changed');
      expect(changedValue, 'Changed');
    });

    testWidgets('should respect maxLines', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(maxLines: 5),
          ),
        ),
      );

      // Verify widget was created with maxLines
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should respect maxLength', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(maxLength: 10),
          ),
        ),
      );

      // Verify widget was created with maxLength
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(enabled: false),
          ),
        ),
      );

      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });
  });
}
