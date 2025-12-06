import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/services/notification_service.dart';

/// Exposes the singleton NotificationService via Riverpod.
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService.instance);
