import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';

void main() {
  group('RecurringBill Entity', () {
    group('Computed Properties - Installments', () {
      test('remainingAmount returns correct value for installment', () {
        final bill = _createInstallmentBill(
          totalAmount: 1200.0,
          paidAmount: 300.0,
        );
        expect(bill.remainingAmount, 900.0);
      });

      test('remainingAmount returns 0 for recurring bills', () {
        final bill = _createRecurringBill();
        expect(bill.remainingAmount, 0.0);
      });

      test('progressPercentage calculates correctly', () {
        final bill = _createInstallmentBill(
          totalAmount: 1000.0,
          paidAmount: 250.0,
        );
        expect(bill.progressPercentage, 25.0);
      });

      test('progressPercentage returns 0 for recurring bills', () {
        final bill = _createRecurringBill();
        expect(bill.progressPercentage, 0.0);
      });

      test('progressPercentage handles zero totalAmount', () {
        final bill = _createInstallmentBill(
          totalAmount: 0.0,
          paidAmount: 0.0,
        );
        expect(bill.progressPercentage, 0.0);
      });

      test('isFullyPaid returns true when remainingAmount is zero', () {
        final bill = _createInstallmentBill(
          totalAmount: 1000.0,
          paidAmount: 1000.0,
        );
        expect(bill.isFullyPaid, true);
      });

      test('isFullyPaid returns false when there is remaining amount', () {
        final bill = _createInstallmentBill(
          totalAmount: 1000.0,
          paidAmount: 500.0,
        );
        expect(bill.isFullyPaid, false);
      });

      test('isFullyPaid returns false for recurring bills', () {
        final bill = _createRecurringBill();
        expect(bill.isFullyPaid, false);
      });

      test('remainingInstallments calculates correctly', () {
        final bill = _createInstallmentBill(
          totalInstallments: 12,
          paidInstallments: 5,
        );
        expect(bill.remainingInstallments, 7);
      });

      test('remainingInstallments returns 0 for recurring bills', () {
        final bill = _createRecurringBill();
        expect(bill.remainingInstallments, 0);
      });

      test('isInstallment returns true for installment type', () {
        final bill = _createInstallmentBill();
        expect(bill.isInstallment, true);
      });

      test('isInstallment returns false for recurring type', () {
        final bill = _createRecurringBill();
        expect(bill.isInstallment, false);
      });
    });

    group('CopyWith', () {
      test('copyWith returns new instance with updated values', () {
        final original = _createRecurringBill(name: 'Original');
        final copied = original.copyWith(name: 'Updated');

        expect(copied.name, 'Updated');
        expect(original.name, 'Original');
        expect(copied.amount, original.amount);
      });

      test('copyWith preserves values when not specified', () {
        final original = _createRecurringBill(
          name: 'Test Bill',
          amount: 150.0,
        );
        final copied = original.copyWith(amount: 200.0);

        expect(copied.name, 'Test Bill');
        expect(copied.amount, 200.0);
      });
    });

    group('Equality', () {
      test('bills with same values are equal', () {
        final bill1 = _createRecurringBill(name: 'Test', amount: 100.0);
        final bill2 = _createRecurringBill(name: 'Test', amount: 100.0);

        expect(bill1, equals(bill2));
      });

      test('bills with different values are not equal', () {
        final bill1 = _createRecurringBill(name: 'Test', amount: 100.0);
        final bill2 = _createRecurringBill(name: 'Test', amount: 200.0);

        expect(bill1, isNot(equals(bill2)));
      });
    });
  });
}

RecurringBill _createRecurringBill({
  String name = 'Test Recurring',
  double amount = 100.0,
}) {
  return RecurringBill(
    name: name,
    amount: amount,
    currency: 'USD',
    categoryId: 1,
    accountId: 1,
    frequency: 'monthly',
    dayOfSchedule: 15,
    nextDueDate: DateTime(2026, 1, 15),
    createdAt: DateTime(2026, 1, 1),
    type: BillType.recurring,
  );
}

RecurringBill _createInstallmentBill({
  double totalAmount = 1200.0,
  int totalInstallments = 12,
  int paidInstallments = 0,
  double paidAmount = 0.0,
}) {
  return RecurringBill(
    name: 'Test Installment',
    amount: 100.0,
    currency: 'USD',
    categoryId: 1,
    accountId: 1,
    frequency: 'monthly',
    dayOfSchedule: 15,
    nextDueDate: DateTime(2026, 1, 15),
    createdAt: DateTime(2026, 1, 1),
    type: BillType.installment,
    totalAmount: totalAmount,
    totalInstallments: totalInstallments,
    paidInstallments: paidInstallments,
    paidAmount: paidAmount,
  );
}
