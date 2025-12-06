import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/finance/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(Id id);
  Future<Id> addCategory(CategoryModel category);
  Future<bool> updateCategory(CategoryModel category);
  Future<bool> deleteCategory(Id id);
  Future<void> initializeDefaultCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseService _databaseService;

  CategoryLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final isar = await _databaseService.database;
      return await isar.categoryModels.where().findAll();
    } catch (e) {
      throw CacheException('Failed to get categories: $e');
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(Id id) async {
    try {
      final isar = await _databaseService.database;
      return await isar.categoryModels.get(id);
    } catch (e) {
      throw CacheException('Failed to get category: $e');
    }
  }

  @override
  Future<Id> addCategory(CategoryModel category) async {
    try {
      final isar = await _databaseService.database;
      return await isar.writeTxn(() async {
        return await isar.categoryModels.put(category);
      });
    } catch (e) {
      throw CacheException('Failed to add category: $e');
    }
  }

  @override
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.categoryModels.put(category);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to update category: $e');
    }
  }

  @override
  Future<bool> deleteCategory(Id id) async {
    try {
      final isar = await _databaseService.database;
      await isar.writeTxn(() async {
        await isar.categoryModels.delete(id);
      });
      return true;
    } catch (e) {
      throw CacheException('Failed to delete category: $e');
    }
  }

  @override
  Future<void> initializeDefaultCategories() async {
    try {
      final isar = await _databaseService.database;
      final existingCategories = await isar.categoryModels.where().findAll();

      // Only initialize if no categories exist
      if (existingCategories.isNotEmpty) {
        return;
      }

      final defaultCategories = [
        CategoryModel()
          ..name = 'Food & Dining'
          ..icon = 'restaurant'
          ..color = '#FF6B6B'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Shopping'
          ..icon = 'shopping_cart'
          ..color = '#4ECDC4'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Transportation'
          ..icon = 'directions_car'
          ..color = '#45B7D1'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Bills & Utilities'
          ..icon = 'receipt'
          ..color = '#FFA07A'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Entertainment'
          ..icon = 'movie'
          ..color = '#98D8C8'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Healthcare'
          ..icon = 'local_hospital'
          ..color = '#F7DC6F'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Education'
          ..icon = 'school'
          ..color = '#BB8FCE'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Travel'
          ..icon = 'flight'
          ..color = '#85C1E2'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Personal Care'
          ..icon = 'face'
          ..color = '#F8B739'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Gifts & Donations'
          ..icon = 'card_giftcard'
          ..color = '#EC7063'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Home & Garden'
          ..icon = 'home'
          ..color = '#52BE80'
          ..isDefault = true,
        CategoryModel()
          ..name = 'Other'
          ..icon = 'category'
          ..color = '#95A5A6'
          ..isDefault = true,
      ];

      await isar.writeTxn(() async {
        for (final category in defaultCategories) {
          await isar.categoryModels.put(category);
        }
      });
    } catch (e) {
      throw CacheException('Failed to initialize default categories: $e');
    }
  }
}
