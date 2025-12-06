import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/app_startup.dart';
import 'package:life_tracker/core/usecases/usecase.dart';
import 'package:life_tracker/features/settings/data/datasources/user_profile_local_data_source.dart';
import 'package:life_tracker/features/settings/data/repositories/user_profile_repository_impl.dart';
import 'package:life_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:life_tracker/features/settings/domain/usecases/get_user_profile.dart';
import 'package:life_tracker/features/settings/domain/usecases/save_user_profile.dart';

// Data Source Provider
final userProfileLocalDataSourceProvider = FutureProvider((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return UserProfileLocalDataSourceImpl(isar: isar);
});

// Repository Provider
final userProfileRepositoryProvider = FutureProvider((ref) async {
  final dataSource = await ref.watch(userProfileLocalDataSourceProvider.future);
  return UserProfileRepositoryImpl(localDataSource: dataSource);
});

// Use Cases Providers
final getUserProfileUseCaseProvider = FutureProvider((ref) async {
  final repository = await ref.watch(userProfileRepositoryProvider.future);
  return GetUserProfile(repository);
});

final saveUserProfileUseCaseProvider = FutureProvider((ref) async {
  final repository = await ref.watch(userProfileRepositoryProvider.future);
  return SaveUserProfile(repository);
});

// State Provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final getUserProfileAsync = ref.watch(getUserProfileUseCaseProvider);
  final saveUserProfileAsync = ref.watch(saveUserProfileUseCaseProvider);

  return getUserProfileAsync.when(
    data: (getUserProfile) => saveUserProfileAsync.when(
      data: (saveUserProfile) => UserProfileNotifier(
        getUserProfile: getUserProfile,
        saveUserProfile: saveUserProfile,
      ),
      loading: () => UserProfileNotifier.loading(),
      error: (e, s) => UserProfileNotifier.loading(),
    ),
    loading: () => UserProfileNotifier.loading(),
    error: (e, s) => UserProfileNotifier.loading(),
  );
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final GetUserProfile? getUserProfile;
  final SaveUserProfile? saveUserProfile;

  UserProfileNotifier({
    required this.getUserProfile,
    required this.saveUserProfile,
  }) : super(const AsyncValue.loading()) {
    if (getUserProfile != null) {
      loadProfile();
    }
  }

  UserProfileNotifier.loading()
      : getUserProfile = null,
        saveUserProfile = null,
        super(const AsyncValue.loading());

  Future<void> loadProfile() async {
    if (getUserProfile == null) return;

    state = const AsyncValue.loading();

  final result = await getUserProfile!(NoParams());

    result.fold(
      (failure) => state = AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  Future<bool> saveProfile(UserProfile profile) async {
    if (saveUserProfile == null) return false;

    final result = await saveUserProfile!(SaveUserProfileParams(profile: profile));

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (savedProfile) {
        state = AsyncValue.data(savedProfile);
        return true;
      },
    );
  }
}
