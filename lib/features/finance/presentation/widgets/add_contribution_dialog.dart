import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/finance/domain/entities/commitment_contribution.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/providers/commitment_provider.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class AddContributionDialog extends ConsumerStatefulWidget {
  final FinancialCommitment commitment;

  const AddContributionDialog({super.key, required this.commitment});

  @override
  ConsumerState<AddContributionDialog> createState() =>
      _AddContributionDialogState();
}

class _AddContributionDialogState extends ConsumerState<AddContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

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

  void _saveContribution() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      final contribution = CommitmentContribution(
        commitmentId: widget.commitment.id!,
        amount: amount,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      ref
          .read(commitmentNotifierProvider.notifier)
          .addContribution(contribution);
      Navigator.of(context).pop();
      FeedbackService.showSuccess(context, 'Contribution added');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Contribution'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goal: ${widget.commitment.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This contribution will be deducted from the linked account.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              AppTextField(
                controller: _noteController,
                label: 'Note (Optional)',
                hint: 'Add a note...',
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
          onPressed: _saveContribution,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
