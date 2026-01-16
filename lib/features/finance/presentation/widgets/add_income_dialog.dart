import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/utils/thousands_separator_formatter.dart';
import 'package:life_tracker/features/finance/domain/entities/income.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/providers/income_provider.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class AddIncomeDialog extends ConsumerStatefulWidget {
  final Income? income;
  final int? preSelectedAccountId;

  const AddIncomeDialog({
    super.key,
    this.income,
    this.preSelectedAccountId,
  });

  @override
  ConsumerState<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends ConsumerState<AddIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCurrency = 'EGP';
  String _selectedSource = 'Salary';
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String? _selectedFrequency;

  final List<String> _currencies = ['USD', 'EGP'];
  final List<String> _sources = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];
  final List<String> _frequencies = ['Monthly', 'Weekly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      final income = widget.income!;
      final numberFormat = NumberFormat('#,##0.00');
      _amountController.text = numberFormat.format(income.amount);
      _selectedCurrency = income.currency;
      _selectedSource = income.source;
      _selectedAccountId = income.accountId.toString();
      _selectedDate = income.date;
      _noteController.text = income.note ?? '';
      _isRecurring = income.isRecurring;
      _selectedFrequency = income.recurringFrequency;
    } else if (widget.preSelectedAccountId != null) {
      _selectedAccountId = widget.preSelectedAccountId.toString();
    }
  }

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

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccountId == null) {
        FeedbackService.showWarning(context, 'Please select an account');
        return;
      }

      if (_isRecurring && _selectedFrequency == null) {
        FeedbackService.showWarning(
          context,
          'Please select a frequency for recurring income',
        );
        return;
      }

      // Strip commas from formatted numbers before parsing
      final amountText = _amountController.text.replaceAll(',', '');
      final amount = double.tryParse(amountText) ?? 0.0;
      final accountId = int.parse(_selectedAccountId!);

      final income = Income(
        id: widget.income?.id,
        amount: amount,
        currency: _selectedCurrency,
        source: _selectedSource,
        accountId: accountId,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isRecurring: _isRecurring,
        recurringFrequency: _isRecurring ? _selectedFrequency : null,
      );

      if (widget.income == null) {
        await ref.read(incomeNotifierProvider.notifier).addIncomeEntry(income);
        // Update account balance
        await _updateAccountBalance(ref, income.accountId, income.amount);
      } else {
        final oldIncome = widget.income!;
        await ref
            .read(incomeNotifierProvider.notifier)
            .updateIncomeEntry(income);
        // Update account balances
        if (oldIncome.accountId != income.accountId) {
          // Account changed - revert old, apply new
          await _updateAccountBalance(
            ref,
            oldIncome.accountId,
            -oldIncome.amount,
          );
          await _updateAccountBalance(ref, income.accountId, income.amount);
        } else {
          // Same account - adjust difference
          final difference = income.amount - oldIncome.amount;
          await _updateAccountBalance(ref, income.accountId, difference);
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      FeedbackService.showSuccess(
        context,
        widget.income == null ? 'Income added successfully' : 'Income updated successfully',
      );
    }
  }

  Future<void> _updateAccountBalance(
    WidgetRef ref,
    int accountId,
    double amountChange,
  ) async {
    final accountsAsync = ref.read(accountListProvider);
    accountsAsync.whenData((accounts) {
      final account = accounts.firstWhere(
        (a) => a.id == accountId,
        orElse: () => accounts.first,
      );

      if (account.id != null) {
        final updatedAccount = account.copyWith(
          balance: account.balance + amountChange,
        );
        ref
            .read(accountNotifierProvider.notifier)
            .updateAccountEntry(updatedAccount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountListProvider);
    final isEditing = widget.income != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Income' : 'Add Income'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              // Currency
              DropdownButtonFormField<String>(
                initialValue: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                items: _currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCurrency = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Source
              DropdownButtonFormField<String>(
                initialValue: _selectedSource,
                decoration: const InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(),
                ),
                items: _sources.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Text(source),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSource = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Account Selector
              accountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return const Text(
                      'No accounts available. Please add an account first.',
                    );
                  }
                  return DropdownButtonFormField<String>(
                    initialValue:
                        _selectedAccountId ?? accounts.first.id.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      border: OutlineInputBorder(),
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
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error loading accounts: $error'),
              ),
              const SizedBox(height: 16),
              // Date Picker
              ListTile(
                title: const Text('Date'),
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
              // Recurring Checkbox
              CheckboxListTile(
                title: const Text('Recurring Income'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value ?? false;
                    if (!_isRecurring) {
                      _selectedFrequency = null;
                    }
                  });
                },
              ),
              // Frequency (if recurring)
              if (_isRecurring) ...[
                const SizedBox(height: 8),
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
                      setState(() => _selectedFrequency = value);
                    }
                  },
                ),
              ],
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
          onPressed: _saveIncome,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
