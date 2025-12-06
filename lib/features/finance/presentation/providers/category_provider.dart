import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/features/finance/domain/entities/category.dart';
import 'package:life_tracker/features/finance/finance_providers.dart';

// Initialize default categories on first access
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);

  // Initialize default categories if needed
  await repository.initializeDefaultCategories();

  // Get all categories
  final result = await repository.getAllCategories();
  return result.fold(
    (failure) => throw failure,
    (categories) => categories,
  );
});

// Provider for getting a category by ID
final categoryByIdProvider =
    FutureProvider.family<Category?, Id>((ref, id) async {
  final repository = ref.read(categoryRepositoryProvider);
  final result = await repository.getCategoryById(id);
  return result.fold(
    (failure) => null,
    (category) => category,
  );
});
