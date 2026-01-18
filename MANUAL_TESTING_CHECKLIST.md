# Life Tracker - Manual Testing Checklist

**Device**: KB2003 (OnePlus Nord CE)
**OS**: Android 14 (API 34)
**Build**: Debug APK (2026-01-18)
**App Version**: 1.0.0+1

---

## 🚀 Initial Setup & Launch

### First Launch
- [ ] App installs successfully
- [ ] Splash screen displays
- [ ] App icon shows correctly on home screen
- [ ] No crashes on first launch
- [ ] Permissions requested (notifications, location, etc.)

### Onboarding Flow
- [ ] Onboarding screens display
- [ ] Can navigate through onboarding
- [ ] Can skip onboarding (if applicable)
- [ ] User profile setup works
- [ ] Initial data setup completes

---

## 📱 Dashboard Module

### Dashboard Screen
- [ ] Dashboard loads without errors
- [ ] All widgets display correctly
- [ ] Summary cards show data
- [ ] Quick actions work
- [ ] Pull-to-refresh works
- [ ] No layout overflow errors
- [ ] Smooth scrolling

### Dashboard Customization
- [ ] Can reorder widgets (drag & drop)
- [ ] Can hide/show widgets
- [ ] Settings persist after app restart
- [ ] Reset to default layout works

---

## 💰 Finance Module

### Accounts
- [ ] **Add Account**:
  - [ ] Form validation works
  - [ ] Can select account type
  - [ ] Can set initial balance
  - [ ] Account saved successfully
  - [ ] Success message displays
- [ ] **View Accounts**:
  - [ ] Accounts list displays
  - [ ] Account details screen works
  - [ ] Balance shows correctly
  - [ ] Recent transactions visible
- [ ] **Edit Account**:
  - [ ] Edit form pre-fills data
  - [ ] Changes save successfully
- [ ] **Delete Account**:
  - [ ] Confirmation dialog appears
  - [ ] Account deleted successfully
  - [ ] Account removed from list

### Expenses
- [ ] **Add Expense**:
  - [ ] Form opens correctly
  - [ ] Can select category
  - [ ] Can select account
  - [ ] Can set amount
  - [ ] Can add note/description
  - [ ] Can set date
  - [ ] Expense saved successfully
- [ ] **View Expenses**:
  - [ ] Expenses list displays
  - [ ] Grouped by date/category
  - [ ] Total amount shows
  - [ ] Filter works (by date, category, account)
- [ ] **Edit Expense**:
  - [ ] Edit form works
  - [ ] Changes persist
- [ ] **Delete Expense**:
  - [ ] Confirmation works
  - [ ] Expense deleted

### Income
- [ ] **Add Income**:
  - [ ] Form works
  - [ ] Can select source
  - [ ] Income saved
- [ ] **View Income**:
  - [ ] Income list displays
  - [ ] Total shows correctly
- [ ] **Edit/Delete Income**: Works

### Bills
- [ ] **Add Bill**:
  - [ ] Can set recurring schedule
  - [ ] Can set due date
  - [ ] Can set amount
  - [ ] Bill saved
- [ ] **View Bills**:
  - [ ] Bills list shows
  - [ ] Upcoming bills highlighted
  - [ ] Overdue bills marked
- [ ] **Pay Bill**:
  - [ ] Payment dialog works
  - [ ] Can select payment account
  - [ ] Payment recorded
  - [ ] Next due date calculated
- [ ] **Edit/Delete Bill**: Works

### Debts
- [ ] **Add Debt**:
  - [ ] Can set creditor/debtor
  - [ ] Can set total amount
  - [ ] Can set due date
  - [ ] Debt saved
- [ ] **View Debts**:
  - [ ] Debts list shows
  - [ ] Remaining amount correct
  - [ ] Progress indicator works
- [ ] **Add Payment**:
  - [ ] Payment dialog works
  - [ ] Amount deducted correctly
  - [ ] Remaining balance updates
- [ ] **Edit/Delete Debt**: Works

