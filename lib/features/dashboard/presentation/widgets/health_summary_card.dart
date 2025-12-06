import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_bmi.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_provider.dart';
import 'package:life_tracker/features/settings/presentation/providers/user_profile_providers.dart';

class HealthSummaryCard extends ConsumerWidget {
  const HealthSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightsAsync = ref.watch(weightNotifierProvider);
    final medicationsAsync = ref.watch(medicationNotifierProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Health',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push(AppRoutes.weight),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Latest Weight & BMI
            weightsAsync.when(
              data: (weights) {
                if (weights.isEmpty) {
                  return _buildEmptyState(
                    context,
                    'No weight entries',
                    'Log your weight to track progress',
                    () => _showAddWeightDialog(context, ref),
                  );
                }
                final latestWeight = weights.first;
                return FutureBuilder<double?>(
                  future: profileAsync.when(
                    data: (profile) async {
                      if (profile?.heightInCm != null) {
                        final bmiResult = await CalculateBmi().call(
                          BmiParams(
                            weight: latestWeight.weight,
                            height: profile!.heightInCm!,
                          ),
                        );
                        return bmiResult.fold(
                          (failure) => null,
                          (value) => value,
                        );
                      }
                      return null;
                    },
                    loading: () async => null,
                    error: (_, __) async => null,
                  ),
                  builder: (context, snapshot) {
                    return _buildWeightInfo(
                      context,
                      latestWeight,
                      snapshot.data,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorState(context, error.toString()),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Next Medication
            medicationsAsync.when(
              data: (medications) {
                final now = DateTime.now();
                final activeMedications = medications.where((m) {
                  return m.endDate == null || m.endDate!.isAfter(now);
                }).toList();
                if (activeMedications.isEmpty) {
                  return _buildEmptyState(
                    context,
                    'No active medications',
                    'Add medications to track intake',
                    () => context.push(AppRoutes.weight),
                  );
                }
                return _buildNextMedication(context, activeMedications);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  _buildErrorState(context, error.toString()),
            ),
            const SizedBox(height: 16),
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddWeightDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Log Weight'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.weight),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Medication'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInfo(
    BuildContext context,
    WeightEntry weight,
    double? bmi,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.monitor_weight, size: 32, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weight.weight.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(weight.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            if (bmi != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getBmiColor(bmi).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BMI: ${bmi.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: _getBmiColor(bmi),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextMedication(
    BuildContext context,
    List<Medication> medications,
  ) {
    // Find next medication (simplified - just show first active medication)
    final nextMed = medications.first;
    final nextTime = nextMed.times.isNotEmpty ? nextMed.times.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medication, size: 24, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next: ${nextMed.name}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (nextTime != null)
                    Text(
                      DateFormat('hh:mm a').format(nextTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onAction,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Error: $error',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
            ),
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue; // Underweight
    if (bmi < 25) return Colors.green; // Normal
    if (bmi < 30) return Colors.orange; // Overweight
    return Colors.red; // Obese
  }

  void _showAddWeightDialog(BuildContext context, WidgetRef ref) {
    // Navigate to weight screen or show dialog
    context.push(AppRoutes.weight);
  }
}
