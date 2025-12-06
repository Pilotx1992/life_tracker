import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/error_widget.dart' as error_widget;
import 'package:life_tracker/shared/widgets/states/skeleton_widgets.dart';

class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationListAsyncValue = ref.watch(medicationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Medications',
            onPressed: () {
              // Implement filter functionality
            },
          ),
        ],
      ),
      body: medicationListAsyncValue.when(
        data: (medications) {
          if (medications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(medicationNotifierProvider.notifier)
                    .loadMedications();
              },
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 400,
                  child: EmptyStateWidget(
                    icon: Icons.medication,
                    title: 'No medications added yet.',
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(medicationNotifierProvider.notifier)
                  .loadMedications();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              cacheExtent: 500,
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medication = medications[index];
                return Dismissible(
                  key: Key('medication_${medication.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onError,
                      size: 32,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Medication'),
                            content: Text(
                              'Are you sure you want to delete ${medication.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (direction) {
                    if (medication.id != null) {
                      ref
                          .read(medicationNotifierProvider.notifier)
                          .deleteMedicationEntry(medication.id!);
                      FeedbackService.showSuccess(
                        context,
                        '${medication.name} deleted',
                      );
                    }
                  },
                  child: ListTile(
                    title: Text(medication.name),
                    subtitle: Text(medication.dosage),
                  ),
                );
              },
            ),
          );
        },
        loading: () => SkeletonList.tiles(itemCount: 8),
        error: (error, stack) => error_widget.ErrorDisplayWidget(
          message: error.toString(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add medication functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
