---
trigger: always_on
glob: "**/*.dart"
description: Expert Flutter Development Rules for Life Tracker
---

# 🚀 Life Tracker - Expert Flutter Development Rules

> *"Clean code is not written by following a set of rules. You don't become a software craftsman by learning a list of rules. Professionalism and craftsmanship come from values that drive disciplines."* - Robert C. Martin

---

## 📋 Project Context

```yaml
Project: Life Tracker
Type: Flutter Mobile Application
Architecture: Clean Architecture with Feature-First Structure
State Management: Riverpod 2.x (with code generation)
Navigation: GoRouter
Database: Isar (Local NoSQL)
Localization: Flutter Intl (English & Arabic RTL)
Min SDK: Flutter 3.x, Dart 3.x
```

---

## 🏗️ Architecture Overview

```
lib/
├── core/                          # Cross-cutting concerns
│   ├── constants/                 # ✅ PRIMARY theme files
│   │   ├── app_theme.dart         # Main theme (Google Fonts)
│   │   ├── app_colors.dart        # Color definitions
│   │   └── app_design_tokens.dart # Spacing, sizing tokens
│   ├── services/                  # App-wide services
│   ├── router/                    # Navigation (GoRouter)
│   └── utils/                     # Helper functions
├── shared/
│   └── widgets/
│       ├── states/                # ⚠️ State widgets HERE!
│       │   ├── empty_state_widget.dart
│       │   ├── loading_widget.dart
│       │   └── error_widget.dart
│       └── ...                    # Other shared widgets
└── features/
    ├── dashboard/
    ├── finance/
    ├── health/
    ├── notes/
    ├── reminders/
    └── settings/
```

---

## 🎯 Golden Rules (NEVER BREAK)

### 1️⃣ Theme Colors - ZERO Hardcoding

```dart
// ❌ FORBIDDEN - Will break in dark mode
color: Colors.black
color: Colors.white  
color: Colors.grey.shade300
backgroundColor: Colors.blue

// ✅ MANDATORY - Theme-aware colors
color: Theme.of(context).colorScheme.onSurface
color: Theme.of(context).colorScheme.surface
color: Theme.of(context).dividerColor
backgroundColor: Theme.of(context).colorScheme.primary
```

#### Complete Color Migration Table:

| Hardcoded ❌ | Theme Equivalent ✅ | Usage |
|-------------|---------------------|-------|
| `Colors.black` | `colorScheme.onSurface` | Primary text |
| `Colors.black87` | `colorScheme.onSurface` | Primary text |
| `Colors.black54` | `colorScheme.onSurface.withOpacity(0.6)` | Secondary text |
| `Colors.white` | `colorScheme.surface` | Backgrounds |
| `Colors.grey` | `colorScheme.outline` | Borders, dividers |
| `Colors.grey.shade100` | `colorScheme.surfaceContainerHighest` | Subtle backgrounds |
| `Colors.grey.shade300` | `Theme.of(context).dividerColor` | Dividers |
| `Colors.red` | `colorScheme.error` | Errors, destructive |
| `Colors.green` | `colorScheme.tertiary` | Success states |
| `Colors.blue` | `colorScheme.primary` | Primary actions |

---

### 2️⃣ Async Context Safety

```dart
// ❌ DANGEROUS - Context may be invalid
Future<void> _saveData() async {
  await repository.save(data);
  Navigator.pop(context);  // 💥 CRASH if widget disposed
  ScaffoldMessenger.of(context).showSnackBar(...);  // 💥 CRASH
}

// ✅ SAFE - Always check mounted
Future<void> _saveData() async {
  try {
    await repository.save(data);
    
    if (!context.mounted) return;  // ✅ Critical check
    
    FeedbackService.showSuccess(context, 'Saved!');
    Navigator.pop(context);
    
  } catch (e) {
    if (!context.mounted) return;  // ✅ Also in catch
    FeedbackService.showError(context, e.toString());
  }
}
```

---

### 3️⃣ Three-State Pattern (MANDATORY)

Every screen displaying async data MUST handle ALL states:

