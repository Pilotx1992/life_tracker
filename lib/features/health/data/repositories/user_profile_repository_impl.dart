import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/health/data/datasources/user_profile_local_data_source.dart';
import 'package:life_tracker/features/health/data/models/user_profile_model.dart';
import 'package:life_tracker/features/health/domain/entities/user_profile.dart';
import 'package:life_tracker/features/health/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource localDataSource;

  UserProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final userProfileModel = await localDataSource.getUserProfile();
      if (userProfileModel == null) {
        return const Right(
          UserProfile(),
        ); // Return an empty profile if not found
      }
      return Right(userProfileModel.toEntity());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveUserProfile(UserProfile userProfile) async {
    try {
      final userProfileModel = UserProfileModel.fromEntity(userProfile);
      await localDataSource.saveUserProfile(userProfileModel);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
