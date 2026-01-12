# 🤖 AI Agent Prompt: Build Life Tracker Flutter Application

> **Complete, Comprehensive Prompt for AI Agent to Build Life Tracker from Scratch**

---

## 📋 MISSION

You are an expert Flutter developer. Your mission is to build **Life Tracker** - a comprehensive, offline-first life tracking mobile application from scratch. This app consolidates health and financial tracking into a single, beautifully designed platform.

---

## 🎯 PROJECT OVERVIEW

### Vision Statement
> "Empower individuals to take control of their health and finances through a simple, secure, and beautiful mobile experience."

### Core Value Propositions
1. **Unified Platform** - Health + Finance + Notes + Reminders in one app
2. **Offline-First** - Works everywhere without internet
3. **Privacy-First** - All data stored locally with encryption
4. **Beautiful UI** - Professional Material 3 design
5. **Free Core Features** - All essential features free forever

### Target Users
- Primary: Android users aged 20-40
- Secondary: Users aged 40-100
- Needs: Life organization, health tracking, financial management
- Languages: English and Arabic (RTL support)

---

## 🛠️ TECH STACK (MANDATORY)

```yaml
Framework: Flutter 3.24.0+
Language: Dart 3.5.0+
Platform: Android (API 23+)

# State Management
State: flutter_riverpod ^2.5.1

# Navigation
Router: go_router ^14.2.0

# Database
Local DB: isar ^3.1.0+1
Secure Storage: flutter_secure_storage ^9.2.2

# UI/UX
Design System: Material 3
Typography: google_fonts ^6.2.1
Animations: lottie (optional)

# Features
Notifications: flutter_local_notifications ^17.2.1+2
Biometric Auth: local_auth ^2.2.0
Image Picker: image_picker ^1.1.2
File Picker: file_picker ^8.0.6
Audio: audioplayers ^6.0.0

# Utilities
Encryption: crypto ^3.0.3
Preferences: shared_preferences ^2.5.3
Timezone: timezone ^0.9.3
Localization: flutter_intl
```

---

## 🏗️ ARCHITECTURE (Clean Architecture)

```
lib/
├── app/
│   └── di/                          # Dependency Injection (Riverpod providers)
│
├── core/
│   ├── constants/
│   │   ├── app_theme.dart           # Material 3 theme (Google Fonts)
│   │   ├── app_colors.dart          # Color definitions
│   │   └── app_design_tokens.dart   # Spacing, sizing tokens
│   ├── services/
│   │   ├── feedback_service.dart    # SnackBar/Toast handling
│   │   ├── notification_service.dart
│   │   └── backup_service.dart
│   ├── router/
│   │   └── app_router.dart          # GoRouter configuration
│   └── utils/                       # Helper functions
│
├── shared/
│   └── widgets/
│       ├── states/
│       │   ├── empty_state_widget.dart
│       │   ├── loading_widget.dart
│       │   ├── error_widget.dart
│       │   └── skeleton_widgets.dart
│       ├── buttons/
│       ├── fields/
│       ├── forms/
│       └── layout/
│
├── features/
│   ├── dashboard/
│   │   ├── data/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   │
│   ├── health/                      # Weight, Medications
│   ├── finance/                     # Accounts, Expenses, Income, Debts, Bills, Commitments
│   ├── notes/                       # Notes with attachments
│   ├── reminders/                   # Standalone & linked reminders
│   ├── settings/                    # App lock, backup, preferences
│   ├── splash/
│   └── onboarding/
│
├── l10n/                            # Localization files
│   ├── app_en.arb
│   └── app_ar.arb
│
└── main.dart
```

---

## 📱 FEATURE SPECIFICATIONS

### 1. HEALTH MODULE

#### 1.1 Weight Tracking
**Purpose**: Track weight, calculate BMI, show ideal weight range

