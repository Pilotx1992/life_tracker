import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/features/reminders/presentation/providers/reminder_provider.dart';

/// Full-screen alarm ringing screen.
/// Displays when an alarm is triggered.
class AlarmRingingScreen extends ConsumerStatefulWidget {
  final Id reminderId;

  const AlarmRingingScreen({
    super.key,
    required this.reminderId,
  });

  @override
  ConsumerState<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends ConsumerState<AlarmRingingScreen> {
  Reminder? _reminder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminder();
    // Prevent screen from going to sleep
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Stop ringing when leaving the alarm screen
    try {
      if (_reminder?.id != null) {
        ref.read(alarmServiceProvider).stopRinging(_reminder!.id!);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to stop ringing: $e');
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadReminder() async {
    try {
      final reminders = ref.read(reminderNotifierProvider).value ?? [];
      final reminder = reminders.firstWhere(
        (r) => r.id == widget.reminderId,
        orElse: () => reminders.first, // Fallback
      );
      setState(() {
        _reminder = reminder;
        _isLoading = false;
      });

      // Start ringing using AlarmService when the screen loads
      try {
        final alarmService = ref.read(alarmServiceProvider);
        await alarmService.startRinging(reminder);
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Failed to start ringing: $e');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _dismissAlarm() async {
    if (_reminder?.id == null) return;

    // Stop ringing and mark as completed
    final notifier = ref.read(reminderListProvider.notifier);
    await notifier.markAsCompleted(_reminder!.id!);

    // Navigate back
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _snoozeAlarm() async {
    if (_reminder == null) return;

    // Snooze the alarm
    // This will be handled by AlarmService
    // For now, navigate back
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_reminder == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              const Text('Reminder not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    }

    final reminder = _reminder!;
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE, MMMM d, y');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Current time
              Text(
                timeFormat.format(now),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(now),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 48),

              // Alarm icon
              Icon(
                Icons.alarm,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),

              // Reminder title
              Text(
                reminder.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Reminder description
              if (reminder.description != null &&
                  reminder.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    reminder.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  // Snooze button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _snoozeAlarm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.snooze, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Snooze\n${reminder.snoozeDuration} min',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Dismiss button
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _dismissAlarm,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Dismiss',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
