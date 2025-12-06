import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An animated card that provides visual feedback on tap
/// with scale effect and optional ripple
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double elevation;
  final Duration animationDuration;
  final double scaleValue;
  final bool enableHaptics;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.elevation = 0,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleValue = 0.98,
    this.enableHaptics = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + 4,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onLongPress() {
    _controller.reverse();
    if (widget.onLongPress != null) {
      if (widget.enableHaptics) {
        HapticFeedback.mediumImpact();
      }
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(12);
    final effectiveBackgroundColor = widget.backgroundColor ?? theme.cardColor;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPress: widget.onLongPress != null ? _onLongPress : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                color: effectiveBackgroundColor,
                elevation: _elevationAnimation.value,
                borderRadius: effectiveBorderRadius,
                child: ClipRRect(
                  borderRadius: effectiveBorderRadius,
                  child: Container(
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// An animated FAB with bounce effect when pressed
class AnimatedFab extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;
  final double? elevation;

  const AnimatedFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
    this.elevation,
  });

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    _controller.reverse();
    if (widget.onPressed != null) {
      HapticFeedback.lightImpact();
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
        scale: _scaleAnimation,
        child: FloatingActionButton(
          onPressed: null, // We handle tap ourselves
          tooltip: widget.tooltip,
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          mini: widget.mini,
          elevation: widget.elevation,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Animated icon button with scale effect
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
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
    _controller.reverse();
    if (widget.onPressed != null) {
      HapticFeedback.selectionClick();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = widget.color ?? theme.iconTheme.color;

    Widget iconWidget = Padding(
      padding: widget.padding,
      child: Icon(
        widget.icon,
        size: widget.size,
        color: iconColor,
      ),
    );

    if (widget.backgroundColor != null) {
      iconWidget = Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: iconWidget,
      );
    }

    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: iconWidget,
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
