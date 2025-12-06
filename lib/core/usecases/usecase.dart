import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';

/// Base class for all use cases in the application.
///
/// Use cases encapsulate business logic and follow the Clean Architecture pattern.
/// They return [Either<Failure, T>] to handle both success and error cases.
///
/// Type parameters:
/// - [T]: The return type on success
/// - [Params]: The parameters required for the use case (use [NoParams] if none)
///
/// Example:
/// ```dart
/// class GetWeights extends UseCase<List<WeightEntry>, NoParams> {
///   final WeightRepository repository;
///
///   GetWeights(this.repository);
///
///   @override
///   Future<Either<Failure, List<WeightEntry>>> call(NoParams params) async {
///     return await repository.getWeights();
///   }
/// }
/// ```
abstract class UseCase<T, Params> {
  /// Executes the use case with the given parameters.
  ///
  /// Returns [Right] with the result on success, or [Left] with a [Failure] on error.
  Future<Either<Failure, T>> call(Params params);
}

/// Parameter class for use cases that don't require any parameters.
///
/// Use this when a use case doesn't need any input.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
