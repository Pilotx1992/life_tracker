import 'package:flutter/material.dart';
import 'package:life_tracker/core/services/app_lock_service.dart';
import 'package:life_tracker/features/settings/presentation/widgets/pin_input_widget.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback? onUnlock;

  const LockScreen({super.key, this.onUnlock});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AppLockService _lockService = AppLockService.instance;
  bool _isAuthenticating = false;
  String? _errorMessage;
  int _remainingLockoutTime = 0;

  @override
  void initState() {
    super.initState();
    _checkLockout();
    _checkBiometricAvailability();
  }

  Future<void> _checkLockout() async {
    final remaining = await _lockService.getRemainingLockoutTime();
    if (remaining > 0) {
      setState(() {
        _remainingLockoutTime = remaining;
      });
      _updateLockoutTimer();
    }
  }

  void _updateLockoutTimer() {
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      final remaining = await _lockService.getRemainingLockoutTime();
      if (remaining > 0) {
        setState(() {
          _remainingLockoutTime = remaining;
        });
        _updateLockoutTimer();
      } else {
        setState(() {
          _remainingLockoutTime = 0;
        });
      }
    });
  }

  Future<void> _checkBiometricAvailability() async {
    final lockMethod = await _lockService.getLockMethod();
    if (lockMethod == 'biometric' || lockMethod == 'both') {
      final isAvailable = await _lockService.isBiometricAvailable();
      if (isAvailable && _remainingLockoutTime == 0) {
        // Auto-trigger biometric if available
        Future.delayed(const Duration(milliseconds: 500), () {
          _authenticateWithBiometric();
        });
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating || _remainingLockoutTime > 0) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final authenticated = await _lockService.authenticateWithBiometric(
      reason: 'Please authenticate to unlock the app',
    );

    if (authenticated) {
      widget.onUnlock?.call();
    } else {
      setState(() {
        _errorMessage = 'Biometric authentication failed';
        _isAuthenticating = false;
      });
      await _checkLockout();
    }
  }

  Future<void> _onPinEntered(String pin) async {
    if (_isAuthenticating || _remainingLockoutTime > 0) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final isValid = await _lockService.verifyPin(pin);

    if (isValid) {
      widget.onUnlock?.call();
    } else {
      final remaining = await _lockService.getRemainingLockoutTime();
      final failedAttempts = await _lockService.getFailedAttempts();

      setState(() {
        _isAuthenticating = false;
        if (remaining > 0) {
          _remainingLockoutTime = remaining;
          _errorMessage =
              'Too many failed attempts. Please wait ${_formatTime(remaining)}.';
          _updateLockoutTimer();
        } else {
          const maxAttempts = 5;
          _errorMessage =
              'Incorrect PIN. ${maxAttempts - failedAttempts} attempts remaining.';
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final lockMethod = _lockService.getLockMethod();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 80,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 24),
                Text(
                  'App Locked',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your PIN or use biometric authentication',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_remainingLockoutTime > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_clock,
                          color: colorScheme.error,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Too many failed attempts',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please wait ${_formatTime(_remainingLockoutTime)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ] else ...[
                  FutureBuilder<String?>(
                    future: lockMethod,
                    builder: (context, snapshot) {
                      final method = snapshot.data;
                      if (method == 'pin' || method == 'both') {
                        return PinInputWidget(
                          onPinEntered: _onPinEntered,
                          enabled: !_isAuthenticating,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<String?>(
                    future: lockMethod,
                    builder: (context, snapshot) {
                      final method = snapshot.data;
                      if (method == 'biometric' || method == 'both') {
                        return FutureBuilder<bool>(
                          future: _lockService.isBiometricAvailable(),
                          builder: (context, snapshot) {
                            if (snapshot.data == true) {
                              return ElevatedButton.icon(
                                onPressed: _isAuthenticating
                                    ? null
                                    : _authenticateWithBiometric,
                                icon: const Icon(Icons.fingerprint),
                                label: const Text('Use Biometric'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
                if (_errorMessage != null && _remainingLockoutTime == 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
