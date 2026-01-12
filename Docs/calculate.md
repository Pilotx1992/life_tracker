# Product Requirements Document (PRD)

**Project Name:** Life Tracker - Advanced Health Physics Module  
**Version:** 4.0 (Updated - January 2026)  
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

## 2. Current Architecture

```
lib/
├── core/
│   ├── utils/
│   │   └── calorie_calculator.dart      ✅ MET-based calculations
│   ├── providers/
│   │   ├── health_provider.dart         ✅ HealthConnectNotifier
│   │   └── pedometer_provider.dart      ✅ PedometerService
│   └── services/
│       ├── health_service.dart          ✅ Health Connect API
│       ├── pedometer_service.dart       ✅ Step counter
│       ├── stand_hours_service.dart     ✅ Stand hour tracking
│       ├── mi_scale_service.dart        ✅ Xiaomi Mi Scale
│       └── ble_service.dart             ✅ BLE generic utilities
├── features/
│   └── health/
│       ├── data/
│       │   └── repositories/
│       │       └── smart_activity_repository.dart  ✅ Data aggregation
│       ├── domain/
│       │   └── entities/
│       │       └── activity_summary.dart           ✅ ActivityData model
│       └── presentation/
│           ├── providers/
│           │   ├── activity_provider.dart          ✅ Combined sources
│           │   └── weight_providers.dart           ✅
│           └── widgets/
│               └── activity_rings_widget.dart      ✅
```

---

## 3. Functional Requirements

### Module A: Physics Engine (Sensor-Based Step Detection)

#### A.1 Step Detection

