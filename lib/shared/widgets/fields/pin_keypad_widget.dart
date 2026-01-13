import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom PIN keypad widget with animations
/// Features: Circular buttons, shake animation, haptic feedback, biometric button
class PinKeypadWidget extends StatefulWidget {
  /// Title text above PIN dots
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Callback when 4 digits are entered
  final Function(String) onPinComplete;

  /// Optional callback on each digit change
  final Function(String)? onPinChanged;

  /// Error message to display (triggers shake animation)
  final String? errorMessage;

  /// Loading state (disables input)
  final bool isLoading;

  /// Show biometric button in keypad
  final bool showBiometricButton;

  /// Callback for biometric button tap
  final VoidCallback? onBiometricTap;

  /// PIN strength level (0-3) for indicator
  final int? strengthLevel;

  /// PIN strength description
  final String? strengthDescription;

  const PinKeypadWidget({
    super.key,
    this.title = 'Enter PIN',
    this.subtitle,
    required this.onPinComplete,
    this.onPinChanged,
    this.errorMessage,
    this.isLoading = false,
    this.showBiometricButton = false,
    this.onBiometricTap,
    this.strengthLevel,
    this.strengthDescription,
  });

  @override
  State<PinKeypadWidget> createState() => PinKeypadWidgetState();
}

class PinKeypadWidgetState extends State<PinKeypadWidget>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PinKeypadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger shake animation when error message appears
    if (widget.errorMessage != null && oldWidget.errorMessage == null) {
      shake();
    }
  }

  void _onKeyPress(String digit) {
    if (_pin.length < 4 && !widget.isLoading) {
      HapticFeedback.selectionClick();
      setState(() {
        _pin += digit;
      });
      widget.onPinChanged?.call(_pin);

      if (_pin.length == 4) {
        // Auto-submit when 4 digits entered
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_pin.length == 4) {
            widget.onPinComplete(_pin);
          }
        });
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty && !widget.isLoading) {
      HapticFeedback.selectionClick();
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
      widget.onPinChanged?.call(_pin);
    }
  }

  /// Clear the PIN input
  void clearPin() {
    setState(() {
      _pin = '';
    });
  }

  /// Trigger shake animation (for errors)
  void shake() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0);
  }

  /// Trigger success haptic feedback
  void triggerSuccessHaptic() {
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;
    final hasError = widget.errorMessage != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          widget.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 24),

        // PIN Dots with shake animation
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < _pin.length;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled
                      ? (hasError ? errorColor : primaryColor)
                      : Colors.transparent,
                  border: Border.all(
                    color: hasError ? errorColor : primaryColor,
                    width: 2,
                  ),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: (hasError ? errorColor : primaryColor)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ),

        // PIN Strength Indicator (only during setup)
        if (widget.strengthDescription != null && _pin.length == 4) ...[
          const SizedBox(height: 12),
          _buildStrengthIndicator(theme),
        ],

        // Error Message
        const SizedBox(height: 12),
        SizedBox(
          height: 20,
          child: widget.errorMessage != null
              ? Text(
                  widget.errorMessage!,
                  style: TextStyle(
                    color: errorColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )
              : null,
        ),

        const SizedBox(height: 24),

        // Numeric Keypad
        _buildKeypad(context),
      ],
    );
  }

  Widget _buildStrengthIndicator(ThemeData theme) {
    final level = widget.strengthLevel ?? 0;
    Color color;
    switch (level) {
      case 0:
        color = Colors.red;
        break;
      case 1:
        color = Colors.orange;
        break;
      case 2:
        color = Colors.yellow.shade700;
        break;
      default:
        color = Colors.green;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          level >= 2 ? Icons.check_circle : Icons.warning,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          widget.strengthDescription ?? '',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Row 1: 1 2 3
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKey(context, '1'),
              const SizedBox(width: 20),
              _buildKey(context, '2'),
              const SizedBox(width: 20),
              _buildKey(context, '3'),
            ],
          ),
          const SizedBox(height: 16),
          // Row 2: 4 5 6
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKey(context, '4'),
              const SizedBox(width: 20),
              _buildKey(context, '5'),
              const SizedBox(width: 20),
              _buildKey(context, '6'),
            ],
          ),
          const SizedBox(height: 16),
          // Row 3: 7 8 9
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildKey(context, '7'),
              const SizedBox(width: 20),
              _buildKey(context, '8'),
              const SizedBox(width: 20),
              _buildKey(context, '9'),
            ],
          ),
          const SizedBox(height: 16),
          // Row 4: [biometric/empty] 0 [delete]
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show biometric button or empty space
              widget.showBiometricButton
                  ? _buildBiometricKey(context)
                  : const SizedBox(width: 64, height: 64),
              const SizedBox(width: 20),
              _buildKey(context, '0'),
              const SizedBox(width: 20),
              _buildDeleteKey(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(BuildContext context, String digit) {
    final theme = Theme.of(context);
    final isDisabled = widget.isLoading;

    return Material(
      color: isDisabled
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surfaceContainerHighest,
      elevation: isDisabled ? 0 : 2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isDisabled ? null : () => _onKeyPress(digit),
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          child: Text(
            digit,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDisabled
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.isLoading || _pin.isEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : _onDelete,
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: isDisabled
                ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricKey(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : widget.onBiometricTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.95, end: 1.05),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            onEnd: () {
              // Restart animation
              if (mounted) {
                setState(() {});
              }
            },
            child: Icon(
              Icons.fingerprint,
              size: 32,
              color: isDisabled
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                  : theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
