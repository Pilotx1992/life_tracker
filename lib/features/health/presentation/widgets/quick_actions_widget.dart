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
    // Golden orange color for unified look
    const sunsetColor = Color.fromARGB(253, 238, 157, 28);

    final actions = [
      _QuickAction(
        icon: Icons.add_chart,
        label: 'Add Weight',
        color: sunsetColor,
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
        color: sunsetColor,
        onTap: () {
          // TODO: Navigate to workout screen
          FeedbackService.showInfo(context, 'Workout tracking coming soon!');
        },
      ),
      _QuickAction(
        icon: Icons.bedtime,
        label: 'Log Sleep',
        color: sunsetColor,
        onTap: () {
          // TODO: Navigate to sleep logging
          FeedbackService.showInfo(context, 'Sleep tracking coming soon!');
        },
      ),
      _QuickAction(
        icon: Icons.medication,
        label: 'Add Medication',
        color: sunsetColor,
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
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: action.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with 3D shadow effect
                          Stack(
                            children: [
                              // Shadow layer for 3D effect
                              Icon(
                                action.icon,
                                color: action.color.withValues(alpha: 0.3),
                                size: 36,
                              ),
                              // Main icon
                              Positioned(
                                left: 0,
                                top: -2,
                                child: Icon(
                                  action.icon,
                                  color: action.color,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            action.label,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 11,
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
