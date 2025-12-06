import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/features/health/data/models/user_profile_model.dart';

abstract class UserProfileLocalDataSource {
  Future<UserProfileModel?> getUserProfile();
  Future<void> saveUserProfile(UserProfileModel userProfile);
}

class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  final DatabaseService _databaseService;

  UserProfileLocalDataSourceImpl(this._databaseService);

  @override
  Future<UserProfileModel?> getUserProfile() async {
    final isar = await _databaseService.database;
    return await isar.userProfileModels.get(1);
  }

  @override
  Future<void> saveUserProfile(UserProfileModel userProfile) async {
    final isar = await _databaseService.database;
    await isar.writeTxn(() async {
      await isar.userProfileModels.put(userProfile);
    });
  }
}