**Data Model**:
```dart
@collection
class WeightEntry {
  Id id = Isar.autoIncrement;
  late double weight;       // in kg (20-300)
  late DateTime date;
  String? note;             // max 200 chars
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
}

@collection
class UserProfile {
  Id id = 1;  // Singleton
  double? height;           // in cm
  int? age;
  String? gender;           // male, female, other
  DateTime? dateOfBirth;
  String? name;
}

@collection
class WeightGoal {
  Id id = Isar.autoIncrement;
  late double targetWeight;
  late DateTime targetDate;
  late DateTime createdAt;
  bool achieved = false;
  DateTime? achievedAt;
}
```

**Features**:
- Log weight with date and optional note
- BMI calculation: `BMI = weight(kg) / height²(m)`
- BMI categories: Underweight, Normal, Overweight, Obese
- Ideal weight range based on height, age, gender
- Weight history list (most recent first, paginated 20/page)
- Edit/delete entries
- Weight goal with progress indicator

**UI Components**:
- Weight entry screen (list view)
- Add weight dialog (FAB)
- BMI display card
- Ideal weight card
- Goal progress card

---

#### 1.2 Medication Reminders
**Purpose**: Schedule medications with notifications

**Data Model**:
```dart
@collection
class Medication {
  Id id = Isar.autoIncrement;
  late String name;         // max 100 chars
  late String dosage;       // e.g., "500mg", "2 pills"
  late List<String> times;  // ["09:00", "21:00"]
  String? instructions;     // max 200 chars
  late DateTime startDate;
  DateTime? endDate;
  bool active = true;
  DateTime createdAt = DateTime.now();
}

@collection
class MedicationIntake {
  Id id = Isar.autoIncrement;
  @Index()
  late int medicationId;
  late DateTime scheduledTime;
  DateTime? takenTime;
  String status = 'pending';  // taken, missed, snoozed
  int snoozeCount = 0;
}
```

**Features**:
- Add medication with name, dosage, multiple times
- Schedule notifications at each time
- Notification actions: "Taken" / "Snooze" (10min, 30min, 1hr)
- Track adherence statistics (% taken, missed doses, streak)
- View active medications list
- Edit/delete medications (cancels scheduled notifications)

---

### 2. FINANCE MODULE

#### 2.1 Account Management
**Data Model**:
```dart
@collection
class Account {
  Id id = Isar.autoIncrement;
  late String name;
  late String currency;     // USD, EUR, EGP, SAR, AED
  late double balance;
  String type = 'cash';     // cash, bank, card, wallet
  String? bankName;
  String? accountNumber;
  bool isActive = true;
  DateTime createdAt = DateTime.now();
}

@collection
class Transfer {
  Id id = Isar.autoIncrement;
  late int fromAccountId;
  late int toAccountId;
  late double amount;
  String? conversionRate;
  late DateTime date;
  String? note;
  DateTime createdAt = DateTime.now();
}
```

**Features**:
- Multiple accounts (Bank, Cash, Credit Card, Debit Card, E-Wallet)
- Multi-currency support
- Transfer between accounts
- Real-time balance tracking
- Account details with recent transactions

---

#### 2.2 Expense Tracking
**Data Model**:
```dart
@collection
class Expense {
  Id id = Isar.autoIncrement;
  late double amount;
  late String currency;
  late String category;
  late DateTime date;
  @Index()
  late int accountId;
  String? note;             // max 200 chars
  String? receiptPath;      // local file path
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
}

@collection
class Category {
  Id id = Isar.autoIncrement;
  late String name;
  late String type;         // expense, income
  String icon = 'other';
  String color = '#757575';
  bool isDefault = false;
  bool isActive = true;
}
```

**Default Categories**:
- 🍔 Food & Dining
- 🚗 Transportation
- 🎭 Entertainment
- 🏥 Healthcare
- 🏠 Housing
- 🛒 Shopping
- 💳 Bills & Utilities
- 🎓 Education
- 🤝 Gifts & Donations
- 📊 Other

