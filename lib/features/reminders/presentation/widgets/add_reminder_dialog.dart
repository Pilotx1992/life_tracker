import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/reminders/domain/usecases/calculate_next_occurrence.dart';
import 'package:life_tracker/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class AddReminderDialog extends ConsumerStatefulWidget {
  final Reminder? reminder;

  const AddReminderDialog({super.key, this.reminder});

  @override
  ConsumerState<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends ConsumerState<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  String _selectedPriority = 'Medium';
  bool _isRecurring = false;
  String? _selectedRecurringPattern;
  int? _recurringInterval;
  DateTime? _recurringEndDate;

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _recurringPatterns = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description ?? '';
      _selectedDateTime = reminder.dateTime;
      _selectedPriority = reminder.priority;
      _isRecurring = reminder.isRecurring;
      _selectedRecurringPattern = reminder.recurringPattern;
      _recurringInterval = reminder.recurringInterval;
      _recurringEndDate = reminder.recurringEndDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectRecurringEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _recurringEndDate ?? _selectedDateTime.add(const Duration(days: 30)),
      firstDate: _selectedDateTime,
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _recurringEndDate = picked;
      });
    }
  }

  void _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      if (_isRecurring && _selectedRecurringPattern == null) {
        FeedbackService.showWarning(
          context,
          'Please select a recurring pattern',
        );
        return;
      }

      // Calculate next occurrence for recurring reminders
      DateTime? nextOccurrence;
      if (_isRecurring && _selectedRecurringPattern != null) {
        final result =
            await ref.read(calculateNextOccurrenceUseCaseProvider).call(
                  CalculateNextOccurrenceParams(
                    currentDateTime: _selectedDateTime,
                    recurringPattern: _selectedRecurringPattern!,
                    recurringInterval: _recurringInterval,
                    recurringEndDate: _recurringEndDate,
                  ),
                );
        nextOccurrence = result.fold((l) => null, (r) => r);
      }

      final reminder = Reminder(
        id: widget.reminder?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dateTime: _selectedDateTime,
        priority: _selectedPriority,
        isRecurring: _isRecurring,
        recurringPattern: _isRecurring ? _selectedRecurringPattern : null,
        recurringInterval: _isRecurring && _selectedRecurringPattern == 'Custom'
            ? _recurringInterval
            : null,
        recurringEndDate: _isRecurring ? _recurringEndDate : null,
        nextOccurrence: nextOccurrence,
        linkedType: widget.reminder?.linkedType,
        linkedId: widget.reminder?.linkedId,
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.reminder == null) {
        await ref
            .read(reminderNotifierProvider.notifier)
            .addReminderEntry(reminder);
      } else {
        await ref
            .read(reminderNotifierProvider.notifier)
            .updateReminderEntry(reminder);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return AlertDialog(
      title: Text(isEditing ? 'Edit Reminder' : 'Add Reminder'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Title',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description (Optional)',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Date & Time
              InkWell(
                onTap: _selectDateTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date & Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${dateFormat.format(_selectedDateTime)} at ${timeFormat.format(_selectedDateTime)}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Priority
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: _priorities
                    .map(
                      (priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Recurring toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recurring'),
                  Switch(
                    value: _isRecurring,
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value;
                        if (!value) {
                          _selectedRecurringPattern = null;
                          _recurringInterval = null;
                          _recurringEndDate = null;
                        }
                      });
                    },
                  ),
                ],
              ),
              // Recurring options
              if (_isRecurring) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRecurringPattern,
                  decoration: const InputDecoration(
                    labelText: 'Recurring Pattern',
                    border: OutlineInputBorder(),
                  ),
                  items: _recurringPatterns
                      .map(
                        (pattern) => DropdownMenuItem(
                          value: pattern,
                          child: Text(pattern),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRecurringPattern = value;
                      if (value != 'Custom') {
                        _recurringInterval = null;
                      }
                    });
                  },
                  validator: (value) {
                    if (_isRecurring && value == null) {
                      return 'Please select a recurring pattern';
                    }
                    return null;
                  },
                ),
                if (_selectedRecurringPattern == 'Custom') ...[
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Interval (days)',
                    controller: TextEditingController(
                      text: _recurringInterval?.toString() ?? '1',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    onChanged: (value) {
                      setState(() {
                        _recurringInterval = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectRecurringEndDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date (Optional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _recurringEndDate != null
                          ? dateFormat.format(_recurringEndDate!)
                          : 'No end date',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveReminder,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
