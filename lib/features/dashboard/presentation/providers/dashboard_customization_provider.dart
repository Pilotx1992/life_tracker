import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Dashboard module types
enum DashboardModule {
  health('health', 'Health'),
  finance('finance', 'Finance'),
  reminders('reminders', 'Reminders'),
  notes('notes', 'Notes');

  final String id;
  final String displayName;
  const DashboardModule(this.id, this.displayName);
}

/// Dashboard customization state
class DashboardCustomization {
  final List<String> moduleOrder; // Ordered list of module IDs
  final Map<String, bool> moduleVisibility; // Map of module ID to visibility

  const DashboardCustomization({
    required this.moduleOrder,
    required this.moduleVisibility,
  });

  factory DashboardCustomization.defaultConfig() {
    return DashboardCustomization(
      moduleOrder: DashboardModule.values.map((m) => m.id).toList(),
      moduleVisibility: {
        for (var module in DashboardModule.values) module.id: true,
      },
    );
  }

  DashboardCustomization copyWith({
    List<String>? moduleOrder,
    Map<String, bool>? moduleVisibility,
  }) {
    return DashboardCustomization(
      moduleOrder: moduleOrder ?? this.moduleOrder,
      moduleVisibility: moduleVisibility ?? this.moduleVisibility,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleOrder': moduleOrder,
      'moduleVisibility': moduleVisibility,
    };
  }

  factory DashboardCustomization.fromJson(Map<String, dynamic> json) {
    return DashboardCustomization(
      moduleOrder:
          List<String>.from((json['moduleOrder'] as List<dynamic>?) ?? []),
      moduleVisibility: Map<String, bool>.from(
        (json['moduleVisibility'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

/// Provider for dashboard customization
class DashboardCustomizationNotifier
    extends StateNotifier<DashboardCustomization> {
  static const String _prefsKey = 'dashboard_customization';

  DashboardCustomizationNotifier()
      : super(DashboardCustomization.defaultConfig()) {
    _loadCustomization();
  }

  Future<void> _loadCustomization() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = DashboardCustomization.fromJson(json);
      }
    } catch (e) {
      // If loading fails, use default configuration
      state = DashboardCustomization.defaultConfig();
    }
  }

  Future<void> _saveCustomization() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_prefsKey, jsonString);
    } catch (e) {
      // Handle error silently or log it
    }
  }

  /// Toggle visibility of a module
  Future<void> toggleModuleVisibility(String moduleId) async {
    final newVisibility = Map<String, bool>.from(state.moduleVisibility);
    newVisibility[moduleId] = !(newVisibility[moduleId] ?? true);
    state = state.copyWith(moduleVisibility: newVisibility);
    await _saveCustomization();
  }

  /// Set module visibility
  Future<void> setModuleVisibility(String moduleId, bool visible) async {
    final newVisibility = Map<String, bool>.from(state.moduleVisibility);
    newVisibility[moduleId] = visible;
    state = state.copyWith(moduleVisibility: newVisibility);
    await _saveCustomization();
  }

  /// Reorder modules
  Future<void> reorderModules(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newOrder = List<String>.from(state.moduleOrder);
    final item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    state = state.copyWith(moduleOrder: newOrder);
    await _saveCustomization();
  }

  /// Reset to default configuration
  Future<void> resetToDefault() async {
    state = DashboardCustomization.defaultConfig();
    await _saveCustomization();
  }

  /// Get ordered list of visible modules
  List<DashboardModule> getVisibleModules() {
    return state.moduleOrder
        .where((id) => state.moduleVisibility[id] ?? true)
        .map(
          (id) => DashboardModule.values.firstWhere(
            (m) => m.id == id,
            orElse: () => DashboardModule.health,
          ),
        )
        .toList();
  }

  /// Check if module is visible
  bool isModuleVisible(String moduleId) {
    return state.moduleVisibility[moduleId] ?? true;
  }
}

final dashboardCustomizationProvider = StateNotifierProvider<
    DashboardCustomizationNotifier, DashboardCustomization>((ref) {
  return DashboardCustomizationNotifier();
});
