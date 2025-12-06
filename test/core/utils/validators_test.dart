import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateWeight', () {
      test('should return null for valid weight', () {
        expect(Validators.validateWeight('70.5'), isNull);
        expect(Validators.validateWeight('100'), isNull);
        expect(Validators.validateWeight('50.25'), isNull);
      });

      test('should return error for empty weight', () {
        expect(Validators.validateWeight(null), isNotNull);
        expect(Validators.validateWeight(''), isNotNull);
      });

      test('should return error for invalid weight', () {
        expect(Validators.validateWeight('abc'), isNotNull);
        expect(Validators.validateWeight('0'), isNotNull);
        expect(Validators.validateWeight('-10'), isNotNull);
      });
    });

    group('validateAmount', () {
      test('should return null for valid amount', () {
        expect(Validators.validateAmount('100.50'), isNull);
        expect(Validators.validateAmount('0'), isNull);
        expect(Validators.validateAmount('999.99'), isNull);
      });

      test('should return error for empty amount', () {
        expect(Validators.validateAmount(null), isNotNull);
        expect(Validators.validateAmount(''), isNotNull);
      });

      test('should return error for invalid amount', () {
        expect(Validators.validateAmount('abc'), isNotNull);
        expect(Validators.validateAmount('-10'), isNotNull);
      });
    });

    group('validatePIN', () {
      test('should return null for valid PIN', () {
        expect(Validators.validatePIN('1234'), isNull);
        expect(Validators.validatePIN('0000'), isNull);
        expect(Validators.validatePIN('9999'), isNull);
      });

      test('should return error for empty PIN', () {
        expect(Validators.validatePIN(null), isNotNull);
        expect(Validators.validatePIN(''), isNotNull);
      });

      test('should return error for invalid PIN', () {
        expect(Validators.validatePIN('123'), isNotNull); // Too short
        expect(Validators.validatePIN('12345'), isNotNull); // Too long
        expect(Validators.validatePIN('abcd'), isNotNull); // Not numeric
        expect(Validators.validatePIN('12ab'), isNotNull); // Mixed
      });
    });

    group('validateHeight', () {
      test('should return null for valid height', () {
        expect(Validators.validateHeight('170.5'), isNull);
        expect(Validators.validateHeight('180'), isNull);
        expect(Validators.validateHeight('150.25'), isNull);
      });

      test('should return error for empty height', () {
        expect(Validators.validateHeight(null), isNotNull);
        expect(Validators.validateHeight(''), isNotNull);
      });

      test('should return error for invalid height', () {
        expect(Validators.validateHeight('abc'), isNotNull);
        expect(Validators.validateHeight('0'), isNotNull);
        expect(Validators.validateHeight('-10'), isNotNull);
      });
    });

    group('validateGenericField', () {
      test('should return null for non-empty field', () {
        expect(Validators.validateGenericField('value', 'Field'), isNull);
        expect(Validators.validateGenericField('test', 'Name'), isNull);
      });

      test('should return error for empty field', () {
        expect(Validators.validateGenericField(null, 'Field'), isNotNull);
        expect(Validators.validateGenericField('', 'Name'), isNotNull);
      });

      test('should include field name in error message', () {
        final error = Validators.validateGenericField('', 'Email');
        expect(error, contains('Email'));
      });
    });
  });
}
