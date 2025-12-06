import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/health/data/datasources/user_profile_local_data_source.dart';
import 'package:life_tracker/features/health/data/repositories/user_profile_repository_impl.dart';
import 'package:life_tracker/features/health/domain/entities/user_profile.dart';
import 'package:life_tracker/features/health/domain/repositories/user_profile_repository.dart';
import 'package:life_tracker/features/health/domain/usecases/get_user_profile.dart';
import 'package:life_tracker/features/health/domain/usecases/update_user_profile.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final localDataSource =
      UserProfileLocalDataSourceImpl(ref.watch(databaseServiceProvider));
  return UserProfileRepositoryImpl(localDataSource: localDataSource);
});

final getUserProfileProvider = Provider<GetUserProfile>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return GetUserProfile(repository);
});

final updateUserProfileProvider = Provider<UpdateUserProfile>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UpdateUserProfile(repository);
});

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final getUserProfile = ref.watch(getUserProfileProvider);
  final result = await getUserProfile(NoParams());
  return result.fold(
    (failure) => throw failure,
    (userProfile) => userProfile,
  );
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});
