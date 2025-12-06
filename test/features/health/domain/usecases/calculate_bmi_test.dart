import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_bmi.dart';

void main() {
  group('CalculateBmi', () {
    late CalculateBmi calculateBmi;

    setUp(() {
      calculateBmi = CalculateBmi();
    });

    test('should calculate BMI correctly for normal weight', () async {
      // Weight: 70 kg, Height: 175 cm
      // BMI = 70 / (1.75)^2 = 70 / 3.0625 = 22.86
      const params = BmiParams(weight: 70.0, height: 175.0);
      final result = await calculateBmi(params);

      expect(result, isA<Right<Failure, double>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (bmi) {
          expect(bmi, closeTo(22.86, 0.1));
        },
      );
    });

    test('should calculate BMI correctly for underweight', () async {
      // Weight: 50 kg, Height: 180 cm
      // BMI = 50 / (1.80)^2 = 50 / 3.24 = 15.43
      const params = BmiParams(weight: 50.0, height: 180.0);
      final result = await calculateBmi(params);

      expect(result, isA<Right<Failure, double>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (bmi) {
          expect(bmi, closeTo(15.43, 0.1));
        },
      );
    });

    test('should calculate BMI correctly for overweight', () async {
      // Weight: 90 kg, Height: 170 cm
      // BMI = 90 / (1.70)^2 = 90 / 2.89 = 31.14
      const params = BmiParams(weight: 90.0, height: 170.0);
      final result = await calculateBmi(params);

      expect(result, isA<Right<Failure, double>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (bmi) {
          expect(bmi, closeTo(31.14, 0.1));
        },
      );
    });

    test('should return failure for zero weight', () async {
      const params = BmiParams(weight: 0.0, height: 175.0);
      final result = await calculateBmi(params);

      expect(result, isA<Left<Failure, double>>());
      result.fold(
        (failure) {
          expect(failure, isA<CalculationFailure>());
          expect(failure.message, contains('positive'));
        },
        (bmi) => fail('Should return failure'),
      );
    });

    test('should return failure for negative weight', () async {
      const params = BmiParams(weight: -10.0, height: 175.0);
      final result = await calculateBmi(params);

      expect(result, isA<Left<Failure, double>>());
      result.fold(
        (failure) {
          expect(failure, isA<CalculationFailure>());
        },
        (bmi) => fail('Should return failure'),
      );
    });

    test('should return failure for zero height', () async {
      const params = BmiParams(weight: 70.0, height: 0.0);
      final result = await calculateBmi(params);

      expect(result, isA<Left<Failure, double>>());
      result.fold(
        (failure) {
          expect(failure, isA<CalculationFailure>());
        },
        (bmi) => fail('Should return failure'),
      );
    });

    test('should return failure for negative height', () async {
      const params = BmiParams(weight: 70.0, height: -10.0);
      final result = await calculateBmi(params);

      expect(result, isA<Left<Failure, double>>());
      result.fold(
        (failure) {
          expect(failure, isA<CalculationFailure>());
        },
        (bmi) => fail('Should return failure'),
      );
    });
  });
}
