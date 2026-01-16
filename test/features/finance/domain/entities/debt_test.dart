import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';

void main() {
  group('Debt Entity', () {
    group('Constructor', () {
      test('creates debt with required fields', () {
        final debt = Debt(
          type: 'i_owe',
          amount: 1000.0,
          person: 'John',
          dueDate: DateTime(2026, 3, 1),
        );

        expect(debt.type, 'i_owe');
        expect(debt.amount, 1000.0);
        expect(debt.paidAmount, 0.0);
        expect(debt.person, 'John');
        expect(debt.isPaid, false);
      });

      test('creates debt with all fields', () {
        final debt = Debt(
          id: 1,
          type: 'owed_to_me',
          amount: 500.0,
          paidAmount: 200.0,
          person: 'Jane',
          dueDate: DateTime(2026, 2, 15),
          createdAt: DateTime(2026, 1, 1),
          note: 'For dinner',
          isPaid: false,
        );

        expect(debt.id, 1);
        expect(debt.paidAmount, 200.0);
        expect(debt.note, 'For dinner');
      });
    });

    group('Computed Properties', () {
      test('remainingAmount calculates correctly', () {
        final debt = Debt(
          type: 'i_owe',
          amount: 1000.0,
          paidAmount: 300.0,
          person: 'John',
          dueDate: DateTime(2026, 3, 1),
        );

        expect(debt.remainingAmount, 700.0);
      });

      test('remainingAmount is zero when fully paid', () {
        final debt = Debt(
          type: 'i_owe',
          amount: 1000.0,
          paidAmount: 1000.0,
          person: 'John',
          dueDate: DateTime(2026, 3, 1),
        );

        expect(debt.remainingAmount, 0.0);
      });

      test('isOverdue returns true for past due date when not paid', () {
        final debt = Debt(
          type: 'i_owe',
          amount: 1000.0,
          person: 'John',
          dueDate: DateTime(2020, 1, 1), // Past date
          isPaid: false,
        );

        expect(debt.isOverdue, true);
      });

      test('isOverdue returns false for future due date', () {
        final debt = Debt(
          type: 'i_owe',
          amount: 1000.0,
          person: 'John',
          dueDate: DateTime(2030, 12, 31), // Future date
          isPaid: false,
        );

        expect(debt.isOverdue, false);
      });

      test('isOverdue returns false when paid even if past due', () {
        final debt = Debt(
          type: 'i_owe',
          amount: 1000.0,
          person: 'John',
          dueDate: DateTime(2020, 1, 1), // Past date
          isPaid: true,
        );

        expect(debt.isOverdue, false);
      });
    });

    group('Debt Types', () {
      test('supports i_owe type', () {
        final debt = Debt(
          type: 'i_owe',
          amount: 1000.0,
          person: 'John',
          dueDate: DateTime(2026, 3, 1),
        );
        expect(debt.type, 'i_owe');
      });

      test('supports owed_to_me type', () {
        final debt = Debt(
          type: 'owed_to_me',
          amount: 500.0,
          person: 'Jane',
          dueDate: DateTime(2026, 3, 1),
        );
        expect(debt.type, 'owed_to_me');
      });
    });

    group('CopyWith', () {
      test('returns new instance with updated paidAmount', () {
        final original = Debt(
          type: 'i_owe',
          amount: 1000.0,
          paidAmount: 200.0,
          person: 'John',
          dueDate: DateTime(2026, 3, 1),
        );
        final copied = original.copyWith(paidAmount: 500.0);

        expect(copied.paidAmount, 500.0);
        expect(original.paidAmount, 200.0);
        expect(copied.remainingAmount, 500.0);
      });

      test('can mark as paid', () {
        final original = Debt(
          type: 'i_owe',
          amount: 1000.0,
          person: 'John',
          dueDate: DateTime(2026, 3, 1),
          isPaid: false,
        );
        final copied = original.copyWith(isPaid: true, paidAmount: 1000.0);

        expect(copied.isPaid, true);
        expect(copied.remainingAmount, 0.0);
      });
    });

    group('Equality', () {
      test('debts with same values are equal', () {
        final dueDate = DateTime(2026, 3, 1);
        final debt1 = Debt(
          type: 'i_owe',
          amount: 1000.0,
          person: 'John',
          dueDate: dueDate,
        );
        final debt2 = Debt(
          type: 'i_owe',
          amount: 1000.0,
          person: 'John',
          dueDate: dueDate,
        );

        expect(debt1, equals(debt2));
      });
    });
  });
}
