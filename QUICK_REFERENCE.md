# ⚡ Quick Reference - Implementation Checklist

> **Use this daily while implementing tasks**

---

## 🚀 Before Starting Any Task

```bash
# 1. Check git status
git status

# 2. Run analysis
flutter analyze

# 3. Create branch/checkpoint
git checkout -b feature/task-name
```

**✅ All checks pass? → Proceed**

---

## 📝 During Implementation

### File Modification Checklist:

- [ ] Read entire file first
- [ ] Verify file path is correct
- [ ] Check existing patterns in file
- [ ] Use `const` where possible
- [ ] Use theme colors (no hardcoded)
- [ ] Check `context.mounted` after async
- [ ] Follow import order (dart → flutter → packages → local)

### Code Quality Checklist:

- [ ] No hardcoded colors (`Colors.black`, `Colors.white`)
- [ ] No missing `context.mounted` checks
- [ ] Imports are correct and organized
- [ ] Code follows existing patterns
- [ ] Variable names are clear

---

## ✅ After Implementation

### Testing Checklist:

```bash
# 1. Static analysis
flutter analyze
# ✅ Must pass

# 2. Build check
flutter run --debug
# ✅ Must build and launch

# 3. Manual testing
# ✅ Feature works as expected
# ✅ Dark mode works (if UI changed)
# ✅ RTL works (if layout changed)
```

### Before Committing:

- [ ] `flutter analyze` passes
- [ ] Manual testing passes
- [ ] No breaking changes
- [ ] Progress updated in plan
- [ ] Commit message is clear

```bash
git add .
git commit -m "feat(ux-ui): [Task Name] - [Description]"
```

---

## 🚨 Common File Paths

### Widgets:
- ✅ Empty State: `lib/shared/widgets/states/empty_state_widget.dart`
- ✅ Loading: `lib/shared/widgets/states/loading_widget.dart`
- ✅ Error: `lib/shared/widgets/states/error_widget.dart`
- ✅ Button: `lib/shared/widgets/buttons/app_button.dart`
- ✅ Text Field: `lib/shared/widgets/fields/app_text_field.dart`

### Theme:
- ✅ Main Theme: `lib/core/constants/app_theme.dart`
- ✅ Colors: `lib/core/constants/app_colors.dart`
- ✅ Design Tokens: `lib/core/constants/app_design_tokens.dart`

### Services:
- ✅ Feedback: `lib/core/services/feedback_service.dart` (to be created)

---

## 🎯 Quick Fixes

### Hardcoded Color Fix:
```dart
// Find: Colors.black87
// Replace: Theme.of(context).colorScheme.onSurface

// Find: Colors.white
// Replace: Theme.of(context).colorScheme.surface
```

### Missing Context Check Fix:
```dart
// After async operation:
if (!context.mounted) return;
// Then use context
```

### Wrong Import Fix:
```dart
// Wrong: import 'package:life_tracker/core/theme/app_theme.dart';
// Correct: import 'package:life_tracker/core/constants/app_theme.dart';
```

---

## 📊 Progress Tracking

After each task:
- [ ] Mark complete in `UX_UI_COMPLETION_PLAN.md`
- [ ] Update progress percentage
- [ ] Note any issues

---

## 🆘 Emergency Commands

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all changes
git checkout .

# Check what files changed
git diff

# See commit history
git log --oneline -10
```

---

*Keep this file open while working!*

