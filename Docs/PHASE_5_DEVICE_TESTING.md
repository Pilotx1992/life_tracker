# Phase 5: Device Testing Guide

**Date Started**: 2026-01-16
**Status**: 🚧 IN PROGRESS
**Priority**: HIGH
**Goal**: Verify app works correctly on real devices across different Android versions

---

## Overview

Phase 5 focuses on comprehensive device testing to ensure the Life Tracker app works correctly across different:
- Android versions (8.0 to 14+)
- Screen sizes (5.5" to 6.7"+)
- Device performance levels (low-end to high-end)
- UI/UX scenarios (light/dark mode, RTL, etc.)

---

## Pre-Testing Setup

### 1. Build Debug APK ✅

**Command**:
```bash
flutter build apk --debug
```

**Output Location**:
```
build/app/outputs/flutter-apk/app-debug.apk
```

**APK Info**:
- **Type**: Debug build
- **Size**: ~40-60MB (with debug symbols)
- **Permissions**: All declared in AndroidManifest.xml
- **Min SDK**: Android 8.0 (API 26)
- **Target SDK**: Android 34

### 2. Available Testing Options

#### Option A: Physical Devices (Recommended)
- **Best for**: Real-world testing, performance validation
- **Requirements**: Android device, USB cable, USB debugging enabled
- **Setup**:
  1. Enable Developer Options on device
  2. Enable USB Debugging
  3. Connect device via USB
  4. Run: `adb devices` to verify connection

#### Option B: Android Emulators
- **Best for**: Testing multiple Android versions
- **Requirements**: Android Studio, Android Emulator
- **Available Emulator**: XM
- **Setup**: `flutter emulators --launch XM`

#### Option C: Both (Ideal)
- Test on 1-2 physical devices + 1-2 emulators
- Covers real-world + various OS versions

---

## Device Testing Matrix

### Recommended Test Devices

| Priority | Device Type | OS Version | Screen | Purpose |
|----------|-------------|------------|--------|---------|
| 🔴 HIGH | Physical Device | Your device | Any | Real-world testing |
| 🟡 MED | Emulator | Android 8.0 (API 26) | 5.5" | Min SDK testing |
| 🟡 MED | Emulator | Android 11 (API 30) | 6.1" | Target audience |
| 🟢 LOW | Emulator | Android 14 (API 34) | 6.7" | Latest features |

### Current Available Devices
- ✅ Emulator "XM" available
- ⏳ Physical devices (to be connected)

---

## Installation & Setup Testing

### Test Checklist:

#### 1. Clean Installation
- [ ] Transfer APK to device (or install via `adb install`)
- [ ] Install APK
- [ ] App icon displays correctly on launcher
- [ ] App name shows as "Life Tracker"
- [ ] No installation errors

**Commands**:
```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# Or reinstall (uninstall first)
adb uninstall com.yourcompany.life_tracker
adb install build/app/outputs/flutter-apk/app-debug.apk
```

#### 2. First Launch
- [ ] Splash screen displays (if implemented)
- [ ] App launches successfully (<3 seconds)
- [ ] No crash on first launch
- [ ] Permission requests appear (if needed)
  - [ ] Notification permission
  - [ ] Storage permission (if needed)
  - [ ] Other permissions as required

#### 3. Onboarding Flow
- [ ] Onboarding screens display correctly
- [ ] Can navigate through onboarding
- [ ] Can skip onboarding (if applicable)
- [ ] Profile setup works
- [ ] Initial database created successfully
- [ ] Reaches dashboard after onboarding

---

## Core Functionality Testing

### Dashboard Module

#### Test Cases:
- [ ] **Dashboard loads successfully**
  - All widgets display correctly
  - Summary cards show placeholder/initial data
  - No layout overflow errors

