import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A button that scales down slightly when pressed for tactile feedback
class AnimatedPressButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double scaleValue;
  final Duration duration;
  final bool enableHaptics;

  const AnimatedPressButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.scaleValue = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.enableHaptics = true,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// Animated list item that fades and slides in when it appears
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration baseDuration;
  final Duration staggerDelay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    final delay = staggerDelay.inMilliseconds * index;
    final duration = baseDuration.inMilliseconds + delay;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Success animation with bouncy checkmark
class SuccessAnimation extends StatelessWidget {
  final double size;
  final Color? color;

  const SuccessAnimation({
    super.key,
    this.size = 64,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final successColor = color ?? Theme.of(context).colorScheme.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: successColor,
              size: size * 0.5,
            ),
          ),
        );
      },
    );
  }
}

/// Error animation with shake effect
class ErrorAnimation extends StatefulWidget {
  final double size;
  final Color? color;

  const ErrorAnimation({
    super.key,
    this.size = 64,
    this.color,
  });

  @override
  State<ErrorAnimation> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = widget.color ?? Theme.of(context).colorScheme.error;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: errorColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: errorColor,
              size: widget.size * 0.5,
            ),
          ),
        );
      },
    );
  }
}

/// Fade-in widget when first built
class FadeIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        // Apply delay by keeping opacity at 0 for the delay portion
        final delayRatio =
            delay.inMilliseconds / (duration + delay).inMilliseconds;
        final adjustedValue =
            ((value - delayRatio) / (1 - delayRatio)).clamp(0.0, 1.0);

        return Opacity(
          opacity: adjustedValue,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Slide-in widget from a direction
class SlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;
  final Curve curve;

  const SlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.beginOffset = const Offset(0, 30),
    this.curve = Curves.easeOutCubic,
  });

  /// Factory constructor for sliding from bottom
  factory SlideIn.fromBottom({
    Key? key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    double distance = 30,
  }) {
    return SlideIn(
      key: key,
      duration: duration,
      beginOffset: Offset(0, distance),
      child: child,
    );
  }

  /// Factory constructor for sliding from right
  factory SlideIn.fromRight({
    Key? key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    double distance = 30,
  }) {
    return SlideIn(
      key: key,
      duration: duration,
      beginOffset: Offset(distance, 0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            beginOffset.dx * (1 - value),
            beginOffset.dy * (1 - value),
          ),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Bounce animation for emphasis (like a notification badge)
class BounceIn extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const BounceIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Pulse animation for attention-grabbing elements
class Pulse extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const Pulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 1.0,
    this.maxScale = 1.05,
  });

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
