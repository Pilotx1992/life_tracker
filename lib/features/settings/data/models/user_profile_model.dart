import 'package:isar/isar.dart';
import 'package:life_tracker/features/settings/domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@collection
class UserProfileModel {
  Id id = Isar.autoIncrement;

  String? name;

  DateTime? dateOfBirth;

  String? gender;

  double? heightInCm;

  String? photoPath;

  @Index()
  DateTime? createdAt;

  DateTime? updatedAt;

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      heightInCm: heightInCm,
      photoPath: photoPath,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static UserProfileModel fromEntity(UserProfile profile) {
    final model = UserProfileModel();
    model.id = profile.id;
    model.name = profile.name;
    model.dateOfBirth = profile.dateOfBirth;
    model.gender = profile.gender;
    model.heightInCm = profile.heightInCm;
    model.photoPath = profile.photoPath;
    model.createdAt = profile.createdAt;
    model.updatedAt = profile.updatedAt;
    return model;
  }
}
