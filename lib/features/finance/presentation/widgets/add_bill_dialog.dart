import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/utils/thousands_separator_formatter.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/domain/usecases/calculate_next_due_date.dart';
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
  int _selectedDay = 1;
  String _selectedCurrency = 'EGP';
  Id? _selectedCategoryId;
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
    final tempBill = RecurringBill(
      name: _nameController.text,
      amount: 0,
      currency: _selectedCurrency,
      categoryId: _selectedCategoryId ?? 0,
      accountId: 0,
      frequency: _selectedFrequency,
      dayOfSchedule: _selectedDay,
      nextDueDate: DateTime.now(),
      reminderDaysBefore: _reminderDaysBefore,
      createdAt: widget.bill?.createdAt ?? DateTime.now(),
    );
    return CalculateNextDueDate.calculate(tempBill);
  }

  Future<void> _saveBill() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        FeedbackService.showWarning(context, 'Please select a category');
        return;
      }

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
        accountId: widget.bill?.accountId ?? 0,
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
        await ref.read(billNotifierProvider.notifier).addBillEntry(bill);
      } else {
        await ref.read(billNotifierProvider.notifier).updateBillEntry(bill);
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      FeedbackService.showSuccess(
        context,
        widget.bill == null ? 'Bill added successfully' : 'Bill updated successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isEditing = widget.bill != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 580),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Bill' : 'Add Recurring Bill',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: theme.colorScheme.onPrimaryContainer,),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Bill Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Bill Name',
                          hintText: 'e.g., Rent, Internet',
                          prefixIcon: const Icon(Icons.label_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: 'EGP',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,),
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final cleanValue = value.replaceAll(',', '');
                          if (double.tryParse(cleanValue) == null ||
                              double.parse(cleanValue) <= 0) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Frequency & Day Row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedFrequency,
                              decoration: InputDecoration(
                                labelText: 'Frequency',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14,),
                              ),
                              items: _frequencies
                                  .map((f) => DropdownMenuItem(
                                      value: f, child: Text(f),),)
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedFrequency = value;
                                    _selectedDay = 1;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: _selectedFrequency == 'Weekly'
                                ? DropdownButtonFormField<int>(
                                    initialValue: _selectedDay,
                                    decoration: InputDecoration(
                                      labelText: 'Day',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14,),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 1, child: Text('Mon'),),
                                      DropdownMenuItem(
                                          value: 2, child: Text('Tue'),),
                                      DropdownMenuItem(
                                          value: 3, child: Text('Wed'),),
                                      DropdownMenuItem(
                                          value: 4, child: Text('Thu'),),
                                      DropdownMenuItem(
                                          value: 5, child: Text('Fri'),),
                                      DropdownMenuItem(
                                          value: 6, child: Text('Sat'),),
                                      DropdownMenuItem(
                                          value: 7, child: Text('Sun'),),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _selectedDay = value);
                                      }
                                    },
                                  )
                                : TextFormField(
                                    initialValue: _selectedDay.toString(),
                                    decoration: InputDecoration(
                                      labelText: 'Day',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14,),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final day = int.tryParse(value);
                                      if (day != null &&
                                          day >= 1 &&
                                          day <= 31) {
                                        setState(() => _selectedDay = day);
                                      }
                                    },
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category
                      categoriesAsync.when(
                        data: (categories) {
                          final validCategoryId = _selectedCategoryId != null &&
                                  categories
                                      .any((c) => c.id == _selectedCategoryId)
                              ? _selectedCategoryId
                              : null;
                          return DropdownButtonFormField<Id>(
                            initialValue: validCategoryId,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            hint: const Text('Select'),
                            items: categories
                                .map((c) => DropdownMenuItem(
                                    value: c.id, child: Text(c.name),),)
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCategoryId = value),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('Error'),
                      ),
                      const SizedBox(height: 12),

                      // Reminder & Active Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _reminderDaysController,
                              decoration: InputDecoration(
                                labelText: 'Remind before',
                                suffixText: 'days',
                                prefixIcon:
                                    const Icon(Icons.notifications_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6,),
                            decoration: BoxDecoration(
                              color: _isActive
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isActive ? 'Active' : 'Paused',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: _isActive
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _isActive,
                                  onChanged: (value) =>
                                      setState(() => _isActive = value),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Note
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Note (Optional)',
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 16),

                      // Submit Button
                      FilledButton(
                        onPressed: _saveBill,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(isEditing ? 'Update Bill' : 'Add Bill'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
