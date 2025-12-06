import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:life_tracker/features/settings/presentation/providers/user_profile_providers.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final parsed = double.tryParse(v);
                  if (parsed == null || parsed <= 0) return 'Invalid height';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _dateOfBirth == null
                      ? 'Date of birth'
                      : 'DOB: ${_dateOfBirth!.toLocal().toIso8601String().split('T')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().subtract(const Duration(days: 365 * 20)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _dateOfBirth = picked);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saveProfile,
                child: const Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final height = double.parse(_heightController.text.trim());
    final now = DateTime.now();

    final profile = UserProfile(
      id: 1,
      name: name,
      dateOfBirth: _dateOfBirth,
      gender: _gender,
      heightInCm: height,
      photoPath: null,
      createdAt: now,
      updatedAt: now,
    );

    final ok =
        await ref.read(userProfileProvider.notifier).saveProfile(profile);

    if (!mounted) return;

    if (ok) {
      FeedbackService.showSuccess(context, 'Profile saved successfully!');
      Navigator.of(context).pop();
    } else {
      FeedbackService.showError(context, 'Failed to save profile');
    }
  }
}
