import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/utils/thousands_separator_formatter.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class AddAccountDialog extends ConsumerStatefulWidget {
  final Account? account;

  const AddAccountDialog({super.key, this.account});

  @override
  ConsumerState<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _cardDigitsController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'Cash';
  String _selectedCurrency = 'EGP';

  final List<String> _accountTypes = [
    'Bank',
    'Cash',
    'Card',
    'E-Wallet',
    'Credit Card',
  ];
  final List<String> _currencies = ['USD', 'EGP'];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      final account = widget.account!;
      final numberFormat = NumberFormat('#,##0.00');
      _nameController.text = account.name;
      // Format with thousand separators for display
      _balanceController.text = numberFormat.format(account.balance);
      _creditLimitController.text = account.creditLimit != null
          ? numberFormat.format(account.creditLimit)
          : '';
      _selectedType = account.type;
      _selectedCurrency = account.currency;
      _bankNameController.text = account.bankName ?? '';
      _cardDigitsController.text = account.cardLastDigits ?? '';
      _notesController.text = account.notes ?? '';
    }
    // For new accounts, leave balance field empty so hint text "0.0" shows
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    _bankNameController.dispose();
    _cardDigitsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      // Strip commas from formatted numbers before parsing
      final balanceText = _balanceController.text.replaceAll(',', '');
      final creditLimitText = _creditLimitController.text.replaceAll(',', '');

      final creditLimit =
          _selectedType == 'Credit Card' && creditLimitText.isNotEmpty
              ? double.tryParse(creditLimitText)
              : null;

      // For Credit Card, balance represents the current available credit
      // If balance < creditLimit, there is debt = creditLimit - balance
      // User enters the current balance manually
      final balance = double.tryParse(balanceText) ?? 0.0;

      final account = Account(
        id: widget.account?.id,
        name: _nameController.text.trim(),
        currency: _selectedCurrency,
        balance: balance,
        type: _selectedType,
        bankName: _bankNameController.text.trim().isEmpty
            ? null
            : _bankNameController.text.trim(),
        cardLastDigits: _cardDigitsController.text.trim().isEmpty
            ? null
            : _cardDigitsController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        creditLimit: creditLimit,
      );

      if (widget.account == null) {
        ref.read(accountNotifierProvider.notifier).addAccountEntry(account);
      } else {
        ref.read(accountNotifierProvider.notifier).updateAccountEntry(account);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Account' : 'Add Account'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add top padding so Account Type label is fully visible
              const SizedBox(height: 8),
              // 1. Account Type
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Account Type',
                  border: OutlineInputBorder(),
                ),
                items: _accountTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // 2. Account Name
              AppTextField(
                controller: _nameController,
                label: 'Account Name',
                hint: 'e.g., Main Checking',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter account name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 3. Credit Limit (for Credit Card accounts) - shown before balance
              if (_selectedType == 'Credit Card') ...[
                AppTextField(
                  controller: _creditLimitController,
                  label: 'Credit Limit',
                  hint: 'e.g., 100,000',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter credit limit';
                    }
                    // Strip commas before parsing
                    final cleanValue = value.replaceAll(',', '');
                    final limit = double.tryParse(cleanValue);
                    if (limit == null || limit <= 0) {
                      return 'Please enter a valid credit limit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              // 4. Current Balance / Initial Balance
              AppTextField(
                controller: _balanceController,
                label: _selectedType == 'Credit Card'
                    ? 'Current Balance'
                    : 'Initial Balance',
                hint: '0.0',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                validator: (value) {
                  // Empty is allowed (defaults to 0.0)
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  // Strip commas before parsing
                  final cleanValue = value.replaceAll(',', '');
                  final balance = double.tryParse(cleanValue);
                  if (balance == null) {
                    return 'Please enter a valid number';
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
              // Bank Name (for Bank accounts)
              if (_selectedType == 'Bank')
                AppTextField(
                  controller: _bankNameController,
                  label: 'Bank Name (Optional)',
                  hint: 'e.g., Chase Bank',
                ),
              // Card Last Digits (for Card accounts)
              if (_selectedType == 'Card') ...[
                const SizedBox(height: 16),
                AppTextField(
                  controller: _cardDigitsController,
                  label: 'Last 4 Digits (Optional)',
                  hint: '1234',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
              ],
              const SizedBox(height: 16),
              // Notes
              AppTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Additional information',
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
          onPressed: _saveAccount,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
