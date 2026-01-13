import 'package:flutter/material.dart';
import 'package:life_tracker/core/services/app_lock_service.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/shared/widgets/fields/pin_keypad_widget.dart';

class AppLockSetupScreen extends StatefulWidget {
  const AppLockSetupScreen({super.key});

  @override
  State<AppLockSetupScreen> createState() => _AppLockSetupScreenState();
}

class _AppLockSetupScreenState extends State<AppLockSetupScreen> {
  final AppLockService _lockService = AppLockService.instance;
  final GlobalKey<PinKeypadWidgetState> _pinKeypadKey = GlobalKey();

  int _currentStep =
      0; // 0: choose method, 1: setup PIN, 2: confirm PIN, 3: test biometric, 4: timeout
  String? _selectedMethod; // 'pin', 'biometric', 'both'
  String? _firstPin;
  String? _errorMessage;
  int? _pinStrengthLevel;
  String? _pinStrengthDescription;
  bool _isBiometricAvailable = false;
  int _selectedTimeout = 300; // 5 minutes in seconds
  final List<int> _timeoutOptions = [
    0,
    60,
    300,
    600,
    1800,
    3600,
  ]; // 0, 1min, 5min, 10min, 30min, 1hr

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadCurrentSettings();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _lockService.isBiometricAvailable();
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  Future<void> _loadCurrentSettings() async {
    final method = await _lockService.getLockMethod();
    final timeout = await _lockService.getAutoLockTimeout();

    setState(() {
      _selectedMethod = method;
      _selectedTimeout = timeout;
    });
  }

  void _selectMethod(String method) {
    setState(() {
      _selectedMethod = method;
      if (method == 'pin') {
        _currentStep = 1; // Go to PIN setup
      } else if (method == 'biometric') {
        if (_isBiometricAvailable) {
          _currentStep = 3; // Go to biometric test
        } else {
          FeedbackService.showWarning(
            context,
            'Biometric authentication is not available on this device',
          );
        }
      } else if (method == 'both') {
        _currentStep = 1; // Start with PIN setup
      }
    });
  }

