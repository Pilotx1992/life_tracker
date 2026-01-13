import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/core/providers/ble_provider.dart';
import 'package:life_tracker/core/providers/health_provider.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/core/services/health_service.dart';
import 'package:life_tracker/features/health/presentation/providers/activity_provider.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_provider.dart';
import 'package:life_tracker/features/health/presentation/widgets/activity_rings_widget.dart';
import 'package:life_tracker/features/health/presentation/widgets/health_insights_widget.dart';
import 'package:life_tracker/features/health/presentation/widgets/health_metric_card.dart';
import 'package:life_tracker/features/health/presentation/widgets/health_summary_card.dart';
import 'package:life_tracker/features/health/presentation/widgets/quick_actions_widget.dart';
import 'package:life_tracker/features/settings/presentation/providers/user_profile_providers.dart';
import 'package:life_tracker/shared/widgets/states/skeleton_widgets.dart';

/// Health Dashboard Screen - Huawei Health style design
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncHealthData();
    });
  }

  Future<void> _syncHealthData() async {
    final healthState = ref.read(healthConnectProvider);
    if (healthState.isAuthorized) {
      await ref.read(healthConnectProvider.notifier).syncAllData(
            startDate: DateTime.now().subtract(const Duration(days: 7)),
            endDate: DateTime.now(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Health'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth, color: theme.colorScheme.onSurface),
            onPressed: () => context.push(AppRoutes.devices),
            tooltip: 'Manage Devices',
          ),
          Consumer(
            builder: (context, ref, child) {
              final healthState = ref.watch(healthConnectProvider);
              return IconButton(
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
                    : Icon(Icons.sync, color: theme.colorScheme.onSurface),
                onPressed: healthState.isSyncing
                    ? null
                    : () async {
                        if (!healthState.isAuthorized) {
                          final granted = await ref
                              .read(healthConnectProvider.notifier)
                              .requestPermissions();
                          if (granted) {
                            await _syncHealthData();
                          }
                        } else {
                          await _syncHealthData();
                        }
                      },
                tooltip: 'Sync Health Data',
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _syncHealthData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity Rings Section
              _buildActivityRings(context, ref, theme),
              const SizedBox(height: 8),
              _buildSourceLabel(context, ref, theme),
              const SizedBox(height: 20),

              // Today's Summary Cards Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Summary",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTodaysSummary(context, ref, theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Health Metrics Grid
              _buildHealthMetricsGrid(context, ref, theme),
              const SizedBox(height: 24),

              // Quick Actions Section
              QuickActionsWidget(theme: theme),
              const SizedBox(height: 24),

              // Health Insights Section
              HealthInsightsWidget(theme: theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityRings(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final activityData = ref.watch(activityDataProvider);

    return ActivityRingsWidget(
      moveProgress: activityData.moveProgress,
      exerciseProgress: activityData.exerciseProgress,
      standProgress: activityData.standProgress,
      steps: activityData.steps,
      moveCurrent: activityData.moveCurrent,
      moveGoal: activityData.moveGoal,
      exerciseCurrent: activityData.exerciseCurrent,
      exerciseGoal: activityData.exerciseGoal,
      standCurrent: activityData.standCurrent,
      standGoal: activityData.standGoal,
      theme: theme,
    );
  }

  Widget _buildTodaysSummary(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final healthState = ref.watch(healthConnectProvider);
    final latestWeightAsync = ref.watch(latestWeightProvider);

    // Get latest heart rate
    HeartRateDataPoint? latestHeartRate;
    if (healthState.heartRateData.isNotEmpty) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      latestHeartRate = healthState.heartRateData.firstWhere(
        (hr) => hr.date.isAfter(todayStart),
        orElse: () => healthState.heartRateData.first,
      );
    }

    // Calculate heart rate trend (compare with average)
    String? heartRateTrend;
    if (healthState.heartRateData.length > 1) {
      final avgHeartRate = healthState.heartRateData
              .map((hr) => hr.heartRate)
              .reduce((a, b) => a + b) /
          healthState.heartRateData.length;
      if (latestHeartRate != null) {
        final diff = latestHeartRate.heartRate - avgHeartRate;
        if (diff.abs() > 5) {
          heartRateTrend = diff > 0 ? '+${diff.toInt()}' : '${diff.toInt()}';
        }
      }
    }

    return Row(
      children: [
        Expanded(
          child: HealthSummaryCard(
            title: 'Heart Rate',
            value:
                latestHeartRate != null ? '${latestHeartRate.heartRate}' : '--',
            unit: 'bpm',
            icon: Icons.favorite,
            iconColor: Colors.red,
            trend: heartRateTrend,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: latestWeightAsync.when(
            data: (weightEntry) {
              final healthState = ref.read(healthConnectProvider);
              double? weight;
              String? weightTrend;

              if (weightEntry != null) {
                weight = weightEntry.weight;
                // Calculate trend
                final weightList = ref.read(weightListProvider).value ?? [];
                if (weightList.length > 1) {
                  weightList.sort((a, b) => b.date.compareTo(a.date));
                  final previousWeight = weightList.length > 1
                      ? weightList[1].weight
                      : weightEntry.weight;
                  final diff = weight - previousWeight;
                  if (diff.abs() > 0.1) {
                    weightTrend = diff > 0
                        ? '+${diff.toStringAsFixed(1)}'
                        : diff.toStringAsFixed(1);
                  }
                }
              } else if (healthState.weightData.isNotEmpty) {
                weight = healthState.weightData.first.weight;
              } else if (ref.read(bleConnectionProvider).latestWeight != null) {
                weight = ref.read(bleConnectionProvider).latestWeight;
              }

              return HealthSummaryCard(
                title: 'Weight',
                value: weight != null ? weight.toStringAsFixed(1) : '--',
                unit: 'kg',
                icon: Icons.monitor_weight,
                iconColor: Colors.blue,
                trend: weightTrend,
                theme: theme,
                onTap: () => context.push(AppRoutes.weight),
              );
            },
            loading: () => const StatCardSkeleton(),
            error: (_, __) => HealthSummaryCard(
              title: 'Weight',
              value: '--',
              unit: 'kg',
              icon: Icons.monitor_weight,
              iconColor: Colors.blue,
              theme: theme,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HealthSummaryCard(
            title: 'Calories',
            value:
                ref.watch(activityDataProvider).moveCurrent.toStringAsFixed(0),
            unit: 'kcal',
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetricsGrid(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final activityData = ref.watch(activityDataProvider);
    final medicationsAsync = ref.watch(medicationListProvider);

    // Use distance from ActivityData (Smart Engine)
    final distanceKm = activityData.distance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Metrics',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              // Medications Card with Loading State
              medicationsAsync.when(
                data: (medications) {
                  final active = medications
                      .where(
                        (m) =>
                            m.endDate == null ||
                            m.endDate!.isAfter(DateTime.now()),
                      )
                      .length;
                  return HealthMetricCard(
                    title: 'Medications',
                    value: '$active',
                    unit: 'Active',
                    icon: Icons.medication,
                    iconColor: Colors.purple,
                    theme: theme,
                    onTap: () => context.push(AppRoutes.medications),
                  );
                },
                loading: () => const GridCardSkeleton(height: null),
                error: (_, __) => HealthMetricCard(
                  title: 'Medications',
                  value: '--',
                  unit: 'Active',
                  icon: Icons.medication,
                  iconColor: Colors.purple,
                  theme: theme,
                  onTap: () => context.push(AppRoutes.medications),
                ),
              ),
              HealthMetricCard(
                title: 'Sleep',
                value: '--',
                unit: 'Hours',
                icon: Icons.bedtime,
                iconColor: Colors.indigo,
                theme: theme,
                // [Phase 2] Sleep data will be added when sleep tracking is implemented
              ),
              _buildBmiCard(context, ref, theme),
              HealthMetricCard(
                title: 'Distance',
                value: distanceKm.toStringAsFixed(1),
                unit: 'km',
                icon: Icons.directions_run,
                iconColor: Colors.green,
                progress:
                    (distanceKm / 5.0).clamp(0.0, 1.0), // Assuming 5km goal
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        return latestWeightAsync.when(
          data: (weightEntry) {
            if (profile == null ||
                weightEntry == null ||
                profile.heightInCm == null ||
                profile.heightInCm! == 0) {
              return HealthMetricCard(
                title: 'BMI',
                value: '--',
                unit: '',
                icon: Icons.monitor_weight_outlined,
                iconColor: Colors.green,
                theme: theme,
              );
            }
            final heightInMeters = profile.heightInCm! / 100;
            final bmi = weightEntry.weight / (heightInMeters * heightInMeters);
            return HealthMetricCard(
              title: 'BMI',
              value: bmi.toStringAsFixed(1),
              unit: _getBmiCategory(bmi),
              icon: Icons.monitor_weight_outlined,
              iconColor: Colors.green,
              theme: theme,
              onTap: () => context.push(AppRoutes.weight),
            );
          },
          loading: () => const GridCardSkeleton(height: null),
          error: (_, __) => HealthMetricCard(
            title: 'BMI',
            value: '--',
            unit: '',
            icon: Icons.monitor_weight_outlined,
            iconColor: Colors.green,
            theme: theme,
          ),
        );
      },
      loading: () => const GridCardSkeleton(height: null),
      error: (_, __) => HealthMetricCard(
        title: 'BMI',
        value: '--',
        unit: '',
        icon: Icons.monitor_weight_outlined,
        iconColor: Colors.green,
        theme: theme,
      ),
    );
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Widget _buildSourceLabel(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final activityData = ref.watch(activityDataProvider);
    final isWatch = activityData.source == DataSource.healthConnect;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWatch ? Icons.watch : Icons.smartphone,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              isWatch ? 'Source: Huawei Watch' : 'Source: Phone Sensor',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
