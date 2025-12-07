---
name: Reminders Full Refactor & Alarm System
overview: Complete refactor of the reminders feature with a full alarm system including sound, vibration, snooze, and repeat functionality. This includes fixing all existing bugs, improving code structure, and implementing a comprehensive notification/alarm system.
todos:
  - id: refactor_provider
    content: Refactor reminder_provider.dart - simplify state management, fix duplicates, improve error handling
    status: completed
  - id: refactor_data_source
    content: Optimize reminder_local_data_source.dart - ensure unique results, improve queries
    status: completed
  - id: refactor_screen
    content: Refactor reminders_screen.dart - simplify logic, improve error handling
    status: completed
  - id: add_dependencies
    content: Add required packages (vibration, audio) to pubspec.yaml
    status: completed
  - id: update_entity
    content: Add alarm properties to Reminder entity (hasAlarm, alarmSound, vibrate, snoozeDuration, repeatCount)
    status: completed
  - id: update_model
    content: Update ReminderModel with new alarm fields and regenerate Isar schema
    status: completed
    dependencies:
      - update_entity
  - id: create_alarm_service
    content: Create AlarmService with scheduling, ringing, snooze, and dismiss functionality
    status: completed
    dependencies:
      - add_dependencies
  - id: create_alarm_sound_service
    content: Create AlarmSoundService for managing alarm sounds and playback
    status: completed
    dependencies:
      - add_dependencies
  - id: update_notification_service
    content: Add alarm notification channel with high importance to NotificationService
    status: completed
  - id: create_alarm_ringing_screen
    content: Create full-screen alarm ringing UI with dismiss and snooze buttons
    status: completed
    dependencies:
      - create_alarm_service
  - id: update_reminder_notification_service
    content: Integrate AlarmService into ReminderNotificationService
    status: completed
    dependencies:
      - create_alarm_service
  - id: update_add_dialog
    content: Add alarm settings UI to AddReminderDialog (toggle, sound, vibration, snooze)
    status: completed
    dependencies:
      - update_entity
  - id: update_reminder_card
    content: Show alarm icon and status in ReminderCard
    status: completed
    dependencies:
      - update_entity
  - id: integrate_provider
    content: Integrate AlarmService into ReminderNotifier (schedule/cancel on add/update/delete)
    status: completed
    dependencies:
      - create_alarm_service
      - refactor_provider
  - id: update_router
    content: Add route for alarm ringing screen in app_router.dart
    status: completed
    dependencies:
      - create_alarm_ringing_screen
  - id: platform_config
    content: Add Android/iOS permissions and configuration for alarms
    status: completed
    dependencies:
      - add_dependencies
  - id: app_initialization
    content: Initialize AlarmService and request permissions in app startup
    status: completed
    dependencies:
      - create_alarm_service
      - platform_config
  - id: testing
    content: Test all alarm scenarios (ring, dismiss, snooze, recurring, multiple alarms)
    status: pending
    dependencies:
      - integrate_provider
      - update_router
      - app_initialization
---

# Reminders Full Refactor & Alarm System Implementation Plan

## Overview

Complete refactor of the reminders feature with a full alarm system. This plan addresses code quality, bug fixes, and implements a comprehensive alarm system with sound, vibration, snooze, and repeat functionality.

## Phase 1: Code Structure Refactoring

### 1.1 Provider Refactoring

**File:** `lib/features/reminders/presentation/providers/reminder_provider.dart`

**Issues to Fix:**

- Remove complex `Future.microtask` and `invalidate` patterns
- Simplify state management
- Fix duplicate reminders issue at the source
- Improve error handling
- Remove unnecessary `_ref` parameter complexity

**Changes:**

- Refactor `ReminderNotifier` to use cleaner state management
- Remove duplicate filtering logic (handle at data source level)
- Simplify provider invalidation strategy
- Add proper error recovery mechanisms
- Use `ref.invalidate` only when necessary, not after every operation

### 1.2 Data Source Optimization