### Financial Commitments
- [ ] **Add Commitment**:
  - [ ] Form works
  - [ ] Can set recurring
  - [ ] Commitment saved
- [ ] **View Commitments**:
  - [ ] List displays
  - [ ] Upcoming commitments visible
- [ ] **Edit/Delete Commitment**: Works

---

## 🏥 Health Module

### Weight Tracking
- [ ] **Add Weight Entry**:
  - [ ] Can enter weight
  - [ ] Can select date
  - [ ] Entry saved
- [ ] **View Weight History**:
  - [ ] List displays
  - [ ] Chart shows trend
  - [ ] BMI calculated correctly
- [ ] **Delete Entry**: Works

### Medications
- [ ] **Add Medication**:
  - [ ] Can enter name
  - [ ] Can set dosage
  - [ ] Can set schedule
  - [ ] Medication saved
- [ ] **View Medications**:
  - [ ] List displays
  - [ ] Schedule visible
  - [ ] Reminders set
- [ ] **Edit/Delete Medication**: Works

### Activities
- [ ] **Add Activity**: Works
- [ ] **View Activities**: List displays
- [ ] **Edit/Delete Activity**: Works

### Health Devices
- [ ] **Connect Device**:
  - [ ] Bluetooth scan works
  - [ ] Can pair device
  - [ ] Data syncs
- [ ] **Sync Health Data**:
  - [ ] Manual sync works
  - [ ] Auto sync works (if enabled)

---

## 📝 Notes Module

### Notes
- [ ] **Create Note**:
  - [ ] Can add title
  - [ ] Can add content
  - [ ] Rich text formatting works
  - [ ] Note saved
- [ ] **View Notes**:
  - [ ] Grid/List view works
  - [ ] Search works
  - [ ] Filter by category works
- [ ] **Edit Note**:
  - [ ] Editor loads note
  - [ ] Changes save
- [ ] **Delete Note**:
  - [ ] Confirmation works
  - [ ] Note deleted

### Checklists
- [ ] **Add Checklist**:
  - [ ] Can add items
  - [ ] Can check/uncheck items
  - [ ] Progress shows
- [ ] **Edit Checklist**:
  - [ ] Can add/remove items
  - [ ] Can reorder items
- [ ] **Delete Checklist Item**: Works

### Attachments
- [ ] **Add Image**:
  - [ ] Camera works
  - [ ] Gallery picker works
  - [ ] Image displays in note
- [ ] **Add File**:
  - [ ] File picker works
  - [ ] File attached
- [ ] **Delete Attachment**: Works

### Voice Recording
- [ ] **Record Voice Note**:
  - [ ] Recording starts
  - [ ] Recording stops
  - [ ] Audio saved
- [ ] **Play Voice Note**:
  - [ ] Playback works
  - [ ] Progress indicator shows
- [ ] **Delete Voice Note**: Works

---

## ⏰ Reminders Module

### Reminders
- [ ] **Create Reminder**:
  - [ ] Can set title
  - [ ] Can set date/time
  - [ ] Can set recurring
  - [ ] Reminder saved
- [ ] **View Reminders**:
  - [ ] List displays
  - [ ] Upcoming reminders shown
  - [ ] Past reminders visible
- [ ] **Edit Reminder**: Works
- [ ] **Delete Reminder**: Works

### Notifications
- [ ] **Receive Notification**:
  - [ ] Notification appears at scheduled time
  - [ ] Sound plays (if enabled)
  - [ ] Vibration works (if enabled)
  - [ ] Notification content correct
- [ ] **Snooze Reminder**: Works
- [ ] **Mark as Complete**:
  - [ ] Reminder marked complete
  - [ ] Notification dismissed

---

## ⚙️ Settings Module

### General Settings
- [ ] **Theme**:
  - [ ] Light mode works
  - [ ] Dark mode works
  - [ ] Theme changes immediately
  - [ ] Theme persists after restart
- [ ] **Language**:
  - [ ] English works
  - [ ] Arabic works (RTL layout)
  - [ ] Language changes immediately
  - [ ] Language persists

