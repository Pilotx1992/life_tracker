import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/notes/services/note_encryption_service.dart';

class PINInputDialog extends StatefulWidget {
  final String title;
  final String? message;
  final bool isSetup; // If true, requires confirmation
  final bool showBiometric; // Whether to show biometric option

  const PINInputDialog({
    super.key,
    required this.title,
    this.message,
    this.isSetup = false,
    this.showBiometric = true, // Default to showing if available
  });

  @override
  State<PINInputDialog> createState() => _PINInputDialogState();
}

class _PINInputDialogState extends State<PINInputDialog> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final _encryptionService = NoteEncryptionService();
  String? _confirmPIN;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.showBiometric && !widget.isSetup) {
      _checkBiometric();
    }
  }

  Future<void> _checkBiometric() async {
    final available = await _encryptionService.isBiometricAvailable();
    final enabled = await _encryptionService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
      // Auto-trigger biometric if available and enabled
      if (available && enabled) {
        _authenticateWithBiometric();
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final pin = await _encryptionService.authenticateWithBiometric(
      reason: 'Authenticate to unlock note',
    );
    if (pin != null && mounted) {
      Navigator.of(context).pop(pin);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    // Check if all digits are filled
    if (index == 3 && value.isNotEmpty) {
      _checkPIN();
    }
  }

  void _checkPIN() {
    final pin = _controllers.map((c) => c.text).join();

    if (kDebugMode) {
      debugPrint('🔢 PIN entered: ${pin.length} digits, isSetup: ${widget.isSetup}');
    }

    if (widget.isSetup) {
      if (_confirmPIN == null) {
        // First entry - ask for confirmation
        if (kDebugMode) {
          debugPrint('📝 First PIN entry, asking for confirmation');
        }
        setState(() {
          _confirmPIN = pin;
        });
        // Clear fields
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        // Confirmation entry
        if (pin == _confirmPIN) {
          if (kDebugMode) {
            debugPrint('✅ PINs match, returning: $pin');
          }
          Navigator.of(context).pop(pin);
        } else {
          // PINs don't match
          if (kDebugMode) {
            debugPrint('❌ PINs do not match');
          }
          FeedbackService.showError(
            context,
            'PINs do not match. Please try again.',
          );
          setState(() {
            _confirmPIN = null;
          });
          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('✅ Verification mode, returning: $pin');
      }
      Navigator.of(context).pop(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBiometricButton = _biometricAvailable && 
                                 _biometricEnabled && 
                                 !widget.isSetup;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.message != null) ...[
            Text(widget.message!),
            const SizedBox(height: 16),
          ],
          if (widget.isSetup && _confirmPIN != null)
            Text(
              'Confirm PIN',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 50,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  obscureText: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _onDigitChanged(index, value),
                ),
              );
            }),
          ),
          // Biometric button
          if (showBiometricButton) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Or use biometric',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 12),
            IconButton.filled(
              onPressed: _authenticateWithBiometric,
              icon: const Icon(Icons.fingerprint, size: 32),
              iconSize: 48,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
