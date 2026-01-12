# Life Tracker - Project Instructions

> A comprehensive, offline-first life tracking Flutter application

## Project Overview

**Life Tracker** is a Flutter mobile application for tracking health, finances, medications, reminders, and notes. It follows Clean Architecture principles with a feature-first structure.

## Tech Stack

- **Framework**: Flutter 3.x, Dart 3.x
- **State Management**: Riverpod 2.x (with code generation)
- **Navigation**: GoRouter
- **Database**: Isar (Local NoSQL)
- **Localization**: Flutter Intl (English & Arabic RTL)
- **Design**: Material 3 with Google Fonts

## Project Structure

```
lib/
├── core/                     # Cross-cutting concerns
│   ├── constants/            # Theme, colors, design tokens
│   ├── services/             # App-wide services (FeedbackService, etc.)
│   ├── router/               # GoRouter navigation
│   └── utils/                # Helper functions
├── shared/widgets/           # Reusable widgets
│   └── states/               # State widgets (empty, loading, error, skeleton)
└── features/                 # Feature modules
    ├── dashboard/
    ├── finance/
    ├── health/
    ├── notes/
    ├── reminders/
    └── settings/
```

## Critical Coding Rules

### 1. Theme Colors - NEVER Hardcode

```dart
// ❌ FORBIDDEN
color: Colors.black
color: Colors.white

// ✅ CORRECT
color: Theme.of(context).colorScheme.onSurface
color: Theme.of(context).colorScheme.surface
```

### 2. Async Context Safety - ALWAYS Check `mounted`

```dart
Future<void> _saveData() async {
  await repository.save(data);
  
  if (!context.mounted) return;  // ✅ Critical check
  
  FeedbackService.showSuccess(context, 'Saved!');
}
```

### 3. Three-State Pattern - MANDATORY for Async Data

```dart
dataAsync.when(
  loading: () => const SkeletonList.cards(itemCount: 5),
  error: (e, s) => ErrorStateWidget(onRetry: () => ref.invalidate(provider)),
  data: (items) => items.isEmpty 
    ? EmptyStateWidget(...) 
    : _buildList(items),
);
```

### 4. RTL Support - Use Directional Properties

```dart
// ❌ AVOID
EdgeInsets.only(left: 16)

// ✅ USE
EdgeInsetsDirectional.only(start: 16)
```

### 5. Deprecated APIs - Use Modern Alternatives

```dart
// ❌ DEPRECATED
color.withOpacity(0.5)

// ✅ CORRECT
color.withValues(alpha: 0.5)
```

## Key Imports

```dart
// State widgets
import 'package:life_tracker/shared/widgets/states/states.dart';

// Theme (PRIMARY location)
import 'package:life_tracker/core/constants/app_theme.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

// User feedback
import 'package:life_tracker/core/services/feedback_service.dart';
```

## Common Patterns

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

### FeedbackService Usage

```dart
FeedbackService.showSuccess(context, 'Item saved!');
FeedbackService.showError(context, 'Failed to save');
FeedbackService.showInfo(context, 'Processing...');
```

## Pre-Commit Checklist

- [ ] `flutter analyze` shows 0 errors, 0 warnings
- [ ] No hardcoded colors (search for `Colors.`)
- [ ] No missing `context.mounted` checks after async
- [ ] Using `withValues(alpha:)` not `withOpacity()`
- [ ] Light/Dark mode tested
- [ ] RTL layout verified

## Commit Format

```
type(scope): message
```

**Example**: `feat(finance): Add RefreshIndicator to expenses screen`

## Documentation

- Full PRD: `Docs/COMPLETE_PRD.md`
- Development Rules: `.gemini/rules/rule1.md`
- Terms: `TERMS.md`
