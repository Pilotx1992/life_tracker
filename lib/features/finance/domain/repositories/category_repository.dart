import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getAllCategories();
  Future<Either<Failure, Category?>> getCategoryById(Id id);
  Future<Either<Failure, Id>> addCategory(Category category);
  Future<Either<Failure, bool>> updateCategory(Category category);
  Future<Either<Failure, bool>> deleteCategory(Id id);
  Future<Either<Failure, void>> initializeDefaultCategories();
}
