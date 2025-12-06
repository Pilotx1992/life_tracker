import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/domain/entities/user_profile.dart';
import 'package:life_tracker/features/health/domain/repositories/user_profile_repository.dart';

class UpdateUserProfile implements UseCase<void, Params> {
  final UserProfileRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    return await repository.saveUserProfile(params.userProfile);
  }
}

class Params extends Equatable {
  final UserProfile userProfile;

  const Params({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}
