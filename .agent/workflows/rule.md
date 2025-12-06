---
description: UX/UI implementation workflows for Life Tracker project
---

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
| `Colors.white` | `colorScheme.surface` |
| `Colors.grey` | `colorScheme.outline` |
| `Colors.grey.shade300` | `dividerColor` |
| `Colors.red` | `colorScheme.error` |
| `Colors.blue` | `colorScheme.primary` |
| `Colors.green` | `colorScheme.tertiary` |

3. `flutter analyze`
4. Test Light + Dark

---

## /add-three-state

```dart
return dataAsync.when(
  loading: () => const LoadingWidget(useShimmer: true),
  error: (e, _) => ErrorStateWidget(
    message: e.toString(),
    onRetry: () => ref.invalidate(provider),
  ),
  data: (items) {
    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inbox,
        message: 'No items',
        actionLabel: 'Add First',
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
  itemExtent: 72,  // If fixed height
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

## /create-feedback-service

Path: `lib/core/services/feedback_service.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedbackService {
  FeedbackService._();

  static void showSuccess(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _show(context, message, Colors.green.shade700, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    HapticFeedback.heavyImpact();
    _show(context, message, Colors.red.shade700, Icons.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, Colors.blue.shade700, Icons.info);
  }

  static void _show(BuildContext ctx, String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
```

---

## /enhance-loading-widget

Path: `lib/shared/widgets/states/loading_widget.dart`

```dart
class LoadingWidget extends StatelessWidget {
  final bool useShimmer;
  const LoadingWidget({super.key, this.useShimmer = true});

  @override
  Widget build(BuildContext context) {
    if (!useShimmer) return const Center(child: CircularProgressIndicator());
    return const _ShimmerList();
  }
}

class _ShimmerList extends StatefulWidget {
  const _ShimmerList();
  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  late final _anim = Tween<double>(begin: -1, end: 2).animate(_ctrl);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) => ListView.builder(
        itemCount: 3,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment(_anim.value - 1, 0),
                end: Alignment(_anim.value, 0),
                colors: [base, highlight, base],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
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

## /quick-wins

// turbo-all

1. `/create-feedback-service`
2. `/verify-theme-files`
3. Add RefreshIndicator to expenses, incomes, debts
4. `flutter analyze`
5. Update plan

---

## /complete-phase-1

// turbo-all

1. `/verify-theme-files`
2. Migrate imports if needed
3. `/check-delete-file` for duplicates
4. `/enhance-loading-widget`
5. `flutter analyze`

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
