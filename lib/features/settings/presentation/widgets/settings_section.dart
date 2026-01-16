import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              title!.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
               color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              final child = children[index];
              
              // Add divider between items
              if (index > 0) {
                return Column(
                  children: [
                   Padding(
                     padding: const EdgeInsets.only(left: 68), // Align with text
                     child: Divider(
                       height: 1, 
                       thickness: 0.5,
                       color: theme.colorScheme.outlineVariant,
                     ),
                   ),
                   child,
                  ],
                );
              }
              
              return child;
            }),
          ),
        ),
      ],
    );
  }
}