**Features**:
- Add expense with amount, category, account, date, receipt
- Custom category creation (name, icon, color)
- View expenses (group by day/category/account)
- Filter by date range, category, account
- Monthly totals and category breakdown
- Edit/delete expenses

---

#### 2.3 Income Tracking
**Data Model**:
```dart
@collection
class Income {
  Id id = Isar.autoIncrement;
  late double amount;
  late String currency;
  late String source;       // Salary, Freelance, Investment, Gift, Other
  late DateTime date;
  @Index()
  late int accountId;
  String? note;
  bool recurring = false;
  String? recurrencePattern;  // JSON: {frequency, day}
  DateTime createdAt = DateTime.now();
}
```

**Features**:
- Add income with source, amount, account
- Custom income sources
- Recurring income (monthly, weekly, bi-weekly)
- Auto-update account balance

---

#### 2.4 Debt Management
**Data Model**:
```dart
@collection
class Debt {
  Id id = Isar.autoIncrement;
  late String type;         // owed_by_me, owed_to_me
  late double amount;
  String currency = 'USD';
  late String person;
  DateTime? dueDate;
  String? reason;
  String status = 'unpaid'; // unpaid, partially_paid, paid
  double paidAmount = 0.0;
  DateTime? paidDate;
  DateTime createdAt = DateTime.now();
}

@collection
class DebtPayment {
  Id id = Isar.autoIncrement;
  late int debtId;
  late double amount;
  late DateTime date;
  String? note;
}
```

**Features**:
- Track "I Owe" and "Owed to Me"
- Partial payments with remaining balance
- Due date reminders (3 days before, on due date)
- Debt summary (total owed, total owed to me, net)
- Overdue debts highlighted

---

#### 2.5 Recurring Bills
**Data Model**:
```dart
@collection
class RecurringBill {
  Id id = Isar.autoIncrement;
  late String name;         // "Netflix", "Rent"
  late double amount;
  String currency = 'USD';
  late String frequency;    // monthly, weekly, yearly
  int? dayOfMonth;          // 1-31
  int? dayOfWeek;           // 0-6
  late String category;
  late int accountId;
  int reminderDaysBefore = 3;
  bool active = true;
  DateTime? lastPaidDate;
  DateTime? nextDueDate;
  DateTime createdAt = DateTime.now();
}

@collection
class BillPayment {
  Id id = Isar.autoIncrement;
  late int billId;
  late DateTime dueDate;
  DateTime? paidDate;
  String status = 'pending';  // pending, paid, overdue
  int? expenseId;           // links to auto-created expense
}
```

**Features**:
- Add recurring bill with frequency, day, category
- Automatic reminders X days before due
- Mark as paid (auto-creates expense)
- Bills calendar view
- Edit/pause/delete bills

---

#### 2.6 Financial Commitments (Savings Goals)
**Data Model**:
```dart
@collection
class FinancialCommitment {
  Id id = Isar.autoIncrement;
  late String name;         // "Wedding", "New Car"
  late double targetAmount;
  String currency = 'USD';
  late DateTime deadline;
  double currentAmount = 0.0;
  String priority = 'medium';  // low, medium, high
  String? note;
  bool completed = false;
  DateTime? completedDate;
  DateTime createdAt = DateTime.now();
}

@collection
class CommitmentContribution {
  Id id = Isar.autoIncrement;
  late int commitmentId;
  late double amount;
  late DateTime date;
  String? note;
}
```

**Features**:
- Add savings goal with target amount and deadline
- Track contributions
- Progress bar and percentage
- Suggested monthly savings
- Milestone notifications (25%, 50%, 75%, 100%)
- Mark as completed

---

### 3. NOTES MODULE

**Data Model**:
```dart
@collection
class Note {
  Id id = Isar.autoIncrement;
  String? title;            // max 100 chars
  late String content;      // max 10,000 chars
  String color = 'blue';    // blue, green, yellow, red, purple, grey
  List<String> attachments = [];  // file paths
  String? voiceNotePath;
  List<ChecklistItem> checklist = [];
  bool locked = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

@embedded
class ChecklistItem {
  late String text;
  bool checked = false;
}
```

