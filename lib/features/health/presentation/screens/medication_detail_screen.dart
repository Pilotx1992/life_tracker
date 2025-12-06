import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart';
import 'package:life_tracker/shared/widgets/states/loading_widget.dart';

class MedicationDetailScreen extends ConsumerWidget {
  final Id medicationId;

  const MedicationDetailScreen({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Details'),
      ),
      body: state.when(
        data: (medications) {
          final meds = medications;
          Medication? medication;
          try {
            medication = meds.firstWhere((med) => med.id == medicationId);
          } catch (e) {
            medication = null;
          }

          if (medication == null) {
            return const LoadingWidget();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Dosage: ${medication.dosage}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Times: ${medication.times.map((e) => '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}').join(', ')}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (medication.instructions != null)
                  Text(
                    'Instructions: ${medication.instructions}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 8),
                Text(
                  'Start Date: ${medication.startDate.toLocal().toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'End Date: ${medication.endDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // TODO: Adherence statistics
                // TODO: Intake history
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorStateWidget(message: error.toString()),
      ),
    );
  }
}
