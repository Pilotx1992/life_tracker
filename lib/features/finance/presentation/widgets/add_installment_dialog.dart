import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/features/finance/domain/entities/recurring_bill.dart';
import 'package:life_tracker/features/finance/presentation/providers/bill_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';

/// Enhanced dialog for adding/editing installments
/// Logic: Total Amount + Number of Installments → Auto-calculate Per Payment
class AddInstallmentDialog extends ConsumerStatefulWidget {
  final RecurringBill? existingInstallment;

  const AddInstallmentDialog({
    super.key,
    this.existingInstallment,
  });

  @override
  ConsumerState<AddInstallmentDialog> createState() =>
      _AddInstallmentDialogState();
}

class _AddInstallmentDialogState extends ConsumerState<AddInstallmentDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _installmentsCountController = TextEditingController();
  final _noteController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _dayOfMonth = 1;
  DateTime _startDate = DateTime.now();
  String _frequency = 'Monthly'; // Monthly, Quarterly, Semi-Annual, Yearly
  bool _isSubmitting = false;

  // Calculated values
  double _perPaymentAmount = 0;
  int _totalInstallments = 0;

  bool get isEditing => widget.existingInstallment != null;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    if (isEditing) {
      final bill = widget.existingInstallment!;
      _nameController.text = bill.name;
      _totalAmountController.text = bill.totalAmount.toStringAsFixed(2);
      _installmentsCountController.text = bill.totalInstallments.toString();
      _noteController.text = bill.note ?? '';
      _totalInstallments = bill.totalInstallments;
      _perPaymentAmount = bill.amount;
      _dayOfMonth = bill.dayOfSchedule;
      _startDate = bill.nextDueDate;
      _frequency = bill.frequency;
    } else {
      _installmentsCountController.text = '12';
      _totalInstallments = 12;
    }

    _totalAmountController.addListener(_calculatePerPayment);
    _installmentsCountController.addListener(_calculatePerPayment);
  }

  /// Calculate per-payment amount from total and number of installments
  void _calculatePerPayment() {
    // Remove commas before parsing
    final cleanTotal = _totalAmountController.text.replaceAll(',', '');
    final total = double.tryParse(cleanTotal) ?? 0;
    final count = int.tryParse(_installmentsCountController.text) ?? 0;

    setState(() {
      _totalInstallments = count;
      if (total > 0 && count > 0) {
        _perPaymentAmount = total / count;
      } else {
        _perPaymentAmount = 0;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _totalAmountController.dispose();
    _installmentsCountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: 'EGP ');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 750),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(theme),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    shrinkWrap: true,
                    children: [
                      _buildNameField(theme),
                      const SizedBox(height: 16),
                      _buildAmountCard(theme, formatter),
                      const SizedBox(height: 16),
                      _buildScheduleSection(theme),
                      const SizedBox(height: 16),
                      _buildNoteField(theme),
                      const SizedBox(height: 24),
                      _buildSubmitButton(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit_note : Icons.add_card,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isEditing ? 'Edit Installment' : 'New Installment',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Installment Name',
        hintText: 'e.g., Car Loan, iPhone, Furniture',
        prefixIcon: const Icon(Icons.label_outline),
        filled: true,
        fillColor:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a name';
        return null;
      },
    );
  }

  Widget _buildAmountCard(ThemeData theme, NumberFormat formatter) {
    final total =
        double.tryParse(_totalAmountController.text.replaceAll(',', '')) ?? 0;
    // Compact number format for large numbers
    final compactFormatter = NumberFormat.compactCurrency(
      symbol: 'EGP ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Payment Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Per Payment - Hero Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            ),
            child: Column(
              children: [
                Text(
                  'Per Payment',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _perPaymentAmount > 0
                          ? formatter.format(_perPaymentAmount)
                          : 'EGP 0.00',
                      key: ValueKey(_perPaymentAmount),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _perPaymentAmount > 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Summary chips - stacked vertically
                Column(
                  children: [
                    _buildInfoChip(
                      theme,
                      '$_totalInstallments payments',
                      Icons.repeat,
                    ),
                    if (total > 0) ...[
                      const SizedBox(height: 6),
                      _buildInfoChip(
                        theme,
                        'Total: ${compactFormatter.format(total)}',
                        Icons.account_balance_wallet_outlined,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Input Fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Total Amount
                TextFormField(
                  controller: _totalAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_ThousandsSeparatorFormatter()],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Total Amount',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    hintText: '1,000,000',
                    suffixText: 'EGP',
                    suffixStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final cleanValue = value.replaceAll(',', '');
                    if (double.tryParse(cleanValue) == null)
                      return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Number of Installments with stepper look
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _installmentsCountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Number of Payments',
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          hintText: '12',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final count = int.tryParse(value);
                          if (count == null || count <= 0) return 'Must be > 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Payment Schedule',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Start Date Card
        InkWell(
          onTap: _selectStartDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'First Payment',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMM dd, yyyy').format(_startDate),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit_calendar, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Frequency & Day Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _frequency,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                  DropdownMenuItem(
                      value: 'Quarterly', child: Text('Quarterly')),
                  DropdownMenuItem(
                      value: 'Semi-Annual', child: Text('Semi-Annual')),
                  DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _frequency = value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _dayOfMonth,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Day',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: List.generate(28, (i) => i + 1)
                    .map((day) =>
                        DropdownMenuItem(value: day, child: Text('$day')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _dayOfMonth = value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteField(ThemeData theme) {
    return TextFormField(
      controller: _noteController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Note (optional)',
        hintText: 'Add any additional details...',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Icon(Icons.note_alt_outlined),
        ),
        filled: true,
        fillColor:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return FilledButton(
      onPressed: _isSubmitting ? null : _submit,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isEditing ? Icons.save : Icons.add_card),
                const SizedBox(width: 8),
                Text(
                  isEditing ? 'Update Installment' : 'Create Installment',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_perPaymentAmount <= 0) {
      FeedbackService.showError(context, 'Please enter valid amounts');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final totalAmount =
          double.parse(_totalAmountController.text.replaceAll(',', ''));

      final installment = RecurringBill(
        id: widget.existingInstallment?.id,
        name: _nameController.text.trim(),
        amount: _perPaymentAmount,
        totalAmount: totalAmount,
        totalInstallments: _totalInstallments,
        paidInstallments: widget.existingInstallment?.paidInstallments ?? 0,
        paidAmount: widget.existingInstallment?.paidAmount ?? 0,
        currency: 'EGP',
        categoryId: widget.existingInstallment?.categoryId ?? 0,
        accountId: widget.existingInstallment?.accountId ?? 0,
        frequency: _frequency,
        dayOfSchedule: _dayOfMonth,
        nextDueDate: _startDate,
        note: _noteController.text.isEmpty ? null : _noteController.text.trim(),
        isActive: true,
        createdAt: widget.existingInstallment?.createdAt ?? DateTime.now(),
        type: BillType.installment,
      );

      if (isEditing) {
        ref.read(billNotifierProvider.notifier).updateBillEntry(installment);
      } else {
        ref.read(billNotifierProvider.notifier).addBillEntry(installment);
      }

      if (!mounted) return;

      Navigator.pop(context);
      FeedbackService.showSuccess(
        context,
        isEditing ? 'Installment updated' : 'Installment created successfully!',
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      FeedbackService.showError(context, 'Failed to save: $e');
    }
  }
}

/// Shows the add installment dialog
Future<void> showAddInstallmentDialog(
  BuildContext context, {
  RecurringBill? existingInstallment,
}) async {
  await showDialog(
    context: context,
    builder: (context) => AddInstallmentDialog(
      existingInstallment: existingInstallment,
    ),
  );
}

/// Input formatter that adds thousands separators (commas)
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Remove existing commas
    final cleanText = newValue.text.replaceAll(',', '');

    // Only allow digits
    if (!RegExp(r'^\d*$').hasMatch(cleanText)) {
      return oldValue;
    }

    // Format with commas
    final formatter = NumberFormat('#,###', 'en_US');
    final number = int.tryParse(cleanText);
    if (number == null) return newValue;

    final formatted = formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
