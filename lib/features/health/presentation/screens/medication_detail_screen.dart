import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/domain/entities/medication_intake.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart';
import 'package:life_tracker/shared/widgets/states/loading_widget.dart';
import 'package:intl/intl.dart';

class MedicationDetailScreen extends ConsumerStatefulWidget {
  final Id medicationId;

  const MedicationDetailScreen({super.key, required this.medicationId});

  @override
  ConsumerState<MedicationDetailScreen> createState() =>
      _MedicationDetailScreenState();
}

class _MedicationDetailScreenState
    extends ConsumerState<MedicationDetailScreen> {
  double? _adherence;
  List<MedicationIntake>? _intakes;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final notifier = ref.read(medicationNotifierProvider.notifier);
    final adherence = await notifier.getAdherence(widget.medicationId);
    final intakes = await notifier.getIntakes(widget.medicationId);

    if (mounted) {
      setState(() {
        _adherence = adherence;
        _intakes = intakes;
        _loadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Details'),
      ),
      body: state.when(
        data: (medications) {
          Medication? medication;
          try {
            medication =
                medications.firstWhere((med) => med.id == widget.medicationId);
          } catch (e) {
            medication = null;
          }

          if (medication == null) {
            return const LoadingWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(medicationNotifierProvider.notifier)
                  .loadMedications();
              await _loadStats();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDesignTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medication Info Card
                  _buildMedicationInfoCard(context, medication),
                  const SizedBox(height: AppDesignTokens.space16),

                  // Adherence Statistics Card
                  _buildAdherenceCard(context, colorScheme),
                  const SizedBox(height: AppDesignTokens.space16),

                  // Intake History
                  _buildIntakeHistorySection(context, colorScheme),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorStateWidget(message: error.toString()),
      ),
    );
  }

  Widget _buildMedicationInfoCard(BuildContext context, Medication medication) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    medication.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesignTokens.space16),
            _buildInfoRow(
                context, Icons.science_outlined, 'Dosage', medication.dosage,),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.access_time,
              'Times',
              medication.times
                  .map((e) =>
                      '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}',)
                  .join(', '),
            ),
            if (medication.instructions != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(context, Icons.note_outlined, 'Instructions',
                  medication.instructions!,),
            ],
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Start Date',
              DateFormat('MMM d, yyyy').format(medication.startDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.event,
              'End Date',
              medication.endDate != null
                  ? DateFormat('MMM d, yyyy').format(medication.endDate!)
                  : 'Ongoing',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value,) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceCard(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Adherence Statistics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesignTokens.space16),
            if (_loadingStats)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_adherence != null) ...[
              // Adherence percentage with progress indicator
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _adherence!,
                        strokeWidth: 12,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getAdherenceColor(_adherence!),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(_adherence! * 100).toStringAsFixed(0)}%',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getAdherenceColor(_adherence!),
                              ),
                            ),
                            Text(
                              'Adherence',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDesignTokens.space16),
              // Summary text
              Center(
                child: Text(
                  _getAdherenceMessage(_adherence!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No intake data yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getAdherenceColor(double adherence) {
    if (adherence >= 0.9) return Colors.green;
    if (adherence >= 0.7) return Colors.orange;
    return Colors.red;
  }

  String _getAdherenceMessage(double adherence) {
    if (adherence >= 0.9) return 'Excellent! Keep up the great work! 💪';
    if (adherence >= 0.7) return 'Good job! Try to be more consistent.';
    if (adherence >= 0.5) return 'Room for improvement. Set reminders!';
    return 'Needs attention. Don\'t forget your medication!';
  }

  Widget _buildIntakeHistorySection(
      BuildContext context, ColorScheme colorScheme,) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: colorScheme.tertiary,
            ),
            const SizedBox(width: 8),
            Text(
              'Recent Intake History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDesignTokens.space12),
        if (_loadingStats)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_intakes != null && _intakes!.isNotEmpty)
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _intakes!.length > 10 ? 10 : _intakes!.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final intake = _intakes![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: intake.isTaken
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    child: Icon(
                      intake.isTaken ? Icons.check : Icons.close,
                      color: intake.isTaken ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    DateFormat('MMM d, yyyy').format(intake.scheduledTime),
                    style: theme.textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'Scheduled: ${DateFormat('HH:mm').format(intake.scheduledTime)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  trailing: intake.isTaken && intake.actualTakenTime != null
                      ? Text(
                          'Taken: ${DateFormat('HH:mm').format(intake.actualTakenTime!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        )
                      : Text(
                          intake.isTaken ? 'Taken' : 'Missed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: intake.isTaken ? Colors.green : Colors.red,
                          ),
                        ),
                );
              },
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDesignTokens.space24),
              child: Center(
                child: Text(
                  'No intake history yet.\nStart taking your medication to see history.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
