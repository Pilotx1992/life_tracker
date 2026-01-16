import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';

void main() {
  group('Income Entity', () {
    final testDate = DateTime(2026, 1, 15);

    group('Constructor', () {
      test('creates income with required fields', () {
        final income = Income(
          amount: 5000.0,
          currency: 'USD',
          source: 'Salary',
          accountId: 1,
          date: testDate,
        );

        expect(income.amount, 5000.0);
        expect(income.currency, 'USD');
        expect(income.source, 'Salary');
        expect(income.accountId, 1);
        expect(income.date, testDate);
        expect(income.isRecurring, false);
        expect(income.recurringFrequency, isNull);
      });

      test('creates recurring income with frequency', () {
        final income = Income(
          amount: 5000.0,
          currency: 'USD',
          source: 'Salary',
          accountId: 1,
          date: testDate,
          isRecurring: true,
          recurringFrequency: 'Monthly',
        );

        expect(income.isRecurring, true);
        expect(income.recurringFrequency, 'Monthly');
      });

      test('supports different income sources', () {
        const sources = ['Salary', 'Freelance', 'Investment', 'Gift', 'Other'];
        for (final source in sources) {
          final income = Income(
            amount: 1000.0,
            currency: 'USD',
            source: source,
            accountId: 1,
            date: testDate,
          );
          expect(income.source, source);
        }
      });
    });

    group('CopyWith', () {
      test('returns new instance with updated amount', () {
        final original = Income(
          amount: 5000.0,
          currency: 'USD',
          source: 'Salary',
          accountId: 1,
          date: testDate,
        );
        final copied = original.copyWith(amount: 6000.0);

        expect(copied.amount, 6000.0);
        expect(original.amount, 5000.0);
      });

      test('preserves all values when no args passed', () {
        final original = Income(
          id: 1,
          amount: 5000.0,
          currency: 'USD',
          source: 'Salary',
          accountId: 1,
          date: testDate,
          isRecurring: true,
          recurringFrequency: 'Monthly',
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
      });
    });

    group('Equality', () {
      test('incomes with same values are equal', () {
        final income1 = Income(
          amount: 5000.0,
          currency: 'USD',
          source: 'Salary',
          accountId: 1,
          date: testDate,
        );
        final income2 = Income(
          amount: 5000.0,
          currency: 'USD',
          source: 'Salary',
          accountId: 1,
          date: testDate,
        );

        expect(income1, equals(income2));
      });
    });
  });
}