  void _onPinEntered(String pin) {
    if (_currentStep == 1) {
      // First PIN entry - check strength
      final isWeak = _lockService.isPinWeak(pin);
      if (isWeak) {
        setState(() {
          _errorMessage = 'Weak PIN! Try a stronger combination.';
          _pinStrengthLevel = _lockService.getPinStrengthLevel(pin);
          _pinStrengthDescription = _lockService.getPinStrengthDescription(pin);
        });
        _pinKeypadKey.currentState?.shake();
        _pinKeypadKey.currentState?.clearPin();
        return;
      }
      
      setState(() {
        _firstPin = pin;
        _errorMessage = null;
        _pinStrengthLevel = null;
        _pinStrengthDescription = null;
        _currentStep = 2; // Go to confirmation
      });
    } else if (_currentStep == 2) {
      // PIN confirmation
      if (pin == _firstPin) {
        _savePin(pin);
      } else {
        setState(() {
          _errorMessage = 'PINs do not match. Try again.';
        });
        _pinKeypadKey.currentState?.shake();
        _pinKeypadKey.currentState?.clearPin();
        
        // After a moment, reset to first entry
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _firstPin = null;
              _errorMessage = null;
              _currentStep = 1;
            });
          }
        });
      }
    }
  }

  void _onPinChanged(String pin) {
    if (_currentStep == 1 && pin.length == 4) {
      // Show strength indicator during first entry
      setState(() {
        _pinStrengthLevel = _lockService.getPinStrengthLevel(pin);
        _pinStrengthDescription = _lockService.getPinStrengthDescription(pin);
      });
    }
  }

  Future<void> _savePin(String pin) async {
    final success = await _lockService.setupPin(pin);
    if (!mounted) return;
    if (success) {
      if (_selectedMethod == 'both') {
        // If both, test biometric next
        setState(() {
          _currentStep = 3;
        });
      } else {
        // If PIN only, go to timeout setting
        setState(() {
          _currentStep = 4;
        });
      }
    } else {
      FeedbackService.showError(
        context,
        'Failed to set up PIN. Please try again.',
      );
    }
  }

  Future<void> _testBiometric() async {
    final authenticated = await _lockService.authenticateWithBiometric(
      reason: 'Test biometric authentication',
    );
    if (!mounted) return;

    if (authenticated) {
      if (_selectedMethod == 'both') {
        // Set lock method to both
        await _lockService.setLockMethod('both');
      } else {
        await _lockService.setLockMethod('biometric');
      }

      setState(() {
        _currentStep = 4; // Go to timeout setting
      });
    } else {
      FeedbackService.showError(
        context,
        'Biometric authentication failed. Please try again.',
      );
    }
  }

  Future<void> _saveTimeout() async {
    await _lockService.setAutoLockTimeout(_selectedTimeout);

    if (mounted) {
      FeedbackService.showSuccess(
        context,
        'App lock has been set up successfully!',
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _disableLock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable App Lock?'),
        content: const Text('Are you sure you want to disable app lock?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _lockService.disableLock();
      if (success && mounted) {
        FeedbackService.showSuccess(context, 'App lock has been disabled.');
        Navigator.of(context).pop(true);
      }
    }
  }

  String _formatTimeout(int seconds) {
    if (seconds == 0) return 'Never';
    if (seconds < 60) return '$seconds seconds';
    if (seconds < 3600) return '${seconds ~/ 60} minutes';
    return '${seconds ~/ 3600} hour${seconds ~/ 3600 > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final isLockEnabled =
        _selectedMethod != null && _selectedMethod!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Lock'),
        actions: [
          if (isLockEnabled)
            TextButton(
              onPressed: _disableLock,
              child: const Text('Disable'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentStep == 0) ...[
              const Text(
                'Choose Lock Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildMethodOption('pin', 'PIN', Icons.pin, 'Use a 4-digit PIN'),
              const SizedBox(height: 12),
              if (_isBiometricAvailable) ...[
                _buildMethodOption(
                  'biometric',
                  'Biometric',
                  Icons.fingerprint,
                  'Use fingerprint or face recognition',
                ),
                const SizedBox(height: 12),
                _buildMethodOption(
                  'both',
                  'Both',
                  Icons.security,
                  'Use both PIN and biometric',
                ),
              ],
            ] else if (_currentStep == 1) ...[
              Center(
                child: PinKeypadWidget(
                  key: _pinKeypadKey,
                  title: 'Create PIN',
                  subtitle: 'Choose a strong 4-digit PIN',
                  onPinComplete: _onPinEntered,
                  onPinChanged: _onPinChanged,
                  errorMessage: _errorMessage,
                  strengthLevel: _pinStrengthLevel,
                  strengthDescription: _pinStrengthDescription,
                ),
              ),
            ] else if (_currentStep == 2) ...[
              Center(
                child: PinKeypadWidget(
                  key: _pinKeypadKey,
                  title: 'Confirm PIN',
                  subtitle: 'Re-enter your PIN to confirm',
                  onPinComplete: _onPinEntered,
                  errorMessage: _errorMessage,
                ),
              ),
            ] else if (_currentStep == 3) ...[
              const Text(
                'Test Biometric',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('Please authenticate using your biometric'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _testBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Test Biometric'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ] else if (_currentStep == 4) ...[
              const Text(
                'Auto-Lock Timeout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Lock the app automatically after inactivity'),
              const SizedBox(height: 24),
              ...[
                RadioGroup<int>(
                  groupValue: _selectedTimeout,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeout = value!;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _timeoutOptions.map((timeout) {
                      return RadioListTile<int>(
                        title: Text(_formatTimeout(timeout)),
                        value: timeout,
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTimeout,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Save Settings'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(
    String method,
    String title,
    IconData icon,
    String description,
  ) {
    final isSelected = _selectedMethod == method;

    return Card(
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: () => _selectMethod(method),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
