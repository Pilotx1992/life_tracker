import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/providers/ble_provider.dart';
import 'package:life_tracker/core/providers/health_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_ideal_weight.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_provider.dart';
import 'package:life_tracker/features/health/presentation/widgets/add_weight_dialog.dart';
import 'package:life_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:life_tracker/features/settings/presentation/providers/user_profile_providers.dart';
import 'package:life_tracker/shared/widgets/states/skeleton_widgets.dart';

class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen({super.key});

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  String _selectedPeriod = 'Day';
  WeightEntry? _selectedWeightEntry;
  bool _showWarning = true;

  @override
  void initState() {
    super.initState();
    _setupBleListener();
  }

  void _setupBleListener() {
    ref.listenManual(bleConnectionProvider, (previous, next) {
      if (next.latestWeight != null &&
          previous?.latestWeight != next.latestWeight) {
        _showWeightConfirmationDialog(next.latestWeight!);
      }
    });
  }

  void _showWeightConfirmationDialog(double weight) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Weight Measurement'),
        content: Text(
          'Received weight measurement: ${weight.toStringAsFixed(1)} kg\n\n'
          'Would you like to save this weight entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final entry = WeightEntry(
                weight: weight,
                date: DateTime.now(),
              );
              ref.read(weightNotifierProvider.notifier).addWeightEntry(entry);
              Navigator.of(context).pop();
              FeedbackService.showSuccess(context, 'Weight entry saved!');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncHealthData() async {
    final healthNotifier = ref.read(healthConnectProvider.notifier);
    await healthNotifier.syncWeightData(
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final bleConnection = ref.watch(bleConnectionProvider);
    final healthState = ref.watch(healthConnectProvider);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Weight'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          if (healthState.isAuthorized)
            IconButton(
              icon: healthState.isSyncing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onSurface,
                        ),
                      ),
                    )
                  : const Icon(Icons.sync),
              tooltip: 'Sync from Health Connect',
              onPressed: healthState.isSyncing ? null : _syncHealthData,
            ),
        ],
      ),
      body: Column(
        children: [
          // Period Navigation
          _buildPeriodNavigation(),

          // Main Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(weightNotifierProvider.notifier).loadWeights();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: latestWeightAsync.when(
                  data: (latestWeight) {
                    if (latestWeight == null) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: _buildEmptyState(context),
                      );
                    }

                    // Use selected weight or latest weight
                    final currentWeight = _selectedWeightEntry ?? latestWeight;

                    return Column(
                      children: [
                        // Weight Details Card
                        _buildWeightDetailsCard(
                          context,
                          currentWeight,
                          latestWeight,
                          profileAsync,
                          theme,
                        ),
                        const SizedBox(height: 16),

                        // Warning Message
                        if (_showWarning)
                          _buildWarningCard(
                            context,
                            currentWeight,
                            profileAsync,
                            theme,
                          ),
                      ],
                    );
                  },
                  loading: () => const PageSkeleton(
                    type: PageSkeletonType.detail,
                  ),
                  error: (error, stack) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Action Buttons
          _buildBottomActions(context, bleConnection),
        ],
      ),
    );
  }

  Widget _buildPeriodNavigation() {
    final theme = Theme.of(context);
    final periods = ['Day', 'Week', 'Month', 'Year'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.green
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No weight entries yet',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first weight entry to get started',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightDetailsCard(
    BuildContext context,
    WeightEntry currentWeight,
    WeightEntry latestWeight,
    AsyncValue<UserProfile?> profileAsync,
    ThemeData theme,
  ) {
    // Calculate weight change
    final weightListAsync = ref.watch(weightListProvider);
    final weightChange = _calculateWeightChange(currentWeight, weightListAsync);
    final bmiData = _calculateBMI(currentWeight, profileAsync);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date/Time Picker
          GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Row(
              children: [
                Text(
                  DateFormat('EEE, MMMM d').format(currentWeight.date),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'at ${DateFormat('HH:mm').format(currentWeight.date)}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Current Weight
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${currentWeight.weight.toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Weight Change Indicator
              if (weightChange != null)
                Builder(
                  builder: (context) {
                    final change = weightChange;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: change < 0
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            change < 0
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: change < 0 ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            change.abs().toStringAsFixed(2),
                            style: TextStyle(
                              color: change < 0 ? Colors.green : Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          if (weightChange != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'Compared to last time',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // BMI
          if (bmiData['bmi'] != null && bmiData['category'] != null)
            Text(
              'BMI ${(bmiData['bmi'] as double).toStringAsFixed(1)} ${bmiData['category'] as String}',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 20),

          // Ideal Weight Range
          _buildIdealWeightRangeSection(
            context,
            currentWeight,
            profileAsync,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildIdealWeightRangeSection(
    BuildContext context,
    WeightEntry currentWeight,
    AsyncValue<UserProfile?> profileAsync,
    ThemeData theme,
  ) {
    return profileAsync.when(
      data: (profile) {
        if (profile == null ||
            profile.heightInCm == null ||
            profile.heightInCm! == 0) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Maintain weight',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    _buildWeightDifferenceText(
                      context,
                      currentWeight.weight,
                      profile,
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildIdealWeightRangeBar(
              context,
              currentWeight.weight,
              profile,
              theme,
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildIdealWeightRangeBar(
    BuildContext context,
    double currentWeight,
    UserProfile profile,
    ThemeData theme,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final idealWeightAsync = ref.watch(
          idealWeightProvider(
            IdealWeightParams(
              height: profile.heightInCm! / 100,
              isMale: profile.gender == 'male',
            ),
          ),
        );

        return idealWeightAsync.when(
          data: (idealWeight) {
            if (idealWeight == null) return const SizedBox.shrink();

            final minIdeal = idealWeight['min'];
            final maxIdeal = idealWeight['max'];
            if (minIdeal == null || maxIdeal == null) {
              return const SizedBox.shrink();
            }

            final totalRange =
                maxIdeal - minIdeal + 20; // Add padding for visualization

            // Calculate position
            final startPosition = (minIdeal - (minIdeal - 10)) / totalRange;
            final endPosition = (maxIdeal - (minIdeal - 10)) / totalRange;
            final currentPosition =
                (currentWeight - (minIdeal - 10)) / totalRange;

            final isInRange =
                currentWeight >= minIdeal && currentWeight <= maxIdeal;

            return Column(
              children: [
                Stack(
                  children: [
                    // Background bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Ideal range (green)
                    Positioned(
                      left: MediaQuery.of(context).size.width *
                          0.1 *
                          startPosition,
                      right: MediaQuery.of(context).size.width *
                          0.1 *
                          (1 - endPosition),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // Current weight indicator
                    if (!isInRange)
                      Positioned(
                        left: MediaQuery.of(context).size.width *
                                0.1 *
                                currentPosition -
                            4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      minIdeal.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      maxIdeal.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildWeightDifferenceText(
    BuildContext context,
    double currentWeight,
    UserProfile profile,
  ) {
    if (profile.heightInCm == null || profile.heightInCm! == 0) {
      return const SizedBox.shrink();
    }

    return Consumer(
      builder: (context, ref, child) {
        final idealWeightAsync = ref.watch(
          idealWeightProvider(
            IdealWeightParams(
              height: profile.heightInCm! / 100,
              isMale: profile.gender == 'male',
            ),
          ),
        );

        return idealWeightAsync.when(
          data: (idealWeight) {
            if (idealWeight == null) return const SizedBox.shrink();
            final maxIdeal = idealWeight['max'];
            if (maxIdeal == null) return const SizedBox.shrink();
            final difference = currentWeight - maxIdeal;
            return Text(
              difference > 0
                  ? '${difference.toStringAsFixed(1)} kg over'
                  : '${difference.abs().toStringAsFixed(1)} kg under',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildWarningCard(
    BuildContext context,
    WeightEntry currentWeight,
    AsyncValue<UserProfile?> profileAsync,
    ThemeData theme,
  ) {
    final theme2 = Theme.of(context);
    return profileAsync.when(
      data: (profile) {
        if (profile == null ||
            profile.heightInCm == null ||
            profile.heightInCm! == 0) {
          return const SizedBox.shrink();
        }

        final idealWeightAsync = ref.watch(
          idealWeightProvider(
            IdealWeightParams(
              height: profile.heightInCm! / 100,
              isMale: profile.gender == 'male',
            ),
          ),
        );

        return idealWeightAsync.when(
          data: (idealWeight) {
            if (idealWeight == null) return const SizedBox.shrink();

            final minIdeal = idealWeight['min']!;
            final maxIdeal = idealWeight['max']!;
            final isInRange = currentWeight.weight >= minIdeal &&
                currentWeight.weight <= maxIdeal;

            if (isInRange) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme2.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your weight is outside of the set range. Eat smart and exercise to get back on track.',
                      style: TextStyle(
                        color:
                            theme2.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: theme2.colorScheme.onSurface.withValues(alpha: 0.6),
                    onPressed: () {
                      setState(() {
                        _showWarning = false;
                      });
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    BleConnectionState bleState,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddWeightDialog(),
                  );
                },
                icon: const Icon(Icons.edit_note, color: Colors.green),
                label: const Text(
                  'Add record',
                  style: TextStyle(color: Colors.green),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: bleState.isConnected
                    ? () {
                        // Measure from scale
                        FeedbackService.showInfo(
                          context,
                          'Waiting for measurement from scale...',
                        );
                      }
                    : () {
                        // Show BLE connection dialog or navigate to device setup
                        FeedbackService.showWarning(
                          context,
                          'Please connect to a scale first',
                        );
                      },
                icon: const Icon(Icons.monitor_weight, color: Colors.green),
                label: const Text(
                  'Measure',
                  style: TextStyle(color: Colors.green),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final theme = Theme.of(context);
    final weightListAsync = ref.watch(weightListProvider);

    weightListAsync.whenData((weights) async {
      if (weights.isEmpty) return;

      // Show bottom sheet with weight entries
      final selected = await showModalBottomSheet<WeightEntry>(
        context: context,
        backgroundColor: theme.colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Weight Entry',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: weights.length,
                  itemBuilder: (context, index) {
                    final weight = weights[index];
                    return ListTile(
                      title: Text(
                        '${weight.weight.toStringAsFixed(1)} kg',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        DateFormat('EEE, MMMM d at HH:mm').format(weight.date),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, weight);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

      if (selected != null) {
        setState(() {
          _selectedWeightEntry = selected;
        });
      }
    });
  }

  double? _calculateWeightChange(
    WeightEntry currentWeight,
    AsyncValue<List<WeightEntry>> weightListAsync,
  ) {
    double? weightChange;
    weightListAsync.whenData((weights) {
      if (weights.length > 1) {
        weights.sort((a, b) => b.date.compareTo(a.date));
        final currentIndex =
            weights.indexWhere((w) => w.id == currentWeight.id);
        if (currentIndex >= 0 && currentIndex < weights.length - 1) {
          final previousWeight = weights[currentIndex + 1];
          weightChange = currentWeight.weight - previousWeight.weight;
        }
      }
    });
    return weightChange;
  }

  Map<String, dynamic> _calculateBMI(
    WeightEntry currentWeight,
    AsyncValue<UserProfile?> profileAsync,
  ) {
    double? bmi;
    String? bmiCategory;
    profileAsync.whenData((profile) {
      if (profile != null &&
          profile.heightInCm != null &&
          profile.heightInCm! > 0) {
        final heightInMeters = profile.heightInCm! / 100;
        bmi = currentWeight.weight / (heightInMeters * heightInMeters);
        bmiCategory = _getBMICategory(bmi!);
      }
    });
    return {'bmi': bmi, 'category': bmiCategory};
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
