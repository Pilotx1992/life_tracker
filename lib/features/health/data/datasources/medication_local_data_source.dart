import 'package:isar/isar.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/features/health/data/models/medication_intake_model.dart';
import 'package:life_tracker/features/health/data/models/medication_model.dart';

abstract class MedicationLocalDataSource {
  Future<List<MedicationModel>> getAllMedications();
  Future<MedicationModel?> getMedicationById(Id id);
  Future<List<MedicationModel>> getActiveMedications();
  Future<Id> addMedication(MedicationModel medication);
  Future<bool> updateMedication(MedicationModel medication);
  Future<bool> deleteMedication(Id id);

  Future<Id> addMedicationIntake(MedicationIntakeModel intake);
  Future<bool> updateMedicationIntake(MedicationIntakeModel intake);
  Future<List<MedicationIntakeModel>> getMedicationIntakesForMedication(
    Id medicationId,
  );
  Future<List<MedicationIntakeModel>> getMedicationIntakesByDate(DateTime date);
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  final DatabaseService databaseService;

  MedicationLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<MedicationModel>> getAllMedications() async {
    try {
      final isar = await databaseService.database;
      return await isar.medicationModels.where().findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<MedicationModel?> getMedicationById(Id id) async {
    try {
      final isar = await databaseService.database;
      return await isar.medicationModels.get(id);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<MedicationModel>> getActiveMedications() async {
    try {
      final isar = await databaseService.database;
      final now = DateTime.now();
      return await isar.medicationModels
          .filter()
          .startDateLessThan(now)
          .and()
          .endDateGreaterThan(now)
          .or()
          .endDateIsNull()
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<Id> addMedication(MedicationModel medication) async {
    try {
      final isar = await databaseService.database;
      return await isar.writeTxn(() => isar.medicationModels.put(medication));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<bool> updateMedication(MedicationModel medication) async {
    try {
      final isar = await databaseService.database;
      return await isar.writeTxn(() async {
        final existingMedication =
            await isar.medicationModels.get(medication.id);
        if (existingMedication == null) {
          return false;
        }
        await isar.medicationModels.put(medication);
        return true;
      });
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<bool> deleteMedication(Id id) async {
    try {
      final isar = await databaseService.database;
      return await isar.writeTxn(() => isar.medicationModels.delete(id));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<Id> addMedicationIntake(MedicationIntakeModel intake) async {
    try {
      final isar = await databaseService.database;
      return await isar.writeTxn(() => isar.medicationIntakeModels.put(intake));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<bool> updateMedicationIntake(MedicationIntakeModel intake) async {
    try {
      final isar = await databaseService.database;
      return await isar.writeTxn(() async {
        final existingIntake = await isar.medicationIntakeModels.get(intake.id);
        if (existingIntake == null) {
          return false;
        }
        await isar.medicationIntakeModels.put(intake);
        return true;
      });
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<MedicationIntakeModel>> getMedicationIntakesForMedication(
    Id medicationId,
  ) async {
    try {
      final isar = await databaseService.database;
      return await isar.medicationIntakeModels
          .filter()
          .medicationIdEqualTo(medicationId)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<MedicationIntakeModel>> getMedicationIntakesByDate(
    DateTime date,
  ) async {
    try {
      final isar = await databaseService.database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      return await isar.medicationIntakeModels
          .filter()
          .scheduledTimeBetween(startOfDay, endOfDay)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
