import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/utils/thousands_separator_formatter.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/usecases/calculate_next_due_date.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/bill_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/providers/category_provider.dart';

class AddBillDialog extends ConsumerStatefulWidget {
  final RecurringBill? bill;

  const AddBillDialog({super.key, this.bill});

  @override
  ConsumerState<AddBillDialog> createState() => _AddBillDialogState();
}

class _AddBillDialogState extends ConsumerState<AddBillDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _reminderDaysController = TextEditingController();

  String _selectedFrequency = 'Monthly';
  int _selectedDay = 1; // Day of month (1-31) or day of week (1-7)
  String _selectedCurrency = 'EGP';
  Id? _selectedCategoryId;
  Id? _selectedAccountId;
  int _reminderDaysBefore = 3;
  bool _isActive = true;

  final List<String> _frequencies = ['Monthly', 'Weekly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      final bill = widget.bill!;
      final numberFormat = NumberFormat('#,##0.00');
      _nameController.text = bill.name;
      _amountController.text = numberFormat.format(bill.amount);
      _selectedFrequency = bill.frequency;
      _selectedDay = bill.dayOfSchedule;
      _selectedCurrency = bill.currency;
      _selectedCategoryId = bill.categoryId;
      _selectedAccountId = bill.accountId;
      _reminderDaysBefore = bill.reminderDaysBefore;
      _isActive = bill.isActive;
      _reminderDaysController.text = _reminderDaysBefore.toString();
      _noteController.text = bill.note ?? '';
    } else {
      _reminderDaysController.text = '3';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _reminderDaysController.dispose();
    super.dispose();
  }

  DateTime _calculateNextDueDate() {
    // Create a temporary bill to calculate next due date
    final tempBill = RecurringBill(
      name: _nameController.text,
      amount: 0,
      currency: _selectedCurrency,
      categoryId: _selectedCategoryId ?? 0,
      accountId: _selectedAccountId ?? 0,
      frequency: _selectedFrequency,
      dayOfSchedule: _selectedDay,
      nextDueDate: DateTime.now(), // Will be recalculated
      reminderDaysBefore: _reminderDaysBefore,
      createdAt: widget.bill?.createdAt ?? DateTime.now(),
    );
    return CalculateNextDueDate.calculate(tempBill);
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        FeedbackService.showWarning(context, 'Please select a category');
        return;
      }
      if (_selectedAccountId == null) {
        FeedbackService.showWarning(context, 'Please select an account');
        return;
      }

      // Strip commas from formatted numbers before parsing
      final amountText = _amountController.text.replaceAll(',', '');
      final amount = double.tryParse(amountText) ?? 0.0;
      final reminderDays = int.tryParse(_reminderDaysController.text) ?? 3;

      final nextDueDate = widget.bill?.nextDueDate ?? _calculateNextDueDate();

      final bill = RecurringBill(
        id: widget.bill?.id,
        name: _nameController.text.trim(),
        amount: amount,
        currency: _selectedCurrency,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        frequency: _selectedFrequency,
        dayOfSchedule: _selectedDay,
        nextDueDate: nextDueDate,
        reminderDaysBefore: reminderDays,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isActive: _isActive,
        createdAt: widget.bill?.createdAt ?? DateTime.now(),
      );

      if (widget.bill == null) {
        ref.read(billNotifierProvider.notifier).addBillEntry(bill);
      } else {
        ref.read(billNotifierProvider.notifier).updateBillEntry(bill);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isEditing = widget.bill != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Bill' : 'Add Recurring Bill'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Bill Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Bill Name',
                  hintText: 'e.g., Rent, Internet, Gym',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a bill name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  // Strip commas before parsing
                  final cleanValue = value.replaceAll(',', '');
                  if (double.tryParse(cleanValue) == null ||
                      double.parse(cleanValue) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Frequency
              DropdownButtonFormField<String>(
                initialValue: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: _frequencies.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFrequency = value;
                      // Reset day selection when frequency changes
                      if (value == 'Weekly') {
                        _selectedDay = 1; // Monday
                      } else {
                        _selectedDay = 1; // 1st of month
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Day Selection
              if (_selectedFrequency == 'Weekly')
                DropdownButtonFormField<int>(
                  initialValue: _selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Day of Week',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Monday')),
                    DropdownMenuItem(value: 2, child: Text('Tuesday')),
                    DropdownMenuItem(value: 3, child: Text('Wednesday')),
                    DropdownMenuItem(value: 4, child: Text('Thursday')),
                    DropdownMenuItem(value: 5, child: Text('Friday')),
                    DropdownMenuItem(value: 6, child: Text('Saturday')),
                    DropdownMenuItem(value: 7, child: Text('Sunday')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDay = value);
                    }
                  },
                )
              else
                TextFormField(
                  initialValue: _selectedDay.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Day of Month',
                    border: OutlineInputBorder(),
                    helperText: 'Enter day of month (1-31)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a day';
                    }
                    final day = int.tryParse(value);
                    if (day == null || day < 1 || day > 31) {
                      return 'Please enter a valid day (1-31)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final day = int.tryParse(value);
                    if (day != null && day >= 1 && day <= 31) {
                      setState(() => _selectedDay = day);
                    }
                  },
                ),
              const SizedBox(height: 16),
              // Category
              categoriesAsync.when(
                data: (categories) {
                  // Ensure selected category ID exists in the list
                  final validCategoryId = _selectedCategoryId != null &&
                          categories.any((c) => c.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : null;
                  return DropdownButtonFormField<Id>(
                    initialValue: validCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select category'),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading categories'),
              ),
              const SizedBox(height: 16),
              // Account
              accountsAsync.when(
                data: (accounts) {
                  // Ensure selected account ID exists in the list
                  final validAccountId = _selectedAccountId != null &&
                          accounts.any((a) => a.id == _selectedAccountId)
                      ? _selectedAccountId
                      : null;
                  return DropdownButtonFormField<Id>(
                    initialValue: validAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select account'),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedAccountId = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an account';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading accounts'),
              ),
              const SizedBox(height: 16),
              // Reminder Days Before
              TextFormField(
                controller: _reminderDaysController,
                decoration: const InputDecoration(
                  labelText: 'Reminder Days Before',
                  hintText: '3',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter reminder days';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days < 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'Additional notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Active Toggle
              SwitchListTile(
                title: const Text('Active'),
                subtitle:
                    const Text('Bill will schedule reminders when active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveBill,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