```dart
@override
Widget build(BuildContext context) {
  final dataAsync = ref.watch(dataProvider);
  
  return dataAsync.when(
    // 1️⃣ LOADING - Show skeleton or spinner
    loading: () => const LoadingWidget(useShimmer: true),
    
    // 2️⃣ ERROR - Show error with retry
    error: (error, stack) => ErrorStateWidget(
      message: _getUserFriendlyError(error),
      onRetry: () => ref.invalidate(dataProvider),
    ),
    
    // 3️⃣ DATA - Handle empty AND populated
    data: (items) {
      if (items.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.inbox_outlined,
          message: 'No items yet',
          actionLabel: 'Add First Item',
          onAction: () => _showAddDialog(context),
        );
      }
      return _buildList(items);
    },
  );
}

String _getUserFriendlyError(Object error) {
  // Don't show technical errors to users
  if (error is NetworkException) return 'Check your connection';
  if (error is DatabaseException) return 'Data error occurred';
  return 'Something went wrong';
}
```

---

## ⚡ Performance Optimization

### ListView Best Practices

```dart
// ❌ SLOW - Creates all widgets upfront
ListView(
  children: items.map((item) => ItemCard(item: item)).toList(),
)

// ✅ FAST - Lazy builds only visible items
ListView.builder(
  // Performance optimizations
  cacheExtent: 500,                          // Pre-render 500px ahead
  addAutomaticKeepAlives: false,             // Reduce memory usage
  addRepaintBoundaries: true,                // Reduce repaints
  
  // Enable pull-to-refresh on empty lists
  physics: const AlwaysScrollableScrollPhysics(),
  
  // Fixed height for extra performance (if applicable)
  itemExtent: 72,  // Use only if all items same height
  
  itemCount: items.length,
  itemBuilder: (context, index) {
    return KeyedSubtree(
      key: ValueKey(items[index].id),  // Unique stable key
      child: ItemCard(item: items[index]),
    );
  },
)
```

### Provider Optimization

```dart
// ❌ INEFFICIENT - Rebuilds on ANY change
final account = ref.watch(accountProvider);
// Uses: account.balance, account.name

// ✅ EFFICIENT - Rebuilds only when balance changes  
final balance = ref.watch(
  accountProvider.select((account) => account.balance),
);

// ✅ For multiple values, use records
final (balance, name) = ref.watch(
  accountProvider.select((a) => (a.balance, a.name)),
);
```

### const Constructors

```dart
// ❌ Creates new instance every rebuild
SizedBox(height: 16)
EdgeInsets.all(16)
Icon(Icons.add)
Text('Hello')

// ✅ Reuses same instance
const SizedBox(height: 16)
const EdgeInsets.all(16)
const Icon(Icons.add)
const Text('Hello')
```

---

## 🔄 State Management Patterns

### Provider Types & Usage

```dart
// 1️⃣ Simple computed value
final totalProvider = Provider<double>((ref) {
  final items = ref.watch(itemsProvider);
  return items.fold(0.0, (sum, item) => sum + item.amount);
});

// 2️⃣ Async data loading
final itemsProvider = FutureProvider.autoDispose<List<Item>>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.getAll();
});

// 3️⃣ Stateful with actions
final itemNotifierProvider = 
    StateNotifierProvider.autoDispose<ItemNotifier, AsyncValue<List<Item>>>((ref) {
  return ItemNotifier(ref.watch(repositoryProvider));
});

// Usage:
// Watch for UI
final items = ref.watch(itemsProvider);

// Read for actions
ref.read(itemNotifierProvider.notifier).addItem(newItem);

// Invalidate to refresh
ref.invalidate(itemsProvider);
```

### Refresh Pattern

```dart
RefreshIndicator(
  onRefresh: () async {
    // Invalidate the provider
    ref.invalidate(dataProvider);
    // Wait for the new data
    await ref.read(dataProvider.future);
  },
  child: ListView.builder(
    // CRITICAL: Enable scroll even when empty
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: items.length,
    itemBuilder: (context, index) => ItemCard(item: items[index]),
  ),
)
```

---

## 🌍 RTL & Internationalization

### Layout Direction

```dart
// ❌ WRONG - Doesn't flip in RTL
Padding(
  padding: EdgeInsets.only(left: 16, right: 8),
  child: Row(
    children: [Icon(Icons.arrow_back), Text('Back')],
  ),
)

// ✅ CORRECT - Automatically flips in RTL
Padding(
  padding: EdgeInsetsDirectional.only(start: 16, end: 8),
  child: Row(
    children: [
      Icon(Icons.adaptive.arrow_back),  // Platform-aware
      Text(context.l10n.back),          // Localized
    ],
  ),
)
```

### Directional Properties

