import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/finance/domain/entities/debt.dart';
import 'package:life_tracker/features/finance/domain/entities/debt_payment.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/providers/debt_provider.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class AddDebtPaymentDialog extends ConsumerStatefulWidget {
  final Debt debt;

  const AddDebtPaymentDialog({super.key, required this.debt});

  @override
  ConsumerState<AddDebtPaymentDialog> createState() =>
      _AddDebtPaymentDialogState();
}

class _AddDebtPaymentDialogState extends ConsumerState<AddDebtPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final remaining = widget.debt.remainingAmount;

      if (amount > remaining) {
        FeedbackService.showError(
          context,
          'Payment amount cannot exceed remaining amount (\$${remaining.toStringAsFixed(2)})',
        );
        return;
      }

      final payment = DebtPayment(
        debtId: widget.debt.id!,
        amount: amount,
        paymentDate: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      ref.read(debtNotifierProvider.notifier).addPayment(payment);

      // Update account balance
      if (_selectedAccountId != null) {
        await _updateAccountBalance(ref, int.parse(_selectedAccountId!), amount);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      FeedbackService.showSuccess(context, 'Payment recorded');
    }
  }

  Future<void> _updateAccountBalance(
    WidgetRef ref,
    int accountId,
    double amount,
  ) async {
    final accountsAsync = ref.read(accountListProvider);
    await accountsAsync.when(
      data: (accounts) async {
        final account = accounts.firstWhere(
          (a) => a.id == accountId,
          orElse: () => accounts.first,
        );

        if (account.id != null) {
          // If "I Owe", paying reduces my balance.
          // If "Owed to Me", receiving increases my balance.
          final amountChange = widget.debt.type == 'i_owe' ? -amount : amount;

          final updatedAccount = account.copyWith(
            balance: account.balance + amountChange,
          );
          await ref
              .read(accountNotifierProvider.notifier)
              .updateAccountEntry(updatedAccount);
        }
      },
      loading: () async {},
      error: (_, __) async {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.debt.remainingAmount;
    final accountsAsync = ref.watch(accountListProvider);

    return AlertDialog(
      title: const Text('Add Payment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remaining: ${remaining.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              // Amount
              AppTextField(
                controller: _amountController,
                label: 'Payment Amount',
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > remaining) {
                    return 'Amount cannot exceed remaining balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Account Selector
              accountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return const Text(
                      'No accounts available. Please add an account first.',
                      style: TextStyle(color: Colors.red),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Select Account (Optional)',
                      border: OutlineInputBorder(),
                      helperText: 'Balance will be updated automatically',
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id.toString(),
                        child: Text(account.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedAccountId = value);
                      }
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('Error loading accounts: $error'),
              ),
              const SizedBox(height: 16),
              // Date
              ListTile(
                title: const Text('Payment Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
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
          onPressed: _savePayment,
          child: const Text('Add Payment'),
        ),
      ],
    );
  }
}
