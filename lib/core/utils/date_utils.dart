import 'package:intl/intl.dart';

class DateUtils {
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'yyyy-MM-dd HH:mm',
  }) {
    return DateFormat(format).format(dateTime);
  }

  static String formatDate(DateTime dateTime, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(dateTime);
  }

  static String formatTime(DateTime dateTime, {String format = 'HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  static String getRelativeTime(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static List<DateTime> getDatesInRange(DateTime startDate, DateTime endDate) {
    final List<DateTime> dates = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || isSameDay(currentDate, endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return dates;
  }
}
