import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/dashboard/presentation/providers/dashboard_customization_provider.dart';

class DashboardCustomizationScreen extends ConsumerWidget {
  const DashboardCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customization = ref.watch(dashboardCustomizationProvider);
    final notifier = ref.read(dashboardCustomizationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Dashboard'),
        actions: [
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset to Default?'),
                  content: const Text(
                    'This will reset all dashboard customizations to default.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await notifier.resetToDefault();
                if (context.mounted) {
                  FeedbackService.showSuccess(
                    context,
                    'Dashboard reset to default',
                  );
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDesignTokens.space16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Customize Your Dashboard',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Toggle visibility and reorder modules to personalize your dashboard.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Module list
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.all(AppDesignTokens.space16),
              onReorder: (oldIndex, newIndex) async {
                await notifier.reorderModules(oldIndex, newIndex);
              },
              children: customization.moduleOrder.map((moduleId) {
                final module = DashboardModule.values.firstWhere(
                  (m) => m.id == moduleId,
                  orElse: () => DashboardModule.health,
                );
                final isVisible =
                    customization.moduleVisibility[moduleId] ?? true;

                return _ModuleCustomizationItem(
                  key: ValueKey(moduleId),
                  module: module,
                  isVisible: isVisible,
                  onVisibilityChanged: (visible) async {
                    await notifier.setModuleVisibility(moduleId, visible);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCustomizationItem extends StatelessWidget {
  final DashboardModule module;
  final bool isVisible;
  final ValueChanged<bool> onVisibilityChanged;

  const _ModuleCustomizationItem({
    required super.key,
    required this.module,
    required this.isVisible,
    required this.onVisibilityChanged,
  });

  IconData _getModuleIcon() {
    switch (module) {
      case DashboardModule.health:
        return Icons.favorite;
      case DashboardModule.finance:
        return Icons.account_balance_wallet;
      case DashboardModule.reminders:
        return Icons.notifications;
      case DashboardModule.notes:
        return Icons.note;
    }
  }

  Color _getModuleColor() {
    switch (module) {
      case DashboardModule.health:
        return AppColors.healthPrimary;
      case DashboardModule.finance:
        return AppColors.financePrimary;
      case DashboardModule.reminders:
        return AppColors.remindersPrimary;
      case DashboardModule.notes:
        return AppColors.notesPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDesignTokens.space12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getModuleColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getModuleIcon(),
            color: _getModuleColor(),
          ),
        ),
        title: Text(module.displayName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isVisible,
              onChanged: onVisibilityChanged,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.drag_handle,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
