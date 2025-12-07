import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/domain/entities/medication_intake.dart';
import 'package:life_tracker/features/health/domain/usecases/add_medication.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_adherence.dart';
import 'package:life_tracker/features/health/domain/usecases/delete_medication.dart';
import 'package:life_tracker/features/health/domain/usecases/get_medications.dart';
import 'package:life_tracker/features/health/domain/usecases/mark_medication_taken.dart';
import 'package:life_tracker/features/health/domain/usecases/get_medication_intakes.dart';
import 'package:life_tracker/features/health/domain/usecases/snooze_medication.dart';
import 'package:life_tracker/features/health/domain/usecases/update_medication.dart';
import 'package:life_tracker/features/health/health_providers.dart';
import 'package:life_tracker/features/health/services/medication_notification_service.dart';
import 'package:life_tracker/core/providers/notification_provider.dart';

// Providers for use cases (dependency injection)
final addMedicationUseCaseProvider =
    Provider((ref) => AddMedication(ref.read(medicationRepositoryProvider)));
final getMedicationsUseCaseProvider =
    Provider((ref) => GetMedications(ref.read(medicationRepositoryProvider)));
final updateMedicationUseCaseProvider =
    Provider((ref) => UpdateMedication(ref.read(medicationRepositoryProvider)));
final deleteMedicationUseCaseProvider =
    Provider((ref) => DeleteMedication(ref.read(medicationRepositoryProvider)));
final markMedicationTakenUseCaseProvider = Provider(
    (ref) => MarkMedicationTaken(ref.read(medicationRepositoryProvider)),);
final snoozeMedicationUseCaseProvider =
    Provider((ref) => SnoozeMedication(ref.read(medicationRepositoryProvider)));
final calculateAdherenceUseCaseProvider = Provider(
    (ref) => CalculateAdherence(ref.read(medicationRepositoryProvider)),);
final getMedicationIntakesUseCaseProvider = Provider(
    (ref) => GetMedicationIntakes(ref.read(medicationRepositoryProvider)),);

// Notification service provider
final medicationNotificationServiceProvider =
    Provider<MedicationNotificationService>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  return MedicationNotificationService(notificationService);
});

// StateNotifier for managing medication-related state
class MedicationNotifier extends StateNotifier<AsyncValue<List<Medication>>> {
  final AddMedication _addMedication;
  final GetMedications _getMedications;
  final UpdateMedication _updateMedication;
  final DeleteMedication _deleteMedication;
  final MarkMedicationTaken _markMedicationTaken;
  final SnoozeMedication _snoozeMedication;
  final CalculateAdherence _calculateAdherence;
  final GetMedicationIntakes _getMedicationIntakes;
  final MedicationNotificationService? _notificationService;

  MedicationNotifier({
    required AddMedication addMedication,
    required GetMedications getMedications,
    required UpdateMedication updateMedication,
    required DeleteMedication deleteMedication,
    required MarkMedicationTaken markMedicationTaken,
    required SnoozeMedication snoozeMedication,
    required CalculateAdherence calculateAdherence,
    required GetMedicationIntakes getMedicationIntakes,
    MedicationNotificationService? notificationService,
  })  : _addMedication = addMedication,
        _getMedications = getMedications,
        _updateMedication = updateMedication,
        _deleteMedication = deleteMedication,
        _markMedicationTaken = markMedicationTaken,
        _snoozeMedication = snoozeMedication,
        _calculateAdherence = calculateAdherence,
        _getMedicationIntakes = getMedicationIntakes,
        _notificationService = notificationService,
        super(const AsyncValue.loading()) {
    loadMedications();
  }

  Future<void> loadMedications({bool onlyActive = false}) async {
    state = const AsyncValue.loading();
    final result =
        await _getMedications(GetMedicationsParams(onlyActive: onlyActive));
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (medications) => AsyncValue.data(medications),
    );
  }

  Future<void> addMedicationEntry(Medication medication) async {
    final result = await _addMedication(medication);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (id) async {
        // Schedule notification
        if (_notificationService != null) {
          await _notificationService.scheduleMedicationNotifications(
            medication.copyWith(id: id),
          );
        }
        loadMedications(); // Reload medications after adding
      },
    );
  }

  Future<void> updateMedicationEntry(Medication medication) async {
    final result = await _updateMedication(medication);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        // Update notification
        if (_notificationService != null && medication.id != null) {
          // We should probably cancel old ones and reschedule new ones
          await _notificationService
              .cancelMedicationNotifications(medication.id!);
          if (medication.isActive) {
            await _notificationService
                .scheduleMedicationNotifications(medication);
          }
        }
        loadMedications(); // Reload medications after updating
      },
    );
  }

  Future<void> deleteMedicationEntry(Id id) async {
    final result = await _deleteMedication(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        // Cancel notification
        if (_notificationService != null) {
          await _notificationService.cancelMedicationNotifications(id);
        }
        loadMedications(); // Reload medications after deleting
      },
    );
  }

  Future<void> markMedicationAsTaken(MedicationIntake intake) async {
    final result = await _markMedicationTaken(
      MarkMedicationTakenParams(
        intakeId: intake.id!,
        medicationId: intake.medicationId,
        scheduledTime: intake.scheduledTime,
      ),
    );
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadMedications(), // Reload medications after marking taken
    );
  }

  Future<void> snoozeMedicationIntake(
      MedicationIntake intake, DateTime newScheduledTime,) async {
    final result = await _snoozeMedication(
      SnoozeMedicationParams(
        intakeId: intake.id!,
        medicationId: intake.medicationId,
        newScheduledTime: newScheduledTime,
      ),
    );
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) => loadMedications(), // Reload medications after snoozing
    );
  }

  Future<double?> getAdherence(Id medicationId) async {
    final result = await _calculateAdherence(medicationId);
    return result.fold(
      (failure) => null,
      (adherence) => adherence,
    );
  }

  Future<List<MedicationIntake>> getIntakes(Id medicationId) async {
    final result = await _getMedicationIntakes(
        GetMedicationIntakesParams(medicationId: medicationId),);
    return result.fold(
      (failure) => [],
      (intakes) => intakes,
    );
  }
}

final medicationNotifierProvider =
    StateNotifierProvider<MedicationNotifier, AsyncValue<List<Medication>>>(
        (ref) {
  return MedicationNotifier(
    addMedication: ref.read(addMedicationUseCaseProvider),
    getMedications: ref.read(getMedicationsUseCaseProvider),
    updateMedication: ref.read(updateMedicationUseCaseProvider),
    deleteMedication: ref.read(deleteMedicationUseCaseProvider),
    markMedicationTaken: ref.read(markMedicationTakenUseCaseProvider),
    snoozeMedication: ref.read(snoozeMedicationUseCaseProvider),
    calculateAdherence: ref.read(calculateAdherenceUseCaseProvider),
    getMedicationIntakes: ref.read(getMedicationIntakesUseCaseProvider),
    notificationService: ref.read(medicationNotificationServiceProvider),
  );
});

final medicationListProvider = Provider<AsyncValue<List<Medication>>>((ref) {
  return ref.watch(medicationNotifierProvider);
});

final activeMedicationListProvider =
    Provider<AsyncValue<List<Medication>>>((ref) {
  // Trigger loading of active medications and return the notifier state.
  // We intentionally don't await loadMedications here; the notifier will
  // update its state when the async call completes.
  ref
      .read(medicationNotifierProvider.notifier)
      .loadMedications(onlyActive: true);
  return ref.watch(medicationNotifierProvider);
});
