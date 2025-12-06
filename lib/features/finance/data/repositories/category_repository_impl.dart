import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/finance/data/datasources/category_local_data_source.dart';
import 'package:life_tracker/features/finance/data/models/category_model.dart';
import 'package:life_tracker/features/finance/domain/entities/category.dart';
import 'package:life_tracker/features/finance/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final categoryModels = await localDataSource.getAllCategories();
      final categories =
          categoryModels.map((model) => model.toEntity()).toList();
      return Right(categories);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Category?>> getCategoryById(Id id) async {
    try {
      final categoryModel = await localDataSource.getCategoryById(id);
      return Right(categoryModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Id>> addCategory(Category category) async {
    try {
      final categoryModel = CategoryModel.fromEntity(category);
      final id = await localDataSource.addCategory(categoryModel);
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCategory(Category category) async {
    try {
      final categoryModel = CategoryModel.fromEntity(category);
      final success = await localDataSource.updateCategory(categoryModel);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(Id id) async {
    try {
      final success = await localDataSource.deleteCategory(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> initializeDefaultCategories() async {
    try {
      await localDataSource.initializeDefaultCategories();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
