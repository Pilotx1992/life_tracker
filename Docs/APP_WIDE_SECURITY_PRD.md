# Product Requirements Document: App-Wide Security

**Project:** Life Tracker  
**Feature:** App-Wide PIN & Biometric Lock  
**Version:** 1.0  
**Date:** 2026-01-18  
**Status:** Draft - Pending Approval

---

## 1. Overview

### 1.1 Problem Statement
The current per-note locking feature is:
- Complex to use (users must lock/unlock each note individually)
- Bug-prone (PIN verification issues, context handling problems)
- Inconsistent with other app data (health, finance, reminders are unprotected)

### 1.2 Solution
Replace per-note locking with **app-wide security** that protects ALL app data behind a single PIN/Biometric lock, similar to banking and finance apps.

### 1.3 Goals
| Goal | Metric |
|------|--------|
| Simplify security UX | Single lock protects entire app |
| Improve reliability | Session-based auth (no per-item encryption) |
| Consistent protection | All features (notes, health, finance) protected equally |
| Modern UX | Biometric support, auto-lock, lockout protection |

---

## 2. User Stories

### 2.1 First-Time Setup
> **As a user**, I want to optionally enable app protection with a PIN so that my personal data is secure.

**Acceptance Criteria:**
- Settings → Security → "Enable App Lock" toggle
- First enable prompts for 4-digit PIN creation
- PIN must be confirmed (enter twice)
- Weak PINs (1111, 1234) show warning but are allowed

### 2.2 Biometric Setup
> **As a user**, I want to unlock the app with my fingerprint/face so I don't have to enter PIN every time.

**Acceptance Criteria:**
- Option only available after PIN is set
- Settings → Security → "Use Biometric" toggle
- Enabling requires biometric verification
- Falls back to PIN if biometric fails

### 2.3 Auto-Lock
> **As a user**, I want the app to automatically lock after being in the background so that someone can't access my data if I forget to lock.

**Acceptance Criteria:**
- Settings → Security → Auto-Lock Timeout (Immediate, 30s, 1min, 5min, Never)
- Default: 30 seconds
- Lock triggers when app returns from background after timeout expires
- Active session extends timeout

### 2.4 Manual Lock
> **As a user**, I want to manually lock the app immediately when needed.

**Acceptance Criteria:**
- "Lock Now" button in Settings → Security
- Immediately shows unlock screen

### 2.5 Lockout Protection
> **As a user**, I want protection against brute-force attacks on my PIN.

**Acceptance Criteria:**
- After 5 failed attempts: 30-second lockout
- After 10 failed attempts: 5-minute lockout
- Counter resets on successful unlock
- Lockout persists across app restarts

### 2.6 Change/Delete PIN
> **As a user**, I want to change or remove my PIN.

**Acceptance Criteria:**
- Change PIN requires current PIN verification
- New PIN must be different from current
- Disable App Lock removes PIN and biometric settings
- Disabling requires current PIN verification

---

## 3. Functional Requirements

### 3.1 Security Service

| Function | Description |
|----------|-------------|
| `setupPin(pin)` | First-time PIN creation with salt generation |
| `verifyPin(pin)` | Verify PIN against stored hash |
| `changePin(old, new)` | Change PIN (requires old PIN) |
| `deletePin()` | Remove PIN and disable security |
| `enableBiometric()` | Enable fingerprint/face unlock |
| `disableBiometric()` | Disable biometric unlock |
| `authenticateWithBiometric()` | Perform biometric auth |
| `lockApp()` | Set app to locked state |
| `unlockApp()` | Set app to unlocked state |
| `shouldLockOnResume(pausedTime)` | Check if should lock based on timeout |

### 3.2 Security Settings (Persisted)

| Setting | Type | Default |
|---------|------|---------|
| `isPinEnabled` | bool | false |
| `isBiometricEnabled` | bool | false |
| `pinSalt` | String | null |
| `failedAttempts` | int | 0 |
| `lockoutUntil` | DateTime | null |
| `autoLockTimeout` | int (seconds) | 30 |
| `sessionDuration` | int (minutes) | 15 |
| `sessionStartTime` | DateTime | null |
| `lastUnlockedAt` | DateTime | null |

### 3.3 PIN Security

- **Length:** 4 digits only
- **Storage:** SHA-256 hash with random salt (32 chars)
- **Salt Storage:** Hive (SecuritySettings)
- **Hash Storage:** FlutterSecureStorage

### 3.4 Unlock Screen

| Element | Behavior |
|---------|----------|
| App Logo | Centered at top |
| PIN Dots | 4 dots showing entered digits |
| Numeric Keypad | 0-9 digits, backspace |
| Biometric Button | Shows if biometric enabled |
| Error Message | Red text below dots |
| Lockout Banner | Red banner with countdown |

### 3.5 Auto-Lock Logic

```
ON app_resume:
  IF pin_enabled:
    IF session_active:
      stay_unlocked
    ELSE IF pause_duration >= auto_lock_timeout:
      lock_app
    ELSE:
      stay_unlocked
```

---

## 4. Non-Functional Requirements

| Requirement | Specification |
|-------------|---------------|
| **Performance** | Unlock screen loads in < 200ms |
| **Security** | PIN never stored in plaintext |
| **Accessibility** | Keypad buttons 48x48dp minimum |
| **Compatibility** | Android 8.0+ (API 26+) |
| **Localization** | English & Arabic support |
| **Theme** | Light & Dark mode support |

---

## 5. UI/UX Design

### 5.1 Settings → Security Section

