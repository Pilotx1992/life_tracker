import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/providers/notification_provider.dart';

class NotificationTestScreen extends ConsumerStatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  ConsumerState<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends ConsumerState<NotificationTestScreen> {
  @override
  Widget build(BuildContext context) {
    final ns = ref.read(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final granted = await ns.requestPermissions();
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Permissions granted: $granted')),
                );
              },
              child: const Text('Request Permissions'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final scheduledDate =
                    DateTime.now().add(const Duration(seconds: 5));
                await ns.scheduleNotification(
                  id: 1000,
                  title: 'Test Notification',
                  body: 'This was scheduled 5 seconds ago',
                  scheduledDate: scheduledDate,
                );
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Scheduled notification in 5s')),
                );
              },
              child: const Text('Schedule test (5s)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final now = DateTime.now();
                final nextMinute = now.add(const Duration(minutes: 1));
                await ns.scheduleDailyNotification(
                  id: 1001,
                  title: 'Daily Test',
                  body: 'Daily notification test',
                  hour: nextMinute.hour,
                  minute: nextMinute.minute,
                );
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                      content: Text(
                          'Scheduled daily at ${nextMinute.hour}:${nextMinute.minute.toString().padLeft(2, '0')}')),
                );
              },
              child: const Text('Schedule daily (next minute)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await ns.cancelAllNotifications();
                if (!mounted) return;
                messenger.showSnackBar(
                    const SnackBar(content: Text('Canceled all notifications')));
              },
              child: const Text('Cancel all'),
            ),
          ],
        ),
      ),
    );
  }
}
