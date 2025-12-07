# Product Requirements Document (PRD)

**Project Name:** Life Tracker - Advanced Health Physics Module  
**Version:** 3.0 (Production-Ready Technical Spec)  
**Platform:** Flutter (Android & iOS)  
**Architecture:** Clean Architecture (Feature-first)  
**State Management:** Riverpod 2.x with code generation  
**Database:** Isar (Local NoSQL)

---

## 1. Executive Summary

Build a **Hybrid Fitness Tracking System** that combines:
1. **Phone Sensors** (Pedometer/Accelerometer) - Real-time step counting
2. **Health Connect API** - Wearable data aggregation (Huawei, Samsung, Fitbit, etc.)
3. **BLE Smart Scales** (Xiaomi Mi Scale, etc.) - Automatic weight sync
4. **Advanced Physics Engine** - MET-based calorie calculation

The system automatically selects the **highest accuracy data source** available and provides **real-time updates** to the user.

---

## 2. Existing Architecture (Life Tracker)

```
lib/
├── core/
│   ├── providers/
│   │   ├── health_provider.dart      ← HealthConnectNotifier
│   │   └── pedometer_provider.dart   ← NEW: PedometerService
│   └── services/
│       ├── health_service.dart       ← Health Connect API
│       └── pedometer_service.dart    ← NEW: Step counter
├── features/
│   └── health/
│       ├── data/
│       │   └── repositories/         ← Weight, Medication repos
│       ├── domain/
│       │   └── entities/             ← WeightEntry, ActivityData
│       └── presentation/
│           ├── providers/
│           │   ├── activity_provider.dart  ← CORE: Combines all sources
│           │   └── weight_providers.dart
│           └── widgets/
│               └── activity_rings_widget.dart
```

---

## 3. Functional Requirements

### Module A: Physics Engine (Sensor-Based Step Detection)

#### A.1 Step Detection Algorithm

**Current Implementation:** `pedometer` package (uses device step counter sensor)

**Advanced Implementation (Optional):** Custom accelerometer processing

```dart
// Vector Magnitude Calculation
double magnitude = sqrt(x² + y² + z²);

// Low-Pass Filter (Smoothing)
smoothedMagnitude = α * magnitude + (1 - α) * previousMagnitude;
// Where α = 0.8 (responsiveness factor)

// Peak Detection
if (smoothedMagnitude > THRESHOLD && previousSlope > 0 && currentSlope < 0) {
  stepCount++;
}
// THRESHOLD = 10.5 m/s² (approximately 1.07G)
```

#### A.2 MET-Based Calorie Calculation

**Formula:**
```
Kcal/min = (MET × 3.5 × Weight_kg) / 200
```

**Dynamic MET Values based on Cadence (steps/minute):**

| Activity | Cadence | MET Value |
|----------|---------|-----------|
| Sedentary | < 30 | 1.0 |
| Standing/Light | 30-69 | 1.5 |
| Slow Walk | 70-99 | 2.5 |
| Normal Walk | 100-119 | 3.5 |
| Brisk Walk | 120-139 | 4.5 |
| Fast Walk | 140-159 | 5.5 |
| Jogging | 160-179 | 7.0 |
| Running | ≥ 180 | 9.0+ |

**Implementation:**
```dart
class CalorieCalculator {
  static double calculateCalories({
    required int steps,
    required Duration duration,
    required double weightKg,
  }) {
    if (duration.inMinutes == 0) return 0;
    
    final cadence = steps / duration.inMinutes;
    final met = _getMETValue(cadence);
    final kcalPerMinute = (met * 3.5 * weightKg) / 200;
    
    return kcalPerMinute * duration.inMinutes;
  }
  
  static double _getMETValue(double cadence) {
    if (cadence < 30) return 1.0;
    if (cadence < 70) return 1.5;
    if (cadence < 100) return 2.5;
    if (cadence < 120) return 3.5;
    if (cadence < 140) return 4.5;
    if (cadence < 160) return 5.5;
    if (cadence < 180) return 7.0;
    return 9.0;
  }
}
```

