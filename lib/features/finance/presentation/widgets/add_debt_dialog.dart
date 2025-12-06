import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/utils/thousands_separator_formatter.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/features/finance/presentation/providers/debt_provider.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class AddDebtDialog extends ConsumerStatefulWidget {
  final Debt? debt;

  const AddDebtDialog({super.key, this.debt});

  @override
  ConsumerState<AddDebtDialog> createState() => _AddDebtDialogState();
}

class _AddDebtDialogState extends ConsumerState<AddDebtDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedType = 'i_owe';
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      final debt = widget.debt!;
      final numberFormat = NumberFormat('#,##0.00');
      _amountController.text = numberFormat.format(debt.amount);
      _personController.text = debt.person;
      _selectedType = debt.type;
      _selectedDueDate = debt.dueDate;
      _noteController.text = debt.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _personController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _saveDebt() {
    if (_formKey.currentState!.validate()) {
      // Strip commas from formatted numbers before parsing
      final amountText = _amountController.text.replaceAll(',', '');
      final amount = double.tryParse(amountText) ?? 0.0;

      final debt = Debt(
        id: widget.debt?.id,
        type: _selectedType,
        amount: amount,
        paidAmount: widget.debt?.paidAmount ?? 0.0,
        person: _personController.text.trim(),
        dueDate: _selectedDueDate,
        createdAt: widget.debt?.createdAt ?? DateTime.now(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isPaid: widget.debt?.isPaid ?? false,
      );

      if (widget.debt == null) {
        ref.read(debtNotifierProvider.notifier).addDebtEntry(debt);
      } else {
        ref.read(debtNotifierProvider.notifier).updateDebtEntry(debt);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.debt != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Debt' : 'Add Debt'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Debt Type
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'i_owe',
                    child: Text('I Owe'),
                  ),
                  DropdownMenuItem(
                    value: 'owed_to_me',
                    child: Text('Owed to Me'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Person Name
              AppTextField(
                controller: _personController,
                label: 'Person/Entity',
                hint: 'e.g., John Doe, Company Name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter person/entity name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Amount
              AppTextField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  // Strip commas before parsing
                  final cleanValue = value.replaceAll(',', '');
                  final amount = double.tryParse(cleanValue);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Due Date
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDueDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDueDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              const SizedBox(height: 16),
              // Note
              AppTextField(
                controller: _noteController,
                label: 'Note (Optional)',
                hint: 'Add a note...',
                maxLines: 3,
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
          onPressed: _saveDebt,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
