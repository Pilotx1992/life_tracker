import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/utils/validators.dart';
import 'package:life_tracker/features/health/domain/entities/weight_entry.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_provider.dart';
import 'package:life_tracker/shared/widgets/buttons/app_button.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class AddWeightDialog extends ConsumerStatefulWidget {
  final WeightEntry? initialWeightEntry;

  const AddWeightDialog({super.key, this.initialWeightEntry});

  @override
  ConsumerState<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends ConsumerState<AddWeightDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.initialWeightEntry?.weight.toStringAsFixed(1) ?? '',
    );
    _noteController =
        TextEditingController(text: widget.initialWeightEntry?.note ?? '');
    _selectedDate = widget.initialWeightEntry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveWeight() {
    if (_formKey.currentState!.validate()) {
      final weight = double.parse(_weightController.text);
      final note = _noteController.text.isEmpty ? null : _noteController.text;

      final newEntry = WeightEntry(
        id: widget.initialWeightEntry?.id,
        weight: weight,
        date: _selectedDate,
        note: note,
      );

      if (widget.initialWeightEntry == null) {
        ref.read(weightNotifierProvider.notifier).addWeightEntry(newEntry);
      } else {
        ref.read(weightNotifierProvider.notifier).updateWeightEntry(newEntry);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialWeightEntry == null ? 'Add Weight' : 'Edit Weight',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _weightController,
              label: 'Weight (kg)',
              keyboardType: TextInputType.number,
              validator: Validators.validateWeight,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _noteController,
              label: 'Note (optional)',
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          text: 'Cancel',
          type: AppButtonType.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          text: widget.initialWeightEntry == null ? 'Add' : 'Save',
          onPressed: _saveWeight,
        ),
      ],
    );
  }
}
