import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/settings/data/datasources/user_profile_local_data_source.dart';
import 'package:life_tracker/features/settings/data/models/user_profile_model.dart';
import 'package:life_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:life_tracker/features/settings/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource localDataSource;

  UserProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserProfile?>> getProfile() async {
    try {
      final profileModel = await localDataSource.getProfile();
      if (profileModel == null) {
        return const Right(null);
      }
      return Right(profileModel.toEntity());
    } catch (e) {
  return Left(DatabaseFailure('Failed to get profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> saveProfile(UserProfile profile) async {
    try {
      final profileModel = UserProfileModel.fromEntity(profile);
      final savedModel = await localDataSource.saveProfile(profileModel);
      return Right(savedModel.toEntity());
    } catch (e) {
  return Left(DatabaseFailure('Failed to save profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProfile() async {
    try {
      await localDataSource.deleteProfile();
      return const Right(unit);
    } catch (e) {
  return Left(DatabaseFailure('Failed to delete profile: ${e.toString()}'));
    }
  }
}