### App Lock
- [ ] **Enable App Lock**:
  - [ ] PIN setup works
  - [ ] Biometric setup works (if available)
  - [ ] App locks on close
- [ ] **Unlock App**:
  - [ ] PIN unlock works
  - [ ] Biometric unlock works
  - [ ] Failed attempts handled
- [ ] **Change PIN**: Works
- [ ] **Disable App Lock**: Works

### Backup & Restore
- [ ] **Create Backup**:
  - [ ] Backup file created
  - [ ] All data included
  - [ ] File saved to storage
- [ ] **Restore Backup**:
  - [ ] File picker works
  - [ ] Data restored correctly
  - [ ] All modules show restored data

### Notifications Settings
- [ ] **Enable/Disable Notifications**: Works
- [ ] **Set Notification Sound**: Works
- [ ] **Set Vibration**: Works

### About
- [ ] **App Version**: Displays correctly
- [ ] **Privacy Policy**: Opens and scrolls
- [ ] **Terms of Service**: Opens and scrolls

---

## 🎨 UI/UX Testing

### Visual
- [ ] No layout overflow errors (red/yellow stripes)
- [ ] All text readable (no cut-off)
- [ ] Icons display correctly
- [ ] Images load properly
- [ ] Colors consistent with theme
- [ ] Proper spacing and padding

### Animations
- [ ] Shimmer loading works smoothly
- [ ] Page transitions smooth
- [ ] Button press feedback works
- [ ] List scroll smooth (60fps)
- [ ] No janky animations

### Responsiveness
- [ ] Touch targets adequate (48x48 min)
- [ ] Buttons respond immediately
- [ ] Forms responsive
- [ ] No UI freezing

### RTL Support (Arabic)
- [ ] Text aligns right
- [ ] Icons mirror correctly
- [ ] Navigation correct direction
- [ ] No layout issues

---

## ⚡ Performance Testing

### App Launch
- [ ] Cold start < 3 seconds
- [ ] Warm start < 1 second
- [ ] No splash screen hang

### Memory
- [ ] No memory leaks (check DevTools)
- [ ] App doesn't crash with large data
- [ ] Handles 1000+ items smoothly

### Battery
- [ ] No excessive battery drain
- [ ] Background services reasonable

### Data
- [ ] Database operations fast
- [ ] No lag when saving
- [ ] Queries optimized

---

## 🔍 Edge Cases

### Error Handling
- [ ] **No Internet**: App works offline
- [ ] **Low Storage**: Handles gracefully
- [ ] **Invalid Input**: Validation works
- [ ] **Database Error**: Shows error message

### Data Integrity
- [ ] Data persists after app close
- [ ] Data persists after device reboot
- [ ] No data loss on crash
- [ ] Concurrent operations handled

### Special Scenarios
- [ ] **Date/Time Change**: App handles correctly
- [ ] **Language Change**: No crashes
- [ ] **Theme Change**: No visual glitches
- [ ] **Rotation**: Layout adapts (if enabled)

---

## 🐛 Bug Tracking

### Critical Bugs (App Crashes)
_None found yet_

### High Priority Bugs (Feature Broken)
_None found yet_

### Medium Priority Bugs (UX Issues)
_None found yet_

### Low Priority Bugs (Minor Issues)
_None found yet_

---

## ✅ Test Summary

**Date Tested**: 2026-01-18
**Tester**: [Your Name]
**Total Tests**: 200+
**Passed**: ___
**Failed**: ___
**Blocked**: ___

**Overall Assessment**:
- [ ] Ready for Release
- [ ] Needs Minor Fixes
- [ ] Needs Major Fixes
- [ ] Not Ready

**Notes**:
_Add any additional observations here_

---

## 📊 Next Steps

Based on test results:
1. Fix critical bugs immediately
2. Address high priority issues
3. Plan medium/low priority fixes for next release
4. Update ROADMAP.md with findings
5. Proceed to release build if all critical tests pass
