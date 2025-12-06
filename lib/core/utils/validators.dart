class Validators {
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight cannot be empty';
    }
    final double? weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'Please enter a valid weight';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount cannot be empty';
    }
    final double? amount = double.tryParse(value);
    if (amount == null || amount < 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  static String? validatePIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN cannot be empty';
    }
    if (value.length != 4 || int.tryParse(value) == null) {
      return 'PIN must be a 4-digit number';
    }
    return null;
  }

  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height cannot be empty';
    }
    final double? height = double.tryParse(value);
    if (height == null || height <= 0) {
      return 'Please enter a valid height';
    }
    return null;
  }

  static String? validateGenericField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }
}
