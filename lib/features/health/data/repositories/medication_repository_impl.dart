import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/exceptions.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/health/data/datasources/medication_local_data_source.dart';
import 'package:life_tracker/features/health/data/models/medication_intake_model.dart';
import 'package:life_tracker/features/health/data/models/medication_model.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/domain/entities/medication_intake.dart';
import 'package:life_tracker/features/health/domain/repositories/medication_repository.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDataSource localDataSource;

  MedicationRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Medication>>> getAllMedications() async {
    try {
      final medicationModels = await localDataSource.getAllMedications();
      return Right(medicationModels.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Medication>> getMedicationById(Id id) async {
    try {
      final medicationModel = await localDataSource.getMedicationById(id);
      if (medicationModel != null) {
        return Right(medicationModel.toEntity());
      } else {
        return const Left(CacheFailure('Medication not found'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Medication>>> getActiveMedications() async {
    try {
      final medicationModels = await localDataSource.getActiveMedications();
      return Right(medicationModels.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Id>> addMedication(Medication medication) async {
    try {
      final id = await localDataSource.addMedication(MedicationModel.fromEntity(medication));
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateMedication(Medication medication) async {
    try {
      final success = await localDataSource.updateMedication(MedicationModel.fromEntity(medication));
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMedication(Id id) async {
    try {
      final success = await localDataSource.deleteMedication(id);
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Id>> addMedicationIntake(MedicationIntake intake) async {
    try {
      final id = await localDataSource.addMedicationIntake(MedicationIntakeModel.fromEntity(intake));
      return Right(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateMedicationIntake(MedicationIntake intake) async {
    try {
      final success = await localDataSource.updateMedicationIntake(MedicationIntakeModel.fromEntity(intake));
      return Right(success);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MedicationIntake>>> getMedicationIntakesForMedication(Id medicationId) async {
    try {
      final intakeModels = await localDataSource.getMedicationIntakesForMedication(medicationId);
      return Right(intakeModels.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MedicationIntake>>> getMedicationIntakesByDate(DateTime date) async {
    try {
      final intakeModels = await localDataSource.getMedicationIntakesByDate(date);
      return Right(intakeModels.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, double>> calculateAdherence(Id medicationId) async {
    try {
      final intakes = await localDataSource.getMedicationIntakesForMedication(medicationId);
      if (intakes.isEmpty) {
        return const Right(1.0); // 100% adherence if no intakes yet
      }

      final totalDoses = intakes.length;
      final takenDoses = intakes.where((intake) => intake.isTaken).length;

      if (totalDoses == 0) {
        return const Right(1.0); // Avoid division by zero
      }

      return Right(takenDoses / totalDoses);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
