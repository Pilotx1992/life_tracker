# Life Tracker - Complete Product Requirements Document (PRD)

**Version:** 1.0.0
**Date:** October 27, 2025
**Status:** Draft
**Platform:** Android (Flutter)
**Target Audience:** Ages 20-100, All professions
**Primary Need:** Unified health and finance management in one place

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Product Vision & Goals](#product-vision--goals)
3. [User Personas](#user-personas)
4. [Feature Specifications](#feature-specifications)
5. [User Stories & Acceptance Criteria](#user-stories--acceptance-criteria)
6. [User Flows](#user-flows)
7. [Non-Functional Requirements](#non-functional-requirements)
8. [Success Metrics & KPIs](#success-metrics--kpis)
9. [Constraints & Assumptions](#constraints--assumptions)
10. [Glossary](#glossary)

---

## 1. Executive Summary

### 1.1 Product Overview

**Life Tracker** is an offline-first Android application that consolidates health and financial tracking into a single, beautifully designed platform. The app enables users to monitor their weight, medications, expenses, income, debts, bills, and maintain notes and reminders—all with robust security and privacy features.

### 1.2 Vision Statement

> "Empower individuals to take control of their health and finances through a simple, secure, and beautiful mobile experience."

### 1.3 Key Differentiators

| Feature | Life Tracker | Competitors |
|---------|-------------|-------------|
| **Unified Platform** | Health + Finance in one app | Separate apps |
| **Offline-First** | Works without internet | Requires connection |
| **Beautiful UI** | Professional, modern design | Basic/cluttered UI |
| **Privacy-First** | Local data, encrypted, app lock | Cloud-dependent |
| **Multi-Currency** | Full support | Limited/none |
| **Free Core Features** | All essentials free | Paywalled basics |

### 1.4 Target Market

- **Primary:** Android users aged 20-40
- **Secondary:** Users aged 40-100
- **Tertiary:** Any profession seeking life organization
- **Geography:** Global (starting with Arabic/English speakers)

### 1.5 Product Goals

#### Business Goals:
1. Acquire 10,000 users in first 6 months
2. Achieve 4.5+ star rating on Google Play
3. 40% monthly active user retention
4. Establish brand as trusted health+finance tracker

#### User Goals:
1. Simplify daily health and financial tracking
2. Gain insights into habits and patterns
3. Never miss medications or bill payments
4. Feel secure about personal data

#### Product Goals:
1. Launch MVP within 10 weeks
2. Maintain app performance (startup < 2s)
3. Achieve 99.9% crash-free sessions
4. Enable offline-first functionality

---

## 2. Product Vision & Goals

### 2.1 Problem Statement

**Current State:**
- Users juggle 5+ apps for health, fitness, finance, notes
- Data scattered across platforms
- Privacy concerns with cloud-only apps
- Complex UIs intimidate non-tech users
- Expensive subscription models

**Pain Points:**
1. **Fragmentation:** "I need 7 apps to manage my life"
2. **Complexity:** "These apps have too many features I don't need"
3. **Privacy:** "I don't trust my financial data in the cloud"
4. **Cost:** "Why should I pay $10/month for a notes app?"
5. **Connectivity:** "Apps don't work without internet"

### 2.2 Solution

**Life Tracker provides:**
- ✅ **Single App:** Health, finance, notes, reminders in one place
- ✅ **Simple UI:** Beautiful, intuitive, professional design
- ✅ **Offline-First:** Works everywhere, syncs when online
- ✅ **Privacy-First:** Local storage, encryption, app lock
- ✅ **Free Core:** All essential features free forever
- ✅ **Multi-Currency:** Global financial tracking

### 2.3 Success Criteria

#### Phase 1 (MVP - 3 months):
- [ ] 5,000 downloads
- [ ] 4.0+ star rating
- [ ] 30% MAU retention
- [ ] < 1% crash rate

#### Phase 2 (Enhanced - 6 months):
- [ ] 25,000 downloads
- [ ] 4.3+ star rating
- [ ] 35% MAU retention
- [ ] Device integration working

#### Phase 3 (Advanced - 12 months):
- [ ] 100,000 downloads
- [ ] 4.5+ star rating
- [ ] 40% MAU retention
- [ ] Cloud sync operational

---

## 3. User Personas

### Persona 1: **Mohammed - The Organized Professional**

**Demographics:**
- Age: 28
- Profession: Software Engineer
- Location: Cairo, Egypt
- Income: Middle class
- Tech-savviness: High

**Goals:**
- Track monthly expenses to save for car
- Monitor weight and fitness progress
- Never miss medication (chronic condition)
- Keep work and personal notes organized

**Pain Points:**
- Spreadsheets are tedious
- Forgets to take evening medication
- Uses 4 different apps (overwhelming)
- Wants data private (doesn't trust cloud)

**User Story:**
> "As a professional, I want one app to track my health and finances so that I can stay organized without managing multiple tools."

**How Life Tracker Helps:**
- Single platform for all tracking
- Medication reminders at specified times
- Simple expense categorization
- Offline-first with encryption

---

### Persona 2: **Fatima - The Busy Student**

**Demographics:**
- Age: 22
- Profession: University Student
- Location: Riyadh, Saudi Arabia
- Income: Part-time freelance + allowance
- Tech-savviness: Medium

**Goals:**
- Track part-time income and spending
- Lose 5kg before graduation
- Manage study deadlines with reminders
- Keep course notes and shopping lists

**Pain Points:**
- Budget apps are too complex
- Weight apps lack Arabic support
- Needs simple, fast interface
- Limited phone storage

**User Story:**
> "As a student, I want a simple app to track my weight and budget so that I can achieve my health goals while managing my limited income."

**How Life Tracker Helps:**
- Simple weight entry + BMI
- Quick expense logging
- Arabic + English support
- Lightweight app size
- Free core features

---

### Persona 3: **Ahmed - The Retiree with Health Needs**

**Demographics:**
- Age: 65
- Profession: Retired
- Location: Alexandria, Egypt
- Income: Pension
- Tech-savviness: Low

**Goals:**
- Track multiple daily medications
- Monitor blood pressure readings
- Manage fixed income and expenses
- Remember bill payment dates

**Pain Points:**
- Forgets medication times (safety risk)
- Complicated app interfaces
- Small text is hard to read
- Needs simple, clear design

**User Story:**
> "As a retiree, I want an easy-to-use app to track my medications and expenses so that I can stay healthy and manage my fixed income."

**How Life Tracker Helps:**
- Large, clear medication reminders
- Simple list-based interface
- Recurring bill reminders
- Accessibility-friendly design
- One-time purchase (no subscriptions)

---

## 4. Feature Specifications

### 4.1 Health Module

#### 4.1.1 Weight Tracking

**Description:**
Users can log their weight daily/weekly and view their BMI and ideal weight based on their profile.

**Priority:** Must Have (MVP)

**User Need:**
"I want to track my weight progress towards my goal."

**Functional Requirements:**

**FR-H-WT-001:** User can enter current weight (in kg)
- Input: Numeric value (20-300 kg)
- Optional: Date (defaults to today)
- Optional: Note (text, max 200 chars)

**FR-H-WT-002:** System calculates and displays BMI
- Formula: BMI = weight (kg) / height² (m)
- Categories: Underweight, Normal, Overweight, Obese
- Requires user profile (height, age, gender)

**FR-H-WT-003:** System calculates and displays ideal weight
- Based on: Height, age, gender
- Formula: Multiple methods (Devine, Robinson, Miller)
- Displays as range (e.g., "65-75 kg")

**FR-H-WT-004:** User can view weight history
- List view: Date, weight, BMI, note
- Sorted: Most recent first
- Pagination: 20 entries per page

**FR-H-WT-005:** User can edit/delete weight entries
- Edit: All fields modifiable
- Delete: With confirmation dialog
- Audit: Track modification date

**FR-H-WT-006:** User can set weight goal
- Target weight (kg)
- Target date
- Progress indicator

**Data Model:**
```dart
@collection
class WeightEntry {
  Id id = Isar.autoIncrement;
  late double weight;       // in kg
  late DateTime date;
  String? note;
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
}

@collection
class UserProfile {
  Id id = 1;  // Singleton
  double? height;          // in cm
  int? age;
  String? gender;          // male, female, other
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

**UI Components:**
- Weight entry screen (list)
- Add weight dialog (floating action button)
- Weight detail view
- BMI display card
- Ideal weight card
- Goal progress card

**Acceptance Criteria:**
```gherkin
Scenario: User logs daily weight
  Given user has set up profile (height, age, gender)
  When user taps "Log Weight" button
  And enters weight "75.5 kg"
  And taps "Save"
  Then weight entry is saved
  And BMI is calculated and displayed
  And ideal weight range is shown
  And entry appears in history list
```

---

#### 4.1.2 Medication Reminders

**Description:**
Users can add medications with dosage and timing, and receive notifications at specified times.

**Priority:** Must Have (MVP)

**User Need:**
"I need reminders to take my medications on time."

**Functional Requirements:**

**FR-H-MED-001:** User can add medication
- Name (required, text, max 100 chars)
- Dosage (required, text, e.g., "500mg", "2 pills")
- Times (required, list of times, e.g., ["09:00", "21:00"])
- Instructions (optional, text, max 200 chars)
- Start date (optional, defaults to today)
- End date (optional, for temporary medications)

**FR-H-MED-002:** System schedules notifications
- Notification at each specified time
- Title: Medication name
- Body: Dosage + instructions
- Action buttons: "Taken" / "Snooze"
- Sound: Default notification sound
- Vibration: Yes
- Channel: High priority

**FR-H-MED-003:** User can mark medication as taken
- From notification: Tap "Taken"
- From app: Checkmark next to time
- Logs timestamp of intake
- Updates adherence statistics

**FR-H-MED-004:** User can snooze reminder
- Snooze options: 10 min, 30 min, 1 hour
- Re-schedules notification
- Tracks snooze count

**FR-H-MED-005:** User can view medication list
- Active medications shown
- Displays: Name, dosage, times
- Sort: Alphabetical
- Filter: Active / All

**FR-H-MED-006:** User can edit/delete medications
- Edit: All fields modifiable
- Delete: With confirmation
- Deletion cancels scheduled notifications

**FR-H-MED-007:** System tracks adherence
- Percentage taken on time
- Missed doses count
- Streak (consecutive days)

**Data Model:**
```dart
@collection
class Medication {
  Id id = Isar.autoIncrement;
  late String name;
  late String dosage;
  late List<String> times;  // ["09:00", "21:00"]
  String? instructions;
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
  String status;  // taken, missed, snoozed
  int snoozeCount = 0;
}
```

**UI Components:**
- Medications list screen
- Add medication dialog
- Edit medication screen
- Medication detail view (with adherence stats)
- Notification with actions

**Acceptance Criteria:**
```gherkin
Scenario: User adds medication with reminders
  Given user is on medications screen
  When user taps "Add Medication"
  And enters name "Aspirin"
  And enters dosage "500mg"
  And adds times "09:00" and "21:00"
  And taps "Save"
  Then medication is saved
  And notifications are scheduled for 09:00 and 21:00 daily
  And medication appears in active list

Scenario: User receives and marks medication as taken
  Given medication "Aspirin" is scheduled for 09:00
  When system time reaches 09:00
  Then notification appears with "Aspirin - 500mg"
  When user taps "Taken" on notification
  Then intake is logged with current timestamp
  And notification is dismissed
  And adherence statistics are updated
```

---

#### 4.1.3 Vital Signs Tracking (Phase 2)

**Description:**
Track blood pressure, blood sugar, heart rate, and temperature readings.

**Priority:** Should Have (Phase 2)

**Functional Requirements:**

**FR-H-VS-001:** User can log blood pressure
- Systolic (mmHg): 60-250
- Diastolic (mmHg): 40-150
- Date/time
- Note (optional)
- Category: Normal, Elevated, Stage 1/2 Hypertension

**FR-H-VS-002:** User can log blood sugar
- Value (mg/dL or mmol/L)
- Timing: Fasting, Before meal, After meal
- Date/time
- Note (optional)

**FR-H-VS-003:** User can log heart rate
- BPM: 30-250
- Date/time
- Activity: Resting, Exercise, Sleep
- Note (optional)

**FR-H-VS-004:** User can log temperature
- Value (°C or °F): 35-42°C
- Date/time
- Method: Oral, Ear, Forehead
- Note (optional)

**FR-H-VS-005:** System integrates with devices
- Bluetooth connection to Mi Band, smart scales
- Auto-import readings
- Data validation
- Manual override

**Data Model:**
```dart
@collection
class VitalSign {
  Id id = Isar.autoIncrement;
  late String type;  // bp, sugar, heartrate, temperature
  late DateTime date;
  late Map<String, double> values;  // flexible for different types
  String? note;
  String? source;  // manual, miband, scale
}

// Example values:
// BP: {systolic: 120, diastolic: 80}
// Sugar: {value: 95, timing: fasting}
// HR: {bpm: 72, activity: resting}
// Temp: {celsius: 37.2}
```

---

#### 4.1.4 Lifestyle Tracking (Phase 2)

**Description:**
Track sleep, exercise, food, and water intake.

**Priority:** Should Have (Phase 2)

##### Sleep Tracking

**FR-H-SLP-001:** User can log sleep hours
- Bedtime (time)
- Wake time (time)
- Duration (auto-calculated)
- Quality: 1-5 stars
- Note (optional, e.g., "interrupted", "restful")

**FR-H-SLP-002:** System shows sleep statistics
- Average hours per night (last 7/30 days)
- Quality trend
- Best/worst nights

##### Exercise Tracking

**FR-H-EX-001:** User can log exercise
- Type: Dropdown (Running, Walking, Cycling, Gym, Yoga, Swimming, Other)
- Duration (minutes)
- Calories burned (optional, auto-estimated or manual)
- Intensity: Low, Medium, High
- Note (optional)

**FR-H-EX-002:** System tracks exercise statistics
- Total minutes this week/month
- Total calories burned
- Most frequent activity

##### Food & Calories

**FR-H-FOOD-001:** User can log meals
- Meal type: Breakfast, Lunch, Dinner, Snack
- Description (text)
- Estimated calories (number)
- Time
- Photo (optional)

**FR-H-FOOD-002:** System tracks daily calories
- Total consumed
- Calorie goal (set by user)
- Remaining calories
- Weekly average

##### Water Intake

**FR-H-WATER-001:** User can log water intake
- Quick add buttons: 250ml, 500ml, 1L, Custom
- Daily goal (configurable, default: 2L)
- Progress bar

**FR-H-WATER-002:** System sends reminders
- Configurable times (e.g., every 2 hours)
- Notification: "Time to hydrate!"

---

#### 4.1.5 Mental Health (Phase 3)

**Description:**
Track mood and maintain health journal.

**Priority:** Could Have (Phase 3)

##### Mood Tracker

**FR-H-MOOD-001:** User can log daily mood
- Mood: 😄 Happy, 😊 Good, 😐 Neutral, 😟 Sad, 😢 Depressed
- Energy level: 1-5
- Stress level: 1-5
- Activities (tags): Exercise, Social, Work, Relax, etc.
- Note (optional)

**FR-H-MOOD-002:** System shows mood trends
- Weekly mood chart
- Patterns (e.g., "You're happier on weekends")
- Correlation with activities

##### Health Journal

**FR-H-JOURNAL-001:** User can write health journal entries
- Date
- Title
- Content (rich text)
- Tags: Symptoms, Achievements, Concerns
- Private by default

---

### 4.2 Finance Module

#### 4.2.1 Expense Tracking

**Description:**
Users can log daily expenses with categories and multiple currencies.

**Priority:** Must Have (MVP)

**User Need:**
"I want to track where my money goes each day."

**Functional Requirements:**

**FR-F-EXP-001:** User can add expense
- Amount (required, positive number, 2 decimal places)
- Currency (required, dropdown: USD, EUR, GBP, EGP, SAR, AED, etc.)
- Category (required, predefined + custom)
- Date (required, defaults to today)
- Account (required, dropdown from user's accounts)
- Note (optional, max 200 chars)
- Receipt photo (optional)

**FR-F-EXP-002:** System provides default categories
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

**FR-F-EXP-003:** User can create custom categories
- Name (required)
- Icon (select from icon set)
- Color (select from palette)

**FR-F-EXP-004:** User can view expense list
- Default view: Current month
- Sort: Most recent first
- Group by: Day / Category / Account
- Filter by: Date range, Category, Account, Currency

**FR-F-EXP-005:** User can edit/delete expenses
- Edit: All fields modifiable
- Delete: With confirmation dialog
- Bulk delete: Select multiple

**FR-F-EXP-006:** System calculates totals
- Total expenses (current month)
- By category breakdown
- By account breakdown
- Currency conversion (user-set rates or API)

**Data Model:**
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
  String? note;
  String? receiptPath;  // Local file path
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
}

@collection
class Category {
  Id id = Isar.autoIncrement;
  late String name;
  late String type;  // expense, income
  String icon = 'other';
  String color = '#757575';
  bool isDefault = false;
  bool isActive = true;
}

@collection
class Account {
  Id id = Isar.autoIncrement;
  late String name;
  late String currency;
  late double balance;
  String type = 'cash';  // cash, bank, card, wallet
  String? bankName;
  String? accountNumber;
  bool isActive = true;
  DateTime createdAt = DateTime.now();
}
```

**UI Components:**
- Expenses list screen
- Add expense dialog (bottom sheet)
- Expense detail view
- Category management screen
- Receipt viewer

**Acceptance Criteria:**
```gherkin
Scenario: User logs an expense
  Given user is on expenses screen
  When user taps "Add Expense" button
  And enters amount "50.00"
  And selects currency "USD"
  And selects category "Food & Dining"
  And selects account "Cash"
  And taps "Save"
  Then expense is saved
  And account balance is decreased by 50 USD
  And expense appears in list
  And monthly total is updated

Scenario: User views expenses by category
  Given user has logged 5 expenses in "Food" and 3 in "Transport"
  When user filters by "Food" category
  Then 5 expenses are displayed
  And category total shows sum of those 5 expenses
```

---

#### 4.2.2 Income Tracking

**Description:**
Users can log income from multiple sources.

**Priority:** Must Have (MVP)

**User Need:**
"I want to track my income from salary, freelance, and other sources."

**Functional Requirements:**

**FR-F-INC-001:** User can add income
- Amount (required, positive)
- Currency (required)
- Source (required: Salary, Freelance, Investment, Gift, Other)
- Date (required, defaults to today)
- Account (required, where money goes)
- Note (optional)
- Recurring (boolean, for monthly salary)

**FR-F-INC-002:** User can create custom income sources
- Name
- Icon
- Color

**FR-F-INC-003:** User can set recurring income
- Frequency: Monthly, Weekly, Bi-weekly
- Day of month (1-31) or day of week
- Auto-create entries (or reminder to log)

**FR-F-INC-004:** User can view income list
- Sort: Most recent first
- Filter: Date range, Source, Account
- Total income (current month)

**FR-F-INC-005:** System updates account balance
- When income is logged
- Balance = previous + income amount
- Handles currency conversion

**Data Model:**
```dart
@collection
class Income {
  Id id = Isar.autoIncrement;
  late double amount;
  late String currency;
  late String source;
  late DateTime date;
  @Index()
  late int accountId;
  String? note;
  bool recurring = false;
  String? recurrencePattern;  // JSON: {frequency, day}
  DateTime createdAt = DateTime.now();
}
```

**Acceptance Criteria:**
```gherkin
Scenario: User logs monthly salary
  Given user has "Bank Account" with balance 1000 USD
  When user adds income:
    | Amount   | 5000   |
    | Currency | USD    |
    | Source   | Salary |
    | Account  | Bank   |
    | Recurring| Yes    |
  And taps "Save"
  Then income is saved
  And account balance becomes 6000 USD
  And recurring pattern is set for monthly
```

---

#### 4.2.3 Account Management

**Description:**
Users can manage multiple accounts (bank, cash, cards) with different currencies.

**Priority:** Must Have (MVP)

**Functional Requirements:**

**FR-F-ACC-001:** User can add account
- Name (required, e.g., "Main Bank", "Cash Wallet")
- Type (required: Bank, Cash, Credit Card, Debit Card, E-Wallet)
- Currency (required)
- Initial balance (required)
- Bank name (optional, for bank accounts)
- Last 4 digits (optional, for cards)
- Icon/color (for visual distinction)

**FR-F-ACC-002:** System tracks account balance
- Balance = initial + incomes - expenses + transfers
- Real-time updates
- Historical balance (not MVP)

**FR-F-ACC-003:** User can transfer between accounts
- From account
- To account
- Amount
- Currency conversion (if different)
- Date
- Note

**FR-F-ACC-004:** User can view account details
- Current balance
- Recent transactions (last 10)
- Total income (month)
- Total expenses (month)

**FR-F-ACC-005:** User can edit/delete accounts
- Edit: Name, type, bank name
- Cannot edit: Initial balance, currency (affects integrity)
- Delete: Only if no transactions (or move to another account)

**Data Model:**
```dart
@collection
class Transfer {
  Id id = Isar.autoIncrement;
  late int fromAccountId;
  late int toAccountId;
  late double amount;
  String? conversionRate;  // If currencies differ
  late DateTime date;
  String? note;
  DateTime createdAt = DateTime.now();
}
```

---

#### 4.2.4 Debt Management

**Description:**
Track money owed to others and money others owe to you.

**Priority:** Must Have (MVP)

**Functional Requirements:**

**FR-F-DEBT-001:** User can add debt
- Type (required: I owe / Owed to me)
- Amount (required)
- Currency (required)
- Person/Entity name (required)
- Due date (optional)
- Reason (optional note)
- Status: Unpaid, Partially Paid, Paid

**FR-F-DEBT-002:** User can log partial payment
- Payment amount
- Payment date
- Remaining balance auto-calculated

**FR-F-DEBT-003:** User can mark debt as paid
- Records payment date
- Moves to "Paid" section
- Option to log as expense/income

**FR-F-DEBT-004:** System sends reminders
- 3 days before due date (if set)
- On due date

**FR-F-DEBT-005:** User can view debt summary
- Total I owe
- Total owed to me
- Net position
- Overdue debts highlighted

**Data Model:**
```dart
@collection
class Debt {
  Id id = Isar.autoIncrement;
  late String type;  // owed_by_me, owed_to_me
  late double amount;
  String currency = 'USD';
  late String person;
  DateTime? dueDate;
  String? reason;
  String status = 'unpaid';  // unpaid, partially_paid, paid
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

**Acceptance Criteria:**
```gherkin
Scenario: User records money owed
  Given user is on debts screen
  When user taps "Add Debt"
  And selects type "I owe"
  And enters amount "500 USD"
  And enters person "Ahmed"
  And sets due date "2025-11-15"
  And taps "Save"
  Then debt is saved
  And appears in "I Owe" section
  And reminder is scheduled for 2025-11-12 (3 days before)
```

---

#### 4.2.5 Recurring Bills

**Description:**
Track recurring expenses like rent, subscriptions, utilities.

**Priority:** Must Have (MVP)

**Functional Requirements:**

**FR-F-BILL-001:** User can add recurring bill
- Name (required, e.g., "Netflix", "Electricity")
- Amount (required)
- Currency (required)
- Frequency (required: Monthly, Weekly, Yearly)
- Day of month (1-31, for monthly) or day of week
- Category (required)
- Account (required, where to pay from)
- Reminder: X days before (configurable, default: 3)

**FR-F-BILL-002:** System sends bill reminders
- Notification X days before due date
- Notification on due date
- Action: "Mark as Paid" / "Snooze"

**FR-F-BILL-003:** User can mark bill as paid
- Records payment date
- Creates expense entry automatically
- Schedules next bill instance

**FR-F-BILL-004:** User can view bills calendar
- Upcoming bills this month
- Amount due
- Days until due

**FR-F-BILL-005:** User can edit/delete bills
- Edit: All fields
- Delete: With confirmation
- Pause: Temporarily disable

**Data Model:**
```dart
@collection
class RecurringBill {
  Id id = Isar.autoIncrement;
  late String name;
  late double amount;
  String currency = 'USD';
  late String frequency;  // monthly, weekly, yearly
  int? dayOfMonth;  // 1-31
  int? dayOfWeek;   // 0-6
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
  late DateTime? paidDate;
  String status = 'pending';  // pending, paid, overdue
  int? expenseId;  // Links to expense entry
}
```

**Acceptance Criteria:**
```gherkin
Scenario: User adds monthly rent bill
  Given user is on bills screen
  When user taps "Add Bill"
  And enters name "Rent"
  And enters amount "1500 USD"
  And selects frequency "Monthly"
  And sets day of month "1"
  And selects category "Housing"
  And selects account "Bank Account"
  And sets reminder "3 days before"
  And taps "Save"
  Then bill is saved
  And next due date is calculated (next month, day 1)
  And reminder is scheduled for 3 days before due date

Scenario: User marks bill as paid
  Given "Rent" bill is due on "2025-11-01"
  When user taps "Mark as Paid" on notification
  Then payment is recorded with today's date
  And expense entry is created automatically
  And next due date is set to "2025-12-01"
  And reminder is scheduled for "2025-11-28"
```

---

#### 4.2.6 Financial Commitments (Future Obligations)

**Description:**
Track future financial goals/obligations (e.g., wedding, car purchase, trip).

**Priority:** Must Have (MVP)

**Functional Requirements:**

**FR-F-COM-001:** User can add commitment
- Name (required, e.g., "Wedding", "New Car")
- Target amount (required)
- Currency (required)
- Deadline (required date)
- Current saved amount (optional, default: 0)
- Priority (optional: Low, Medium, High)
- Note (optional)

**FR-F-COM-002:** User can update saved amount
- Add savings progress
- Records date of each contribution
- Progress percentage auto-calculated

**FR-F-COM-003:** System shows progress
- Progress bar (current / target)
- Percentage complete
- Amount remaining
- Days remaining until deadline
- Suggested monthly savings (if deadline set)

**FR-F-COM-004:** System sends milestone notifications
- 25%, 50%, 75%, 100% reached
- 30 days before deadline

**FR-F-COM-005:** User can mark commitment as completed
- Records completion date
- Moves to "Achieved" section

**Data Model:**
```dart
@collection
class FinancialCommitment {
  Id id = Isar.autoIncrement;
  late String name;
  late double targetAmount;
  String currency = 'USD';
  late DateTime deadline;
  double currentAmount = 0.0;
  String priority = 'medium';
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

**Acceptance Criteria:**
```gherkin
Scenario: User creates wedding savings goal
  Given user is on commitments screen
  When user taps "Add Commitment"
  And enters name "Wedding"
  And enters target "100000 EGP"
  And sets deadline "2026-06-01"
  And taps "Save"
  Then commitment is saved
  And progress shows "0 / 100,000 EGP (0%)"
  And suggested savings shows "Monthly: 10,000 EGP" (for 10 months)

Scenario: User adds savings progress
  Given "Wedding" commitment exists with 0 EGP saved
  When user taps "Add Savings"
  And enters amount "15000 EGP"
  And taps "Save"
  Then contribution is recorded
  And progress updates to "15,000 / 100,000 EGP (15%)"
  And notification shows "Great! 15% towards your Wedding goal"
```

---

#### 4.2.7 Alerts & Notifications

**Description:**
Notify users about financial events.

**Priority:** Must Have (MVP)

**Functional Requirements:**

**FR-F-ALT-001:** High spending alert
- Trigger: When month's expenses exceed user-defined threshold
- Notification: "You've spent 5,000 USD this month (High spending alert)"
- Configurable threshold per currency

**FR-F-ALT-002:** Low balance alert
- Trigger: When account balance falls below user-defined minimum
- Notification: "Bank Account balance is low: 50 USD remaining"
- Configurable per account

**FR-F-ALT-003:** Bill due reminder
- Already covered in FR-F-BILL-002

**FR-F-ALT-004:** Debt due reminder
- Already covered in FR-F-DEBT-004

---

### 4.3 Notes Module

#### 4.3.1 Note Management

**Description:**
Users can create, edit, and organize simple notes with attachments.

**Priority:** Must Have (MVP)

**User Need:**
"I want a simple place to jot down thoughts, lists, and attach files."

**Functional Requirements:**

**FR-N-NOTE-001:** User can create note
- Title (optional, max 100 chars)
- Content (required, plain text, max 10,000 chars)
- Color (required, 6 predefined colors)
- Attachments (optional, images/files, max 5 per note)
- Voice note (optional, audio recording, max 5 min)
- Checklist items (optional, list of tasks with checkboxes)

**FR-N-NOTE-002:** System provides color options
- Colors: Blue, Green, Yellow, Red, Purple, Grey
- Used for visual organization

**FR-N-NOTE-003:** User can attach files
- Image: JPG, PNG (from camera or gallery)
- File: PDF, TXT, DOC, XLS (from file picker)
- Max size per file: 10 MB
- Max total: 50 MB per note

**FR-N-NOTE-004:** User can record voice note
- Integrated audio recorder
- Play, pause, delete controls
- Displayed as audio player in note

**FR-N-NOTE-005:** User can create checklist
- Add/remove checklist items
- Check/uncheck items
- Items persist with note

**FR-N-NOTE-006:** User can view notes list
- Default view: Grid or List (user preference)
- Sort: Last modified first
- Filter by color
- Shows: Title (or first line), date, color, attachment indicator

**FR-N-NOTE-007:** User can edit note
- All fields modifiable
- Auto-save on exit or manual save

**FR-N-NOTE-008:** User can delete note
- Confirmation dialog
- Permanent deletion (no trash in MVP)
- Deletes associated files

**FR-N-NOTE-009:** User can lock individual note
- Requires PIN (app lock PIN or custom)
- Locked notes show lock icon
- Content hidden until unlocked

**FR-N-NOTE-010:** User can share note
- Share as text (content only)
- Share with attachments (files)
- Via: Email, WhatsApp, etc. (system share sheet)

**Data Model:**
```dart
@collection
class Note {
  Id id = Isar.autoIncrement;
  String? title;
  late String content;
  String color = 'blue';
  List<String> attachments = [];  // File paths
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

**UI Components:**
- Notes grid/list view
- Note editor screen (full screen)
- Color picker (bottom sheet)
- File picker integration
- Audio recorder widget
- Checklist input widget
- Lock note dialog

**Acceptance Criteria:**
```gherkin
Scenario: User creates a note with checklist
  Given user is on notes screen
  When user taps "New Note"
  And enters title "Grocery List"
  And adds checklist item "Milk"
  And adds checklist item "Bread"
  And adds checklist item "Eggs"
  And selects color "Green"
  And taps "Save"
  Then note is saved
  And appears in notes list with green color
  And shows "3 items" indicator

Scenario: User locks a note
  Given user has note "Personal Thoughts"
  When user opens note
  And taps "Lock Note" option
  And enters PIN "1234"
  And taps "Confirm"
  Then note is locked
  And lock icon appears on note card
  When user tries to open note
  Then PIN prompt is shown
  When user enters correct PIN "1234"
  Then note content is displayed
```

---

#### 4.3.2 Note Organization (Phase 2)

**Description:**
Advanced organization features like tags and search.

**Priority:** Should Have (Phase 2)

**FR-N-ORG-001:** User can add tags to notes
- Multiple tags per note
- Autocomplete from existing tags
- Filter notes by tag

**FR-N-ORG-002:** User can search notes
- Search in: Title, content, checklist items
- Real-time search results
- Highlights matching text

---

### 4.4 Reminders Module

#### 4.4.1 Reminder Management

**Description:**
Users can create standalone reminders or link them to medications, bills, notes.

**Priority:** Must Have (MVP)

**User Need:**
"I want flexible reminders for various tasks and events."

**Functional Requirements:**

**FR-R-REM-001:** User can create reminder
- Title (required, max 100 chars)
- Description (optional, max 500 chars)
- Date & Time (required)
- Recurring (optional: None, Daily, Weekly, Monthly)
- Priority (required: Normal, Important, Urgent)
- Linked to (optional: Medication, Bill, Note)
- Notification settings (sound, vibrate)

**FR-R-REM-002:** System schedules notification
- At specified date/time
- Notification title: Reminder title
- Notification body: Description
- Actions: "Done" / "Snooze"
- Sound: Based on priority (louder for urgent)
- Channel: By priority

**FR-R-REM-003:** User can set recurring reminders
- Daily: Every day at time
- Weekly: Specific day(s) of week
- Monthly: Specific day of month

**FR-R-REM-004:** User can link reminders
- Link to medication: Auto-created from medication times
- Link to bill: Auto-created from bill due date
- Link to note: Manually link existing note

**FR-R-REM-005:** User can view reminders list
- Tabs: Upcoming, Completed, All
- Sort: Nearest first
- Group by: Today, Tomorrow, This Week, Later
- Shows: Title, time, priority indicator

**FR-R-REM-006:** User can mark reminder as done
- From notification: Tap "Done"
- From app: Swipe or checkbox
- Moves to "Completed"
- If recurring: Schedules next instance

**FR-R-REM-007:** User can snooze reminder
- Snooze options: 10 min, 30 min, 1 hour, 3 hours, Tomorrow
- Re-schedules notification

**FR-R-REM-008:** User can edit/delete reminders
- Edit: All fields
- Delete: With confirmation
- Deleting linked reminder doesn't delete source (medication, bill)

**Data Model:**
```dart
@collection
class Reminder {
  Id id = Isar.autoIncrement;
  late String title;
  String? description;
  late DateTime dateTime;
  String recurring = 'none';  // none, daily, weekly, monthly
  String? recurrencePattern;  // JSON for complex patterns
  String priority = 'normal';  // normal, important, urgent
  String? linkedType;  // medication, bill, note, null
  int? linkedId;
  bool completed = false;
  DateTime? completedAt;
  DateTime createdAt = DateTime.now();
}
```

**UI Components:**
- Reminders list screen (with tabs)
- Add reminder dialog
- Reminder detail view
- Priority selector
- Recurrence selector
- Link selector (if applicable)
- Notification with actions

**Acceptance Criteria:**
```gherkin
Scenario: User creates urgent reminder
  Given user is on reminders screen
  When user taps "Add Reminder"
  And enters title "Doctor Appointment"
  And enters description "Annual checkup at City Hospital"
  And sets date/time "2025-11-05 10:00"
  And selects priority "Urgent"
  And taps "Save"
  Then reminder is saved
  And notification is scheduled
  And reminder appears in "Upcoming" with urgent indicator

Scenario: User creates recurring weekly reminder
  Given user creates reminder "Team Meeting"
  And sets time "Monday 09:00"
  And selects recurring "Weekly"
  And taps "Save"
  Then reminder is saved
  And notification is scheduled for next Monday 09:00
  When Monday arrives and user marks as done
  Then reminder is moved to completed
  And next instance is scheduled for following Monday
```

---

### 4.5 Settings & Security Module

#### 4.5.1 App Lock

**Description:**
Secure the app with PIN, pattern, or biometric authentication.

**Priority:** Must Have (MVP)

**User Need:**
"I want to protect my sensitive health and financial data."

**Functional Requirements:**

**FR-S-LOCK-001:** User can enable app lock
- Options: PIN (4-6 digits), Pattern (3x3 grid), Biometric (fingerprint/face)
- Setup flow: Choose method → Create → Confirm
- Option to require on every launch or after X minutes

**FR-S-LOCK-002:** System locks app
- Immediately: If user backgrounds app
- After timeout: Configurable (1, 5, 15, 30 min, Never)
- On launch: Always (if enabled)

**FR-S-LOCK-003:** User can unlock app
- Enter PIN / Pattern / Use biometric
- 3 failed attempts: 30-second lockout
- 5 failed attempts: 1-minute lockout
- 10 failed attempts: Require security answer or reset (future)

**FR-S-LOCK-004:** User can change lock method
- Requires current authentication
- Can switch between PIN/Pattern/Biometric

**FR-S-LOCK-005:** User can disable app lock
- Requires authentication
- Confirmation: "Are you sure? Your data won't be protected."

**Data Model:**
```dart
// Stored in Flutter Secure Storage (not Isar)
class AppLockSettings {
  bool enabled;
  String method;  // pin, pattern, biometric
  String hashedSecret;  // For PIN/Pattern
  int autoLockMinutes;
  DateTime? lastUnlockTime;
}
```

**UI Components:**
- App lock setup screen
- Lock screen (overlay)
- PIN/Pattern input widget
- Biometric prompt
- Settings screen with app lock options

**Acceptance Criteria:**
```gherkin
Scenario: User sets up PIN lock
  Given user is in settings
  When user taps "App Lock"
  And selects "Enable"
  And chooses "PIN"
  And enters PIN "123456"
  And confirms PIN "123456"
  And sets auto-lock "After 5 minutes"
  And taps "Save"
  Then app lock is enabled
  And PIN is securely stored
  When user backgrounds app for 6 minutes
  And reopens app
  Then lock screen is shown
  When user enters correct PIN "123456"
  Then app unlocks and shows main screen
```

---

#### 4.5.2 Database Encryption

**Description:**
Encrypt local database for data security.

**Priority:** Must Have (MVP)

**Functional Requirements:**

**FR-S-ENC-001:** System encrypts Isar database
- Uses Isar built-in encryption
- Encryption key derived from device-specific identifier
- Stored securely in Flutter Secure Storage

**FR-S-ENC-002:** Locked notes are double-encrypted
- Note content encrypted with note-specific key
- Key encrypted with user's PIN
- Ensures even with database access, locked notes are secure

---

#### 4.5.3 Backup & Restore

**Description:**
Users can backup and restore their data.

**Priority:** Must Have (MVP)

**Functional Requirements:**

**FR-S-BAK-001:** User can create local backup
- Exports all data to encrypted JSON file
- Saved to device storage (Documents folder)
- Filename: `life_tracker_backup_YYYYMMDD_HHMMSS.ltb`
- Includes: All entries, settings (except sensitive keys)

**FR-S-BAK-002:** System encrypts backup file
- Password-protected (user sets password)
- AES-256 encryption
- Cannot be opened without password

**FR-S-BAK-003:** User can restore from backup
- Select backup file
- Enter backup password
- Merge options: Replace all / Merge with existing
- Confirmation: "This will overwrite current data"

**FR-S-BAK-004:** User can enable auto-backup (Phase 2)
- Schedule: Daily, Weekly
- Destination: Google Drive (encrypted)
- Requires Google account sign-in

**Data Model:**
```dart
class BackupData {
  String version;
  DateTime createdAt;
  Map<String, dynamic> data;  // All collections
  Map<String, dynamic> settings;
}
```

**Acceptance Criteria:**
```gherkin
Scenario: User creates encrypted backup
  Given user has data in the app
  When user goes to Settings > Backup
  And taps "Create Backup"
  And enters backup password "SecurePass123"
  And confirms password
  And taps "Create"
  Then backup file is created
  And saved to device as "life_tracker_backup_20251027_153045.ltb"
  And success message is shown

Scenario: User restores from backup
  Given user has backup file on device
  When user goes to Settings > Backup
  And taps "Restore from Backup"
  And selects backup file
  And enters backup password "SecurePass123"
  And confirms "Replace all data"
  And taps "Restore"
  Then backup is decrypted
  And all data is imported
  And app restarts with restored data
```

---

#### 4.5.4 User Profile

**Description:**
Users can set up their profile for personalized calculations.

**Priority:** Must Have (MVP)

**Functional Requirements:**

**FR-S-PRO-001:** User can create/edit profile
- Name (optional)
- Date of birth / Age (optional, used for ideal weight)
- Gender (optional: Male, Female, Other)
- Height (optional, in cm, used for BMI)
- Photo (optional)

**FR-S-PRO-002:** Profile affects calculations
- BMI requires: Height, current weight
- Ideal weight requires: Height, age, gender

**FR-S-PRO-003:** Onboarding prompts profile setup
- On first launch
- Optional skip (can set up later)

---

#### 4.5.5 General Settings

**Description:**
App-wide configuration options.

**Priority:** Must Have (MVP)

**Functional Requirements:**

**FR-S-SET-001:** Theme
- Light mode
- Dark mode
- Auto (system)

**FR-S-SET-002:** Language
- English
- Arabic
- Auto-detect (future: more languages)

**FR-S-SET-003:** Default currency
- Set from list of major currencies
- Used as default when adding expenses/income

**FR-S-SET-004:** Notification settings
- Enable/disable all notifications
- Per-module: Medications, Reminders, Bills, Alerts

**FR-S-SET-005:** Date & Time format
- Date: DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD
- Time: 12-hour, 24-hour

**FR-S-SET-006:** About
- App version
- Open source licenses
- Privacy policy
- Terms of service
- Contact support

---

### 4.6 Dashboard

**Description:**
Home screen showing overview of all modules.

**Priority:** Must Have (MVP)

**User Need:**
"I want to see a quick summary of my health and finances when I open the app."

**Functional Requirements:**

**FR-D-001:** Dashboard shows health summary
- Latest weight + BMI (if logged today/week)
- Next medication reminder
- Health quick actions: Log weight, Add medication

**FR-D-002:** Dashboard shows finance summary
- Total balance (all accounts)
- This month's expenses
- This month's income
- Upcoming bills (next 7 days)
- Finance quick actions: Add expense, Add income

**FR-D-003:** Dashboard shows reminders summary
- Today's reminders count
- Next upcoming reminder
- Quick action: Add reminder

**FR-D-004:** Dashboard shows notes summary
- Total notes count
- Recent note (last edited)
- Quick action: New note

**FR-D-005:** User can customize dashboard
- Show/hide modules
- Reorder modules
- (Future: Widget-style customization)

**UI Layout:**
```
┌─────────────────────────────────────┐
│  👋 Hello, [Name]                    │
│  [Date]                              │
├─────────────────────────────────────┤
│  HEALTH                              │
│  ┌──────────────────────────────┐   │
│  │ Weight: 75.5 kg | BMI: 23.1  │   │
│  │ ━━━━━━━━━━ Normal            │   │
│  └──────────────────────────────┘   │
│  Next: Aspirin at 9:00 PM           │
├─────────────────────────────────────┤
│  FINANCE                             │
│  ┌──────────────────────────────┐   │
│  │ Total Balance: $5,250        │   │
│  │ This Month: -$1,200 / +$5000 │   │
│  └──────────────────────────────┘   │
│  Upcoming: Rent on Nov 1 ($1500)    │
├─────────────────────────────────────┤
│  REMINDERS                           │
│  3 reminders today                   │
│  Next: Team Meeting at 2:00 PM      │
├─────────────────────────────────────┤
│  NOTES                               │
│  12 notes | Last: Grocery List       │
└─────────────────────────────────────┘
```

---

## 5. User Stories & Acceptance Criteria

### 5.1 Health Stories

#### Epic: Weight Management
**US-H-001:** As a user, I want to track my daily weight so that I can monitor my progress towards my goal.
- **AC1:** I can quickly log today's weight in kg
- **AC2:** I see my BMI calculated automatically
- **AC3:** I see my ideal weight range
- **AC4:** I can view my weight history as a list

**US-H-002:** As a user, I want to set a weight goal so that I can stay motivated.
- **AC1:** I can set target weight and target date
- **AC2:** I see progress percentage
- **AC3:** I see days remaining

#### Epic: Medication Adherence
**US-H-003:** As a user, I want reminders for my medications so that I never miss a dose.
- **AC1:** I can add medication with dosage and times
- **AC2:** I receive notification at each scheduled time
- **AC3:** I can mark medication as taken from notification
- **AC4:** I can snooze reminder if needed

**US-H-004:** As a user, I want to see my medication adherence so that I know if I'm taking meds consistently.
- **AC1:** I see percentage of doses taken on time
- **AC2:** I see missed doses count
- **AC3:** I see current streak (consecutive days)

---

### 5.2 Finance Stories

#### Epic: Expense Tracking
**US-F-001:** As a user, I want to quickly log expenses so that I know where my money goes.
- **AC1:** I can add expense with amount, category, account in < 10 seconds
- **AC2:** I can optionally add date, note, receipt photo
- **AC3:** I see expense in list immediately
- **AC4:** My account balance updates automatically

**US-F-002:** As a user, I want to see my spending by category so that I can identify areas to save.
- **AC1:** I can filter expenses by category
- **AC2:** I see total amount per category
- **AC3:** I see percentage of total spending per category

#### Epic: Income Tracking
**US-F-003:** As a user, I want to log my income from various sources so that I have a complete financial picture.
- **AC1:** I can add income with amount, source, account
- **AC2:** My account balance increases automatically
- **AC3:** I can set recurring income for salary

#### Epic: Debt Management
**US-F-004:** As a user, I want to track debts so that I remember what I owe and what's owed to me.
- **AC1:** I can add "I owe" and "Owed to me" entries
- **AC2:** I see total I owe and total owed to me
- **AC3:** I receive reminder before due date
- **AC4:** I can mark debt as paid

#### Epic: Bill Management
**US-F-005:** As a user, I want to track recurring bills so that I never miss a payment.
- **AC1:** I can add monthly/weekly bills with due date
- **AC2:** I receive reminder 3 days before due date
- **AC3:** I can mark bill as paid, which creates expense
- **AC4:** System schedules next bill automatically

---

### 5.3 Notes & Reminders Stories

#### Epic: Note-Taking
**US-N-001:** As a user, I want to create quick notes so that I can jot down ideas.
- **AC1:** I can create note with title and content
- **AC2:** I can choose color for visual organization
- **AC3:** I can attach images and files
- **AC4:** I can record voice note

**US-N-002:** As a user, I want to create checklists in notes so that I can track tasks.
- **AC1:** I can add checklist items to note
- **AC2:** I can check/uncheck items
- **AC3:** Checked items are visually marked
- **AC4:** Checklist state persists

**US-N-003:** As a user, I want to lock sensitive notes so that they're protected.
- **AC1:** I can lock individual note with PIN
- **AC2:** Locked notes require PIN to view
- **AC3:** Lock icon is shown on locked notes

#### Epic: Reminders
**US-R-001:** As a user, I want to set reminders for tasks so that I don't forget.
- **AC1:** I can create reminder with title, date/time
- **AC2:** I receive notification at specified time
- **AC3:** I can mark reminder as done
- **AC4:** I can snooze reminder

**US-R-002:** As a user, I want recurring reminders so that I don't have to recreate them.
- **AC1:** I can set daily, weekly, or monthly recurrence
- **AC2:** When marked as done, next instance is auto-created
- **AC3:** I can edit or delete recurring reminder

---

### 5.4 Security Stories

#### Epic: App Security
**US-S-001:** As a user, I want to lock the app so that no one else can see my data.
- **AC1:** I can enable PIN, pattern, or biometric lock
- **AC2:** App locks immediately when backgrounded
- **AC3:** App requires unlock on next launch
- **AC4:** App locks after configurable timeout

**US-S-002:** As a user, I want to backup my data so that I don't lose it.
- **AC1:** I can create encrypted backup to device
- **AC2:** I can restore from backup with password
- **AC3:** Backup includes all data and settings

---

## 6. User Flows

### 6.1 Onboarding Flow

```
[Launch App First Time]
       ↓
[Welcome Screen]
 "Welcome to Life Tracker"
  - Slide 1: Track health
  - Slide 2: Manage finances
  - Slide 3: Never forget with reminders
       ↓
[Get Started] button
       ↓
[Profile Setup (Optional)]
  - Name
  - Date of Birth
  - Gender
  - Height
       ↓
[App Lock Setup (Optional)]
  - Skip / Enable PIN / Enable Biometric
       ↓
[Dashboard]
```

### 6.2 Add Weight Flow

```
[Weight Screen]
       ↓
[Tap FAB "Log Weight"]
       ↓
[Add Weight Dialog]
  - Weight input (numeric)
  - Date picker (default: today)
  - Note input (optional)
       ↓
[Tap "Save"]
       ↓
[Validation]
  - Weight between 20-300 kg?
    - No → Show error "Please enter valid weight"
    - Yes → Continue
       ↓
[Calculate BMI]
  - Requires profile height
    - No height → Prompt "Set height in profile for BMI"
    - Has height → Calculate BMI
       ↓
[Save to Database]
       ↓
[Update UI]
  - Close dialog
  - Add entry to list
  - Update BMI card
  - Show success message
```

### 6.3 Add Expense Flow

```
[Finance Screen] or [Dashboard]
       ↓
[Tap "Add Expense"]
       ↓
[Add Expense Bottom Sheet]
  - Amount input (focus)
  - Currency dropdown (default: user's)
  - Category selector (icons)
  - Account dropdown
  - Date picker (default: today)
  - Note input (optional)
  - Receipt photo (optional)
       ↓
[Tap "Save"]
       ↓
[Validation]
  - Amount > 0?
  - Category selected?
  - Account selected?
    - Any fail → Show error
    - All pass → Continue
       ↓
[Update Account Balance]
  balance = balance - amount
       ↓
[Save to Database]
       ↓
[Update UI]
  - Close sheet
  - Add expense to list
  - Update account balance
  - Update monthly total
  - Show success snackbar
       ↓
[Check Alerts]
  - Is spending > threshold? → Show alert
  - Is balance < minimum? → Show alert
```

### 6.4 Add Medication with Reminder Flow

```
[Medications Screen]
       ↓
[Tap "Add Medication"]
       ↓
[Add Medication Screen]
  - Name input
  - Dosage input (e.g., "500mg")
  - Times selector (add multiple)
    - [Add Time] button → Time picker
  - Instructions (optional)
  - Start date (default: today)
       ↓
[Tap "Save"]
       ↓
[Validation]
  - Name not empty?
  - Dosage not empty?
  - At least one time?
    - Any fail → Show error
    - All pass → Continue
       ↓
[Save Medication to Database]
       ↓
[Schedule Notifications]
  For each time:
    - Create daily recurring notification
    - Set title: Medication name
    - Set body: Dosage + instructions
    - Set actions: Taken / Snooze
       ↓
[Update UI]
  - Navigate back
  - Show medication in list
  - Show success message "Reminders set for [times]"
```

### 6.5 Create Note with Checklist Flow

```
[Notes Screen]
       ↓
[Tap FAB "New Note"]
       ↓
[Note Editor Screen]
  - Title input (optional)
  - Content input (multiline)
  - [Add Checklist Item] button
       ↓
[User taps "Add Checklist Item"]
       ↓
[Checklist Item Dialog]
  - Text input
       ↓
[Tap "Add"]
       ↓
[Item added to list in editor]
  - Shows checkbox + text
  - Can check/uncheck
  - Can delete item
       ↓
[User selects color (bottom bar)]
  - 6 color options
       ↓
[Tap "Save" (top right)]
       ↓
[Save Note to Database]
       ↓
[Navigate back to Notes Screen]
       ↓
[Note appears in grid/list]
  - Shows title or first line
  - Shows selected color
  - Shows "3 items" if has checklist
```

### 6.6 Set Reminder for Bill Flow

```
[Bills Screen]
       ↓
[User adds bill "Rent"]
  - Name: "Rent"
  - Amount: 1500 USD
  - Frequency: Monthly
  - Day: 1
  - Reminder: 3 days before
       ↓
[Tap "Save"]
       ↓
[Calculate Next Due Date]
  - Next month, day 1
       ↓
[Calculate Reminder Date]
  - Due date - 3 days
       ↓
[Create Linked Reminder]
  - Title: "Bill due: Rent"
  - Description: "$1500 on Nov 1"
  - Date: Reminder date
  - Linked to: Bill ID
       ↓
[Schedule Notification]
       ↓
[Save Bill to Database]
       ↓
[Update UI]
  - Show bill in list
  - Show next due date
  - Confirmation: "Reminder set for Oct 29"
```

### 6.7 App Lock Flow

```
[User Backgrounds App]
       ↓
[App goes to background]
       ↓
[Record last active time]
       ↓
--- Time passes ---
       ↓
[User Reopens App]
       ↓
[Check if app lock enabled]
  - No → Show Dashboard
  - Yes → Continue
       ↓
[Check time since last active]
  - < auto-lock timeout → Show Dashboard
  - >= auto-lock timeout → Show Lock Screen
       ↓
[Lock Screen Overlay]
  - App logo
  - "Enter PIN" / "Use Fingerprint"
  - PIN input / Biometric prompt
       ↓
[User enters PIN / Uses biometric]
       ↓
[Verify]
  - Incorrect → Show error, attempt count++
  - Correct → Continue
       ↓
[Unlock App]
  - Hide lock screen
  - Show Dashboard
  - Reset attempt count
```

---

## 7. Non-Functional Requirements

### 7.1 Performance

**NFR-P-001:** App cold start time < 2 seconds
- Measured from tap to interactive dashboard
- On mid-range Android device (2020+)

**NFR-P-002:** Database queries < 100ms
- For lists with 1000+ entries
- With proper indexing

**NFR-P-003:** Smooth animations at 60 FPS
- Transitions, scrolling, interactions
- No jank or stuttering

**NFR-P-004:** App size < 50 MB
- Installed size on device
- Without user data

**NFR-P-005:** Memory usage < 200 MB
- During normal operation
- No memory leaks

### 7.2 Offline Functionality

**NFR-O-001:** All core features work offline
- Except cloud sync (Phase 2)
- No "no internet" errors for main features

**NFR-O-002:** Data persists locally
- Isar database
- Survives app restart

**NFR-O-003:** Sync when online (Phase 2)
- Background sync
- Conflict resolution (last-write-wins for MVP)

### 7.3 Security & Privacy

**NFR-S-001:** Local data storage only (MVP)
- No data sent to external servers
- All processing on device

**NFR-S-002:** Database encryption
- Isar encryption enabled
- Encryption key secured

**NFR-S-003:** Locked notes double-encrypted
- Content encrypted separately
- Key derived from user PIN

**NFR-S-004:** No analytics/tracking (MVP)
- Respect user privacy
- Phase 2: Optional, opt-in analytics

**NFR-S-005:** Compliance
- GDPR-ready (data portability, deletion)
- No personal data collection without consent

### 7.4 Usability

**NFR-U-001:** Intuitive UI
- New users can add weight in < 30 seconds without tutorial
- Clear labels and icons

**NFR-U-002:** Minimal taps
- Quick actions accessible from dashboard
- FABs for primary actions

**NFR-U-003:** Error messages are clear
- "Please enter weight between 20-300 kg" instead of "Invalid input"

**NFR-U-004:** Accessibility
- Support TalkBack (screen reader)
- Minimum touch target: 48x48 dp
- Sufficient color contrast (WCAG AA)

**NFR-U-005:** Localization
- Full Arabic and English support
- RTL support for Arabic
- Date/number formatting per locale

### 7.5 Compatibility

**NFR-C-001:** Android version support
- Minimum: Android 6.0 (API 23)
- Target: Android 14 (API 34)

**NFR-C-002:** Device support
- Screen sizes: 4.5" to 7" (phones)
- Screen densities: mdpi to xxxhdpi
- Orientations: Portrait (primary), Landscape (supported)

**NFR-C-003:** Hardware
- RAM: 2 GB minimum
- Storage: 100 MB free space

### 7.6 Reliability

**NFR-R-001:** Crash-free rate > 99%
- Measured over 30 days
- Crash reporting via Firebase Crashlytics (Phase 2)

**NFR-R-002:** Data integrity
- No data loss on app crash
- Isar transactions ensure consistency

**NFR-R-003:** Backup robustness
- Backup creates valid file or fails cleanly
- No partial/corrupted backups

### 7.7 Maintainability

**NFR-M-001:** Code quality
- Clean Architecture
- Comprehensive comments
- Dart analysis with no errors/warnings

**NFR-M-002:** Testing
- Unit test coverage > 70%
- Widget test coverage > 50%
- Integration tests for critical flows

**NFR-M-003:** Documentation
- Inline code documentation
- README with setup instructions
- Architecture diagram

---

## 8. Success Metrics & KPIs

### 8.1 User Acquisition

| Metric | MVP (3 months) | Phase 2 (6 months) | Phase 3 (12 months) |
|--------|----------------|-------------------|---------------------|
| Downloads | 5,000 | 25,000 | 100,000 |
| Active Users (MAU) | 2,000 | 10,000 | 40,000 |
| User Growth Rate | N/A | +50% MoM | +20% MoM |

### 8.2 User Engagement

| Metric | Target |
|--------|--------|
| Daily Active Users (DAU) | 30% of MAU |
| Session Length | 3-5 minutes |
| Sessions per Day | 2-3 |
| Retention (Day 1) | 60% |
| Retention (Day 7) | 40% |
| Retention (Day 30) | 30% |

### 8.3 Feature Adoption

| Feature | Target Adoption |
|---------|----------------|
| Weight Tracking | 60% of users |
| Medication Reminders | 40% of users |
| Expense Tracking | 80% of users |
| Notes | 50% of users |
| Reminders | 70% of users |
| App Lock | 60% of users |

### 8.4 User Satisfaction

| Metric | Target |
|--------|--------|
| Google Play Rating | 4.5+ stars |
| Positive Reviews % | 80% |
| Feature Requests | Track top 10 |
| Support Tickets | < 2% of users |

### 8.5 Performance Metrics

| Metric | Target |
|--------|--------|
| App Startup Time | < 2 seconds |
| Crash-Free Rate | > 99% |
| ANR (App Not Responding) Rate | < 0.1% |
| API Success Rate (Phase 2) | > 99.5% |

### 8.6 Business Metrics (Future)

| Metric | Phase 3 Target |
|--------|---------------|
| Conversion to Premium | 5% (if premium tier added) |
| Average Revenue Per User | $2-5 (if monetized) |
| Lifetime Value (LTV) | $10-20 |

---

## 9. Constraints & Assumptions

### 9.1 Constraints

**Technical Constraints:**
- Flutter framework limitations
- Android platform restrictions (notifications, background tasks)
- Device hardware limitations (low-end devices)
- Isar database limitations (no server-side queries)

**Resource Constraints:**
- Solo developer (initial development)
- 10-week development timeline for MVP
- Budget: Minimal (self-funded)

**Legal Constraints:**
- GDPR compliance (if European users)
- Google Play Store policies
- No medical claims (not a medical device)

### 9.2 Assumptions

**User Assumptions:**
- Users have Android 6.0+ devices
- Users understand basic smartphone operations
- Users are comfortable granting permissions (storage, notifications)
- Users want privacy-focused, offline-first solution

**Technical Assumptions:**
- Flutter remains stable and supported
- Isar database is reliable for production use
- Device hardware improves over time (better performance)
- Biometric APIs are available on most devices

**Business Assumptions:**
- Market exists for unified health+finance tracker
- Users will download app without aggressive marketing (organic growth)
- Freemium model is viable (if monetization added later)
- App Store approval without major changes

**Development Assumptions:**
- Clean Architecture enables easy feature additions
- Riverpod is sufficient for all state management needs
- Testing can be done incrementally
- No major platform changes during development

---

## 10. Glossary

**BMI (Body Mass Index):** A measure of body fat based on height and weight. Formula: weight (kg) / height² (m).

**Ideal Weight:** The recommended weight range for a person based on height, age, and gender.

**Adherence:** The degree to which a patient correctly follows medical advice, particularly medication schedules.

**Recurring Transaction:** A financial transaction that repeats at regular intervals (e.g., monthly salary, weekly groceries).

**Financial Commitment:** A future financial obligation or savings goal (e.g., wedding, car purchase).

**Debt:** Money owed by one party to another.

**Creditor:** Person/entity to whom money is owed.

**Debtor:** Person/entity who owes money.

**Checklist:** A list of items with checkboxes to track completion status.

**App Lock:** Security feature requiring authentication (PIN/Pattern/Biometric) to access the app.

**Encryption:** The process of converting data into a coded form to prevent unauthorized access.

**Backup:** A copy of data saved for restoration in case of data loss.

**Cloud Sync:** Synchronization of data between local device and cloud server.

**Offline-First:** Design approach where app works primarily with local data and syncs to cloud when available.

**Clean Architecture:** Software design pattern that separates concerns into layers (Presentation, Domain, Data).

**Riverpod:** State management library for Flutter.

**Isar:** Fast, local NoSQL database for Flutter.

**MVP (Minimum Viable Product):** The version of a product with minimum features necessary to satisfy early users.

**MAU (Monthly Active Users):** Number of unique users who engage with the app in a month.

**DAU (Daily Active Users):** Number of unique users who engage with the app in a day.

**KPI (Key Performance Indicator):** Measurable value demonstrating effectiveness in achieving business objectives.

**NFR (Non-Functional Requirement):** Requirement specifying quality attributes rather than specific behaviors.

**AC (Acceptance Criteria):** Conditions that must be met for a user story to be considered complete.

---

## 11. Appendices

### Appendix A: Competitive Analysis

| Feature | Life Tracker | MyFitnessPal | Mint | Google Keep | Todoist |
|---------|--------------|--------------|------|-------------|---------|
| Weight Tracking | ✅ | ✅ | ❌ | ❌ | ❌ |
| Medication Reminders | ✅ | ❌ | ❌ | ❌ | Limited |
| Expense Tracking | ✅ | ❌ | ✅ | ❌ | ❌ |
| Income Tracking | ✅ | ❌ | ✅ | ❌ | ❌ |
| Debt Management | ✅ | ❌ | Limited | ❌ | ❌ |
| Notes | ✅ | ❌ | ❌ | ✅ | ❌ |
| Reminders | ✅ | ❌ | ❌ | ✅ | ✅ |
| Offline-First | ✅ | Limited | ❌ | ✅ | Limited |
| App Lock | ✅ | ❌ | ❌ | ❌ | Premium |
| Multi-Currency | ✅ | ❌ | Limited | ❌ | ❌ |
| Free Core Features | ✅ | Limited | ✅ | ✅ | Limited |

### Appendix B: Technology Radar

**Adopt:**
- Flutter 3.x
- Riverpod 2.x
- Isar 3.x
- Go Router
- Flutter Local Notifications

**Trial (Phase 2):**
- Firebase (Auth, Firestore, Storage)
- Flutter Blue Plus (BLE)
- Health Connect

**Assess (Phase 3):**
- TensorFlow Lite (for insights)
- AR Kit (future features)

**Hold:**
- Redux (Riverpod is sufficient)
- SQLite (Isar is faster)
- GetX (prefer Riverpod)

---

## 12. Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2025-10-27 | [Author] | Initial PRD creation |

---

## 13. Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Product Owner | [Name] | __________ | ______ |
| Tech Lead | [Name] | __________ | ______ |
| Designer | [Name] | __________ | ______ |
| Stakeholder | [Name] | __________ | ______ |

---

**END OF DOCUMENT**

*Total Pages: ~70*
*Word Count: ~18,000+*
*Estimated Reading Time: 90 minutes*
