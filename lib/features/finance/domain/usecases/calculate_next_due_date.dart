import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';

/// Calculates the next due date for a recurring bill based on its frequency and day of schedule.
///
/// For Monthly bills: dayOfSchedule is the day of the month (1-31)
/// For Weekly bills: dayOfSchedule is the day of the week (1=Monday, 7=Sunday)
/// For Yearly bills: dayOfSchedule is the day of the month (1-31)
class CalculateNextDueDate {
  /// Calculates the next due date from a given reference date (usually today or the last due date).
  static DateTime calculate(RecurringBill bill, {DateTime? fromDate}) {
    final referenceDate = fromDate ?? DateTime.now();
    final currentDate =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);

    switch (bill.frequency.toLowerCase()) {
      case 'monthly':
        return _calculateMonthlyNextDueDate(bill.dayOfSchedule, currentDate);
      case 'weekly':
        return _calculateWeeklyNextDueDate(bill.dayOfSchedule, currentDate);
      case 'yearly':
        return _calculateYearlyNextDueDate(bill.dayOfSchedule, currentDate);
      default:
        throw ArgumentError('Invalid frequency: ${bill.frequency}');
    }
  }

  /// Calculates next due date for monthly bills.
  /// dayOfSchedule: 1-31 (day of month)
  static DateTime _calculateMonthlyNextDueDate(
    int dayOfMonth,
    DateTime currentDate,
  ) {
    // Clamp day to valid range for the month
    final daysInCurrentMonth =
        DateTime(currentDate.year, currentDate.month + 1, 0).day;
    final validDay =
        dayOfMonth > daysInCurrentMonth ? daysInCurrentMonth : dayOfMonth;

    // Try current month first
    var nextDate = DateTime(currentDate.year, currentDate.month, validDay);

    // If the date has passed, move to next month
    if (nextDate.isBefore(currentDate)) {
      // Try next month
      final nextMonth = currentDate.month == 12
          ? DateTime(currentDate.year + 1, 1, 1)
          : DateTime(currentDate.year, currentDate.month + 1, 1);
      final daysInNextMonth =
          DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
      final nextValidDay =
          dayOfMonth > daysInNextMonth ? daysInNextMonth : dayOfMonth;
      nextDate = DateTime(nextMonth.year, nextMonth.month, nextValidDay);
    }

    return nextDate;
  }

  /// Calculates next due date for weekly bills.
  /// dayOfSchedule: 1=Monday, 2=Tuesday, ..., 7=Sunday
  static DateTime _calculateWeeklyNextDueDate(
    int dayOfWeek,
    DateTime currentDate,
  ) {
    // Convert to Dart's weekday (Monday=1, Sunday=7)
    final currentWeekday = currentDate.weekday;

    // Calculate days until next occurrence
    int daysUntilNext;
    if (dayOfWeek > currentWeekday) {
      // This week
      daysUntilNext = dayOfWeek - currentWeekday;
    } else if (dayOfWeek < currentWeekday) {
      // Next week
      daysUntilNext = 7 - currentWeekday + dayOfWeek;
    } else {
      // Same day - if it's today, schedule for next week
      daysUntilNext = 7;
    }

    return currentDate.add(Duration(days: daysUntilNext));
  }

  /// Calculates next due date for yearly bills.
  /// dayOfSchedule: 1-31 (day of month)
  static DateTime _calculateYearlyNextDueDate(
    int dayOfMonth,
    DateTime currentDate,
  ) {
    // Try current year first
    var nextDate = DateTime(currentDate.year, currentDate.month, dayOfMonth);

    // Clamp to valid day for the month
    final daysInMonth = DateTime(nextDate.year, nextDate.month + 1, 0).day;
    if (dayOfMonth > daysInMonth) {
      nextDate = DateTime(nextDate.year, nextDate.month, daysInMonth);
    }

    // If the date has passed this year, move to next year
    if (nextDate.isBefore(currentDate)) {
      nextDate = DateTime(currentDate.year + 1, currentDate.month, dayOfMonth);
      // Clamp again for next year
      final daysInNextMonth =
          DateTime(nextDate.year, nextDate.month + 1, 0).day;
      if (dayOfMonth > daysInNextMonth) {
        nextDate = DateTime(nextDate.year, nextDate.month, daysInNextMonth);
      }
    }

    return nextDate;
  }
}
