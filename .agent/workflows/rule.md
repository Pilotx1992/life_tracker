---
description: UX/UI implementation workflows for Life Tracker project
---

# 🔄 UX/UI Workflows

## 📋 Quick Commands

```bash
ls lib/path/to/file.dart          # Verify file
grep -r "filename" lib/           # Check imports
grep -n "Colors\." lib/file.dart  # Find hardcoded colors
flutter analyze                   # Check errors
```

---

## /ux-task - Single Task

// turbo-all

1. Read task from `UX_UI_COMPLETION_PLAN.md`
2. Verify file: `ls lib/path/to/file.dart`
3. Read entire file
4. Implement (theme colors, context.mounted, Keys)
5. `flutter analyze`
6. Test: Light/Dark/RTL
7. Update plan ✅

---

## /ux-phase - Complete Phase

1. List all tasks in phase
2. Run `/ux-task` for each
3. Test all together
4. Update progress to 100%
5. `git commit -m "feat(ux-ui): Complete Phase X"`

---

## /fix-hardcoded-colors

// turbo

1. Find: `grep -n "Colors\." lib/file.dart`
2. Replace:

| Hardcoded ❌ | Theme ✅ |
|-------------|----------|
| `Colors.black` | `colorScheme.onSurface` |
| `Colors.black54` | `colorScheme.onSurface.withValues(alpha: 0.6)` |
| `Colors.white` | `colorScheme.surface` |
| `Colors.grey` | `colorScheme.outline` |
| `Colors.grey.shade300` | `dividerColor` |
| `Colors.red` | `colorScheme.error` |
| `Colors.blue` | `colorScheme.primary` |
| `Colors.green` | `colorScheme.tertiary` |

3. **IMPORTANT**: Use `withValues(alpha: x)` NOT `withOpacity(x)`
4. `flutter analyze`
5. Test Light + Dark

---

## /add-three-state

```dart
return dataAsync.when(
  loading: () => const SkeletonList.cards(itemCount: 5),
  error: (e, _) => ErrorStateWidget(
    message: e.toString(),
    onRetry: () => ref.invalidate(provider),
  ),
  data: (items) {
    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inbox,
        message: context.l10n.noItems,
        actionLabel: context.l10n.addFirst,
        onAction: _add,
      );
    }
    return _buildList(items);
  },
);
```

Test: Loading → Error → Empty → Data

---

## /add-refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(provider);
    await ref.read(provider.future);
  },
  child: ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    cacheExtent: 500,
    itemBuilder: (ctx, i) => ItemCard(key: ValueKey(items[i].id)),
  ),
)
```

---

## /optimize-list

```dart
ListView.builder(
  cacheExtent: 500,
  addAutomaticKeepAlives: false,
  physics: const AlwaysScrollableScrollPhysics(),
  itemBuilder: (ctx, i) => KeyedSubtree(
    key: ValueKey(items[i].id),
    child: ItemCard(item: items[i]),
  ),
)
```

---

## /optimize-provider

```dart
// ❌ Rebuilds on ANY change
final account = ref.watch(accountProvider);

// ✅ Rebuilds only when balance changes
final balance = ref.watch(accountProvider.select((a) => a.balance));

// ✅ Multiple values
final (balance, name) = ref.watch(
  accountProvider.select((a) => (a.balance, a.name)),
);
```

---

## /show-feedback

```dart
// ✅ Use FeedbackService instead of ScaffoldMessenger
FeedbackService.showSuccess(context, 'Saved!');
FeedbackService.showError(context, 'Failed');
FeedbackService.showInfo(context, 'Processing...');
```

---

## /skeleton-loading

```dart
// For card lists
loading: () => const SkeletonList.cards(itemCount: 5),

// For tile lists
loading: () => const SkeletonList.listTiles(itemCount: 8),
```

---

## /check-delete-file

// turbo

1. `grep -r "filename" lib/`
2. If found → update imports first
3. If not found → safe to delete
4. `flutter analyze`

---

## /verify-theme-files

// turbo

```bash
grep -r "core/theme/app_theme" lib/
grep -r "core/theme/app_colors" lib/
```

- Found → migrate to `core/constants/`
- Not found → safe to delete duplicates

---

## /test-dark-mode

1. Enable dark mode
2. Check: text readable, icons visible, cards contrast
3. Issues? → `/fix-hardcoded-colors`

---

## /test-rtl

1. Set language to Arabic
2. Check: alignment, icons, arrows, no overflow
3. Fixes:
   - `EdgeInsets` → `EdgeInsetsDirectional`
   - `Alignment` → `AlignmentDirectional`

---

## 📁 Correct Import Paths

```dart
// ✅ State widgets
import 'package:life_tracker/shared/widgets/states/states.dart';
import 'package:life_tracker/shared/widgets/states/skeleton_widgets.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart';

// ✅ Services
import 'package:life_tracker/core/services/feedback_service.dart';

// ✅ Theme (PRIMARY)
import 'package:life_tracker/core/constants/app_theme.dart';
import 'package:life_tracker/core/constants/app_colors.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';

// ❌ AVOID (old paths)
import 'package:life_tracker/core/theme/app_theme.dart';  // Don't use
```

---

## Symbols

| Symbol | Meaning |
|--------|---------|
| `// turbo` | Auto-run step |
| `// turbo-all` | Auto-run ALL |

## Commit Format

```bash
git commit -m "feat(ux-ui): description"
git commit -m "fix(theme): description"
git commit -m "perf(list): description"
```
