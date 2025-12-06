import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';

class CalculateNextOccurrenceParams {
  final DateTime currentDateTime;
  final String recurringPattern;
  final int? recurringInterval;
  final DateTime? recurringEndDate;

  CalculateNextOccurrenceParams({
    required this.currentDateTime,
    required this.recurringPattern,
    this.recurringInterval,
    this.recurringEndDate,
  });
}

class CalculateNextOccurrence
    implements UseCase<DateTime, CalculateNextOccurrenceParams> {
  @override
  Future<Either<Failure, DateTime>> call(
    CalculateNextOccurrenceParams params,
  ) async {
    try {
      DateTime nextOccurrence;

      switch (params.recurringPattern) {
        case 'Daily':
          nextOccurrence = params.currentDateTime.add(const Duration(days: 1));
          break;
        case 'Weekly':
          nextOccurrence = params.currentDateTime.add(const Duration(days: 7));
          break;
        case 'Monthly':
          // Add approximately one month
          nextOccurrence = DateTime(
            params.currentDateTime.year,
            params.currentDateTime.month + 1,
            params.currentDateTime.day,
            params.currentDateTime.hour,
            params.currentDateTime.minute,
          );
          break;
        case 'Yearly':
          nextOccurrence = DateTime(
            params.currentDateTime.year + 1,
            params.currentDateTime.month,
            params.currentDateTime.day,
            params.currentDateTime.hour,
            params.currentDateTime.minute,
          );
          break;
        case 'Custom':
          final interval = params.recurringInterval ?? 1;
          nextOccurrence = params.currentDateTime.add(Duration(days: interval));
          break;
        default:
          return Left(
            ValidationFailure(
              'Invalid recurring pattern: ${params.recurringPattern}',
            ),
          );
      }

      // Check if next occurrence exceeds end date
      if (params.recurringEndDate != null &&
          nextOccurrence.isAfter(params.recurringEndDate!)) {
        return const Left(
            ValidationFailure('Next occurrence exceeds end date'));
      }

      return Right(nextOccurrence);
    } catch (e) {
      return Left(
        CalculationFailure('Failed to calculate next occurrence: $e'),
      );
    }
  }
}
