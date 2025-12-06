import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';

part 'database_provider.g.dart';

@riverpod
Future<Isar> database(DatabaseRef ref) async {
  // Initialize and return the shared Isar instance from DatabaseService
  return await DatabaseService.instance.database;
}
