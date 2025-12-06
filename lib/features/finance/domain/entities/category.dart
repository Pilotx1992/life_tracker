import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

class Category extends Equatable {
  final Id? id;
  final String name;
  final String icon; // Icon name/code
  final String color; // Hex color code
  final bool isDefault;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, name, icon, color, isDefault];

  Category copyWith({
    Id? id,
    String? name,
    String? icon,
    String? color,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