**Features**:
- Create notes with title, content, color
- 6 predefined colors
- Attachments: images (JPG, PNG), files (PDF, TXT, DOC, XLS)
- Voice notes (record, play, delete)
- Checklist items (add, check/uncheck, remove)
- Grid/List view toggle
- Lock individual notes with PIN
- Share notes (text + attachments)
- Edit/delete notes

---

### 4. REMINDERS MODULE

**Data Model**:
```dart
@collection
class Reminder {
  Id id = Isar.autoIncrement;
  late String title;        // max 100 chars
  String? description;      // max 500 chars
  late DateTime dateTime;
  String recurring = 'none';  // none, daily, weekly, monthly
  String? recurrencePattern;  // JSON for complex patterns
  String priority = 'normal'; // normal, important, urgent
  String? linkedType;       // medication, bill, note, null
  int? linkedId;
  bool completed = false;
  DateTime? completedAt;
  DateTime createdAt = DateTime.now();
}
```

**Features**:
- Create standalone reminders
- Recurring reminders (daily, weekly, monthly)
- Priority levels (normal, important, urgent)
- Link to medication, bill, or note
- Notification with "Done" / "Snooze" actions
- Snooze options: 10min, 30min, 1hr, 3hrs, Tomorrow
- Tabs: Upcoming, Completed, All
- Group by: Today, Tomorrow, This Week, Later

---

### 5. SETTINGS MODULE

#### 5.1 App Lock
- Enable/disable app lock
- Methods: PIN (4-6 digits), Pattern, Biometric
- Auto-lock timeout: 1, 5, 15, 30 min, Never
- Failed attempt lockout (3 attempts = 30s, 5 = 1min)

#### 5.2 Backup & Restore
- Create encrypted local backup (AES-256)
- Password-protected backup files
- Restore with merge/replace options
- File format: `life_tracker_backup_YYYYMMDD_HHMMSS.ltb`

#### 5.3 User Preferences
- Theme: Light, Dark, System
- Language: English, Arabic (RTL)
- Currency: Default currency setting
- Date/Time format preferences
- Notification settings

#### 5.4 User Profile
- Name, Date of Birth, Gender, Height
- Used for BMI and ideal weight calculations

---

## 🎨 UI/UX REQUIREMENTS

### Design System
- **Material 3** with custom color scheme
- **Google Fonts** for typography
- **Dark Mode** support (mandatory)
- **RTL Support** for Arabic

### Critical UI Rules

#### 1. NEVER Hardcode Colors
```dart
// ❌ FORBIDDEN
color: Colors.black

// ✅ CORRECT
color: Theme.of(context).colorScheme.onSurface
```

#### 2. Always Check `context.mounted` After Async
```dart
Future<void> _saveData() async {
  await repository.save(data);
  
  if (!context.mounted) return;  // CRITICAL
  
  FeedbackService.showSuccess(context, 'Saved!');
}
```

#### 3. Three-State Pattern for Async Data
```dart
dataAsync.when(
  loading: () => const SkeletonList.cards(itemCount: 5),
  error: (e, s) => ErrorStateWidget(onRetry: () => ref.invalidate(provider)),
  data: (items) => items.isEmpty 
    ? EmptyStateWidget(...) 
    : _buildList(items),
);
```

#### 4. Use Directional Properties for RTL
```dart
// ❌ AVOID
EdgeInsets.only(left: 16)

// ✅ USE
EdgeInsetsDirectional.only(start: 16)
```

#### 5. Use Modern APIs
```dart
// ❌ DEPRECATED
color.withOpacity(0.5)

// ✅ CORRECT
color.withValues(alpha: 0.5)
```

