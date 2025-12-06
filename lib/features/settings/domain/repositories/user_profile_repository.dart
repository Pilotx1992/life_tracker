import 'package:dartz/dartz.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/settings/domain/entities/user_profile.dart';

/// Repository interface for User Profile operations
abstract class UserProfileRepository {
  /// Get the user profile (there should only be one)
  Future<Either<Failure, UserProfile?>> getProfile();

  /// Create or update the user profile
  Future<Either<Failure, UserProfile>> saveProfile(UserProfile profile);

  /// Delete the user profile
  Future<Either<Failure, Unit>> deleteProfile();
}