#### A.3 Distance Calculation

**Formula:**
```
Distance_km = Steps × Stride_length_m / 1000
```

**Dynamic Stride Length (based on height and cadence):**
```dart
double getStrideLength(double heightCm, double cadence) {
  final baseStride = heightCm * 0.415; // Base stride (cm)
  
  // Adjust for walking speed
  double multiplier = 1.0;
  if (cadence > 120) multiplier = 1.1;      // Brisk walk
  if (cadence > 160) multiplier = 1.35;     // Running
  
  return (baseStride * multiplier) / 100; // Return in meters
}
```

---

### Module B: Hardware Integration

#### B.1 Xiaomi Mi Scale (BLE)

**Device Names:** `MI_SCALE`, `MIBFS`, `MISCALE2`

**Characteristic UUID:** `0x2A9D` (Weight Measurement)

**Data Parsing:**
```dart
double parseWeight(List<int> bytes) {
  // Mi Scale uses Little Endian
  final rawWeight = bytes[1] | (bytes[2] << 8);
  
  // Check unit (byte[0] bit 0: 0=SI, 1=Imperial)
  final isImperial = (bytes[0] & 0x01) != 0;
  
  if (isImperial) {
    return rawWeight * 0.01 * 0.453592; // Convert lbs to kg
  }
  return rawWeight * 0.005; // SI: already in kg (0.005 resolution)
}
```

#### B.2 Health Connect Integration (Existing)

**Supported Data Types:**
- `HealthDataType.STEPS`
- `HealthDataType.ACTIVE_ENERGY_BURNED`
- `HealthDataType.HEART_RATE`
- `HealthDataType.WEIGHT`
- `HealthDataType.DISTANCE_DELTA`

**Sync Strategy:**
```dart
Future<void> syncAllData({
  required DateTime startDate,
  required DateTime endDate,
}) async {
  await Future.wait([
    _syncSteps(startDate, endDate),
    _syncCalories(startDate, endDate),
    _syncHeartRate(startDate, endDate),
    _syncWeight(startDate, endDate),
  ]);
}
```

---

### Module C: Smart Data Aggregation (Priority System)

**Data Source Priority:**

| Priority | Source | Accuracy | Latency |
|----------|--------|----------|---------|
| 1 | Health Connect (Wearable) | ⭐⭐⭐⭐⭐ | 5-15 min |
| 2 | Pedometer (Device Sensor) | ⭐⭐⭐⭐ | Real-time |
| 3 | Accelerometer (Calculated) | ⭐⭐⭐ | Real-time |

**Logic:**
```dart
final activityDataProvider = Provider<ActivityData>((ref) {
  final healthConnectSteps = ref.watch(healthConnectStepsProvider);
  final pedometerSteps = ref.watch(pedometerStepsProvider);
  
  // Use the HIGHER value (more accurate source)
  final todaySteps = max(healthConnectSteps, pedometerSteps);
  
  // Get user weight for accurate calorie calculation
  final userWeight = ref.watch(latestWeightProvider)?.weight ?? 70.0;
  
  // Calculate calories using physics
  final calories = CalorieCalculator.calculateCalories(
    steps: todaySteps,
    duration: _getActiveTime(),
    weightKg: userWeight,
  );
  
  return ActivityData(
    steps: todaySteps,
    calories: calories,
    source: pedometerSteps > healthConnectSteps 
        ? DataSource.pedometer 
        : DataSource.healthConnect,
  );
});
```

---

## 4. Implementation Checklist

### Phase 1: Core Physics ✅ (Completed)
- [x] Add `pedometer` package
- [x] Create `PedometerService` with midnight reset
- [x] Create `pedometer_provider.dart`
- [x] Update `activityDataProvider` to use pedometer

### Phase 2: Advanced Calculations 🔄 (In Progress)
- [x] Weight-based calorie calculation
- [ ] MET-based calorie calculation with cadence detection
- [ ] Dynamic stride length for distance
- [ ] Stand hours tracking per hour