| Non-Directional ❌ | Directional ✅ |
|-------------------|----------------|
| `EdgeInsets.only(left:)` | `EdgeInsetsDirectional.only(start:)` |
| `EdgeInsets.only(right:)` | `EdgeInsetsDirectional.only(end:)` |
| `Alignment.centerLeft` | `AlignmentDirectional.centerStart` |
| `Alignment.centerRight` | `AlignmentDirectional.centerEnd` |
| `BorderRadius.only(topLeft:)` | `BorderRadiusDirectional.only(topStart:)` |
| `TextAlign.left` | `TextAlign.start` |

---

## 🎨 UI Component Standards

### Button Guidelines

```dart
// Primary action
FilledButton(
  onPressed: _submit,
  child: const Text('Submit'),
)

// Secondary action  
OutlinedButton(
  onPressed: _cancel,
  child: const Text('Cancel'),
)

// Destructive action
FilledButton(
  onPressed: _delete,
  style: FilledButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.error,
  ),
  child: const Text('Delete'),
)

// Icon button with tooltip (for accessibility)
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: _delete,
  tooltip: 'Delete item',  // Required for a11y
)
```

### Card Standards

```dart
Card(
  // Use theme values
  elevation: 0,  // Flat design, use color for hierarchy
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: Theme.of(context).dividerColor,
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: content,
  ),
)
```

---

## ♿ Accessibility Requirements

### Touch Targets (Minimum 48x48)

```dart
// ❌ TOO SMALL - 24x24 icon is not accessible
Icon(Icons.add, size: 24)

// ✅ ACCESSIBLE - 48x48 touch target
IconButton(
  iconSize: 24,
  padding: const EdgeInsets.all(12),  // 24 + 12*2 = 48
  icon: const Icon(Icons.add),
  onPressed: _add,
  tooltip: 'Add new item',  // Screen reader support
)
```

### Semantic Labels

```dart
// ❌ NO ACCESSIBILITY
Container(
  decoration: BoxDecoration(color: Colors.green),
  child: Text('$balance'),
)

// ✅ SCREEN READER FRIENDLY
Semantics(
  label: 'Account balance: $balance Egyptian Pounds',
  child: Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    child: Text('$balance'),
  ),
)
```

---

## 📁 File Path Reference

### Correct Paths (MEMORIZE THESE)

```dart
// ✅ State widgets
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/states/loading_widget.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart';

// ✅ Theme (PRIMARY)
import 'package:life_tracker/core/constants/app_theme.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

// ❌ AVOID (duplicates)
import 'package:life_tracker/core/theme/app_theme.dart';  // Don't use
```

---

## ✅ Pre-Commit Checklist

```markdown
Before every commit, verify:

### Code Quality
- [ ] `flutter analyze` shows 0 errors, 0 warnings
- [ ] No hardcoded colors (grep -n "Colors\." lib/)
- [ ] No missing `context.mounted` checks
- [ ] All async errors handled

### Testing
- [ ] Feature works as expected
- [ ] Light mode displays correctly
- [ ] Dark mode displays correctly
- [ ] RTL layout correct (if applicable)
- [ ] No console errors

### Performance
- [ ] Using const constructors
- [ ] ListView.builder for lists > 10 items
- [ ] Provider.select() for large objects

### Commit Message
Format: type(scope): message
Example: feat(finance): Add RefreshIndicator to expenses screen
```

---

## 🐛 Debugging Checklist

### When Something Doesn't Work:

1. **Check the error message** - Read it carefully
2. **Verify file paths** - Run `ls lib/path/to/file.dart`
3. **Check imports** - Correct package path?
4. **Run flutter analyze** - Fix all errors
5. **Hot restart** - Sometimes hot reload isn't enough
6. **Check provider state** - Use Riverpod DevTools

### Common Issues:

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Widget overflow | Fixed width in Row/Column | Use Expanded/Flexible |
| Colors wrong in dark mode | Hardcoded colors | Use theme colors |
| Crash on navigation | Using context after async | Add `mounted` check |
| List not refreshing | Missing invalidate | Call `ref.invalidate()` |
| Empty list not scrollable | Missing physics | Add `AlwaysScrollableScrollPhysics` |

---

## 📊 Current Task: UX/UI Implementation

See `UX_UI_COMPLETION_PLAN.md` for the complete 12-phase plan.

### Immediate Priorities:
1. 🔴 Create `FeedbackService` 
2. 🔴 Add shimmer to `LoadingWidget`
3. 🔴 Add `RefreshIndicator` to missing screens
4. 🟠 Add `cacheExtent` to all `ListView.builder`
5. 🟠 Replace hardcoded colors with theme colors

---

*"Any fool can write code that a computer can understand. Good programmers write code that humans can understand."* - Martin Fowler