**File:** `lib/features/reminders/data/datasources/reminder_local_data_source.dart`

**Changes:**

- Ensure queries return unique results (no duplicates)
- Optimize database queries
- Add proper indexing hints if needed
- Improve error messages

### 1.3 Screen Refactoring

**File:** `lib/features/reminders/presentation/screens/reminders_screen.dart`

**Changes:**

- Simplify `_groupReminders` logic
- Improve `Dismissible` error handling
- Add proper loading states
- Remove unused methods (`_deleteReminder`)
- Improve refresh logic

### 1.4 Repository & Use Cases

**Files:**

- `lib/features/reminders/data/repositories/reminder_repository_impl.dart`
- `lib/features/reminders/domain/usecases/*.dart`

**Changes:**

- Ensure all use cases handle errors properly
- Add validation logic
- Improve error messages
- Ensure data consistency

## Phase 2: Alarm System Implementation

### 2.1 Alarm Service Creation

**New File:** `lib/features/reminders/services/alarm_service.dart`

**Features:**

- Schedule alarms with sound and vibration
- Handle alarm ringing (repeat sound until dismissed)
- Snooze functionality (reschedule after X minutes)
- Cancel alarms
- Get active alarms
- Handle alarm actions (dismiss, snooze)

**Dependencies:**

- Use `flutter_local_notifications` for scheduling
- Use `audioplayers` for alarm sound playback
- Use `vibration` package (may need to add) for vibration
- Use `just_audio` or similar for better audio control

### 2.2 Alarm Notification Channel

**File:** `lib/core/services/notification_service.dart`

**Changes:**

- Add dedicated alarm notification channel with high importance
- Configure channel for sound and vibration
- Set up foreground service for alarms (Android)
- Configure notification actions (Dismiss, Snooze)

### 2.3 Alarm UI Components

**New Files:**

- `lib/features/reminders/presentation/widgets/alarm_ringing_screen.dart` - Full-screen alarm UI
- `lib/features/reminders/presentation/widgets/alarm_controls.dart` - Dismiss/Snooze buttons

**Features:**

- Full-screen alarm interface when alarm rings
- Large dismiss button
- Snooze button (with configurable duration)
- Display reminder title and description
- Show current time
- Play alarm sound in loop
- Vibrate continuously

### 2.4 Alarm Sound Management

**New File:** `lib/features/reminders/services/alarm_sound_service.dart`

**Features:**

- Manage alarm sound files
- Provide default alarm sounds
- Allow custom alarm sounds (future enhancement)
- Control volume
- Loop playback until dismissed

### 2.5 Update Reminder Notification Service

**File:** `lib/features/reminders/services/reminder_notification_service.dart`

**Changes:**

- Integrate with `AlarmService` instead of basic notifications
- Schedule alarms instead of simple notifications
- Handle alarm-specific actions
- Support snooze functionality
- Support recurring alarms

## Phase 3: Reminder Entity Enhancements

### 3.1 Add Alarm Properties

**File:** `lib/features/reminders/domain/entities/reminder.dart`

**New Properties:**

- `bool hasAlarm` - Whether reminder has alarm enabled
- `String? alarmSound` - Path to alarm sound file
- `bool vibrate` - Whether to vibrate
- `int snoozeDuration` - Snooze duration in minutes (default: 5)
- `int repeatCount` - How many times to repeat alarm sound (-1 for infinite)

### 3.2 Update Reminder Model

**File:** `lib/features/reminders/data/models/reminder_model.dart`

**Changes:**

- Add new fields to match entity
- Update Isar schema
- Run code generation

## Phase 4: UI Updates

### 4.1 Add Reminder Dialog Updates

**File:** `lib/features/reminders/presentation/widgets/add_reminder_dialog.dart`

**New Features:**

- Toggle for alarm on/off
- Alarm sound selector
- Vibration toggle
- Snooze duration selector
- Repeat count selector

### 4.2 Reminder Card Updates

