import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/errors/failures.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/domain/entities/medication_intake.dart';

abstract class MedicationRepository {
  Future<Either<Failure, List<Medication>>> getAllMedications();
  Future<Either<Failure, Medication>> getMedicationById(Id id);
  Future<Either<Failure, List<Medication>>> getActiveMedications();
  Future<Either<Failure, Id>> addMedication(Medication medication);
  Future<Either<Failure, bool>> updateMedication(Medication medication);
  Future<Either<Failure, bool>> deleteMedication(Id id);

  Future<Either<Failure, Id>> addMedicationIntake(MedicationIntake intake);
  Future<Either<Failure, bool>> updateMedicationIntake(MedicationIntake intake);
  Future<Either<Failure, List<MedicationIntake>>>
      getMedicationIntakesForMedication(Id medicationId);
  Future<Either<Failure, List<MedicationIntake>>> getMedicationIntakesByDate(
    DateTime date,
  );
  Future<Either<Failure, double>> calculateAdherence(Id medicationId);
}
