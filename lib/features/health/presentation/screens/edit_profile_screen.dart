import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/health/domain/entities/user_profile.dart';
import 'package:life_tracker/features/health/presentation/providers/profile_provider.dart';
import 'package:life_tracker/features/health/domain/usecases/update_user_profile.dart'
    as uup;

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String? _gender;

  @override
  Widget build(BuildContext context) {
    final userProfileAsyncValue = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: userProfileAsyncValue.when(
        data: (userProfile) {
          _nameController.text = userProfile.name ?? '';
          _heightController.text = userProfile.height?.toString() ?? '';
          _ageController.text = userProfile.age?.toString() ?? '';
          _gender = userProfile.gender;

          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final updatedProfile = UserProfile(
                          name: _nameController.text,
                          height: double.parse(_heightController.text),
                          age: int.parse(_ageController.text),
                          gender: _gender,
                        );
                        ref
                            .read(updateUserProfileProvider)
                            .call(uup.Params(userProfile: updatedProfile));
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
