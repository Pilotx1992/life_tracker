import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';

void main() {
  group('Account Entity', () {
    group('Constructor', () {
      test('creates account with required fields', () {
        const account = Account(
          name: 'Main Bank',
          currency: 'USD',
          balance: 1000.0,
          type: 'Bank',
        );

        expect(account.name, 'Main Bank');
        expect(account.currency, 'USD');
        expect(account.balance, 1000.0);
        expect(account.type, 'Bank');
        expect(account.id, isNull);
      });

      test('creates account with all fields', () {
        const account = Account(
          id: 1,
          name: 'Credit Card',
          currency: 'EUR',
          balance: -500.0,
          type: 'Card',
          bankName: 'ABC Bank',
          cardLastDigits: '1234',
          notes: 'Monthly expenses',
          creditLimit: 5000.0,
        );

        expect(account.id, 1);
        expect(account.bankName, 'ABC Bank');
        expect(account.cardLastDigits, '1234');
        expect(account.notes, 'Monthly expenses');
        expect(account.creditLimit, 5000.0);
      });

      test('supports different account types', () {
        const types = ['Bank', 'Cash', 'Card', 'E-Wallet'];
        for (final type in types) {
          final account = Account(
            name: 'Test',
            currency: 'USD',
            balance: 0,
            type: type,
          );
          expect(account.type, type);
        }
      });
    });

    group('CopyWith', () {
      test('returns new instance with updated name', () {
        const original = Account(
          name: 'Original',
          currency: 'USD',
          balance: 100.0,
          type: 'Bank',
        );
        final copied = original.copyWith(name: 'Updated');

        expect(copied.name, 'Updated');
        expect(original.name, 'Original');
        expect(copied.balance, original.balance);
      });

      test('returns new instance with updated balance', () {
        const original = Account(
          name: 'Test',
          currency: 'USD',
          balance: 100.0,
          type: 'Bank',
        );
        final copied = original.copyWith(balance: 200.0);

        expect(copied.balance, 200.0);
        expect(original.balance, 100.0);
      });

      test('preserves all values when no args passed', () {
        const original = Account(
          id: 1,
          name: 'Test',
          currency: 'USD',
          balance: 100.0,
          type: 'Bank',
          bankName: 'My Bank',
          notes: 'Notes',
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
      });
    });

    group('Equality', () {
      test('accounts with same values are equal', () {
        const account1 = Account(
          name: 'Test',
          currency: 'USD',
          balance: 100.0,
          type: 'Bank',
        );
        const account2 = Account(
          name: 'Test',
          currency: 'USD',
          balance: 100.0,
          type: 'Bank',
        );

        expect(account1, equals(account2));
      });

      test('accounts with different values are not equal', () {
        const account1 = Account(
          name: 'Test',
          currency: 'USD',
          balance: 100.0,
          type: 'Bank',
        );
        const account2 = Account(
          name: 'Test',
          currency: 'USD',
          balance: 200.0, // Different balance
          type: 'Bank',
        );

        expect(account1, isNot(equals(account2)));
      });

      test('accounts with different ids are not equal', () {
        const account1 = Account(
          id: 1,
          name: 'Test',
          currency: 'USD',
          balance: 100.0,
          type: 'Bank',
        );
        const account2 = Account(
          id: 2,
          name: 'Test',
          currency: 'USD',
          balance: 100.0,
          type: 'Bank',
        );

        expect(account1, isNot(equals(account2)));
      });
    });

    group('Props', () {
      test('props includes all fields', () {
        const account = Account(
          id: 1,
          name: 'Test',
          currency: 'USD',
          balance: 100.0,
          type: 'Bank',
          bankName: 'My Bank',
          cardLastDigits: '1234',
          notes: 'Notes',
          creditLimit: 5000.0,
        );

        expect(account.props, [
          1,
          'Test',
          'USD',
          100.0,
          'Bank',
          'My Bank',
          '1234',
          'Notes',
          5000.0,
        ]);
      });
    });
  });
}
