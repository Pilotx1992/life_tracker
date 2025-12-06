import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/transfer_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/domain/entities/transfer.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class PayCreditCardDialog extends ConsumerStatefulWidget {
  final Account creditCardAccount;

  const PayCreditCardDialog({
    super.key,
    required this.creditCardAccount,
  });

  @override
  ConsumerState<PayCreditCardDialog> createState() =>
      _PayCreditCardDialogState();
}

class _PayCreditCardDialogState extends ConsumerState<PayCreditCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedAccountId;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _payCreditCard() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      FeedbackService.showWarning(context, 'Please select a payment account');
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      FeedbackService.showWarning(context, 'Please enter a valid amount');
      return;
    }

    try {
      final currencyFormat = NumberFormat.currency(symbol: '\$');
      final accountsAsync = ref.read(accountListProvider);
      await accountsAsync.when(
        data: (accounts) async {
          // الحساب الذي سيدفع منه
          final fromAccount = accounts.firstWhere(
            (a) => a.id.toString() == _selectedAccountId,
            orElse: () => throw Exception('Account not found'),
          );

          // التحقق من وجود رصيد كافي
          if (fromAccount.balance < amount) {
            if (mounted) {
              FeedbackService.showError(context, 'Insufficient balance');
            }
            return;
          }

          // الحصول على أحدث بيانات Credit Card
          final creditCardAccount = accounts.firstWhere(
            (a) => a.id == widget.creditCardAccount.id,
            orElse: () => widget.creditCardAccount,
          );

          // حساب الدين الحالي (utilized limit = creditLimit - balance)
          final cardCreditLimit = creditCardAccount.creditLimit ?? 0.0;
          final utilizedLimit =
              cardCreditLimit > 0 && creditCardAccount.balance < cardCreditLimit
                  ? cardCreditLimit - creditCardAccount.balance
                  : 0.0;

          final currentDebt = utilizedLimit;

          // التحقق من أن المبلغ لا يتجاوز الدين الحالي
          if (amount > currentDebt) {
            if (mounted) {
              FeedbackService.showError(
                context,
                'Amount cannot exceed current debt (${currencyFormat.format(currentDebt)})',
              );
            }
            return;
          }

          // تحديث الحساب المدفوع منه (ينقص)
          final updatedFromAccount = fromAccount.copyWith(
            balance: fromAccount.balance - amount,
          );
          await ref
              .read(accountNotifierProvider.notifier)
              .updateAccountEntry(updatedFromAccount);

          // تحديث Credit Card (يزيد balance عند الدفع - ندفع الدين)
          // balance يجب ألا يتجاوز creditLimit
          final newBalance =
              (creditCardAccount.balance + amount).clamp(0.0, cardCreditLimit);

          final updatedCreditCard = creditCardAccount.copyWith(
            balance: newBalance,
          );
          await ref
              .read(accountNotifierProvider.notifier)
              .updateAccountEntry(updatedCreditCard);

          // إنشاء Transfer لتسجيل الدفع (سداد المديونية)
          final paymentTransfer = Transfer(
            amount: amount,
            currency: fromAccount.currency,
            fromAccountId: fromAccount.id!,
            toAccountId: creditCardAccount.id!,
            date: DateTime.now(),
            note: 'Credit Card Payment',
          );
          await ref
              .read(transferNotifierProvider.notifier)
              .addTransferEntry(paymentTransfer);

          if (mounted) {
            Navigator.of(context).pop();
            FeedbackService.showSuccess(
              context,
              'Paid ${NumberFormat.currency(symbol: '\$').format(amount)} to ${creditCardAccount.name}',
            );
          }
        },
        loading: () async {
          if (mounted) {
            FeedbackService.showInfo(context, 'Loading accounts...');
          }
        },
        error: (error, stack) async {
          if (mounted) {
            FeedbackService.showError(context, 'Error: $error');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        FeedbackService.showError(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountListProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return AlertDialog(
      title: Text('Pay ${widget.creditCardAccount.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Credit Card Balance
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Balance',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            currencyFormat
                                .format(widget.creditCardAccount.balance),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  if (amount > widget.creditCardAccount.balance) {
                    return 'Amount cannot exceed credit card balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Select Account
              accountsAsync.when(
                data: (accounts) {
                  final regularAccounts =
                      accounts.where((a) => a.type != 'Credit Card').toList();

                  if (regularAccounts.isEmpty) {
                    return const Text('No regular accounts available');
                  }

                  // Auto-select first account if none selected
                  if (_selectedAccountId == null &&
                      regularAccounts.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _selectedAccountId == null) {
                        setState(() {
                          _selectedAccountId =
                              regularAccounts.first.id.toString();
                        });
                      }
                    });
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId ??
                        regularAccounts.first.id.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Pay From',
                      border: OutlineInputBorder(),
                    ),
                    items: regularAccounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id.toString(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                account.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currencyFormat.format(account.balance),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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
                error: (error, stack) => Text('Error: $error'),
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
          onPressed: _payCreditCard,
          child: const Text('Pay'),
        ),
      ],
    );
  }
}
