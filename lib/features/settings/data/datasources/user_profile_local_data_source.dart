import 'package:isar/isar.dart';
import 'package:life_tracker/features/settings/data/models/user_profile_model.dart';

/// Local data source for User Profile using Isar
abstract class UserProfileLocalDataSource {
  /// Get the user profile
  Future<UserProfileModel?> getProfile();

  /// Save (create or update) the user profile
  Future<UserProfileModel> saveProfile(UserProfileModel profile);

  /// Delete the user profile
  Future<void> deleteProfile();
}

class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  final Isar isar;

  UserProfileLocalDataSourceImpl({required this.isar});

  @override
  Future<UserProfileModel?> getProfile() async {
    // There should only be one profile, so get the first one
    return await isar.userProfileModels.where().findFirst();
  }

  @override
  Future<UserProfileModel> saveProfile(UserProfileModel profile) async {
    await isar.writeTxn(() async {
      // Update the updatedAt timestamp
      profile.updatedAt = DateTime.now();

      // If id is 0 (new profile), set createdAt
      if (profile.id == 0 || profile.id == Isar.autoIncrement) {
        profile.createdAt = DateTime.now();
      }

      await isar.userProfileModels.put(profile);
    });

    // Return the saved profile
    return (await getProfile())!;
  }

  @override
  Future<void> deleteProfile() async {
    await isar.writeTxn(() async {
      await isar.userProfileModels.clear();
    });
  }
}
