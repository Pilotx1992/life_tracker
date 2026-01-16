import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/usecases/calculate_next_due_date.dart';

void main() {
  group('CalculateNextDueDate', () {
    group('Monthly Bills', () {
      test('should return next month if day has passed', () {
        final bill = _createBill(frequency: 'monthly', dayOfSchedule: 10);
        // From Jan 15, day 10 has passed, so next is Feb 10
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 1, 15),
        );
        expect(result, DateTime(2026, 2, 10));
      });

      test('should return this month if day has not passed', () {
        final bill = _createBill(frequency: 'monthly', dayOfSchedule: 20);
        // From Jan 15, day 20 is still in the future
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 1, 15),
        );
        expect(result, DateTime(2026, 1, 20));
      });

      test('should return next month if day is today', () {
        final bill = _createBill(frequency: 'monthly', dayOfSchedule: 15);
        // From Jan 15, day 15 is today, so next is Feb 15
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 1, 15),
        );
        expect(result, DateTime(2026, 2, 15));
      });

      test('should clamp to last day of month for short months', () {
        final bill = _createBill(frequency: 'monthly', dayOfSchedule: 31);
        // February doesn't have 31 days
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 1, 15),
        );
        // Feb 2026 has 28 days
        expect(result, DateTime(2026, 1, 31));
      });

      test('should handle December to January transition', () {
        final bill = _createBill(frequency: 'monthly', dayOfSchedule: 10);
        // From Dec 15, next is Jan 10 next year
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 12, 15),
        );
        expect(result, DateTime(2027, 1, 10));
      });
    });

    group('Weekly Bills', () {
      test('should return this week if day has not passed', () {
        final bill = _createBill(frequency: 'weekly', dayOfSchedule: 5);
        // Jan 15, 2026 is Thursday (4), Friday (5) hasn't passed
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 1, 15), // Thursday
        );
        expect(result, DateTime(2026, 1, 16)); // Friday
      });

      test('should return next week if day has passed', () {
        final bill = _createBill(frequency: 'weekly', dayOfSchedule: 2);
        // Jan 15, 2026 is Thursday (4), Tuesday (2) passed
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 1, 15), // Thursday
        );
        expect(result, DateTime(2026, 1, 20)); // Next Tuesday (5 days later)
      });

      test('should return next week for same day', () {
        final bill = _createBill(frequency: 'weekly', dayOfSchedule: 4);
        // Jan 15, 2026 is Thursday (4), same day = next week
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 1, 15), // Thursday
        );
        expect(result, DateTime(2026, 1, 22)); // Next Thursday
      });
    });

    group('Yearly Bills', () {
      test('should return this year if date has not passed', () {
        final bill = _createBill(frequency: 'yearly', dayOfSchedule: 20);
        // From Jan 15, day 20 hasn't passed
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 1, 15),
        );
        expect(result, DateTime(2026, 1, 20));
      });

      test('should return next year if date has passed', () {
        final bill = _createBill(frequency: 'yearly', dayOfSchedule: 10);
        // From Jan 15, day 10 has passed
        final result = CalculateNextDueDate.calculate(
          bill,
          fromDate: DateTime(2026, 1, 15),
        );
        expect(result, DateTime(2027, 1, 10));
      });
    });

    group('Edge Cases', () {
      test('should throw for invalid frequency', () {
        final bill = _createBill(frequency: 'invalid', dayOfSchedule: 15);
        expect(
          () => CalculateNextDueDate.calculate(
            bill,
            fromDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}

RecurringBill _createBill({
  required String frequency,
  required int dayOfSchedule,
}) {
  return RecurringBill(
    name: 'Test Bill',
    amount: 100.0,
    currency: 'USD',
    categoryId: 1,
    accountId: 1,
    frequency: frequency,
    dayOfSchedule: dayOfSchedule,
    nextDueDate: DateTime.now(),
    createdAt: DateTime.now(),
  );
}
