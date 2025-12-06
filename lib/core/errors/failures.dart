import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final List<Object?> properties;

  const Failure(this.message, [this.properties = const []]);

  @override
  List<Object> get props => [message, properties];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Failure']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation Failure']);
}

class CalculationFailure extends Failure {
  const CalculationFailure([super.message = 'Calculation Failure']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database Failure']);
}