# Product Requirements Document (PRD)
## OmniFit Physics Tracker v2.0

**Document Version:** 2.0  
**Last Updated:** December 11, 2025  
**Platform:** Flutter (Android & iOS)  
**Target Release:** Q2 2026  
**Document Owner:** Product & Engineering Team

---

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Product Vision & Goals](#2-product-vision--goals)
3. [Technical Architecture & Stack](#3-technical-architecture--stack)
4. [Functional Requirements](#4-functional-requirements)
5. [Non-Functional Requirements](#5-non-functional-requirements)
6. [Data Models & Entities](#6-data-models--entities)
7. [API & Integration Specifications](#7-api--integration-specifications)
8. [UI/UX Specifications](#8-uiux-specifications)
9. [Security & Privacy](#9-security--privacy)
10. [Testing Strategy](#10-testing-strategy)
11. [Implementation Roadmap](#11-implementation-roadmap)
12. [Success Metrics & KPIs](#12-success-metrics--kpis)
13. [Risk Assessment & Mitigation](#13-risk-assessment--mitigation)
14. [Appendix](#14-appendix)

---

## 1. Executive Summary

### 1.1 Problem Statement
Current fitness tracking applications suffer from three critical limitations:
- **Wearable Dependency**: Users without smartwatches receive no tracking capabilities
- **Static Biometrics**: Manual weight updates lead to inaccurate calorie calculations
- **Data Silos**: No seamless switching between phone-based and wearable-based tracking

### 1.2 Solution Overview
OmniFit Physics Tracker introduces a **Hybrid Intelligence System** that:
1. **Operates Independently**: Uses advanced physics algorithms to track fitness via phone sensors when no wearable is available
2. **Seamlessly Upgrades**: Automatically switches to superior wearable data (via Health Connect) when detected
3. **Self-Updates**: Integrates directly with Xiaomi Mi Scales via BLE to maintain accurate biometric data for precise calorie calculations

### 1.3 Core Value Proposition
- **Universal Accessibility**: Works for users with or without wearables
- **Scientific Accuracy**: Physics-based calculations using METs methodology
- **Dynamic Precision**: Auto-updating biometrics ensure calculation accuracy
- **Zero Friction**: Automatic source switching without user intervention

### 1.4 Target Users
- **Primary**: Fitness enthusiasts aged 18-45 who own smartphones but not necessarily smartwatches
- **Secondary**: Smartwatch owners seeking unified tracking across devices
- **Tertiary**: Weight management users with smart scales

---

## 2. Product Vision & Goals

### 2.1 Vision Statement
"To democratize precision fitness tracking by making professional-grade activity monitoring accessible to every smartphone user, while seamlessly integrating with their existing smart devices."

### 2.2 Business Goals
1. Achieve 100,000 active users within 6 months of launch
2. Maintain >85% weekly retention rate
3. Average daily engagement of 15+ minutes
4. App Store rating of 4.5+ stars

### 2.3 User Goals
1. Track daily activity with <5% error margin vs. premium wearables
2. Receive accurate calorie burn estimates
3. Maintain updated weight data without manual input
4. Understand data sources and accuracy confidence

### 2.4 Technical Goals
1. <2% CPU usage during background tracking
2. <50MB memory footprint
3. Step detection accuracy >95% vs. manual counting
4. <100ms latency for UI updates
5. Battery drain <3% per hour during active tracking

---

## 3. Technical Architecture & Stack

### 3.1 Architecture Pattern

**Clean Architecture** with **Feature-First** organization:

> **✅ IMPLEMENTED** - The following structure is already in place in the Life Tracker project.

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_design_tokens.dart
│   ├── providers/
│   │   ├── health_provider.dart        ✅ HealthConnectNotifier
│   │   ├── pedometer_provider.dart     ✅ Physics Engine (Fallback)
│   │   └── ble_provider.dart           ✅ Mi Scale BLE
│   ├── services/
│   │   ├── health_service.dart         ✅ Health Connect Integration
│   │   ├── pedometer_service.dart      ✅ Step Counting Service
│   │   └── notification_service.dart
│   ├── utils/
│   │   └── calorie_calculator.dart     ✅ METs Calculation Engine
│   └── router/
├── features/
│   ├── health/                         ← Primary Module (OmniFit)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   │       └── smart_activity_repository.dart  ✅ Priority Logic
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── activity_summary.dart    ✅ Core Entity
│   │   │   │   ├── weight_entry.dart
│   │   │   │   └── user_profile.dart
│   │   │   ├── repositories/
│   │   │   │   └── activity_repository.dart  ✅ Interface
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── activity_provider.dart    ✅ UI State
│   │       │   ├── weight_provider.dart
│   │       │   └── medication_provider.dart
│   │       ├── screens/
│   │       │   └── health_screen.dart        ✅ Dashboard
│   │       └── widgets/
│   │           ├── activity_rings_widget.dart
│   │           └── health_insights_widget.dart
│   ├── settings/
│   │   └── presentation/providers/
│   │       └── user_profile_providers.dart
│   ├── finance/
│   ├── notes/
│   ├── reminders/
│   └── dashboard/
└── main.dart
```

### 3.2 Technology Stack

#### Core Framework
- **Flutter SDK**: 3.19+ (Stable Channel)
- **Dart**: 3.3+

#### State Management
- **flutter_riverpod**: 2.5.0+ (Reactive state management)
  - `AsyncNotifier` for async data streams
  - `StreamProvider` for real-time sensor data
  - `StateNotifier` for UI state

#### Local Storage
- **isar**: 3.1.0+ (High-performance NoSQL database)
  - Stores: Sensor data, Activity sessions, User profiles
  - Advantages: Zero-copy reads, automatic indexing, reactive queries

#### Background Processing
- **flutter_background_service**: 5.0.0+
- **Isolates**: For heavy mathematical computations

#### External Integrations

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_blue_plus` | 1.31.0+ | BLE communication with Mi Scale |
| `health` | 10.0.0+ | Health Connect / HealthKit integration |
| `sensors_plus` | 4.0.0+ | Accelerometer, gyroscope data |
| `permission_handler` | 11.0.0+ | Runtime permissions management |
| `geolocator` | 11.0.0+ | GPS for outdoor activity tracking |
| `shared_preferences` | 2.2.0+ | Lightweight settings storage |

#### Development Tools
- **freezed**: 2.4.0+ (Immutable data classes)
- **json_serializable**: 6.7.0+ (JSON serialization)
- **mocktail**: 1.0.0+ (Testing mocks)
- **flutter_test**: SDK (Unit & widget testing)

### 3.3 Design Patterns

#### Repository Pattern
```dart
abstract class ActivityRepository {
  Stream<ActivityData> getActivityStream();
  Future<ActivitySession> saveSession(ActivitySession session);
  Future<List<ActivitySession>> getHistory(DateRange range);
}
```

#### Strategy Pattern (Data Source Selection)
```dart
abstract class DataSourceStrategy {
  bool isAvailable();
  int getPriority();
  Stream<ActivityData> getStream();
}

class WearableStrategy implements DataSourceStrategy { ... }
class PhoneSensorStrategy implements DataSourceStrategy { ... }
```

#### Observer Pattern (Sensor Events)
```dart
abstract class SensorEventListener {
  void onStepDetected(Step step);
  void onCalorieUpdate(double calories);
}
```

---

## 4. Functional Requirements

### 4.1 Module A: Physics Engine (Internal Sensor Logic)

#### 4.1.1 Step Detection Algorithm

**Input Sources:**
- Accelerometer (X, Y, Z axes)
- Sampling Rate: 50 Hz (configurable: 25-100 Hz)

**Processing Pipeline:**

**Step 1: Vector Magnitude Calculation**
```dart
double calculateMagnitude(AccelerometerEvent event) {
  return sqrt(
    event.x * event.x + 
    event.y * event.y + 
    event.z * event.z
  );
}
```
Formula: $$v = \sqrt{x^2 + y^2 + z^2}$$

**Step 2: Low-Pass Filter (Smoothing)**
- **Algorithm**: Exponential Moving Average (EMA)
- **Formula**: $$filtered_n = \alpha \times raw_n + (1 - \alpha) \times filtered_{n-1}$$
- **Alpha Value**: 0.15 (configurable: 0.1-0.3)
- **Purpose**: Remove high-frequency noise and jitter

**Step 3: Peak Detection**
- **Threshold**: 1.2G (11.772 m/s²)
- **Conditions**:
  1. Current magnitude > threshold
  2. Previous value < current value (rising edge)
  3. Next value < current value (peak confirmation)
  4. Minimum time between steps: 250ms (max cadence: 240 steps/min)
  
**Step 4: Orientation Compensation**
- **Problem**: Phone orientation affects accelerometer readings
- **Solution**: Use gravity-normalized coordinates
```dart
Vector3 normalizeOrientation(Vector3 raw, Vector3 gravity) {
  return raw - gravity; // Remove static gravity component
}
```

**Step 5: False Positive Filtering**
- **Gesture Detection**: Distinguish walking from phone manipulation
- **Method**: Analyze frequency spectrum
  - Walking: 1-3 Hz dominant frequency
  - Hand gestures: 3-10 Hz dominant frequency

#### 4.1.2 Distance Calculation

**Formula:**
$$Distance_{meters} = Steps \times Stride\_Length$$

**Stride Length Estimation:**
- **Method 1 (Height-based)**: 
  $$Stride = Height_{cm} \times 0.413$$
- **Method 2 (Calibrated)**:
  - User walks known distance
  - System calculates: $$Stride = Known\_Distance / Detected\_Steps$$

**Speed Calculation:**
$$Speed_{m/s} = Distance_{meters} / Time_{seconds}$$

#### 4.1.3 Calorie Estimation (METs Methodology)

**Scientific Foundation:**
- **METs** = Metabolic Equivalent of Task
- 1 MET = Resting metabolic rate = 3.5 ml O₂/kg/min

**Dynamic MET Assignment:**

| Activity Type | Cadence (steps/min) | MET Value | Description |
|---------------|---------------------|-----------|-------------|
| Sedentary | < 70 | 1.2 | Standing, minimal movement |
| Slow Walk | 70-100 | 3.0 | Casual pace (~3 km/h) |
| Moderate Walk | 100-115 | 3.5 | Average pace (~4.5 km/h) |
| Brisk Walk | 115-125 | 4.0 | Fast pace (~6 km/h) |
| Light Jog | 125-140 | 6.0 | Slow running (~7 km/h) |
| Running | 140-160 | 8.0 | Moderate running (~9 km/h) |
| Fast Running | > 160 | 10.0+ | Sprint pace (~12+ km/h) |

**Calorie Calculation Formula:**

$$Kcal/min = \frac{MET \times 3.5 \times Weight_{kg}}{200}$$

**Enhanced Formula (with heart rate when available):**

$$Kcal/min = \frac{(Age \times 0.074) - (Weight_{kg} \times 0.05741) + (HR \times 0.4472) - 20.4022}{4.184}$$

**Implementation:**
```dart
double calculateCalories({
  required double met,
  required double weightKg,
  required Duration duration,
  double? heartRate,
}) {
  final minutes = duration.inSeconds / 60.0;
  
  if (heartRate != null) {
    // Enhanced formula with HR
    return calculateWithHeartRate(heartRate, weightKg, minutes);
  }
  
  // Standard MET formula
  return (met * 3.5 * weightKg / 200) * minutes;
}
```

#### 4.1.4 Activity Classification

**Machine Learning Enhancement** (Future Phase):
- Train lightweight TensorFlow Lite model
- Features: Cadence, magnitude variance, frequency spectrum
- Classes: Walking, Running, Cycling, Stairs, Stationary

**Current Rule-Based System:**
```dart
enum ActivityType {
  stationary,  // Cadence < 50
  walking,     // Cadence 70-125
  running,     // Cadence > 125
  cycling,     // Speed > 15 km/h, low cadence
  stairs,      // High vertical acceleration variance
}
```

---

### 4.2 Module B: Hardware Integration

#### 4.2.1 Xiaomi Mi Scale (BLE Integration)

**Supported Models:**
- Mi Body Composition Scale (XMTZC01HM, XMTZC02HM, XMTZC05HM)
- Mi Smart Scale 2 (XMTZC04HM)

**BLE Specifications:**

| Parameter | Value |
|-----------|-------|
| Protocol | Bluetooth 5.0 LE |
| Service UUID | `181B` (Weight Scale Service) |
| Characteristic UUID | `2A9C` (Weight Measurement) |
| Device Name Patterns | `MI_SCALE`, `MIBFS`, `MIBCS` |

**Connection Flow:**

```
┌─────────────┐
│ Start Scan  │
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│ Filter by Device Name   │
│ Pattern Matching        │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ Connect to Device       │
│ Timeout: 10 seconds     │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ Discover Services       │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ Read Characteristic     │
│ Parse Weight Data       │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ Update User Profile     │
│ Recalculate Calories    │
└─────────────────────────┘
```

**Data Parsing:**

Xiaomi scales transmit data in **Little Endian** format:

```dart
class MiScaleParser {
  WeightData parse(List<int> rawBytes) {
    // Byte structure:
    // [0-1]: Control flags
    // [2-3]: Weight (kg) * 200 (Little Endian)
    // [4-5]: Impedance (Ohms)
    // [6-12]: Timestamp
    
    final controlByte = rawBytes[0];
    final hasImpedance = (controlByte & 0x02) != 0;
    final unit = (controlByte & 0x01) == 0 ? 'kg' : 'lb';
    
    // Convert Little Endian bytes to weight
    final weightRaw = rawBytes[2] | (rawBytes[3] << 8);
    final weight = weightRaw / 200.0; // Divide by 200 for kg
    
    return WeightData(
      weight: weight,
      unit: unit,
      timestamp: DateTime.now(),
      hasImpedance: hasImpedance,
    );
  }
}
```

**Error Handling:**
- **Connection Timeout**: Retry up to 3 times with exponential backoff
- **Invalid Data**: Validate weight range (20-200 kg)
- **Bluetooth Disabled**: Show user-friendly prompt to enable
- **Permission Denied**: Request with rationale dialog

#### 4.2.2 Huawei Watch Integration (via Health Connect)

**Architecture Decision:**
- ❌ **Not Using**: Huawei Health SDK (proprietary, limited access)
- ✅ **Using**: Google Health Connect (universal aggregator)

**Rationale:**
Huawei Health automatically syncs to Health Connect on Android, allowing us to access data through a standardized API without vendor lock-in.

**Health Connect Data Types:**

| Data Type | Description | Priority |
|-----------|-------------|----------|
| `STEPS` | Step count | High |
| `ACTIVE_ENERGY_BURNED` | Calories burned | High |
| `HEART_RATE` | BPM readings | Medium |
| `DISTANCE` | Distance traveled | Medium |
| `SPEED` | Movement speed | Low |
| `EXERCISE_SESSION` | Workout sessions | Medium |

**Data Query Strategy:**

```dart
class HealthConnectRepository {
  Future<ActivityData> getRecentActivity() async {
    final now = DateTime.now();
    final fiveMinutesAgo = now.subtract(Duration(minutes: 5));
    
    final steps = await Health().getHealthDataFromTypes(
      startTime: fiveMinutesAgo,
      endTime: now,
      types: [HealthDataType.STEPS],
    );
    
    final calories = await Health().getHealthDataFromTypes(
      startTime: fiveMinutesAgo,
      endTime: now,
      types: [HealthDataType.ACTIVE_ENERGY_BURNED],
    );
    
    return ActivityData(
      steps: steps.fold(0, (sum, item) => sum + item.value),
      calories: calories.fold(0.0, (sum, item) => sum + item.value),
      source: DataSource.healthConnect,
      timestamp: now,
    );
  }
}
```

**Sync Strategy:**
- **Polling Interval**: Every 5 minutes when app is active
- **Background Sync**: Every 15 minutes via background service
- **Real-time**: Subscribe to Health Connect broadcasts (when available)

---

### 4.3 Module C: Smart Repository (Priority Logic)

#### 4.3.1 Data Source Prioritization

**Priority Hierarchy:**

```
Priority 1: Wearable Data (Health Connect)
  ├─ Condition: Data updated within last 5 minutes
  ├─ Accuracy: ±2% (heart rate sensors available)
  └─ Confidence: 95%

Priority 2: Phone Sensors (Physics Engine)
  ├─ Condition: No recent wearable data
  ├─ Accuracy: ±5% (accelerometer-based)
  └─ Confidence: 85%

Priority 3: Manual Input
  ├─ Condition: All automatic sources unavailable
  └─ Confidence: 50%
```

**Decision Algorithm:**

```dart
class SmartActivityRepository {
  Stream<ActivityData> getActivityStream() async* {
    await for (final _ in Stream.periodic(Duration(seconds: 1))) {
      // Check Health Connect first
      final healthData = await _healthRepo.getRecentActivity();
      
      if (healthData != null && 
          healthData.timestamp.isAfter(
            DateTime.now().subtract(Duration(minutes: 5))
          )) {
        yield healthData.copyWith(
          source: DataSource.wearable,
          confidence: 0.95,
        );
        continue;
      }
      
      // Fallback to phone sensors
      final sensorData = await _sensorRepo.getCurrentActivity();
      yield sensorData.copyWith(
        source: DataSource.phoneSensor,
        confidence: 0.85,
      );
    }
  }
}
```

#### 4.3.2 Data Fusion Strategy

When both sources are available, use **weighted average**:

```dart
ActivityData fuseData(ActivityData wearable, ActivityData phone) {
  final wearableWeight = 0.7; // Higher confidence
  final phoneWeight = 0.3;
  
  return ActivityData(
    steps: (wearable.steps * wearableWeight + 
            phone.steps * phoneWeight).round(),
    calories: wearable.calories * wearableWeight + 
              phone.calories * phoneWeight,
    source: DataSource.hybrid,
    confidence: 0.98,
  );
}
```

#### 4.3.3 Anomaly Detection

**Validation Rules:**
- Steps: 0-300 per minute (max human cadence: ~270)
- Calories: 0-25 kcal/min (max sustained human output)
- Speed: 0-15 m/s (elite sprinter: ~12.5 m/s)

```dart
bool isValidActivityData(ActivityData data) {
  if (data.steps < 0 || data.steps > 300) return false;
  if (data.calories < 0 || data.calories > 25) return false;
  if (data.speed < 0 || data.speed > 15) return false;
  return true;
}
```

---

### 4.4 User Profile Management

#### 4.4.1 Biometric Data

**Required Fields:**
- **Weight** (kg): 20-200 kg, precision 0.1 kg
- **Height** (cm): 100-250 cm
- **Age** (years): 13-120 years
- **Gender**: Male / Female / Other (affects calorie calculations)

**Optional Fields:**
- **Activity Level**: Sedentary / Light / Moderate / Active / Very Active
- **Fitness Goal**: Weight Loss / Maintenance / Muscle Gain
- **Target Daily Calories**: Auto-calculated or manual

**Auto-Update Logic:**
```dart
class UserProfileService {
  Future<void> updateWeight(double newWeight, String source) async {
    final profile = await _profileRepo.get();
    
    // Validate reasonable weight change (max 5kg per week)
    if (profile.weight != null) {
      final daysSinceLastUpdate = 
        DateTime.now().difference(profile.weightUpdatedAt).inDays;
      final maxChange = (daysSinceLastUpdate / 7.0) * 5.0;
      
      if ((newWeight - profile.weight).abs() > maxChange) {
        // Flag for manual confirmation
        await _notificationService.showWeightConfirmation(newWeight);
        return;
      }
    }
    
    await _profileRepo.update(
      profile.copyWith(
        weight: newWeight,
        weightUpdatedAt: DateTime.now(),
        weightSource: source,
      ),
    );
    
    // Trigger recalculation of historical data
    await _recalculateHistoricalCalories();
  }
}
```

---

### 4.5 Activity Session Management

#### 4.5.1 Session Detection

**Auto-Start Conditions:**
- Cadence > 70 steps/min sustained for 2 minutes
- Total steps > 100 within 5-minute window

**Auto-Pause Conditions:**
- Cadence < 30 steps/min for 3 minutes
- Magnitude variance < threshold (stationary)

**Auto-End Conditions:**
- Paused for > 10 minutes
- Manual stop by user
- Phone battery < 5% (saves session)

#### 4.5.2 Session Data Model

```dart
@freezed
class ActivitySession with _$ActivitySession {
  factory ActivitySession({
    required String id,
    required DateTime startTime,
    DateTime? endTime,
    required ActivityType type,
    required int totalSteps,
    required double totalCalories,
    required double totalDistance,
    required Duration duration,
    required DataSource primarySource,
    required List<ActivityDataPoint> dataPoints,
    Map<String, dynamic>? metadata,
  }) = _ActivitySession;
}
```

---

## 5. Non-Functional Requirements

### 5.1 Performance

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Step detection latency | < 500ms | Time from physical step to UI update |
| Calorie calculation | < 100ms | Benchmark test with 1000 calculations |
| BLE scan duration | < 10s | Average time to discover Mi Scale |
| Health Connect query | < 2s | Average query time for 1-hour data |
| App cold start time | < 3s | Time to interactive UI |
| Memory footprint | < 50MB | Profiler average during active use |
| CPU usage (background) | < 2% | Android Studio Profiler |
| Battery drain | < 3%/hour | Standard fitness tracking scenario |
| Database query time | < 50ms | 95th percentile for Isar queries |

### 5.2 Reliability

- **Uptime**: 99.9% (excluding device/OS crashes)
- **Data Loss**: < 0.01% of sensor readings
- **Crash-Free Rate**: > 99.5% of sessions
- **Successful BLE Connections**: > 90% of attempts

### 5.3 Scalability

- **Local Storage**: Support 2+ years of daily data (estimated 500MB)
- **Concurrent Operations**: Handle sensor sampling + BLE + Health Connect simultaneously
- **Batch Processing**: Process up to 10,000 sensor readings/second

### 5.4 Compatibility

**Android:**
- Minimum SDK: 23 (Android 6.0 Marshmallow)
- Target SDK: 34 (Android 14)
- Health Connect: Android 9+ (API 28+)

**iOS:**
- Minimum Version: 13.0
- Target Version: 17.0
- HealthKit: iOS 13+

**Devices:**
- Screen sizes: 4.7" - 6.7"
- RAM: Minimum 2GB
- Storage: Minimum 100MB free

### 5.5 Accessibility

- **Screen Reader Support**: Full TalkBack/VoiceOver compatibility
- **Text Scaling**: Support 100%-200% system font size
- **Color Contrast**: WCAG AA compliance (4.5:1 minimum)
- **Touch Targets**: Minimum 44x44 dp (iOS HIG guidelines)
- **Localization**: English, Spanish, French, German, Chinese (Phase 1)

---

## 6. Data Models & Entities

### 6.1 Core Entities

#### ActivityData
```dart
@freezed
class ActivityData with _$ActivityData {
  factory ActivityData({
    required int steps,
    required double calories,
    required double distance,
    required double speed,
    required DataSource source,
    required DateTime timestamp,
    required double confidence,
    int? heartRate,
    ActivityType? type,
  }) = _ActivityData;
}
```

#### UserProfile
```dart
@freezed
class UserProfile with _$UserProfile {
  factory UserProfile({
    required String id,
    required String name,
    required double weight,
    required int height,
    required int age,
    required Gender gender,
    DateTime? weightUpdatedAt,
    String? weightSource,
    ActivityLevel? activityLevel,
    FitnessGoal? goal,
    double? targetDailyCalories,
    double? strideLength,
  }) = _UserProfile;
}
```

#### SensorDataPoint
```dart
@Collection()
class SensorDataPoint {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime timestamp;
  
  late double x;
  late double y;
  late double z;
  late double magnitude;
  late double filteredMagnitude;
  
  bool isStep = false;
  double? cadence;
}
```

### 6.2 Database Schema (Isar)

**Collections:**

1. **sensor_data_points**
   - Retention: 7 days
   - Index: timestamp (for range queries)
   - Estimated size: ~50KB per hour

2. **activity_sessions**
   - Retention: Unlimited (user managed)
   - Index: startTime, type
   - Estimated size: ~5KB per session

3. **user_profiles**
   - Retention: Unlimited
   - Single record (updated in place)

4. **weight_history**
   - Retention: Unlimited
   - Index: timestamp
   - Records every weight measurement

---

## 7. API & Integration Specifications

### 7.1 BLE Protocol (Mi Scale)

**Service Discovery:**
```dart
// Scan Parameters
scanDuration: Duration(seconds: 10)
scanMode: ScanMode.lowLatency
withServices: [Guid("0000181B-0000-1000-8000-00805F9B34FB")]
```

**Characteristic Read:**
```dart
// Weight Measurement Characteristic
serviceUuid: "0000181B-0000-1000-8000-00805F9B34FB"
characteristicUuid: "00002A9C-0000-1000-8000-00805F9B34FB"
properties: [Read, Notify]
```

### 7.2 Health Connect API

**Permissions Required:**
```kotlin
// Android Manifest
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED"/>
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
<uses-permission android:name="android.permission.health.READ_DISTANCE"/>
```

**Data Types Mapping:**
```dart
final dataTypes = [
  HealthDataType.STEPS,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.HEART_RATE,
  HealthDataType.DISTANCE,
  HealthDataType.MOVE_MINUTES,
];
```

---

## 8. UI/UX Specifications

### 8.1 Screen Hierarchy

```
├── Splash Screen
├── Onboarding Flow
│   ├── Welcome
│   ├── Permissions Request
│   ├── Profile Setup
│   └── Goal Setting
├── Main App (Bottom Navigation)
│   ├── Dashboard (Home)
│   ├── Activity History
│   ├── Devices
│   └── Profile
└── Modal Screens
    ├── Active Workout
    ├── BLE Scanner
    └── Settings
```

### 8.2 Dashboard Design Specifications

**Layout Structure:**
```
┌─────────────────────────────────┐
│  Status Bar: Source Indicator   │ ← 60dp height
├─────────────────────────────────┤
│                                 │
│   ╭───────────────────────╮    │
│   │  Circular Progress    │    │ ← 240dp diameter
│   │    12,543 / 10,000    │    │   Steps indicator
│   ╰───────────────────────╯    │
│                                 │
├─────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐      │
│  │ 342 kcal│  │ 8.2 km  │      │ ← Metric cards
│  └─────────┘  └─────────┘      │   120dp height
├─────────────────────────────────┤
│  Recent Activity                │
│  ├─ Morning Walk: 2,340 steps  │
│  ├─ Lunch Break: 890 steps     │
│  └─ Evening: 1,230 steps        │
└─────────────────────────────────┘
```

**Color Scheme:**

| Element | Color | Usage |
|---------|-------|-------|
| Primary | #6366F1 (Indigo) | Main brand, CTAs |
| Secondary | #10B981 (Green) | Success, wearable active |
| Warning | #F59E0B (Amber) | Phone sensor mode |
| Error | #EF4444 (Red) | Errors, disconnected |
| Background | #F9FAFB (Gray 50) | Screen background |
| Surface | #FFFFFF | Cards, elevated elements |
| Text Primary | #111827 (Gray 900) | Main text |
| Text Secondary | #6B7280 (Gray 500) | Supporting text |

**Typography:**
- **Headings**: Inter Bold / Roboto Bold
- **Body**: Inter Regular / Roboto Regular  
- **Numbers**: Roboto Mono (monospaced for metrics)

**Font Sizes:**

| Usage | Size | Weight |
|-------|------|--------|
| H1 (Dashboard Title) | 28sp | Bold |
| H2 (Section Headers) | 20sp | SemiBold |
| H3 (Card Titles) | 16sp | Medium |
| Body | 14sp | Regular |
| Caption | 12sp | Regular |
| Metric Value | 48sp | Bold |
| Metric Label | 12sp | Medium |

### 8.3 Source Indicator Component

> **✅ IMPLEMENTED** - Source label is displayed below Activity Rings in `HealthScreen`.

**States:**

| State | Icon | Text | Color |
|-------|------|------|-------|
| Wearable Active | `Icons.watch` | "Source: Huawei Watch" | Green (#10B981) |
| Phone Sensor | `Icons.smartphone` | "Source: Phone Sensor" | Amber (#F59E0B) |
| Disconnected | `Icons.link_off` | "Disconnected" | Red (#EF4444) |
| Syncing | `CircularProgressIndicator` | "Syncing..." | Primary |

---

## 9. Security & Privacy

### 9.1 Data Protection

- **Local Storage**: All sensor data stored locally using Isar (encrypted at rest on Android 10+)
- **No Cloud Sync**: User data never leaves device (Phase 1)
- **BLE Security**: Xiaomi Mi Scale uses standard BLE pairing
- **Health Connect**: Follows Google's Health Connect privacy guidelines

### 9.2 Permissions

| Permission | Android | iOS | Rationale |
|------------|---------|-----|-----------|
| Activity Recognition | Required | N/A | Step detection |
| Bluetooth | Required | Required | Mi Scale connection |
| Health Connect | Required | N/A | Wearable data access |
| HealthKit | N/A | Required | Apple Health integration |
| Location (Background) | Optional | Optional | GPS tracking for outdoor activities |

### 9.3 Data Retention

- **Sensor Data**: 7 days (auto-purge)
- **Activity Sessions**: Until user deletes
- **Weight History**: Until user deletes
- **User Profile**: Until app uninstall

---

## 10. Testing Strategy

### 10.1 Unit Tests

| Component | Coverage Target | Key Test Cases |
|-----------|-----------------|----------------|
| CalorieCalculator | 100% | MET values, edge cases (0 steps, max cadence) |
| SmartActivityRepository | 95% | Source switching, fallback logic |
| MiScaleParser | 100% | Little Endian parsing, invalid data |
| PedometerService | 90% | Day reset, step counting |

### 10.2 Integration Tests

- **Health Connect Flow**: Mock health package, verify data aggregation
- **BLE Connection**: Mock flutter_blue_plus, verify connection state machine
- **Provider Wiring**: Ensure SmartActivityRepository → ActivityProvider → UI

### 10.3 Widget Tests

- **ActivityRingsWidget**: Render with various progress levels
- **SourceIndicator**: Verify correct icon/text for each source
- **HealthScreen**: Golden tests for light/dark mode

### 10.4 E2E Tests

- **Happy Path**: App launch → Pedometer tracking → Calories update
- **Wearable Path**: Health Connect permission → Sync → Source switch
- **Scale Path**: BLE scan → Connect to Mi Scale → Weight update

---

## 11. Implementation Roadmap

### Phase 1: Core & Physics Engine ✅ COMPLETED

| Task | Status | Files |
|------|--------|-------|
| CalorieCalculator with METs | ✅ Done | `lib/core/utils/calorie_calculator.dart` |
| PedometerService | ✅ Done | `lib/core/services/pedometer_service.dart` |
| PedometerProvider | ✅ Done | `lib/core/providers/pedometer_provider.dart` |
| ActivitySummary Entity | ✅ Done | `lib/features/health/domain/entities/activity_summary.dart` |
| ActivityRepository Interface | ✅ Done | `lib/features/health/domain/repositories/activity_repository.dart` |

### Phase 2: Health Connect Integration ✅ COMPLETED

| Task | Status | Files |
|------|--------|-------|
| HealthService (Steps, Weight, HR) | ✅ Done | `lib/core/services/health_service.dart` |
| Extended: ActiveEnergy, Distance | ✅ Done | `lib/core/services/health_service.dart` |
| HealthConnectState with new fields | ✅ Done | `lib/core/providers/health_provider.dart` |
| Auto-sync (6-hour interval) | ✅ Done | `HealthConnectNotifier._startAutoSync()` |

### Phase 3: BLE Integration (Mi Scale) 🔶 PARTIALLY DONE

| Task | Status | Files |
|------|--------|-------|
| BLE Provider (Scan, Connect) | ✅ Done | `lib/core/providers/ble_provider.dart` |
| Mi Scale Parser | 🔶 Needs Verification | Device-specific testing required |
| Weight Auto-Update | 🔲 TODO | Link BLE weight to UserProfile |

### Phase 4: Smart Repository ✅ COMPLETED

| Task | Status | Files |
|------|--------|-------|
| SmartActivityRepository | ✅ Done | `lib/features/health/data/repositories/smart_activity_repository.dart` |
| Priority Logic (5-min recency) | ✅ Done | `_emitActivityUpdate()` method |
| ActivityProvider Refactor | ✅ Done | `lib/features/health/presentation/providers/activity_provider.dart` |
| Source Label in UI | ✅ Done | `lib/features/health/presentation/screens/health_screen.dart` |

### Phase 5: UI Polish 🔲 NEXT

| Task | Status | Priority |
|------|--------|----------|
| Confidence indicator | 🔲 TODO | Medium |
| Historical data view | 🔲 TODO | Low |
| Activity session auto-detection | 🔲 TODO | Medium |
| Onboarding flow | 🔲 TODO | Low |

---

## 12. Success Metrics & KPIs

### 12.1 Accuracy Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Step Accuracy (Phone) | ≥ 95% | Compare vs. manual counting |
| Step Accuracy (Watch) | ≥ 98% | Compare vs. Health Connect |
| Calorie Accuracy | ≤ 5% deviation | Compare vs. treadmill calorie output |
| Source Switch Latency | < 1 second | Time from data arrival to UI update |

### 12.2 User Engagement

| Metric | Target |
|--------|--------|
| Daily Active Users | Track growth |
| Average Session Duration | > 5 minutes |
| Permission Grant Rate | > 80% |

### 12.3 Technical Health

| Metric | Target |
|--------|--------|
| Crash-Free Sessions | > 99.5% |
| ANR Rate | < 0.1% |
| Battery Impact | < 3%/hour |

---

## 13. Risk Assessment & Mitigation

### 13.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| HealthDataType.ACTIVE_ENERGY_BURNED not supported | Medium | Medium | ✅ Graceful fallback to calculated calories |
| BLE connection failures | Medium | Low | Retry logic with exponential backoff |
| Pedometer accuracy on budget devices | Medium | Medium | Calibration option for stride length |
| Health Connect not installed | Medium | High | Show installation prompt with deep link |

### 13.2 Platform Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Android background restrictions | High | High | Use foreground service with notification |
| iOS HealthKit permission complexity | Medium | Medium | Clear onboarding with permission rationale |
| Huawei devices without Google Services | Medium | Medium | Manual Weight entry fallback |

### 13.3 ⚠️ Critical Blind Spots (Identified Post-Review)

> **IMPORTANT**: The following technical issues were identified during implementation review and require special attention.

#### 🔴 Blind Spot #1: Raw Sensors vs. OS Pedometer Contradiction

**The Issue:**
Section 4.1 describes step detection from scratch using `sensors_plus` (physics calculations at 50Hz). However, the actual implementation uses `PedometerService` which relies on the OS hardware step counter.

**Why It Matters:**
- **Raw Accelerometer (50Hz)**: ~15% battery drain/hour, requires Background Isolate
- **OS Step Counter**: ~0.5% battery drain/hour, hardware-optimized, always-on

**Resolution:**
```dart
/// ✅ CURRENT APPROACH (Battery-Efficient)
/// PedometerService uses Pedometer.stepCountStream which taps into 
/// the device's hardware step counter (TYPE_STEP_COUNTER on Android).
/// 
/// The "Physics Engine" in Section 4.1 is DOCUMENTATION ONLY for 
/// understanding the underlying math. We do NOT run raw accelerometer
/// calculations 24/7.
///
/// Fallback Strategy:
/// - Primary: OS Hardware Step Counter (via pedometer package)
/// - Fallback: Only if OS counter unavailable AND user explicitly enables
```

**Action**: ✅ No code change needed. Documentation clarified.

---

#### 🔴 Blind Spot #2: Android 14+ Background Restrictions (Aggressive App Killing)

**The Issue:**
Android 14+ aggressively kills background processes even with `flutter_background_service`. Heavy physics calculations with screen off = app termination within 2-5 minutes.

**Why It Matters:**
- Target: CPU < 2% in background
- Reality: Without proper Foreground Service declaration, app may not survive background at all

**Resolution:**
```kotlin
// AndroidManifest.xml - Required for Android 14+
<service
    android:name=".ForegroundService"
    android:foregroundServiceType="health"
    android:exported="false">
</service>

<uses-permission android:name="android.permission.FOREGROUND_SERVICE_HEALTH"/>
```

```dart
/// Foreground Service with persistent notification
/// Required for any background step tracking on Android 14+
class HealthTrackingService {
  static Future<void> startForegroundService() async {
    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        foregroundServiceNotificationId: 888,
        initialNotificationTitle: 'Life Tracker',
        initialNotificationContent: 'Tracking your activity',
      ),
    );
  }
}
```

**Action**: 🔲 TODO - Add foreground service configuration to `AndroidManifest.xml`.

---

#### 🔴 Blind Spot #3: Xiaomi Scale "Stabilized Weight" Trap

**The Issue:**
Mi Scales broadcast weight data continuously as a stream while the user stands on them. Values fluctuate rapidly (±2kg) until the user stands still. Saving every broadcast would create thousands of database entries in seconds.

**Why It Matters:**
- Scale sends ~10 readings/second while user is moving
- Only the FINAL "stabilized" reading should be saved
- Control byte contains stabilization flag

**Resolution:**
```dart
/// MiScaleParser - MUST check stabilization flag before saving
class MiScaleParser {
  /// Byte 0 Control Flags:
  /// - Bit 0: Unit (0=kg, 1=lb/catty)
  /// - Bit 1: Has impedance data
  /// - Bit 4: Weight stabilized (CRITICAL!)
  /// - Bit 5: Impedance stabilized
  
  WeightReading? parse(List<int> rawBytes) {
    if (rawBytes.length < 13) return null;
    
    final controlByte = rawBytes[0];
    final isStabilized = (controlByte & 0x20) != 0; // Bit 5
    
    // ⚠️ CRITICAL: Only accept stabilized readings
    if (!isStabilized) {
      return null; // Ignore fluctuating weight
    }
    
    final weightRaw = rawBytes[1] | (rawBytes[2] << 8);
    final weight = weightRaw / 200.0; // Little Endian, divide by 200
    
    return WeightReading(
      weight: weight,
      isStabilized: true,
      timestamp: DateTime.now(),
    );
  }
}
```

**Action**: 🔲 TODO - Implement `MiScaleService` with stabilization check (see Phase 3).

---

### 13.4 Data Aging Refinement

> **Original Logic**: Switch to phone sensor if Health Connect data > 5 minutes old.
> 
> **Problem**: 5 minutes may be too aggressive. Health Connect sync can be delayed.

**Updated Logic:**

```dart
/// SmartActivityRepository - Updated Data Aging
/// 
/// Tier 1: Health Connect (< 5 mins) → Use directly, 95% confidence
/// Tier 2: Health Connect (5-30 mins) → Use with 80% confidence  
/// Tier 3: Health Connect (> 30 mins) OR no data → Fallback to phone sensor
/// 
/// Example: User removes watch at 10:00 AM, leaves it on desk.
/// - 10:05 AM: Still showing watch data (might just be sync delay)
/// - 10:30 AM: Auto-switch to phone sensor (watch clearly not being worn)

final dataAge = now.difference(healthState.lastSyncTime!);

if (dataAge < const Duration(minutes: 5)) {
  // Tier 1: Fresh wearable data
  source = ActivityDataSource.healthConnect;
  confidence = 0.95;
} else if (dataAge < const Duration(minutes: 30)) {
  // Tier 2: Slightly stale but acceptable
  source = ActivityDataSource.healthConnect;
  confidence = 0.80;
} else {
  // Tier 3: Too old - fallback to phone
  source = ActivityDataSource.phoneSensor;
  confidence = 0.85;
}
```

**Action**: 🔲 TODO - Update `SmartActivityRepository` with tiered confidence.

---

### 13.5 UI Confidence Indicator Specification

> **Purpose**: Help users understand data accuracy at a glance.

**Visual Design:**

| Confidence Level | Icon | Color | Label | When Shown |
|------------------|------|-------|-------|------------|
| High (≥90%) | 🟢 | Green #10B981 | "High Confidence" | Fresh wearable data |
| Medium (70-89%) | 🟡 | Amber #F59E0B | "Estimated" | Phone sensor / stale watch |
| Low (<70%) | 🔴 | Red #EF4444 | "Limited Data" | Manual / very old data |

**Implementation:**

```dart
Widget buildConfidenceIndicator(double confidence) {
  final (icon, color, label) = switch (confidence) {
    >= 0.90 => ('●', Colors.green, 'High Confidence'),
    >= 0.70 => ('◐', Colors.amber, 'Estimated'),
    _ => ('○', Colors.red, 'Limited Data'),
  };
  
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(icon, style: TextStyle(color: color, fontSize: 10)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 10)),
    ],
  );
}
```

**Action**: 🔲 TODO - Add confidence indicator to `HealthScreen` next to calories.

---

## 14. Appendix

### A. Current Implementation Mapping

| PRD Component | Actual File | Status |
|---------------|-------------|--------|
| Physics Engine | `PedometerService` | ✅ Using OS step counter (reliable) |
| METs Calculator | `CalorieCalculator.getMETValue()` | ✅ Dynamic based on cadence |
| Health Connect | `HealthService` + `HealthConnectNotifier` | ✅ Core + optional data types |
| Smart Repository | `SmartActivityRepository` | ✅ Tiered confidence (5/30 min) |
| UI Source Label | `HealthScreen._buildSourceLabel()` | ✅ Shows Watch/Phone |
| Activity Rings | `ActivityRingsWidget` | ✅ Existing component |
| Mi Scale BLE | `MiScaleService` | ✅ NEW - With stabilization check |
| Confidence Field | `ActivitySummary.confidence` | ✅ NEW - 0.0-1.0 range |

### B. Key Code References

**CalorieCalculator (METs):**
```dart
// lib/core/utils/calorie_calculator.dart
static double getMETValue(double cadence) {
  if (cadence < 70) return 1.2;    // Sedentary
  if (cadence <= 100) return 3.0;  // Slow Walk
  if (cadence <= 125) return 4.0;  // Brisk Walk
  if (cadence <= 130) return 6.0;  // Fast Walk
  return 8.0;                      // Run
}
```

**SmartActivityRepository (Tiered Confidence):**
```dart
// lib/features/health/data/repositories/smart_activity_repository.dart
if (dataAge < const Duration(minutes: 5)) {
  // Tier 1: Fresh wearable data
  source = ActivityDataSource.healthConnect;
  confidence = 0.95;
} else if (dataAge < const Duration(minutes: 30)) {
  // Tier 2: Slightly stale but acceptable
  source = ActivityDataSource.healthConnect;
  confidence = 0.80;
} else {
  // Tier 3: Too old - fallback to phone
  source = ActivityDataSource.phoneSensor;
  confidence = 0.85;
}
```

**MiScaleService (Stabilization Check):**
```dart
// lib/core/services/mi_scale_service.dart
MiScaleWeightReading? _parseMiScaleData(List<int> data) {
  final controlByte = data[0];
  
  // ⚠️ CRITICAL: Check stabilization flags
  final isStabilized = (controlByte & 0x20) != 0; // Bit 5
  final isMeasuring = (controlByte & 0x10) != 0;  // Bit 4
  
  // Only accept stabilized readings
  if (isMeasuring && !isStabilized) {
    return null; // Still fluctuating - ignore
  }
  
  final weightRaw = data[1] | (data[2] << 8);
  final weight = weightRaw / 200.0; // Little Endian, divide by 200
  
  return MiScaleWeightReading(weight: weight, isStabilized: true, ...);
}
```

### C. Glossary

| Term | Definition |
|------|------------|
| MET | Metabolic Equivalent of Task - measure of energy expenditure |
| Cadence | Steps per minute |
| Health Connect | Google's unified health data API for Android |
| BLE | Bluetooth Low Energy |
| Priority Logic | Algorithm that selects best data source based on recency/quality |
| Stabilized Weight | Final reading after user stands still on scale (flag in control byte) |
| Tiered Confidence | System where data freshness determines accuracy rating (95%/80%/85%) |

---

**Document Changelog:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 2024 | Initial PRD |
| 2.0 | Dec 11, 2025 | Updated to match Life Tracker implementation, added status indicators |
| 2.1 | Dec 11, 2025 | Added critical blind spots (Section 13.3), MiScaleService with stabilization, tiered confidence logic |