### Phase 3: BLE Integration 📋 (Planned)
- [ ] Create `BleScaleService` using `flutter_blue_plus`
- [ ] Xiaomi Mi Scale parser
- [ ] Auto-update weight on successful scan
- [ ] Device pairing/bonding

### Phase 4: UI Enhancements 📋 (Planned)
- [ ] Data source indicator (Watch/Phone icon)
- [ ] Real-time calorie counter with animation
- [ ] Weekly trends chart
- [ ] Device sync status

---

## 5. Daily Reset Logic

**Midnight Reset (00:00:00):**
```dart
void _checkDayReset() {
  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);
  
  if (_lastResetDate == null || _lastResetDate!.isBefore(todayMidnight)) {
    // New day detected
    _stepCountAtMidnight = _currentStepCount;
    _lastResetDate = todayMidnight;
    _saveState();
  }
}

// Today's steps = current sensor count - count at midnight
int get todaySteps => (_currentStepCount - _stepCountAtMidnight).clamp(0, 999999);
```

---

## 6. Error Handling Strategy

| Error | Handling |
|-------|----------|
| Pedometer unavailable | Fall back to Health Connect only |
| Health Connect permissions denied | Use Pedometer only |
| BLE scan fails | Notify user, retry button |
| Weight sync fails | Keep last known weight |
| No data available | Show "-- " with setup prompt |

---

## 7. Testing Checklist

### Unit Tests
- [ ] `CalorieCalculator.calculateCalories()` with various inputs
- [ ] MET value selection logic
- [ ] Stride length calculation
- [ ] Midnight reset logic

### Integration Tests
- [ ] Pedometer + Health Connect data merge
- [ ] Weight sync flow
- [ ] Daily reset at midnight

### Manual Tests
- [ ] Walk with phone and verify step count
- [ ] Compare with wearable device
- [ ] Verify calorie calculation matches expectation
- [ ] Test BLE scale connection

---

## 8. Performance Considerations

1. **Battery Optimization:**
   - Use `pedometer` package (uses low-power step counter sensor)
   - Avoid continuous accelerometer polling
   - Health Connect sync every 6 hours (not continuous)

2. **Memory:**
   - Store only daily aggregates in Isar
   - Purge raw sensor data older than 24 hours

3. **UI:**
   - Use `const` widgets where possible
   - Debounce UI updates (max 1 update/second for step counter)

---

## 9. 🚀 DETAILED EXECUTION ROADMAP

> **⚠️ CRITICAL:** Follow this roadmap step-by-step. Do NOT skip steps. Each step includes verification before proceeding.

---

### 📌 STEP 1: Create CalorieCalculator Utility

**File:** `lib/core/utils/calorie_calculator.dart`

**Dependencies:** None

**Code:**
```dart
import 'dart:math';

/// MET-based calorie calculator using scientific formulas
class CalorieCalculator {
  /// Calculate calories burned based on steps, duration, and weight
  /// Formula: Kcal/min = (MET × 3.5 × Weight_kg) / 200
  static double calculateCalories({
    required int steps,
    required Duration duration,
    required double weightKg,
  }) {
    if (duration.inMinutes == 0 || steps == 0) return 0;
    
    final minutes = duration.inMinutes.toDouble();
    final cadence = steps / minutes;
    final met = getMETValue(cadence);
    final kcalPerMinute = (met * 3.5 * weightKg) / 200;
    
    return kcalPerMinute * minutes;
  }
  
  /// Get MET value based on cadence (steps per minute)
  static double getMETValue(double cadence) {
    if (cadence < 30) return 1.0;    // Sedentary
    if (cadence < 70) return 1.5;    // Standing/Light
    if (cadence < 100) return 2.5;   // Slow Walk
    if (cadence < 120) return 3.5;   // Normal Walk
    if (cadence < 140) return 4.5;   // Brisk Walk
    if (cadence < 160) return 5.5;   // Fast Walk
    if (cadence < 180) return 7.0;   // Jogging
    return 9.0;                       // Running
  }
  
  /// Calculate distance in kilometers
  static double calculateDistance({
    required int steps,
    required double heightCm,
    double? cadence,
  }) {
    final strideLength = getStrideLength(heightCm, cadence ?? 100);
    return (steps * strideLength) / 1000; // Convert to km
  }
  
  /// Get stride length in meters based on height and activity
  static double getStrideLength(double heightCm, double cadence) {
    // Base stride is approximately 41.5% of height
    final baseStride = heightCm * 0.415;
    
    // Adjust for walking speed
    double multiplier = 1.0;
    if (cadence > 120) multiplier = 1.1;      // Brisk walk
    if (cadence > 160) multiplier = 1.35;     // Running
    
    return (baseStride * multiplier) / 100; // Return in meters
  }
}
```

