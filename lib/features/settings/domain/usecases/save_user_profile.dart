import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:life_tracker/features/settings/domain/repositories/user_profile_repository.dart';

class SaveUserProfile implements UseCase<UserProfile, SaveUserProfileParams> {
  final UserProfileRepository repository;

  SaveUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(
    SaveUserProfileParams params,
  ) async {
    return await repository.saveProfile(params.profile);
  }
}

class SaveUserProfileParams extends Equatable {
  final UserProfile profile;

  const SaveUserProfileParams({required this.profile});

  @override
  List<Object?> get props => [profile];
}
