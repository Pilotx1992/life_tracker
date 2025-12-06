# Integration Tests

This directory contains integration tests for the Life Tracker app. Integration tests verify complete user flows across the entire application.

## Running Integration Tests

### On Android Emulator/Device

```bash
flutter test integration_test/
```

### On iOS Simulator/Device

```bash
flutter test integration_test/
```

### With Coverage

```bash
flutter test --coverage integration_test/
```

## Test Structure

### Current Tests

1. **app_test.dart** - Basic app launch and navigation tests
2. **weight_tracking_flow_test.dart** - Complete weight tracking flow (Add → View → Edit → Delete)
3. **notes_flow_test.dart** - Complete notes flow (Create → Add checklist → Save → Edit)
4. **backup_restore_flow_test.dart** - Backup and restore flow (Create data → Backup → Clear → Restore)

## Test Flows

### Weight Tracking Flow
- Navigate to weight screen
- Add new weight entry
- View weight in list
- Edit weight entry
- Delete weight entry
- Verify all operations complete successfully

### Notes Flow
- Navigate to notes screen
- Create new note
- Add checklist items
- Save note
- Edit note
- Verify all operations complete successfully

### Backup/Restore Flow
- Create test data
- Create backup file
- Clear app data
- Restore from backup
- Verify data is restored correctly

## Notes

- Integration tests require a running emulator or physical device
- Tests may take longer to run than unit/widget tests
- Some tests may require specific app state or permissions
- Tests are designed to be independent and can run in any order

## Future Enhancements

- Add expense tracking flow tests
- Add medication flow tests
- Add app lock flow tests
- Add reminder flow tests
- Add more comprehensive navigation tests

