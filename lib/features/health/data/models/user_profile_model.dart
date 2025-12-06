import 'package:isar/isar.dart';
import 'package:life_tracker/features/health/domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@collection
class UserProfileModel {
  Id id = 1;

  String? name;
  double? height;
  int? age;
  String? gender;
  String? photo;

  UserProfile toEntity() {
    return UserProfile(
      name: name,
      height: height,
      age: age,
      gender: gender,
      photo: photo,
    );
  }

  static UserProfileModel fromEntity(UserProfile entity) {
    return UserProfileModel()
      ..name = entity.name
      ..height = entity.height
      ..age = entity.age
      ..gender = entity.gender
      ..photo = entity.photo;
  }
}