**Verification:**
```bash
flutter analyze lib/core/utils/calorie_calculator.dart
```

---

### 📌 STEP 2: Create ActivitySession Entity

**File:** `lib/features/health/domain/entities/activity_session.dart`

**Dependencies:** None

**Code:**
```dart
import 'package:equatable/equatable.dart';

/// Represents an activity session for tracking cadence and MET
class ActivitySession extends Equatable {
  final DateTime startTime;
  final int stepsAtStart;
  final int currentSteps;
  
  const ActivitySession({
    required this.startTime,
    required this.stepsAtStart,
    required this.currentSteps,
  });
  
  Duration get duration => DateTime.now().difference(startTime);
  
  int get sessionSteps => currentSteps - stepsAtStart;
  
  double get cadence {
    final minutes = duration.inMinutes;
    if (minutes == 0) return 0;
    return sessionSteps / minutes;
  }
  
  ActivitySession copyWith({
    DateTime? startTime,
    int? stepsAtStart,
    int? currentSteps,
  }) {
    return ActivitySession(
      startTime: startTime ?? this.startTime,
      stepsAtStart: stepsAtStart ?? this.stepsAtStart,
      currentSteps: currentSteps ?? this.currentSteps,
    );
  }
  
  @override
  List<Object?> get props => [startTime, stepsAtStart, currentSteps];
}
```

**Verification:**
```bash
flutter analyze lib/features/health/domain/entities/activity_session.dart
```

---

### 📌 STEP 3: Update ActivityData Entity

**File:** `lib/features/health/presentation/providers/activity_provider.dart`

**Add to ActivityData class:**
```dart
class ActivityData {
  final double moveCurrent;      // Calories burned
  final double moveGoal;
  final double exerciseCurrent;  // Exercise minutes
  final double exerciseGoal;
  final double standCurrent;     // Stand hours
  final double standGoal;
  final int steps;
  final double distance;         // NEW: Distance in km
  final double cadence;          // NEW: Steps per minute
  final DataSource source;       // NEW: Data source indicator
  
  // ... rest of implementation
}

enum DataSource {
  pedometer,      // Phone sensor
  healthConnect,  // Wearable device
  manual,         // User input
}
```

---

### 📌 STEP 4: Update activityDataProvider with MET Calculations

**File:** `lib/features/health/presentation/providers/activity_provider.dart`

**Important Changes:**
1. Import `CalorieCalculator`
2. Track session start time for cadence
3. Use MET-based calorie calculation

**Code Structure:**
```dart
import 'package:life_tracker/core/utils/calorie_calculator.dart';

final activityDataProvider = Provider<ActivityData>((ref) {
  // ... existing step calculation ...
  
  // Get user profile for height
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final heightCm = profile?.heightInCm ?? 170.0;
  
  // Calculate time since day start for cadence
  final now = DateTime.now();
  final dayStart = DateTime(now.year, now.month, now.day, 6, 0); // 6 AM
  final activeDuration = now.difference(dayStart);
  
  // Calculate cadence
  final cadence = activeDuration.inMinutes > 0 
      ? todaySteps / activeDuration.inMinutes 
      : 0.0;
  
  // MET-based calorie calculation
  final calories = CalorieCalculator.calculateCalories(
    steps: todaySteps,
    duration: activeDuration,
    weightKg: userWeight,
  );
  
  // Distance calculation
  final distance = CalorieCalculator.calculateDistance(
    steps: todaySteps,
    heightCm: heightCm,
    cadence: cadence,
  );
  
  return ActivityData(/* ... */);
});
```

