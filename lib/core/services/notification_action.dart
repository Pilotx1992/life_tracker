import 'package:flutter/foundation.dart';

@immutable
class NotificationAction {
  const NotificationAction({
    required this.id,
    required this.label,
    this.payload,
  });

  final String id;
  final String label;
  final String? payload;
}
