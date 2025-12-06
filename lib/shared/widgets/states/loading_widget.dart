import 'package:flutter/material.dart';

/// Loading state widget with optional shimmer effect
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final bool useShimmer;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40,
    this.useShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useShimmer) {
      return const ShimmerLoading();
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading effect widget
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use theme colors for shimmer effect
    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHighest;
    final highlightColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surfaceContainerHigh;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment(_animation.value - 1, 0),
                    end: Alignment(_animation.value, 0),
                    colors: [
                      baseColor,
                      highlightColor,
                      baseColor,
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
