import 'package:flutter/material.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

/// A shimmer box that can be used to build skeleton screens
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final bool circular;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 4,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHighest;

    return ShimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: circular ? null : BorderRadius.circular(borderRadius),
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

/// A shimmer effect wrapper that adds the animated gradient
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            final baseColor = isDark
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surfaceContainerHighest;
            final highlightColor = isDark
                ? theme.colorScheme.surfaceContainerHigh
                : theme.colorScheme.surface;

            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Skeleton for a list card item
class CardSkeleton extends StatelessWidget {
  final bool showIcon;
  final bool showSubtitle;
  final bool showTrailing;

  const CardSkeleton({
    super.key,
    this.showIcon = true,
    this.showSubtitle = true,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.space16,
        vertical: AppDesignTokens.space8,
      ),
      child: Padding(
        padding: AppDesignTokens.cardPadding,
        child: Row(
          children: [
            if (showIcon) ...[
              const ShimmerBox(
                width: 48,
                height: 48,
                borderRadius: 12,
              ),
              const SizedBox(width: AppDesignTokens.space16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 120, height: 16, borderRadius: 4),
                  if (showSubtitle) ...[
                    const SizedBox(height: AppDesignTokens.space8),
                    const ShimmerBox(width: 80, height: 12, borderRadius: 4),
                  ],
                ],
              ),
            ),
            if (showTrailing)
              const ShimmerBox(width: 60, height: 20, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a list tile item (simpler than card)
class ListTileSkeleton extends StatelessWidget {
  final bool showLeading;
  final bool showTrailing;

  const ListTileSkeleton({
    super.key,
    this.showLeading = true,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.space16,
        vertical: AppDesignTokens.space12,
      ),
      child: Row(
        children: [
          if (showLeading) ...[
            const ShimmerBox(width: 40, height: 40, circular: true),
            const SizedBox(width: AppDesignTokens.space16),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14, borderRadius: 4),
                SizedBox(height: AppDesignTokens.space8),
                ShimmerBox(width: 150, height: 12, borderRadius: 4),
              ],
            ),
          ),
          if (showTrailing)
            const ShimmerBox(width: 24, height: 24, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton for a grid card (used in dashboard grids)
class GridCardSkeleton extends StatelessWidget {
  final double? height;

  const GridCardSkeleton({
    super.key,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      padding: AppDesignTokens.cardPadding,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 40, height: 40, borderRadius: 10),
          Spacer(),
          ShimmerBox(width: 60, height: 24, borderRadius: 4),
          SizedBox(height: AppDesignTokens.space8),
          ShimmerBox(width: 80, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton for a stat/metric card
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDesignTokens.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignTokens.cardBorderRadius,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              ShimmerBox(width: 36, height: 36, borderRadius: 8),
              SizedBox(width: AppDesignTokens.space12),
              Expanded(
                child: ShimmerBox(height: 12, borderRadius: 4),
              ),
            ],
          ),
          const SizedBox(height: AppDesignTokens.space16),
          const ShimmerBox(width: 100, height: 28, borderRadius: 4),
          const SizedBox(height: AppDesignTokens.space8),
          const ShimmerBox(width: 60, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton for a profile/header section
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: AppDesignTokens.pagePadding,
      child: Column(
        children: [
          ShimmerBox(width: 80, height: 80, circular: true),
          SizedBox(height: AppDesignTokens.space16),
          ShimmerBox(width: 150, height: 20, borderRadius: 4),
          SizedBox(height: AppDesignTokens.space8),
          ShimmerBox(width: 200, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

/// A list of skeleton items
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.padding,
  });

  /// Creates a list of card skeletons
  factory SkeletonList.cards({
    Key? key,
    int itemCount = 5,
    bool showIcon = true,
    bool showSubtitle = true,
    bool showTrailing = true,
  }) {
    return SkeletonList(
      key: key,
      itemCount: itemCount,
      itemBuilder: (context, index) => CardSkeleton(
        showIcon: showIcon,
        showSubtitle: showSubtitle,
        showTrailing: showTrailing,
      ),
    );
  }

  /// Creates a list of list tile skeletons
  factory SkeletonList.tiles({
    Key? key,
    int itemCount = 5,
    bool showLeading = true,
    bool showTrailing = false,
  }) {
    return SkeletonList(
      key: key,
      itemCount: itemCount,
      itemBuilder: (context, index) => ListTileSkeleton(
        showLeading: showLeading,
        showTrailing: showTrailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// A grid of skeleton items
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final Widget Function(BuildContext, int)? itemBuilder;
  final EdgeInsetsGeometry? padding;

  const SkeletonGrid({
    super.key,
    this.itemCount = 4,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.itemBuilder,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? AppDesignTokens.pagePadding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: AppDesignTokens.space16,
        mainAxisSpacing: AppDesignTokens.space16,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder ?? (context, index) => const GridCardSkeleton(),
    );
  }
}

/// Full page loading skeleton with different layouts
class PageSkeleton extends StatelessWidget {
  final PageSkeletonType type;

  const PageSkeleton({
    super.key,
    this.type = PageSkeletonType.list,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case PageSkeletonType.list:
        return const SkeletonList(
          itemCount: 5,
          itemBuilder: _buildListCard,
        );
      case PageSkeletonType.grid:
        return const SkeletonGrid();
      case PageSkeletonType.detail:
        return const SingleChildScrollView(
          padding: AppDesignTokens.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeaderSkeleton(),
              SizedBox(height: AppDesignTokens.space24),
              StatCardSkeleton(),
              SizedBox(height: AppDesignTokens.space16),
              StatCardSkeleton(),
              SizedBox(height: AppDesignTokens.space24),
              ShimmerBox(width: 100, height: 16, borderRadius: 4),
              SizedBox(height: AppDesignTokens.space16),
              CardSkeleton(),
              CardSkeleton(),
              CardSkeleton(),
            ],
          ),
        );
    }
  }

  static Widget _buildListCard(BuildContext context, int index) {
    return const CardSkeleton();
  }
}

/// Types of page skeleton layouts
enum PageSkeletonType {
  list,
  grid,
  detail,
}