- [ ] **Navigation works**
  - Bottom navigation bar visible
  - Can navigate to all 5 modules:
    - [ ] Dashboard
    - [ ] Finance
    - [ ] Health
    - [ ] Notes
    - [ ] Reminders
    - [ ] Settings

- [ ] **Dashboard customization** (if implemented)
  - Widget reordering works
  - Widget visibility toggle works
  - Settings persist after restart

### Finance Module

#### Test Cases:
- [ ] **Accounts**
  - Can add new account
  - Can edit account
  - Can delete account
  - Account list displays correctly
  - Account balance updates correctly

- [ ] **Expenses**
  - Can add new expense
  - Can edit expense
  - Can delete expense
  - Expense list displays correctly
  - Categories work correctly
  - Date picker works

- [ ] **Income**
  - Can add new income
  - Can edit income
  - Can delete income
  - Income list displays correctly
  - Sources work correctly

- [ ] **Bills**
  - Can add recurring bill
  - Can mark bill as paid
  - Bill due dates calculate correctly
  - Overdue bills highlighted
  - Next due date shows correctly

- [ ] **Debts**
  - Can add new debt
  - Can record payment
  - Can mark as paid off
  - Interest calculations correct
  - Payment history displays

- [ ] **Commitments**
  - Can add financial commitment
  - Can edit commitment
  - Can delete commitment
  - Recurring logic works

- [ ] **Credit Cards**
  - Can add credit card account
  - Can record payment
  - Balance updates correctly
  - Payment history shows

### Health Module

#### Test Cases:
- [ ] **Weight Tracking**
  - Can add weight entry
  - Can edit weight entry
  - Can delete weight entry
  - Weight chart displays correctly
  - BMI calculation correct
  - Goal weight shows

- [ ] **Medications**
  - Can add medication
  - Can edit medication
  - Can delete medication
  - Medication schedule works
  - Reminders trigger (if enabled)

- [ ] **Activities**
  - Can add activity
  - Can edit activity
  - Can delete activity
  - Activity log displays

### Notes Module

#### Test Cases:
- [ ] **Basic Notes**
  - Can create new note
  - Can edit note
  - Can delete note
  - Rich text formatting works
  - Notes list displays correctly

- [ ] **Checklists**
  - Can add checklist items
  - Can check/uncheck items
  - Can reorder items
  - Checklist state persists

- [ ] **Attachments** (if implemented)
  - Can attach files
  - Can view attachments
  - Can delete attachments

- [ ] **Voice Recording** (if implemented)
  - Can record voice note
  - Can play recording
  - Can delete recording

- [ ] **Encryption** (if implemented)
  - Can encrypt note with PIN
  - Can decrypt note with correct PIN
  - Cannot decrypt with wrong PIN

### Reminders Module

#### Test Cases:
- [ ] **Basic Reminders**
  - Can create reminder
  - Can edit reminder
  - Can delete reminder
  - Reminder list displays correctly

- [ ] **Scheduling**
  - Can set reminder date/time
  - Can set recurring reminder
  - Notification appears at scheduled time
  - Notification sound works
  - Notification actions work

- [ ] **Completion**
  - Can mark reminder as complete
  - Completed reminders handled correctly
  - Can snooze reminder (if implemented)

### Settings Module

#### Test Cases:
- [ ] **Theme Settings**
  - Can switch between light/dark mode
  - Theme change is immediate
  - Theme persists after restart
  - All screens respect theme

- [ ] **Language Settings**
  - Can switch to Arabic
  - RTL layout works correctly
  - All text translates correctly
  - Can switch back to English

- [ ] **App Lock**
  - Can enable app lock
  - Can set PIN
  - Can enable biometric
  - Lock triggers correctly
  - Unlock works with correct PIN
  - Unlock works with biometric

- [ ] **Backup & Restore**
  - Can export backup (JSON)
  - Backup file created successfully
  - Can import backup
  - Data restores correctly

- [ ] **About Section**
  - App version displays correctly
  - Privacy policy opens
  - Terms of service opens

