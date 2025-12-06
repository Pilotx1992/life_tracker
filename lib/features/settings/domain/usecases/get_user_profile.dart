import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:life_tracker/features/settings/domain/repositories/user_profile_repository.dart';

class GetUserProfile implements UseCase<UserProfile?, NoParams> {
  final UserProfileRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile?>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
