import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

/// App theme configuration for light and dark modes
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: _buildAppBarTheme(Brightness.light),
      cardTheme: _buildCardTheme(),
      floatingActionButtonTheme: _buildFABTheme(),
      inputDecorationTheme: _buildInputTheme(Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 16,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        error: AppColors.errorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      cardTheme: _buildCardTheme(),
      floatingActionButtonTheme: _buildFABTheme(),
      inputDecorationTheme: _buildInputTheme(Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 16,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTextTheme = GoogleFonts.cairoTextTheme();
    final color = brightness == Brightness.light
        ? AppColors.textPrimary
        : AppColors.textPrimaryDark;

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: brightness == Brightness.light
            ? AppColors.textSecondary
            : AppColors.textSecondaryDark,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: brightness == Brightness.light
          ? AppColors.surface
          : AppColors.surfaceDark,
      foregroundColor: brightness == Brightness.light
          ? AppColors.textPrimary
          : AppColors.textPrimaryDark,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.light
            ? AppColors.textPrimary
            : AppColors.textPrimaryDark,
      ),
    );
  }

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      elevation: AppDesignTokens.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.space16,
        vertical: AppDesignTokens.space8,
      ),
    );
  }

  static FloatingActionButtonThemeData _buildFABTheme() {
    return FloatingActionButtonThemeData(
      elevation: AppDesignTokens.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(Brightness brightness) {
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.light
          ? AppColors.inputBackground
          : AppColors.inputBackgroundDark,
      // Lighter hint text color for better UX
      hintStyle: TextStyle(
        color: brightness == Brightness.light
            ? AppColors.textHint
            : AppColors.textHintDark,
        fontWeight: FontWeight.normal,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? AppColors.border
              : AppColors.borderDark,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? AppColors.border
              : AppColors.borderDark,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.space16,
        vertical: AppDesignTokens.space16,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: AppDesignTokens.elevationSmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.space24,
          vertical: AppDesignTokens.space12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.space24,
          vertical: AppDesignTokens.space12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesignTokens.space16,
          vertical: AppDesignTokens.space8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.space8),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