---

## Data Persistence Testing

### Test Cases:
- [ ] **After app restart**
  - All data persists
  - Settings persist
  - User state maintained
  - No data loss

- [ ] **After device reboot**
  - All data persists
  - Notifications still scheduled
  - Settings maintained
  - App lock state persists

- [ ] **After app update** (for future)
  - Data migrates correctly
  - No data loss
  - App continues to work

---

## UI/UX Testing

### Visual Testing

#### Light Mode
- [ ] All screens render correctly
- [ ] Text is readable
- [ ] Colors are appropriate
- [ ] Icons visible
- [ ] No visual glitches

#### Dark Mode
- [ ] All screens render correctly
- [ ] Text is readable (white on dark)
- [ ] Colors adjusted appropriately
- [ ] Icons visible
- [ ] No burn-in risk (true black or dark gray)

#### RTL (Arabic)
- [ ] Layout flips correctly
- [ ] Text aligns right
- [ ] Icons in correct positions
- [ ] Navigation flows right-to-left
- [ ] No layout breaking

### Responsive Design
- [ ] Works on small screens (5.5")
- [ ] Works on medium screens (6.1")
- [ ] Works on large screens (6.7"+)
- [ ] Text scales correctly
- [ ] No overflow errors
- [ ] Padding/margins appropriate

### Animations
- [ ] Smooth page transitions
- [ ] Smooth list scrolling (60fps)
- [ ] Loading animations smooth
- [ ] Button press feedback immediate
- [ ] No janky animations
- [ ] No stuttering

---

## Performance Testing

### App Launch Time
- [ ] **Cold start**: <3 seconds
- [ ] **Warm start**: <1 second
- [ ] **Hot reload**: Instant

**How to measure**:
```bash
# Use adb logcat to see timing
adb logcat | grep "Displayed com.yourcompany.life_tracker"
```

### Scrolling Performance
- [ ] Lists scroll smoothly at 60fps
- [ ] No dropped frames during scroll
- [ ] Large lists (100+ items) perform well
- [ ] Images load without blocking UI

**Test with**:
- Finance: 100+ expenses
- Health: 100+ weight entries
- Notes: 50+ notes

### Memory Usage
- [ ] No memory leaks detected
- [ ] Memory usage stable over time
- [ ] App doesn't grow unbounded

**How to check**:
```bash
# Check memory usage
adb shell dumpsys meminfo com.yourcompany.life_tracker
```

### Battery Usage
- [ ] App doesn't drain battery abnormally
- [ ] No wakelocks keeping device awake
- [ ] Background usage minimal

**How to check**:
- Android Settings → Battery → Battery Usage
- Look for Life Tracker usage

### Database Performance
- [ ] Queries are fast (<100ms)
- [ ] No UI blocking from DB operations
- [ ] Large datasets handled well

---

## Edge Cases Testing

### Low Memory
- [ ] App handles low memory gracefully
- [ ] No crash when memory constrained
- [ ] Data not lost during low memory

**How to test**:
```bash
# Simulate low memory
adb shell am send-trim-memory com.yourcompany.life_tracker MODERATE
```

### No Internet Connection
- [ ] App works offline (offline-first)
- [ ] No crashes from network errors
- [ ] Appropriate messaging if internet needed

### Full Storage
- [ ] App handles full storage gracefully
- [ ] Shows appropriate error message
- [ ] Doesn't crash

### Date/Time Changes
- [ ] Scheduled notifications adjust correctly
- [ ] Bill due dates correct after time zone change
- [ ] No crashes from date changes

### Language Changes
- [ ] App adapts to system language
- [ ] Translations load correctly
- [ ] No crashes from language switch

### Rotation (if enabled)
- [ ] Layout adapts to landscape
- [ ] No data loss during rotation
- [ ] State preserved

---

## Notification Testing

### Test Cases:
- [ ] **Basic notifications**
  - Notification appears
  - Title and body correct
  - Icon displays correctly

- [ ] **Scheduled notifications**
  - Appears at exact scheduled time
  - Sound plays (if enabled)
  - Vibration works (if enabled)

- [ ] **Notification actions** (if implemented)
  - Action buttons work
  - Correct action triggered
  - App opens to correct screen

- [ ] **Notification permissions**
  - Permission requested correctly
  - Works after granted
  - Handles denied gracefully

**How to test**:
1. Create reminder for 1 minute from now
2. Close app or put in background
3. Wait for notification
4. Verify notification appears
5. Tap notification → app opens to reminder

---

## Security Testing

### App Lock
- [ ] PIN lock works correctly
- [ ] Biometric lock works correctly
- [ ] Lock triggers immediately
- [ ] Lock after timeout works
- [ ] Failed attempts handled
- [ ] Can't bypass lock

### Data Security
- [ ] Encrypted notes stay encrypted
- [ ] PIN stored securely (flutter_secure_storage)
- [ ] No sensitive data in logs
- [ ] No data leak through screenshots (if lock enabled)

### Permissions
- [ ] Only necessary permissions requested
- [ ] Permissions requested at right time
- [ ] Graceful degradation if denied

---

## Crash Testing

### Scenarios to Test:
- [ ] App doesn't crash with empty data
- [ ] App doesn't crash with large data
- [ ] App doesn't crash with invalid input
- [ ] App doesn't crash on rapid button taps
- [ ] App doesn't crash on rapid navigation
- [ ] App doesn't crash on back button spam

**How to check crashes**:
```bash
# View crash logs
adb logcat -d | grep -i "crash\|exception\|error"

# Clear logs, reproduce crash, view new logs
adb logcat -c
# Reproduce crash
adb logcat -d > crash_log.txt
```

---

## Bug Reporting Template

If you find any bugs during testing, document them using this format:

```markdown
## Bug Report: [Short Title]

**Bug ID**: BUG-001
**Severity**: Critical / High / Medium / Low
**Status**: Open / In Progress / Fixed / Closed

### Environment
- **Device**: [e.g., Samsung Galaxy S21]
- **OS Version**: [e.g., Android 12 (API 31)]
- **App Version**: [e.g., 1.0.0 debug]
- **Build**: [e.g., app-debug.apk]

### Description
[Clear description of the bug]

### Steps to Reproduce
1. [First step]
2. [Second step]
3. [Third step]
4. [etc.]

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Screenshots/Video
[Attach screenshots or video if applicable]

### Logs
```
[Paste relevant logs from adb logcat]
```

### Frequency
- [ ] Always reproducible
- [ ] Sometimes reproducible (X out of Y attempts)
- [ ] Rarely reproducible

### Workaround
[If a workaround exists, describe it]

### Additional Notes
[Any other relevant information]
```

---

## Testing Progress Tracking

### Device Testing Status

#### Device 1: [Device Name]
- **OS**: Android X.X
- **Status**: Not Started / In Progress / Complete
- **Tests Passed**: 0 / X
- **Bugs Found**: 0
- **Notes**: [Any notes]

#### Device 2: [Device Name]
- **OS**: Android X.X
- **Status**: Not Started / In Progress / Complete
- **Tests Passed**: 0 / X
- **Bugs Found**: 0
- **Notes**: [Any notes]

#### Device 3: [Device Name]
- **OS**: Android X.X
- **Status**: Not Started / In Progress / Complete
- **Tests Passed**: 0 / X
- **Bugs Found**: 0
- **Notes**: [Any notes]

### Overall Progress

| Category | Tests | Passed | Failed | % Complete |
|----------|-------|--------|--------|------------|
| Installation | 0 | 0 | 0 | 0% |
| Core Functionality | 0 | 0 | 0 | 0% |
| Data Persistence | 0 | 0 | 0 | 0% |
| UI/UX | 0 | 0 | 0 | 0% |
| Performance | 0 | 0 | 0 | 0% |
| Edge Cases | 0 | 0 | 0 | 0% |
| Notifications | 0 | 0 | 0 | 0% |
| Security | 0 | 0 | 0 | 0% |
| **TOTAL** | **0** | **0** | **0** | **0%** |

---

## Tools & Commands Reference

### ADB Commands

```bash
# List connected devices
adb devices

# Install APK
adb install path/to/app.apk

# Reinstall APK (keeps data)
adb install -r path/to/app.apk

# Uninstall app
adb uninstall com.yourcompany.life_tracker

# View logs
adb logcat

# View logs for specific app
adb logcat | grep life_tracker

# Clear logs
adb logcat -c

# Take screenshot
adb shell screencap /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# Record video
adb shell screenrecord /sdcard/demo.mp4
# Stop with Ctrl+C after recording
adb pull /sdcard/demo.mp4

# Check memory usage
adb shell dumpsys meminfo com.yourcompany.life_tracker

# Check battery usage
adb shell dumpsys batterystats com.yourcompany.life_tracker

# Simulate low memory
adb shell am send-trim-memory com.yourcompany.life_tracker MODERATE

# Force stop app
adb shell am force-stop com.yourcompany.life_tracker

# Start app
adb shell am start -n com.yourcompany.life_tracker/.MainActivity

# Check app version
adb shell dumpsys package com.yourcompany.life_tracker | grep versionName
```

### Flutter Commands

```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Run on connected device
flutter run

# Run with specific device
flutter run -d <device_id>

# Check connected devices
flutter devices

# Launch emulator
flutter emulators --launch XM

# Hot reload (while app running)
# Press 'r' in terminal

# Hot restart (while app running)
# Press 'R' in terminal

# Open DevTools
flutter pub global run devtools
```

---

## Phase 5 Completion Criteria

Phase 5 is considered complete when:

- [ ] **Tested on minimum 3 devices/emulators**
  - At least 1 physical device OR 3 emulators
  - Covering Android 8.0, 11, and 14

- [ ] **All critical functionality verified**
  - Installation works
  - All 5 modules functional
  - Data persists correctly
  - No critical bugs

- [ ] **Performance acceptable**
  - Launch time <3 seconds
  - Smooth scrolling (60fps)
  - No memory leaks
  - Acceptable battery usage

- [ ] **UI/UX polished**
  - Light/dark mode works
  - RTL layout correct
  - No visual glitches
  - Animations smooth

- [ ] **Bugs documented**
  - All bugs logged in bug tracking
  - Critical bugs fixed before release
  - Medium/low bugs tracked for future

- [ ] **Sign-off ready**
  - Testing summary created
  - Known issues documented
  - Release recommendation made

---

## Next Steps After Phase 5

Once device testing is complete:

1. **Fix Critical Bugs** (if any found)
   - Prioritize by severity
   - Test fixes on affected devices
   - Verify no regressions

2. **Update Documentation**
   - Document test results
   - Update [PROGRESS.md](PROGRESS.md)
   - Update [ROADMAP.md](ROADMAP.md)

3. **Proceed to Phase 6: Release Build**
   - Generate signing key
   - Configure ProGuard
   - Build release APK/AAB
   - Test release build

---

## Resources

- [Flutter Debugging Guide](https://docs.flutter.dev/testing/debugging)
- [Android Debug Bridge (adb)](https://developer.android.com/studio/command-line/adb)
- [Android Testing Guide](https://developer.android.com/training/testing)
- [Flutter Performance Profiling](https://docs.flutter.dev/perf/ui-performance)

---

**Document Created**: 2026-01-16
**Status**: Ready for use
**Related Documents**:
- [ROADMAP.md](ROADMAP.md) - Phase 5 overview
- [PROGRESS.md](PROGRESS.md) - Current progress
