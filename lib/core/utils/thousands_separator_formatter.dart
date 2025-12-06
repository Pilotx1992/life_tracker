import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// TextInputFormatter that formats numbers with thousand separators
/// Example: 10000 -> 10,000
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final int decimalDigits;
  final String decimalSeparator;
  final String thousandSeparator;

  ThousandsSeparatorInputFormatter({
    this.decimalDigits = 2,
    this.decimalSeparator = '.',
    this.thousandSeparator = ',',
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If empty, return as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-numeric characters except decimal point
    String newText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle multiple decimal points - keep only first one
    final parts = newText.split('.');
    if (parts.length > 2) {
      newText = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Split into integer and decimal parts
    String integerPart;
    String decimalPart = '';

    if (newText.contains('.')) {
      final splitParts = newText.split('.');
      integerPart = splitParts[0];
      decimalPart = splitParts.length > 1 ? splitParts[1] : '';
      // Limit decimal digits
      if (decimalPart.length > decimalDigits) {
        decimalPart = decimalPart.substring(0, decimalDigits);
      }
    } else {
      integerPart = newText;
    }

    // Remove leading zeros from integer part (except if it's just "0")
    if (integerPart.length > 1 && integerPart.startsWith('0')) {
      integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');
      if (integerPart.isEmpty) integerPart = '0';
    }

    // Format integer part with thousand separators
    if (integerPart.isNotEmpty) {
      final number = int.tryParse(integerPart) ?? 0;
      final formatter = NumberFormat('#,###');
      integerPart = formatter.format(number);
    }

    // Combine integer and decimal parts
    String formattedText;
    if (newText.contains('.')) {
      formattedText = '$integerPart.$decimalPart';
    } else {
      formattedText = integerPart;
    }

    // Calculate new cursor position
    // The cursor should stay at the end for most cases
    int newCursorPosition = formattedText.length;

    // If user was typing in the middle, try to preserve relative position
    if (oldValue.selection.baseOffset < oldValue.text.length) {
      // Count how many digits were before cursor in old value
      final oldTextBeforeCursor =
          oldValue.text.substring(0, oldValue.selection.baseOffset);
      final digitsBeforeCursor =
          oldTextBeforeCursor.replaceAll(RegExp(r'[^\d.]'), '').length;

      // Find position in new value that has same number of digits before it
      int digitCount = 0;
      for (int i = 0; i < formattedText.length; i++) {
        if (RegExp(r'[\d.]').hasMatch(formattedText[i])) {
          digitCount++;
        }
        if (digitCount >= digitsBeforeCursor) {
          newCursorPosition = i + 1;
          break;
        }
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
