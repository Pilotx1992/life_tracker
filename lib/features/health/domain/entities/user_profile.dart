import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String? name;
  final double? height;
  final int? age;
  final String? gender;
  final String? photo;

  const UserProfile({
    this.name,
    this.height,
    this.age,
    this.gender,
    this.photo,
  });

  @override
  List<Object?> get props => [name, height, age, gender, photo];
}
