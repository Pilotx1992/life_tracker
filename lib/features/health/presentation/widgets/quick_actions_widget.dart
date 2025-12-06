import 'package:flutter/material.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/health/presentation/widgets/add_weight_dialog.dart';
import 'package:life_tracker/features/health/presentation/widgets/add_medication_dialog.dart';

/// Quick Actions Widget
/// Horizontal scrollable list of action cards
class QuickActionsWidget extends StatelessWidget {
  final ThemeData theme;

  const QuickActionsWidget({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    final actions = [
      _QuickAction(
        icon: Icons.add_chart,
        label: 'Add Weight',
        color: colorScheme.primary,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const AddWeightDialog(),
          );
        },
      ),
      _QuickAction(
        icon: Icons.fitness_center,
        label: 'Start Workout',
        color: colorScheme.tertiary,
        onTap: () {
          // TODO: Navigate to workout screen
          FeedbackService.showInfo(context, 'Workout tracking coming soon!');
        },
      ),
      _QuickAction(
        icon: Icons.bedtime,
        label: 'Log Sleep',
        color: colorScheme.secondary,
        onTap: () {
          // TODO: Navigate to sleep logging
          FeedbackService.showInfo(context, 'Sleep tracking coming soon!');
        },
      ),
      _QuickAction(
        icon: Icons.medication,
        label: 'Add Medication',
        color: colorScheme.inversePrimary,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const AddMedicationDialog(),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            cacheExtent: 500,
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Container(
                width: 90,
                margin: const EdgeInsetsDirectional.only(end: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      action.color.withValues(alpha: 0.2),
                      action.color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: action.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: action.color.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: action.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: action.color.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            action.icon,
                            color: action.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action.label,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