```
┌──────────────────────────────────────┐
│ 🔒 Security                          │
├──────────────────────────────────────┤
│ App Lock                    [Toggle] │
│ Change PIN                      [>]  │
│ Use Biometric               [Toggle] │
├──────────────────────────────────────┤
│ Auto-Lock                            │
│   ○ Immediately                      │
│   ● After 30 seconds                 │
│   ○ After 1 minute                   │
│   ○ After 5 minutes                  │
│   ○ Never                            │
├──────────────────────────────────────┤
│ [Lock Now]                           │
└──────────────────────────────────────┘
```

### 5.2 Unlock Screen

```
┌──────────────────────────────────────┐
│                                      │
│           [App Logo]                 │
│          Life Tracker                │
│                                      │
│           Enter PIN                  │
│           ● ● ○ ○                    │
│                                      │
│         [Error Message]              │
│                                      │
│      ┌───┐ ┌───┐ ┌───┐               │
│      │ 1 │ │ 2 │ │ 3 │               │
│      └───┘ └───┘ └───┘               │
│      ┌───┐ ┌───┐ ┌───┐               │
│      │ 4 │ │ 5 │ │ 6 │               │
│      └───┘ └───┘ └───┘               │
│      ┌───┐ ┌───┐ ┌───┐               │
│      │ 7 │ │ 8 │ │ 9 │               │
│      └───┘ └───┘ └───┘               │
│      ┌───┐ ┌───┐ ┌───┐               │
│      │ 🔐│ │ 0 │ │ ⌫ │               │
│      └───┘ └───┘ └───┘               │
│                                      │
└──────────────────────────────────────┘
```

---

## 6. Migration Plan

### 6.1 Existing Locked Notes
1. On app update, scan for notes with `isLocked = true`
2. Show migration dialog: "X locked notes found. Enter your PIN to unlock them permanently."
3. User enters current note PIN → all notes decrypted → `isLocked = false`
4. If user cancels, notes remain locked (feature removed, data inaccessible)

> [!CAUTION]
> Users who forget their PIN will lose access to locked note content permanently.

### 6.2 Database Migration
- Remove `isLocked` field from Note entity
- Remove `encryptedContent` field from Note entity
- Run Isar schema migration

---

## 7. Technical Architecture

### 7.1 New Files
```
lib/
├── core/
│   ├── models/
│   │   └── security_settings.dart       # Hive model + adapter
│   ├── services/
│   │   └── security_service.dart        # Main security logic
│   └── screens/
│       └── unlock_screen.dart           # Unlock UI
└── shared/
    └── widgets/
        └── pin_input_widget.dart        # Reusable PIN input
```

### 7.2 Modified Files
| File | Change |
|------|--------|
| `main.dart` | Add SecurityWrapper, WidgetsBindingObserver |
| `settings_screen.dart` | Add Security section |
| `note.dart` | Remove isLocked, encryptedContent |
| `note_editor_screen.dart` | Remove all lock logic |
| `notes_screen.dart` | Remove PIN verification from delete |

### 7.3 Deleted Files
- `note_encryption_service.dart`
- `pin_input_dialog.dart` (replaced by new widget)

### 7.4 Dependencies
| Package | Purpose | Status |
|---------|---------|--------|
| `flutter_secure_storage` | Store PIN hash | Already installed |
| `local_auth` | Biometric auth | Already installed |
| `crypto` | SHA-256 hashing | Already installed |
| `hive_flutter` | Store SecuritySettings | Already installed |

---

## 8. Testing Plan

### 8.1 Unit Tests
- SecurityService: PIN setup, verify, change, delete
- SecurityService: Lockout logic
- SecurityService: Session management

### 8.2 Integration Tests
- Full unlock flow (PIN + biometric)
- Auto-lock on resume
- Settings persistence

### 8.3 Manual Test Cases
| ID | Test Case | Expected Result |
|----|-----------|-----------------|
| T1 | Enable PIN for first time | PIN setup dialog appears |
| T2 | Enter correct PIN | App unlocks |
| T3 | Enter wrong PIN 5 times | 30s lockout |
| T4 | Enable biometric | Fingerprint prompt appears |
| T5 | Biometric unlock | App unlocks without PIN |
| T6 | Background 31s, resume | Unlock screen appears |
| T7 | Background 10s, resume | App stays unlocked |
| T8 | Tap "Lock Now" | Immediate lock |
| T9 | Change PIN | Old PIN required, then new PIN |
| T10 | Disable App Lock | Current PIN required |

---

## 9. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| User forgets PIN | High - Data loss | Show recovery warning on setup |
| Biometric fails | Medium - UX friction | Always allow PIN fallback |
| Lockout during emergency | Medium | Emergency message visible on lockout |
| Migration fails | High | Backup reminder before update |

---

## 10. Success Metrics

| Metric | Target |
|--------|--------|
| Unlock time (PIN) | < 3 seconds |
| Unlock time (biometric) | < 1 second |
| Zero security bypass bugs | 0 vulnerabilities |
| User adoption | > 50% enable PIN within 7 days |

---

## 11. Timeline

| Phase | Duration | Tasks |
|-------|----------|-------|
| Phase 1 | 2 hours | Remove per-note lock code |
| Phase 2 | 4 hours | Implement SecurityService, UnlockScreen |
| Phase 3 | 2 hours | Settings UI, Integration |
| Phase 4 | 1 hour | Testing & Bug fixes |
| **Total** | **~9 hours** | |

---

## 12. Approval

- [ ] Product Owner Approval
- [ ] Technical Review Complete
- [ ] Security Review Complete

---

*Document prepared based on analysis of alkhazna security implementation.*
