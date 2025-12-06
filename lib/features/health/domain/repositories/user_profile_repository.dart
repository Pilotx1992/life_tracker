import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/health/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();
  Future<Either<Failure, void>> saveUserProfile(UserProfile userProfile);
}
