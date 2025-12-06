import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputWidget extends StatefulWidget {
  final Function(String) onPinEntered;
  final bool enabled;

  const PinInputWidget({
    super.key,
    required this.onPinEntered,
    this.enabled = true,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enabled) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onPinChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all fields are filled
    final pin = _pinControllers.map((c) => c.text).join();
    if (pin.length == 4) {
      widget.onPinEntered(pin);
      // Clear fields after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        for (var controller in _pinControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 60,
          child: TextField(
            controller: _pinControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            obscureText: true,
            textAlign: TextAlign.center,
            enabled: widget.enabled,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              counterText: '',
            ),
            onChanged: (value) => _onPinChanged(value, index),
          ),
        );
      }),
    );
  }
}
