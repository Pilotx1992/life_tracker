import 'package:flutter/material.dart';

/// App color constants for light and dark themes
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Light Theme Colors
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  static const Color secondary = Color(0xFF4CAF50); // Green
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);

  static const Color accent = Color(0xFFFF9800); // Orange
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);

  static const Color inputBackground = Color(0xFFFAFAFA);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color dividerDark = Color(0xFF2C2C2C);
  static const Color borderDark = Color(0xFF424242);

  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF808080);
  static const Color textDisabledDark = Color(0xFF606060);

  static const Color inputBackgroundDark = Color(0xFF2C2C2C);

  // Module Specific Colors
  static const Color healthPrimary = Color(0xFFE91E63); // Pink
  static const Color financePrimary = Color(0xFF4CAF50); // Green
  static const Color notesPrimary = Color(0xFFFFC107); // Amber
  static const Color remindersPrimary = Color(0xFF9C27B0); // Purple

  // Note Colors
  static const Color noteBlue = Color(0xFF2196F3);
  static const Color noteGreen = Color(0xFF4CAF50);
  static const Color noteYellow = Color(0xFFFFC107);
  static const Color noteRed = Color(0xFFF44336);
  static const Color notePurple = Color(0xFF9C27B0);
  static const Color noteGrey = Color(0xFF9E9E9E);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFFFF5722),
    'transport': Color(0xFF2196F3),
    'entertainment': Color(0xFF9C27B0),
    'healthcare': Color(0xFFE91E63),
    'housing': Color(0xFF795548),
    'shopping': Color(0xFFFFC107),
    'bills': Color(0xFF607D8B),
    'education': Color(0xFF00BCD4),
    'gifts': Color(0xFFFF9800),
    'fuel': Color(0xFFFF9800),
    'car_service': Color(0xFF78909C),
    'other': Color(0xFF9E9E9E),
  };

  // BMI Category Colors
  static const Color bmiUnderweight = Color(0xFF2196F3);
  static const Color bmiNormal = Color(0xFF4CAF50);
  static const Color bmiOverweight = Color(0xFFFFC107);
  static const Color bmiObese = Color(0xFFF44336);

  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusInactive = Color(0xFF9E9E9E);
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusOverdue = Color(0xFFF44336);
  static const Color statusPaid = Color(0xFF4CAF50);

  // Finance Semantic Colors (for consistent income/expense theming)
  static const Color income = Color(0xFF4CAF50); // Green - money in
  static const Color incomeLight = Color(0xFFE8F5E9);
  static const Color expense = Color(0xFFF44336); // Red - money out
  static const Color expenseLight = Color(0xFFFFEBEE);
  static const Color iOwe = Color(0xFFF44336); // Debt I owe
  static const Color owedToMe = Color(0xFF4CAF50); // Debt owed to me
}
