import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/features/health/domain/entities/medication_intake.dart';
import 'package:life_tracker/features/health/domain/usecases/add_medication.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_adherence.dart';
import 'package:life_tracker/features/health/domain/usecases/delete_medication.dart';
import 'package:life_tracker/features/health/domain/usecases/get_medication_intakes.dart';
import 'package:life_tracker/features/health/domain/usecases/get_medications.dart';
import 'package:life_tracker/features/health/domain/usecases/mark_medication_taken.dart';
import 'package:life_tracker/features/health/domain/usecases/snooze_medication.dart';
import 'package:life_tracker/features/health/domain/usecases/update_medication.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/features/health/services/medication_notification_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'medication_provider_test.mocks.dart';

@GenerateMocks([
  AddMedication,
  GetMedications,
  UpdateMedication,
  DeleteMedication,
  MarkMedicationTaken,
  SnoozeMedication,
  CalculateAdherence,
  GetMedicationIntakes,
  MedicationNotificationService,
])
void main() {
  late MockAddMedication mockAddMedication;
  late MockGetMedications mockGetMedications;
  late MockUpdateMedication mockUpdateMedication;
  late MockDeleteMedication mockDeleteMedication;
  late MockMarkMedicationTaken mockMarkMedicationTaken;
  late MockSnoozeMedication mockSnoozeMedication;
  late MockCalculateAdherence mockCalculateAdherence;
  late MockGetMedicationIntakes mockGetMedicationIntakes;
  late MockMedicationNotificationService mockNotificationService;
  late ProviderContainer container;

  setUp(() {
    mockAddMedication = MockAddMedication();
    mockGetMedications = MockGetMedications();
    mockUpdateMedication = MockUpdateMedication();
    mockDeleteMedication = MockDeleteMedication();
    mockMarkMedicationTaken = MockMarkMedicationTaken();
    mockSnoozeMedication = MockSnoozeMedication();
    mockCalculateAdherence = MockCalculateAdherence();
    mockGetMedicationIntakes = MockGetMedicationIntakes();
    mockNotificationService = MockMedicationNotificationService();

    container = ProviderContainer(
      overrides: [
        addMedicationUseCaseProvider.overrideWithValue(mockAddMedication),
        getMedicationsUseCaseProvider.overrideWithValue(mockGetMedications),
        updateMedicationUseCaseProvider.overrideWithValue(mockUpdateMedication),
        deleteMedicationUseCaseProvider.overrideWithValue(mockDeleteMedication),
        markMedicationTakenUseCaseProvider
            .overrideWithValue(mockMarkMedicationTaken),
        snoozeMedicationUseCaseProvider.overrideWithValue(mockSnoozeMedication),
        calculateAdherenceUseCaseProvider
            .overrideWithValue(mockCalculateAdherence),
        getMedicationIntakesUseCaseProvider
            .overrideWithValue(mockGetMedicationIntakes),
        medicationNotificationServiceProvider
            .overrideWithValue(mockNotificationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('getIntakes returns list of intakes on success', () async {
    // Arrange
    final intakes = [
      MedicationIntake(
        id: 1,
        medicationId: 1,
        scheduledTime: DateTime.now(),
        isTaken: true,
      ),
    ];
    when(mockGetMedicationIntakes(any)).thenAnswer((_) async => Right(intakes));

    // Stub getMedications to avoid errors in notifier initialization
    when(mockGetMedications(any)).thenAnswer((_) async => const Right([]));

    // Act
    final result =
        await container.read(medicationNotifierProvider.notifier).getIntakes(1);

    // Assert
    expect(result, intakes);
    verify(
      mockGetMedicationIntakes(
        const GetMedicationIntakesParams(medicationId: 1),
      ),
    );
  });

  test('getAdherence returns adherence percentage on success', () async {
    // Arrange
    when(mockCalculateAdherence(any))
        .thenAnswer((_) async => const Right(85.5));

    // Stub getMedications to avoid errors in notifier initialization
    when(mockGetMedications(any)).thenAnswer((_) async => const Right([]));

    // Act
    final result = await container
        .read(medicationNotifierProvider.notifier)
        .getAdherence(1);

    // Assert
    expect(result, 85.5);
    verify(mockCalculateAdherence(1));
  });
}
