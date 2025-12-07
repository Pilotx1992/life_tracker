import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/utils/validators.dart';
import 'package:life_tracker/features/health/domain/entities/medication.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/shared/widgets/buttons/app_button.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class AddMedicationDialog extends ConsumerStatefulWidget {
  final Medication? initialMedication;

  const AddMedicationDialog({super.key, this.initialMedication});

  @override
  ConsumerState<AddMedicationDialog> createState() =>
      _AddMedicationDialogState();
}

class _AddMedicationDialogState extends ConsumerState<AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;
  List<DateTime> _selectedTimes = [];
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialMedication?.name ?? '');
    _dosageController =
        TextEditingController(text: widget.initialMedication?.dosage ?? '');
    _instructionsController = TextEditingController(
      text: widget.initialMedication?.instructions ?? '',
    );
    _selectedTimes = widget.initialMedication?.times ?? [];
    _startDate = widget.initialMedication?.startDate ?? DateTime.now();
    _endDate = widget.initialMedication?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        _selectedTimes.add(
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
        );
        _selectedTimes.sort((a, b) => a.compareTo(b));
      });
    }
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _startDate.isAfter(_endDate!)) {
            _endDate = _startDate; // Ensure end date is not before start date
          }
        } else {
          _endDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _startDate = _endDate!; // Ensure start date is not after end date
          }
        }
      });
    }
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final newMedication = Medication(
        id: widget.initialMedication?.id,
        name: _nameController.text,
        dosage: _dosageController.text,
        times: _selectedTimes,
        instructions: _instructionsController.text.isEmpty
            ? null
            : _instructionsController.text,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (widget.initialMedication == null) {
        ref
            .read(medicationNotifierProvider.notifier)
            .addMedicationEntry(newMedication);
      } else {
        ref
            .read(medicationNotifierProvider.notifier)
            .updateMedicationEntry(newMedication);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialMedication == null ? 'Add Medication' : 'Edit Medication',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Medication Name',
                validator: (value) =>
                    Validators.validateGenericField(value, 'Medication Name'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _dosageController,
                label: 'Dosage (e.g., 10mg, 1 pill)',
                validator: (value) =>
                    Validators.validateGenericField(value, 'Dosage'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Times'),
                subtitle: Text(
                  _selectedTimes
                      .map(
                        (e) =>
                            '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}',
                      )
                      .join(', '),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add_alarm),
                  onPressed: () => _selectTime(context),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _instructionsController,
                label: 'Instructions (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Start Date: ${_startDate.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, isStartDate: true),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'End Date: ${_endDate?.toLocal().toString().split(' ')[0] ?? 'No End Date'}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, isStartDate: false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          text: 'Cancel',
          type: AppButtonType.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          text: widget.initialMedication == null ? 'Add' : 'Save',
          onPressed: _saveMedication,
        ),
      ],
    );
  }
}
