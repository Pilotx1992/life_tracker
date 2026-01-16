import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';

void main() {
  group('FinancialCommitment Entity', () {
    final createdAt = DateTime(2026, 1, 1);
    final updatedAt = DateTime(2026, 1, 15);

    group('Constructor', () {
      test('creates commitment with required fields', () {
        final commitment = FinancialCommitment(
          name: 'Emergency Fund',
          description: 'Build 6-month emergency fund',
          targetAmount: 10000.0,
          currency: 'USD',
          deadline: DateTime(2026, 12, 31),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.name, 'Emergency Fund');
        expect(commitment.targetAmount, 10000.0);
        expect(commitment.currentAmount, 0.0);
        expect(commitment.isCompleted, false);
      });

      test('creates commitment with partial progress', () {
        final commitment = FinancialCommitment(
          name: 'Vacation',
          description: 'Summer vacation fund',
          targetAmount: 5000.0,
          currentAmount: 2000.0,
          currency: 'USD',
          deadline: DateTime(2026, 6, 1),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.currentAmount, 2000.0);
      });
    });

    group('Computed Properties', () {
      test('progress calculates correctly', () {
        final commitment = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currentAmount: 250.0,
          currency: 'USD',
          deadline: DateTime(2026, 12, 31),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.progress, 0.25);
      });

      test('progress clamps at 1.0 when overfunded', () {
        final commitment = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currentAmount: 1500.0,
          currency: 'USD',
          deadline: DateTime(2026, 12, 31),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.progress, 1.0);
      });

      test('progress returns 0 when targetAmount is 0', () {
        final commitment = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 0.0,
          currentAmount: 0.0,
          currency: 'USD',
          deadline: DateTime(2026, 12, 31),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.progress, 0.0);
      });

      test('remainingAmount calculates correctly', () {
        final commitment = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currentAmount: 300.0,
          currency: 'USD',
          deadline: DateTime(2026, 12, 31),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.remainingAmount, 700.0);
      });

      test('remainingAmount is 0 when fully funded', () {
        final commitment = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currentAmount: 1000.0,
          currency: 'USD',
          deadline: DateTime(2026, 12, 31),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.remainingAmount, 0.0);
      });

      test('daysRemaining calculates correctly for future date', () {
        // Use a far future date to ensure test reliability
        final commitment = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currency: 'USD',
          deadline: DateTime(2030, 12, 31),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.daysRemaining, greaterThan(0));
      });

      test('daysRemaining is 0 for past deadline', () {
        final commitment = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currency: 'USD',
          deadline: DateTime(2020, 1, 1),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.daysRemaining, 0);
      });

      test('isOverdue returns true for past deadline with remaining amount',
          () {
        final commitment = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currentAmount: 500.0,
          currency: 'USD',
          deadline: DateTime(2020, 1, 1), // Past
          accountId: 1,
          isCompleted: false,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.isOverdue, true);
      });

      test('isOverdue returns false when completed', () {
        final commitment = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currentAmount: 1000.0,
          currency: 'USD',
          deadline: DateTime(2020, 1, 1), // Past
          accountId: 1,
          isCompleted: true,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment.isOverdue, false);
      });
    });

    group('CopyWith', () {
      test('returns new instance with updated currentAmount', () {
        final original = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currentAmount: 200.0,
          currency: 'USD',
          deadline: DateTime(2026, 12, 31),
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final copied = original.copyWith(currentAmount: 500.0);

        expect(copied.currentAmount, 500.0);
        expect(original.currentAmount, 200.0);
      });

      test('can mark as completed', () {
        final original = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currentAmount: 1000.0,
          currency: 'USD',
          deadline: DateTime(2026, 12, 31),
          accountId: 1,
          isCompleted: false,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final completed = original.copyWith(isCompleted: true);

        expect(completed.isCompleted, true);
        expect(original.isCompleted, false);
      });
    });

    group('Equality', () {
      test('commitments with same values are equal', () {
        final deadline = DateTime(2026, 12, 31);
        final commitment1 = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currency: 'USD',
          deadline: deadline,
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final commitment2 = FinancialCommitment(
          name: 'Test',
          description: 'Test',
          targetAmount: 1000.0,
          currency: 'USD',
          deadline: deadline,
          accountId: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(commitment1, equals(commitment2));
      });
    });
  });
}
