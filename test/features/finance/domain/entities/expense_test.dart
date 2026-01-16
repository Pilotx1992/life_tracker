import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';

void main() {
  group('Expense Entity', () {
    final testDate = DateTime(2026, 1, 15);

    group('Constructor', () {
      test('creates expense with required fields', () {
        final expense = Expense(
          amount: 50.0,
          currency: 'USD',
          categoryId: 1,
          accountId: 2,
          date: testDate,
        );

        expect(expense.amount, 50.0);
        expect(expense.currency, 'USD');
        expect(expense.categoryId, 1);
        expect(expense.accountId, 2);
        expect(expense.date, testDate);
        expect(expense.id, isNull);
        expect(expense.note, isNull);
        expect(expense.receiptPath, isNull);
      });

      test('creates expense with all fields', () {
        final expense = Expense(
          id: 10,
          amount: 100.0,
          currency: 'EUR',
          categoryId: 3,
          accountId: 4,
          date: testDate,
          note: 'Grocery shopping',
          receiptPath: '/path/to/receipt.jpg',
        );

        expect(expense.id, 10);
        expect(expense.note, 'Grocery shopping');
        expect(expense.receiptPath, '/path/to/receipt.jpg');
      });
    });

    group('CopyWith', () {
      test('returns new instance with updated amount', () {
        final original = Expense(
          amount: 50.0,
          currency: 'USD',
          categoryId: 1,
          accountId: 2,
          date: testDate,
        );
        final copied = original.copyWith(amount: 75.0);

        expect(copied.amount, 75.0);
        expect(original.amount, 50.0);
      });

      test('preserves all values when no args passed', () {
        final original = Expense(
          id: 1,
          amount: 50.0,
          currency: 'USD',
          categoryId: 1,
          accountId: 2,
          date: testDate,
          note: 'Test',
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
      });
    });

    group('Equality', () {
      test('expenses with same values are equal', () {
        final expense1 = Expense(
          amount: 50.0,
          currency: 'USD',
          categoryId: 1,
          accountId: 2,
          date: testDate,
        );
        final expense2 = Expense(
          amount: 50.0,
          currency: 'USD',
          categoryId: 1,
          accountId: 2,
          date: testDate,
        );

        expect(expense1, equals(expense2));
      });

      test('expenses with different amounts are not equal', () {
        final expense1 = Expense(
          amount: 50.0,
          currency: 'USD',
          categoryId: 1,
          accountId: 2,
          date: testDate,
        );
        final expense2 = Expense(
          amount: 100.0,
          currency: 'USD',
          categoryId: 1,
          accountId: 2,
          date: testDate,
        );

        expect(expense1, isNot(equals(expense2)));
      });
    });
  });
}
