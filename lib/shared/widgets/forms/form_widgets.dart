import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A smart text field that validates in real-time after the first interaction
/// and shows a success indicator when validation passes.
class SmartTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final bool showSuccessIndicator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  const SmartTextField({
    super.key,
    required this.controller,
    this.validator,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.showSuccessIndicator = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  State<SmartTextField> createState() => _SmartTextFieldState();
}

class _SmartTextFieldState extends State<SmartTextField> {
  bool _hasInteracted = false;
  String? _errorText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    // Validate when losing focus
    if (!_focusNode.hasFocus && _hasInteracted) {
      _validate(widget.controller.text);
    }
  }

  void _validate(String value) {
    if (_hasInteracted && widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  void _onChanged(String value) {
    if (_hasInteracted) {
      _validate(value);
    }
    widget.onChanged?.call(value);
  }

  void _onFieldSubmitted(String value) {
    if (!_hasInteracted) {
      setState(() => _hasInteracted = true);
    }
    _validate(value);
    widget.onFieldSubmitted?.call(value);
  }

  /// Call this to trigger validation manually (e.g., on form submit)
  bool validate() {
    setState(() => _hasInteracted = true);
    _validate(widget.controller.text);
    return _errorText == null;
  }

  Widget? _buildSuffixIcon() {
    // Show custom suffix icon if provided
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    // Show success indicator if enabled and validation passed
    if (widget.showSuccessIndicator &&
        _hasInteracted &&
        _errorText == null &&
        widget.controller.text.isNotEmpty) {
      return Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      validator: widget.validator,
      onChanged: _onChanged,
      onFieldSubmitted: _onFieldSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        errorText: _errorText,
        // Add visual feedback when focused
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// A form wrapper that warns users about unsaved changes before leaving
class UnsavedChangesWrapper extends StatefulWidget {
  final Widget child;
  final bool hasUnsavedChanges;
  final String? title;
  final String? message;

  const UnsavedChangesWrapper({
    super.key,
    required this.child,
    required this.hasUnsavedChanges,
    this.title,
    this.message,
  });

  @override
  State<UnsavedChangesWrapper> createState() => _UnsavedChangesWrapperState();
}

class _UnsavedChangesWrapperState extends State<UnsavedChangesWrapper> {
  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(widget.title ?? 'Discard Changes?'),
            content: Text(widget.message ??
                'You have unsaved changes. Are you sure you want to leave?',),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _showDiscardDialog()) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: widget.child,
    );
  }
}

/// A form mixin that provides change tracking functionality
mixin FormChangeTracker<T extends StatefulWidget> on State<T> {
  bool _hasChanges = false;

  bool get hasUnsavedChanges => _hasChanges;

  void markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void markAsSaved() {
    if (_hasChanges) {
      setState(() => _hasChanges = false);
    }
  }
}

/// Currency input formatter that allows decimal numbers with 2 decimal places
class CurrencyInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final bool allowNegative;

  CurrencyInputFormatter({
    this.decimalPlaces = 2,
    this.allowNegative = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Build pattern based on options
    final pattern = allowNegative
        ? r'^-?\d*\.?\d{0,' + decimalPlaces.toString() + r'}$'
        : r'^\d*\.?\d{0,' + decimalPlaces.toString() + r'}$';

    final regex = RegExp(pattern);

    if (regex.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

/// Phone number input formatter
class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to reasonable phone number length
    if (digitsOnly.length > 15) {
      return oldValue;
    }

    // Format with spaces for readability (e.g., "010 1234 5678")
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Common validators for form fields
class FormValidators {
  FormValidators._();

  /// Validates that the field is not empty
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates phone number format
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates minimum length
  static String? Function(String?) minLength(int length, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.length < length) {
        final field = fieldName ?? 'This field';
        return '$field must be at least $length characters';
      }
      return null;
    };
  }

  /// Validates maximum length
  static String? Function(String?) maxLength(int length, {String? fieldName}) {
    return (String? value) {
      if (value != null && value.length > length) {
        final field = fieldName ?? 'This field';
        return '$field must be at most $length characters';
      }
      return null;
    };
  }

  /// Validates that value is a positive number
  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number <= 0) {
      return 'Please enter a positive number';
    }
    return null;
  }

  /// Validates that value is a valid amount (for currency)
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid amount';
    }
    if (number < 0) {
      return 'Amount cannot be negative';
    }
    return null;
  }

  /// Combines multiple validators
  static String? Function(String?) combine(
      List<String? Function(String?)> validators,) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
