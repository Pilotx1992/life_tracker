import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/core/utils/extensions.dart';

void main() {
  group('DateTimeExtension', () {
    group('dateOnly', () {
      test('should return date without time', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30, 45);
        final dateOnly = dateTime.dateOnly;
        expect(dateOnly.year, 2024);
        expect(dateOnly.month, 1);
        expect(dateOnly.day, 15);
        expect(dateOnly.hour, 0);
        expect(dateOnly.minute, 0);
        expect(dateOnly.second, 0);
      });
    });

    group('isSameDay', () {
      test('should return true for same day', () {
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 15, 20, 45);
        expect(date1.isSameDay(date2), isTrue);
      });

      test('should return false for different days', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        expect(date1.isSameDay(date2), isFalse);
      });
    });

    group('isToday', () {
      test('should return true for today', () {
        final today = DateTime.now();
        expect(today.isToday(), isTrue);
      });

      test('should return false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isToday(), isFalse);
      });

      test('should return false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isToday(), isFalse);
      });
    });

    group('isYesterday', () {
      test('should return true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isYesterday(), isTrue);
      });

      test('should return false for today', () {
        final today = DateTime.now();
        expect(today.isYesterday(), isFalse);
      });
    });

    group('isTomorrow', () {
      test('should return true for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isTomorrow(), isTrue);
      });

      test('should return false for today', () {
        final today = DateTime.now();
        expect(today.isTomorrow(), isFalse);
      });
    });
  });

  group('StringExtension', () {
    group('isValidEmail', () {
      test('should return true for valid emails', () {
        expect('test@example.com'.isValidEmail(), isTrue);
        expect('user.name@domain.co.uk'.isValidEmail(), isTrue);
        expect('user+tag@example.com'.isValidEmail(), isTrue);
      });

      test('should return false for invalid emails', () {
        expect('invalid'.isValidEmail(), isFalse);
        expect('@example.com'.isValidEmail(), isFalse);
        expect('user@'.isValidEmail(), isFalse);
        expect('user@domain'.isValidEmail(), isFalse);
        expect(''.isValidEmail(), isFalse);
      });
    });
  });

  group('NumExtension', () {
    test('heightBox should create SizedBox with height', () {
      const num value = 20;
      final box = value.heightBox;
      expect(box, isA<SizedBox>());
      expect(box.height, 20.0);
      expect(box.width, isNull);
    });

    test('widthBox should create SizedBox with width', () {
      const num value = 30;
      final box = value.widthBox;
      expect(box, isA<SizedBox>());
      expect(box.width, 30.0);
      expect(box.height, isNull);
    });
  });
}
