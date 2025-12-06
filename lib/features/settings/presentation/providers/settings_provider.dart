import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings keys
class SettingsKeys {
  static const String themeMode = 'theme_mode'; // 'light', 'dark', 'system'
  static const String language = 'language'; // 'en', 'ar'
  static const String defaultCurrency =
      'default_currency'; // e.g., 'USD', 'EUR'
  static const String dateFormat =
      'date_format'; // e.g., 'MM/dd/yyyy', 'dd/MM/yyyy'
  static const String timeFormat = 'time_format'; // '12h', '24h'
  static const String notificationsEnabled = 'notifications_enabled';
  static const String notificationSound = 'notification_sound';
  static const String notificationVibration = 'notification_vibration';
}

/// Settings provider that manages app preferences
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings.defaultSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeStr = prefs.getString(SettingsKeys.themeMode) ?? 'system';
    final themeMode = _parseThemeMode(themeModeStr);

    final language = prefs.getString(SettingsKeys.language) ?? 'en';
    final defaultCurrency =
        prefs.getString(SettingsKeys.defaultCurrency) ?? 'USD';
    final dateFormat = prefs.getString(SettingsKeys.dateFormat) ?? 'MM/dd/yyyy';
    final timeFormat = prefs.getString(SettingsKeys.timeFormat) ?? '12h';
    final notificationsEnabled =
        prefs.getBool(SettingsKeys.notificationsEnabled) ?? true;
    final notificationSound =
        prefs.getBool(SettingsKeys.notificationSound) ?? true;
    final notificationVibration =
        prefs.getBool(SettingsKeys.notificationVibration) ?? true;

    state = AppSettings(
      themeMode: themeMode,
      language: language,
      defaultCurrency: defaultCurrency,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      notificationsEnabled: notificationsEnabled,
      notificationSound: notificationSound,
      notificationVibration: notificationVibration,
    );
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.themeMode, _themeModeToString(mode));
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.language, language);
    state = state.copyWith(language: language);
  }

  Future<void> setDefaultCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.defaultCurrency, currency);
    state = state.copyWith(defaultCurrency: currency);
  }

  Future<void> setDateFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.dateFormat, format);
    state = state.copyWith(dateFormat: format);
  }

  Future<void> setTimeFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.timeFormat, format);
    state = state.copyWith(timeFormat: format);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SettingsKeys.notificationsEnabled, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> setNotificationSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SettingsKeys.notificationSound, enabled);
    state = state.copyWith(notificationSound: enabled);
  }

  Future<void> setNotificationVibration(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SettingsKeys.notificationVibration, enabled);
    state = state.copyWith(notificationVibration: enabled);
  }
}

/// App settings model
class AppSettings {
  final ThemeMode themeMode;
  final String language;
  final String defaultCurrency;
  final String dateFormat;
  final String timeFormat;
  final bool notificationsEnabled;
  final bool notificationSound;
  final bool notificationVibration;

  const AppSettings({
    required this.themeMode,
    required this.language,
    required this.defaultCurrency,
    required this.dateFormat,
    required this.timeFormat,
    required this.notificationsEnabled,
    required this.notificationSound,
    required this.notificationVibration,
  });

  factory AppSettings.defaultSettings() {
    return const AppSettings(
      themeMode: ThemeMode.system,
      language: 'en',
      defaultCurrency: 'USD',
      dateFormat: 'MM/dd/yyyy',
      timeFormat: '12h',
      notificationsEnabled: true,
      notificationSound: true,
      notificationVibration: true,
    );
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? language,
    String? defaultCurrency,
    String? dateFormat,
    String? timeFormat,
    bool? notificationsEnabled,
    bool? notificationSound,
    bool? notificationVibration,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      notificationVibration:
          notificationVibration ?? this.notificationVibration,
    );
  }
}

/// Provider for settings
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
