import 'package:equatable/equatable.dart';

/// User Profile entity
/// Represents the user's personal information used for personalized calculations
class UserProfile extends Equatable {
  final int id;
  final String? name;
  final DateTime? dateOfBirth;
  final String? gender; // 'Male', 'Female', 'Other', or null
  final double? heightInCm;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.name,
    this.dateOfBirth,
    this.gender,
    this.heightInCm,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Check if profile has minimum info for BMI calculation
  bool get canCalculateBmi => heightInCm != null && heightInCm! > 0;

  /// Check if profile has minimum info for ideal weight calculation
  bool get canCalculateIdealWeight =>
      heightInCm != null && heightInCm! > 0 && gender != null && age != null;

  @override
  List<Object?> get props => [
        id,
        name,
        dateOfBirth,
        gender,
        heightInCm,
        photoPath,
        createdAt,
        updatedAt,
      ];

  UserProfile copyWith({
    int? id,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    double? heightInCm,
    String? photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightInCm: heightInCm ?? this.heightInCm,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
