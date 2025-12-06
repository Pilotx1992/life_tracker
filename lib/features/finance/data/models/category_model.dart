import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/category.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String icon; // Icon name/code (e.g., 'food', 'shopping', 'transport')
  late String color; // Hex color code
  bool isDefault = false; // Whether this is a default category

  CategoryModel();

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      color: color,
      isDefault: isDefault,
    );
  }

  factory CategoryModel.fromEntity(Category entity) {
    final model = CategoryModel()
      ..name = entity.name
      ..icon = entity.icon
      ..color = entity.color
      ..isDefault = entity.isDefault;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  CategoryModel copyWith({
    Id? id,
    String? name,
    String? icon,
    String? color,
    bool? isDefault,
  }) {
    final model = CategoryModel()
      ..name = name ?? this.name
      ..icon = icon ?? this.icon
      ..color = color ?? this.color
      ..isDefault = isDefault ?? this.isDefault;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
