import 'package:flutter/material.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

/// A section widget with a header and content
/// Used for organizing content into logical sections
class Section extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  const Section({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? AppDesignTokens.sectionPadding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || subtitle != null || trailing != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppDesignTokens.space16),
          ],
          child,
        ],
      ),
    );
  }
}

/// A card widget with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool elevated;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevated = false,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius = borderRadius ?? AppDesignTokens.cardBorderRadius;

    Widget cardContent = Container(
      padding: padding ?? AppDesignTokens.cardPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: effectiveRadius,
        border: elevated
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius,
        child: cardContent,
      );
    }

    if (margin != null) {
      cardContent = Padding(padding: margin!, child: cardContent);
    }

    return cardContent;
  }
}

/// A list section with a header
class ListSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool showDividers;

  const ListSection({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.padding,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: AppDesignTokens.space16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        const SizedBox(height: AppDesignTokens.space8),
        ...List.generate(
          children.length,
          (index) => Column(
            children: [
              children[index],
              if (showDividers && index < children.length - 1)
                Divider(
                  height: 1,
                  indent: AppDesignTokens.space16,
                  endIndent: AppDesignTokens.space16,
                  color: theme.dividerColor,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A divider with optional label
class LabeledDivider extends StatelessWidget {
  final String? label;
  final double height;
  final Color? color;

  const LabeledDivider({
    super.key,
    this.label,
    this.height = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = color ?? theme.dividerColor;

    if (label == null) {
      return Divider(height: height, color: dividerColor);
    }

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(child: Divider(color: dividerColor)),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDesignTokens.space16),
            child: Text(
              label!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(child: Divider(color: dividerColor)),
        ],
      ),
    );
  }
}

/// A page wrapper with consistent padding and optional app bar
class PageWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;
  final Color? backgroundColor;

  const PageWrapper({
    super.key,
    required this.child,
    this.padding,
    this.safeArea = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ?? AppDesignTokens.pagePadding,
      child: child,
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    if (backgroundColor != null) {
      content = ColoredBox(color: backgroundColor!, child: content);
    }

    return content;
  }
}

/// A responsive container that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = AppDesignTokens.contentWidthMedium,
    this.padding,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// A stat card for displaying metrics
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: effectiveIconColor,
                  ),
                ),
                const SizedBox(width: AppDesignTokens.space12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppDesignTokens.space12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A summary row for key-value pairs
class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Widget? trailing;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDesignTokens.space8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: labelStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ),
          Text(
            value,
            style: valueStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppDesignTokens.space8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