**Implementation:** [`pedometer`](https://pub.dev/packages/pedometer) package (uses device step counter sensor)

**Key Features:**
- Uses low-power hardware step counter sensor
- Automatic midnight reset
- Persistent state across app restarts
- Background step accumulation

#### A.2 MET-Based Calorie Calculation ✅ IMPLEMENTED

**File:** [`lib/core/utils/calorie_calculator.dart`](file:///c:/Users/X/life_tracker/lib/core/utils/calorie_calculator.dart)

**Formula:**
```
Kcal/min = (MET × 3.5 × Weight_kg) / 200
```

**Current MET Values (Cadence-Based):**

| Activity | Cadence (steps/min) | MET Value |
|----------|---------------------|-----------|
| Sedentary/Standing | < 70 | 1.2 |
| Slow Walk | 70-100 | 3.0 |
| Brisk Walk | 100-125 | 4.0 |
| Fast Walk | 125-130 | 6.0 |
| Running | > 130 | 8.0 |

**Implementation:**
```dart
class CalorieCalculator {
  /// MET-based calorie calculation
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
  
  /// Simple estimation when duration unavailable
  static double calculateCaloriesSimple({
    required int steps,
    required double weightKg,
  }) {
    // Base: 0.04 kcal per step for 70kg person
    final weightMultiplier = weightKg / 70.0;
    return steps * 0.04 * weightMultiplier;
  }
  
  static double getMETValue(double cadence) {
    if (cadence < 70) return 1.2;
    if (cadence <= 100) return 3.0;
    if (cadence <= 125) return 4.0;
    if (cadence <= 130) return 6.0;
    return 8.0;
  }
}
```

#### A.3 Distance Calculation ✅ IMPLEMENTED

**Formula:**
```
Distance_km = Steps × Stride_length_m / 1000
```

**Dynamic Stride Length (based on height and cadence):**
```dart
static double getStrideLength(double heightCm, double cadence) {
  // Base stride is approximately 41.5% of height
  final baseStride = heightCm * 0.415;
  
  // Adjust for walking speed
  double multiplier = 1.0;
  if (cadence > 120) multiplier = 1.1;      // Brisk walk
  if (cadence > 160) multiplier = 1.35;     // Running
  
  return (baseStride * multiplier) / 100; // Return in meters
}
```

#### A.4 Exercise Minutes ✅ IMPLEMENTED

**Logic:**
- Exercise counted only for intentional physical activity
- Requires at least 3,000 steps threshold
- 150 steps above threshold = 1 minute of exercise
- Capped at 120 minutes per day

```dart
static double calculateExerciseMinutes(int steps) {
  if (steps < 3000) return 0.0;
  return ((steps - 3000) / 150).clamp(0.0, 120.0);
}
```

#### A.5 Stand Hours ✅ IMPLEMENTED

**Logic:**
- Simple estimation: 500 steps = 1 stand hour
- Capped at hours elapsed since midnight

```dart
static double calculateStandHours(int steps, double hoursElapsed) {
  if (steps == 0) return 0.0;
  return (steps / 500).clamp(0.0, hoursElapsed);
}
```

---

### Module B: Hardware Integration

#### B.1 Xiaomi Mi Scale (BLE) ✅ IMPLEMENTED

**File:** [`lib/core/services/mi_scale_service.dart`](file:///c:/Users/X/life_tracker/lib/core/services/mi_scale_service.dart)

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

#### B.2 Health Connect Integration ✅ IMPLEMENTED

**File:** [`lib/core/services/health_service.dart`](file:///c:/Users/X/life_tracker/lib/core/services/health_service.dart)

**Supported Data Types:**
- `HealthDataType.STEPS`
- `HealthDataType.ACTIVE_ENERGY_BURNED`
- `HealthDataType.HEART_RATE`
- `HealthDataType.WEIGHT`
- `HealthDataType.DISTANCE_DELTA`

---

### Module C: Smart Data Aggregation ✅ IMPLEMENTED

**File:** [`lib/features/health/data/repositories/smart_activity_repository.dart`](file:///c:/Users/X/life_tracker/lib/features/health/data/repositories/smart_activity_repository.dart)

**Data Source Priority:**

| Priority | Source | Accuracy | Latency |
|----------|--------|----------|---------|
| 1 | Health Connect (Wearable) | ⭐⭐⭐⭐⭐ | 5-15 min |
| 2 | Pedometer (Device Sensor) | ⭐⭐⭐⭐ | Real-time |
| 3 | Accelerometer (Calculated) | ⭐⭐⭐ | Real-time |

**Provider Chain:**
```dart
/// Stream provider for activity summary from repository
final activitySummaryStreamProvider = StreamProvider<ActivitySummary>((ref) {
  final repository = ref.watch(smartActivityRepositoryProvider);
  return repository.getActivityStream();
});

/// Provider for Activity Rings data
final activityDataProvider = Provider<ActivityData>((ref) {
  final summaryAsync = ref.watch(activitySummaryStreamProvider);
  
  // Default values
  double move = 0, exercise = 0, stand = 0, distance = 0;
  int steps = 0;
  DataSource source = DataSource.pedometer;
  
  summaryAsync.whenData((summary) {
    move = summary.activeCalories;
    exercise = summary.exerciseMinutes;
    stand = summary.standHours;
    steps = summary.steps;
    distance = summary.distanceMeters / 1000.0;
    source = summary.source == ActivityDataSource.healthConnect
        ? DataSource.healthConnect
        : DataSource.pedometer;
  });
  
  return ActivityData(
    moveCurrent: move,
    moveGoal: 270.0,
    exerciseCurrent: exercise,
    exerciseGoal: 30.0,
    standCurrent: stand,
    standGoal: 12.0,
    steps: steps,
    stepGoal: 10000,
    distance: distance,
    source: source,
  );
});
```

---

## 4. Implementation Checklist

### Phase 1: Core Physics ✅ COMPLETED

- [x] Add `pedometer` package
- [x] Create `PedometerService` with midnight reset
- [x] Create `pedometer_provider.dart`
- [x] Update `activityDataProvider` to use pedometer
- [x] Create `CalorieCalculator` utility class

### Phase 2: Advanced Calculations ✅ COMPLETED

- [x] Weight-based calorie calculation
- [x] MET-based calorie calculation with cadence detection
- [x] Dynamic stride length for distance
- [x] Stand hours tracking per hour
- [x] Exercise minutes calculation
- [x] Activity level detection (Sedentary → Running)

### Phase 3: BLE Integration ✅ COMPLETED

- [x] Create `BleScaleService` using `flutter_blue_plus`
- [x] Create `MiScaleService` for Xiaomi scales
- [x] Xiaomi Mi Scale parser
- [x] Auto-update weight on successful scan
- [ ] Device pairing/bonding (UI improvements)

### Phase 4: UI Enhancements 🔄 IN PROGRESS

- [x] Activity Rings Widget
- [ ] Data source indicator (Watch/Phone icon)
- [ ] Real-time calorie counter with animation
- [ ] Weekly trends chart
- [ ] Device sync status indicator

---

## 5. Daily Reset Logic ✅ IMPLEMENTED

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

## 7. Key Files Reference

| Component | File Path |
|-----------|-----------|
| Calorie Calculator | [`lib/core/utils/calorie_calculator.dart`](file:///c:/Users/X/life_tracker/lib/core/utils/calorie_calculator.dart) |
| Activity Provider | [`lib/features/health/presentation/providers/activity_provider.dart`](file:///c:/Users/X/life_tracker/lib/features/health/presentation/providers/activity_provider.dart) |
| Smart Repository | [`lib/features/health/data/repositories/smart_activity_repository.dart`](file:///c:/Users/X/life_tracker/lib/features/health/data/repositories/smart_activity_repository.dart) |
| Pedometer Service | [`lib/core/services/pedometer_service.dart`](file:///c:/Users/X/life_tracker/lib/core/services/pedometer_service.dart) |
| Stand Hours Service | [`lib/core/services/stand_hours_service.dart`](file:///c:/Users/X/life_tracker/lib/core/services/stand_hours_service.dart) |
| Mi Scale Service | [`lib/core/services/mi_scale_service.dart`](file:///c:/Users/X/life_tracker/lib/core/services/mi_scale_service.dart) |
| BLE Service | [`lib/core/services/ble_service.dart`](file:///c:/Users/X/life_tracker/lib/core/services/ble_service.dart) |
| Health Service | [`lib/core/services/health_service.dart`](file:///c:/Users/X/life_tracker/lib/core/services/health_service.dart) |

---

## 8. Performance Considerations

### Battery Optimization
- ✅ Uses `pedometer` package (low-power step counter sensor)
- ✅ Avoids continuous accelerometer polling
- ✅ Health Connect sync periodically (not continuous)

### Memory
- ✅ Stores only daily aggregates
- ✅ Purges raw sensor data older than 24 hours

### UI
- ✅ Uses `const` widgets where possible
- ✅ Debounces UI updates (max 1 update/second for step counter)

---

## 9. Testing Checklist

### Unit Tests

- [ ] `CalorieCalculator.calculateCalories()` with various inputs
- [ ] `CalorieCalculator.calculateCaloriesSimple()` validation
- [ ] MET value selection logic
- [ ] Stride length calculation
- [ ] Midnight reset logic
- [ ] Exercise minutes calculation
- [ ] Stand hours calculation

### Integration Tests

- [ ] Pedometer + Health Connect data merge
- [ ] Weight sync flow
- [ ] Daily reset at midnight
- [ ] SmartActivityRepository data aggregation

### Manual Tests

- [ ] Walk with phone and verify step count
- [ ] Compare with wearable device
- [ ] Verify calorie calculation matches expectation
- [ ] Test BLE scale connection

---

## 10. Expected Results

After full implementation:

| Metric | Source | Update Frequency |
|--------|--------|------------------|
| Steps | Pedometer + Health Connect | Real-time |
| Calories | MET calculation | Real-time |
| Distance | Stride × Steps | Real-time |
| Exercise | Cadence-based | Per minute |
| Stand Hours | Hourly tracking | Per hour |
| Weight | BLE Scale + Manual | On sync |

---

## 11. Future Enhancements (Phase 5+)

### Planned Features

1. **Custom Step Goals** - User-configurable daily targets
2. **Weekly/Monthly Reports** - Trend analysis and insights
3. **Workout Detection** - Auto-detect workout sessions
4. **Heart Rate Zones** - Integration with HR monitors
5. **Sleep Tracking** - Via Health Connect
6. **Nutrition Integration** - Calorie balance with food logging

### Technical Improvements

1. **Background Sync Service** - For wearable data when app is closed
2. **Widget Support** - Home screen step counter widget
3. **Wear OS Companion** - If applicable
4. **Export/Import** - Health data backup and restore

---

*Last Updated: January 2026*