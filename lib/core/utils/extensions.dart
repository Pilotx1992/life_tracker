import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() {
    return isSameDay(DateTime.now());
  }

  bool isYesterday() {
    return isSameDay(DateTime.now().subtract(const Duration(days: 1)));
  }

  bool isTomorrow() {
    return isSameDay(DateTime.now().add(const Duration(days: 1)));
  }
}

extension StringExtension on String {
  bool isValidEmail() {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }
}

extension NumExtension on num {
  SizedBox get heightBox => SizedBox(height: toDouble());
  SizedBox get widthBox => SizedBox(width: toDouble());
}