---

### 📌 STEP 5: Create Stand Hours Tracker

**File:** `lib/core/services/stand_hours_service.dart`

**Logic:**
- Track step events per hour
- If at least 50 steps in an hour → count as stand hour
- Store hourly data in SharedPreferences

**Code:**
```dart
class StandHoursService {
  static const String _hourlyStepsKey = 'hourly_steps_';
  
  final Map<int, int> _hourlySteps = {};
  
  /// Record steps for the current hour
  void recordSteps(int steps) {
    final currentHour = DateTime.now().hour;
    _hourlySteps[currentHour] = steps;
  }
  
  /// Calculate stand hours (hours with >= 50 steps)
  int calculateStandHours() {
    return _hourlySteps.values.where((steps) => steps >= 50).length;
  }
  
  /// Reset at midnight
  void resetDaily() {
    _hourlySteps.clear();
  }
}
```

---

### 📌 STEP 6: Integration Testing

**Before proceeding to BLE, verify:**

| Test | Command | Expected |
|------|---------|----------|
| Analyze | `flutter analyze` | 0 errors |
| Run | `flutter run` | App starts |
| Walk 100 steps | Physical test | Steps update in real-time |
| Check calories | Walk 1000 steps | ~40-50 kcal (depending on weight) |

---

### 📌 STEP 7: BLE Scale Integration (Phase 3)

**File:** `lib/core/services/ble_scale_service.dart`

**Dependencies:** `flutter_blue_plus` (already in project)

**Device UUIDs:**
```dart
// Xiaomi Mi Scale
static const String MI_SCALE_SERVICE = '0000181b-0000-1000-8000-00805f9b34fb';
static const String MI_SCALE_CHAR = '00002a9d-0000-1000-8000-00805f9b34fb';
```

---

## 10. 🔒 SAFETY CHECKPOINTS

Before each phase, create a git checkpoint:

```bash
# Before Phase 2
git add -A && git commit -m "checkpoint: before MET calculations"
git tag phase1-complete

# Before Phase 3
git add -A && git commit -m "checkpoint: before BLE integration"
git tag phase2-complete

# Before Phase 4
git add -A && git commit -m "checkpoint: before UI enhancements"
git tag phase3-complete
```

**Rollback command:**
```bash
git reset --hard phase1-complete  # Example: rollback to Phase 1
```

---

## 11. 📋 FILE CREATION ORDER

Execute in this exact order:

| Order | File | Type |
|-------|------|------|
| 1 | `lib/core/utils/calorie_calculator.dart` | NEW |
| 2 | `lib/features/health/domain/entities/activity_session.dart` | NEW |
| 3 | `lib/core/services/stand_hours_service.dart` | NEW |
| 4 | `lib/features/health/presentation/providers/activity_provider.dart` | MODIFY |
| 5 | `lib/features/settings/presentation/providers/user_profile_providers.dart` | VERIFY |
| 6 | `lib/core/services/ble_scale_service.dart` | NEW (Phase 3) |

---

## 12. 🧪 VERIFICATION SCRIPT

Run after each phase:

```bash
# Full verification
flutter clean
flutter pub get
flutter analyze
flutter run -d <device_id>
```

---

## 13. 📊 EXPECTED RESULTS

After full implementation:

| Metric | Source | Update Frequency |
|--------|--------|------------------|
| Steps | Pedometer + Health Connect | Real-time |
| Calories | MET calculation | Real-time |
| Distance | Stride × Steps | Real-time |
| Exercise | Cadence-based | Per minute |
| Stand Hours | Hourly tracking | Per hour |
| Weight | BLE Scale + Manual | On sync |