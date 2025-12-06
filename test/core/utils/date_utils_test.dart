import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/core/utils/date_utils.dart';

void main() {
  group('DateUtils', () {
    group('formatDateTime', () {
      test('should format DateTime with default format', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        final result = DateUtils.formatDateTime(date);
        expect(result, '2024-01-15 14:30');
      });

      test('should format DateTime with custom format', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        final result =
            DateUtils.formatDateTime(date, format: 'dd/MM/yyyy HH:mm');
        expect(result, '15/01/2024 14:30');
      });
    });

    group('formatDate', () {
      test('should format date with default format', () {
        final date = DateTime(2024, 1, 15);
        final result = DateUtils.formatDate(date);
        expect(result, '2024-01-15');
      });

      test('should format date with custom format', () {
        final date = DateTime(2024, 1, 15);
        final result = DateUtils.formatDate(date, format: 'dd/MM/yyyy');
        expect(result, '15/01/2024');
      });
    });

    group('formatTime', () {
      test('should format time with default format', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        final result = DateUtils.formatTime(date);
        expect(result, '14:30');
      });

      test('should format time with custom format', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        final result = DateUtils.formatTime(date, format: 'hh:mm a');
        expect(result, '02:30 PM');
      });
    });

    group('getRelativeTime', () {
      test('should return "Just now" for recent time', () {
        final now = DateTime.now();
        final result = DateUtils.getRelativeTime(now);
        expect(result, 'Just now');
      });

      test('should return minutes ago', () {
        final date = DateTime.now().subtract(const Duration(minutes: 5));
        final result = DateUtils.getRelativeTime(date);
        expect(result, '5 minutes ago');
      });

      test('should return hours ago', () {
        final date = DateTime.now().subtract(const Duration(hours: 2));
        final result = DateUtils.getRelativeTime(date);
        expect(result, '2 hours ago');
      });

      test('should return days ago', () {
        final date = DateTime.now().subtract(const Duration(days: 3));
        final result = DateUtils.getRelativeTime(date);
        expect(result, '3 days ago');
      });

      test('should return weeks ago', () {
        final date = DateTime.now().subtract(const Duration(days: 14));
        final result = DateUtils.getRelativeTime(date);
        expect(result, '2 weeks ago');
      });

      test('should return months ago', () {
        final date = DateTime.now().subtract(const Duration(days: 60));
        final result = DateUtils.getRelativeTime(date);
        expect(result, '2 months ago');
      });

      test('should return years ago', () {
        final date = DateTime.now().subtract(const Duration(days: 400));
        final result = DateUtils.getRelativeTime(date);
        expect(result, '1 years ago');
      });
    });

    group('isSameDay', () {
      test('should return true for same day', () {
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 15, 20, 45);
        expect(DateUtils.isSameDay(date1, date2), isTrue);
      });

      test('should return false for different days', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        expect(DateUtils.isSameDay(date1, date2), isFalse);
      });

      test('should return false for different months', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 2, 15);
        expect(DateUtils.isSameDay(date1, date2), isFalse);
      });

      test('should return false for different years', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2025, 1, 15);
        expect(DateUtils.isSameDay(date1, date2), isFalse);
      });
    });

    group('getDatesInRange', () {
      test('should return all dates in range', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 5);
        final dates = DateUtils.getDatesInRange(start, end);
        expect(dates.length, 5);
        expect(dates.first, start);
        expect(dates.last, end);
      });

      test('should return single date when start equals end', () {
        final date = DateTime(2024, 1, 15);
        final dates = DateUtils.getDatesInRange(date, date);
        expect(dates.length, 1);
        expect(dates.first, date);
      });

      test('should return empty list when start is after end', () {
        final start = DateTime(2024, 1, 5);
        final end = DateTime(2024, 1, 1);
        final dates = DateUtils.getDatesInRange(start, end);
        expect(dates.length, 0);
      });
    });
  });
}