**File:** `lib/features/reminders/presentation/widgets/reminder_card.dart`

**Changes:**

- Show alarm icon if alarm is enabled
- Display alarm time prominently
- Show snooze status if applicable

## Phase 5: Integration & Testing

### 5.1 Provider Integration

**File:** `lib/features/reminders/presentation/providers/reminder_provider.dart`

**Changes:**

- Integrate `AlarmService` into reminder operations
- Schedule alarms when reminders are added/updated
- Cancel alarms when reminders are deleted/completed
- Handle alarm actions (dismiss, snooze)

### 5.2 App Initialization

**File:** `lib/main.dart` or initialization file

**Changes:**

- Initialize `AlarmService` on app start
- Request notification permissions
- Request audio/vibration permissions
- Set up alarm handlers

### 5.3 Navigation Updates

**File:** `lib/core/router/app_router.dart`

**Changes:**

- Add route for alarm ringing screen
- Handle deep links from alarm notifications

## Phase 6: Dependencies & Configuration

### 6.1 Add Required Packages

**File:** `pubspec.yaml`

**New Dependencies:**

- `vibration` - For vibration support
- `just_audio` or keep `audioplayers` - For better audio control
- `flutter_ringtone_player` (optional) - For system ringtones

### 6.2 Platform Configuration

**Files:**

- `android/app/src/main/AndroidManifest.xml` - Add permissions and foreground service
- `ios/Runner/Info.plist` - Add permissions

**Android Permissions:**

- `VIBRATE`
- `USE_FULL_SCREEN_INTENT` (for alarm screen)
- `FOREGROUND_SERVICE` (for alarm service)

**iOS Permissions:**

- Audio playback permissions
- Notification permissions

## Phase 7: Testing & Bug Fixes

### 7.1 Test Scenarios

- Create reminder with alarm
- Alarm rings at scheduled time
- Dismiss alarm
- Snooze alarm
- Recurring reminders with alarms
- Multiple alarms
- Alarm with sound and vibration
- Alarm without sound (vibration only)
- Cancel alarm when reminder is deleted
- Cancel alarm when reminder is completed

### 7.2 Bug Fixes

- Fix duplicate reminders issue
- Fix crash on delete
- Fix upcoming reminders not showing
- Fix completed reminders duplication
- Fix notification scheduling issues

## Implementation Order

1. **Phase 1** - Code refactoring (fix existing bugs first)
2. **Phase 6** - Add dependencies and platform config
3. **Phase 3** - Update entity and model
4. **Phase 2** - Implement alarm system
5. **Phase 4** - Update UI
6. **Phase 5** - Integration
7. **Phase 7** - Testing and final bug fixes

## Files to Create

1. `lib/features/reminders/services/alarm_service.dart`
2. `lib/features/reminders/services/alarm_sound_service.dart`
3. `lib/features/reminders/presentation/widgets/alarm_ringing_screen.dart`
4. `lib/features/reminders/presentation/widgets/alarm_controls.dart`

## Files to Modify

1. `lib/features/reminders/presentation/providers/reminder_provider.dart`
2. `lib/features/reminders/presentation/screens/reminders_screen.dart`
3. `lib/features/reminders/data/datasources/reminder_local_data_source.dart`
4. `lib/features/reminders/domain/entities/reminder.dart`
5. `lib/features/reminders/data/models/reminder_model.dart`
6. `lib/features/reminders/services/reminder_notification_service.dart`
7. `lib/core/services/notification_service.dart`
8. `lib/features/reminders/presentation/widgets/add_reminder_dialog.dart`
9. `lib/features/reminders/presentation/widgets/reminder_card.dart`
10. `lib/core/router/app_router.dart`
11. `pubspec.yaml`
12. Platform configuration files

## Notes

- Keep backward compatibility with existing reminders (default alarm settings)
- Ensure alarms work when app is closed (background execution)
- Handle timezone changes
- Handle device reboot (reschedule alarms)
- Consider battery optimization impact
- Test on both Android and iOS