### ListView Best Practices
```dart
ListView.builder(
  cacheExtent: 500,
  physics: const AlwaysScrollableScrollPhysics(),
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

### RefreshIndicator Pattern
```dart
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(provider);
    await ref.read(provider.future);
  },
  child: ListView.builder(...),
)
```

---

## 🔔 NOTIFICATION SYSTEM

### Notification Channels
1. **Medication** - High priority
2. **Bills** - Default priority
3. **Reminders** - Based on priority level
4. **Debts** - Default priority

### Notification Actions
- Medications: "Taken" / "Snooze"
- Bills: "Mark as Paid" / "Snooze"
- Reminders: "Done" / "Snooze"

---

## 🌍 LOCALIZATION

### Supported Languages
1. **English** (en) - Default
2. **Arabic** (ar) - RTL

### Implementation
- Use `flutter_intl` package
- ARB files in `lib/l10n/`
- Access via `context.l10n.key`

---

## 📊 DASHBOARD

### Summary Cards
- Today's weight (if logged)
- Medications due today
- Upcoming bills
- Total balance across accounts
- Active reminders

### Quick Actions (FABs)
- Add Weight
- Add Expense
- Add Note
- Add Reminder

### Customization
- Show/hide modules
- Reorder cards

---

## 🔒 SECURITY

### Data Protection
- Isar database encryption
- PIN-protected locked notes
- Secure storage for sensitive keys
- Encrypted backups

### App Lock
- PIN / Pattern / Biometric
- Auto-lock timeout
- Failed attempt lockout

---

## 📱 SCREENS LIST

1. **Splash Screen**
2. **Onboarding Flow** (first launch)
3. **Dashboard**
4. **Health**
   - Weight Screen (list + add)
   - Medications Screen (list + add)
   - Medication Detail
5. **Finance**
   - Accounts Screen
   - Account Detail
   - Expenses Screen
   - Income Screen
   - Debts Screen
   - Bills Screen
   - Commitments Screen
6. **Notes**
   - Notes Grid/List
   - Note Editor
7. **Reminders**
   - Reminders List (tabbed)
   - Add Reminder
8. **Settings**
   - Main Settings
   - App Lock Setup
   - Backup & Restore
   - Profile
   - About

---

## ✅ ACCEPTANCE CRITERIA

### Core Functionality
- [ ] All data persists offline using Isar
- [ ] App lock works with PIN/Biometric
- [ ] Notifications fire at scheduled times
- [ ] Dark mode switches all UI correctly
- [ ] RTL layout renders correctly in Arabic
- [ ] Backup/Restore works with encryption

### Performance
- [ ] App startup < 2 seconds
- [ ] Smooth scrolling (60 FPS)
- [ ] No memory leaks
- [ ] 99.9% crash-free sessions

### Design
- [ ] Material 3 design language
- [ ] Consistent spacing and typography
- [ ] Professional, beautiful UI
- [ ] Accessibility compliance

---

## 🚀 BUILD INSTRUCTIONS

```bash
# 1. Create Flutter project
flutter create life_tracker --org com.yourcompany
cd life_tracker

# 2. Install dependencies (update pubspec.yaml first)
flutter pub get

# 3. Generate Isar schemas
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Generate localization files
flutter gen-l10n

# 5. Run the app
flutter run

# 6. Build release APK
flutter build apk --release
```

---

## 📝 COMMIT FORMAT

```
type(scope): message

Examples:
feat(finance): Add expense tracking screen
fix(health): Fix BMI calculation for edge cases
refactor(notes): Migrate to Riverpod providers
docs(readme): Update feature list
```

---

## 🎯 FINAL NOTES

1. **Start with core infrastructure**: Theme, Router, DI setup
2. **Build feature by feature**: Complete one module before moving to next
3. **Test as you go**: Unit tests for repositories, widget tests for screens
4. **Focus on UX**: Beautiful, intuitive, professional design
5. **Localization from start**: Use localization keys, not hardcoded strings
6. **Security first**: Encrypt sensitive data, validate all inputs

**Good luck building Life Tracker!** 🚀
