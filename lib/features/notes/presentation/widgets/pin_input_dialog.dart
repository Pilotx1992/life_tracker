import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_tracker/core/services/feedback_service.dart';

class PINInputDialog extends StatefulWidget {
  final String title;
  final String? message;
  final bool isSetup; // If true, requires confirmation

  const PINInputDialog({
    super.key,
    required this.title,
    this.message,
    this.isSetup = false,
  });

  @override
  State<PINInputDialog> createState() => _PINInputDialogState();
}

class _PINInputDialogState extends State<PINInputDialog> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  String? _confirmPIN;

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

    if (widget.isSetup) {
      if (_confirmPIN == null) {
        // First entry - ask for confirmation
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
          Navigator.of(context).pop(pin);
        } else {
          // PINs don't match
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
      Navigator.of(context).pop(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
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
