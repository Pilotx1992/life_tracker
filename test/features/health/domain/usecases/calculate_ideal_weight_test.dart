import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_ideal_weight.dart';

void main() {
  group('CalculateIdealWeight', () {
    late CalculateIdealWeight calculateIdealWeight;

    setUp(() {
      calculateIdealWeight = CalculateIdealWeight();
    });

    test('should calculate ideal weight for male', () async {
      // Height: 180 cm = 70.87 inches
      // Over 5 feet: 70.87 - 60 = 10.87 inches
      // Ideal weight: 50 + (2.3 * 10.87) = 75.0 kg
      const params = IdealWeightParams(height: 180.0, isMale: true);
      final result = await calculateIdealWeight(params);

      expect(result, isA<Right<Failure, Map<String, double>>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (range) {
          expect(range['min'], isNotNull);
          expect(range['max'], isNotNull);
          expect(range['min']!, lessThan(range['max']!));
          // Should be around 75 kg with 10% range
          expect(range['min']!, closeTo(67.5, 5.0));
          expect(range['max']!, closeTo(82.5, 5.0));
        },
      );
    });

    test('should calculate ideal weight for female', () async {
      // Height: 165 cm = 64.96 inches
      // Over 5 feet: 64.96 - 60 = 4.96 inches
      // Ideal weight: 45.5 + (2.3 * 4.96) = 56.9 kg
      const params = IdealWeightParams(height: 165.0, isMale: false);
      final result = await calculateIdealWeight(params);

      expect(result, isA<Right<Failure, Map<String, double>>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (range) {
          expect(range['min'], isNotNull);
          expect(range['max'], isNotNull);
          expect(range['min']!, lessThan(range['max']!));
          // Should be around 57 kg with 10% range
          expect(range['min']!, closeTo(51.0, 5.0));
          expect(range['max']!, closeTo(63.0, 5.0));
        },
      );
    });

    test('should return range for height <= 5 feet', () async {
      // Height: 150 cm = 59 inches (less than 5 feet)
      const params = IdealWeightParams(height: 150.0, isMale: true);
      final result = await calculateIdealWeight(params);

      expect(result, isA<Right<Failure, Map<String, double>>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (range) {
          expect(range['min'], isNotNull);
          expect(range['max'], isNotNull);
          // Should return basic range
          expect(range['min']!, greaterThanOrEqualTo(45.0));
          expect(range['max']!, lessThanOrEqualTo(60.0));
        },
      );
    });

    test('should return failure for zero height', () async {
      const params = IdealWeightParams(height: 0.0, isMale: true);
      final result = await calculateIdealWeight(params);

      expect(result, isA<Left<Failure, Map<String, double>>>());
      result.fold(
        (failure) {
          expect(failure, isA<CalculationFailure>());
          expect(failure.message, contains('positive'));
        },
        (range) => fail('Should return failure'),
      );
    });

    test('should return failure for negative height', () async {
      const params = IdealWeightParams(height: -10.0, isMale: true);
      final result = await calculateIdealWeight(params);

      expect(result, isA<Left<Failure, Map<String, double>>>());
      result.fold(
        (failure) {
          expect(failure, isA<CalculationFailure>());
        },
        (range) => fail('Should return failure'),
      );
    });

    test('should return different ranges for male vs female', () async {
      const height = 175.0;
      const maleParams = IdealWeightParams(height: height, isMale: true);
      const femaleParams = IdealWeightParams(height: height, isMale: false);

      final maleResult = await calculateIdealWeight(maleParams);
      final femaleResult = await calculateIdealWeight(femaleParams);

      maleResult.fold(
        (failure) => fail('Male calculation should succeed'),
        (maleRange) {
          femaleResult.fold(
            (failure) => fail('Female calculation should succeed'),
            (femaleRange) {
              // Male ideal weight should be higher than female
              expect(maleRange['min']!, greaterThan(femaleRange['min']!));
              expect(maleRange['max']!, greaterThan(femaleRange['max']!));
            },
          );
        },
      );
    });
  });
}
