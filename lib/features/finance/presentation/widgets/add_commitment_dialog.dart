import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/core/utils/thousands_separator_formatter.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/providers/commitment_provider.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class AddCommitmentDialog extends ConsumerStatefulWidget {
  final FinancialCommitment? commitment;

  const AddCommitmentDialog({super.key, this.commitment});

  @override
  ConsumerState<AddCommitmentDialog> createState() =>
      _AddCommitmentDialogState();
}

class _AddCommitmentDialogState extends ConsumerState<AddCommitmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCurrency = 'EGP';
  Id? _selectedAccountId;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    if (widget.commitment != null) {
      final commitment = widget.commitment!;
      _nameController.text = commitment.name;
      _descriptionController.text = commitment.description;
      // Format with thousand separators
      final numberFormat = NumberFormat('#,##0.00');
      _targetAmountController.text =
          numberFormat.format(commitment.targetAmount);
      _selectedCurrency = commitment.currency;
      _selectedAccountId = commitment.accountId;
      _selectedDeadline = commitment.deadline;
      _noteController.text = commitment.note ?? '';
    } else {
      _selectedDeadline = DateTime.now().add(const Duration(days: 365));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _saveCommitment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccountId == null) {
        FeedbackService.showWarning(context, 'Please select an account');
        return;
      }

      // Strip commas before parsing
      final cleanAmount = _targetAmountController.text.replaceAll(',', '');
      final targetAmount = double.tryParse(cleanAmount) ?? 0.0;
      final now = DateTime.now();

      final commitment = FinancialCommitment(
        id: widget.commitment?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: widget.commitment?.currentAmount ?? 0.0,
        currency: _selectedCurrency,
        deadline: _selectedDeadline,
        accountId: _selectedAccountId!,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isCompleted: widget.commitment?.isCompleted ?? false,
        createdAt: widget.commitment?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.commitment == null) {
        ref
            .read(commitmentNotifierProvider.notifier)
            .addCommitmentEntry(commitment);
      } else {
        ref
            .read(commitmentNotifierProvider.notifier)
            .updateCommitmentEntry(commitment);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);

      if (!mounted) return;
      FeedbackService.showSuccess(
        context,
        widget.commitment == null
            ? 'Commitment added successfully'
            : 'Commitment updated successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final isEditing = widget.commitment != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Commitment' : 'Add Financial Commitment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              AppTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'e.g., Vacation Fund, Emergency Savings',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'What is this commitment for?',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Target Amount
              AppTextField(
                controller: _targetAmountController,
                label: 'Target Amount',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter target amount';
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
              // Deadline
              InkWell(
                onTap: _selectDeadline,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Deadline',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
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
              // Note
              AppTextField(
                controller: _noteController,
                label: 'Note (Optional)',
                hint: 'Additional notes',
                maxLines: 2,
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
          onPressed: _saveCommitment,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
