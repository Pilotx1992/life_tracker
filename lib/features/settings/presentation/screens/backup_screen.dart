import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/services/backup_service.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/core/services/restore_service.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService.instance;
  final RestoreService _restoreService = RestoreService.instance;
  final _passwordController = TextEditingController();
  final _restorePasswordController = TextEditingController();

  bool _isCreatingBackup = false;
  bool _usePassword = false;
  List<BackupFileInfo> _backups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _restorePasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadBackups() async {
    setState(() {
      _isLoading = true;
    });
    final backups = await _backupService.listBackups();
    setState(() {
      _backups = backups;
      _isLoading = false;
    });
  }

  Future<void> _createBackup() async {
    if (_usePassword && _passwordController.text.isEmpty) {
      FeedbackService.showWarning(context, 'Please enter a password');
      return;
    }

    setState(() {
      _isCreatingBackup = true;
    });

    try {
      await _backupService.createBackup(
        password: _usePassword ? _passwordController.text : null,
      );

      if (mounted) {
        FeedbackService.showSuccess(context, 'Backup created successfully!');
        _passwordController.clear();
        setState(() {
          _usePassword = false;
        });
        await _loadBackups();
      }
    } catch (e) {
      if (mounted) {
        FeedbackService.showError(context, 'Failed to create backup: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingBackup = false;
        });
      }
    }
  }

  Future<void> _restoreBackup(BackupFileInfo backup) async {
    // Show dialog to enter password and conflict strategy
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _RestoreDialog(
        backup: backup,
        passwordController: _restorePasswordController,
      ),
    );

    if (result == null) return;

    final password = result['password'];
    final strategy = result['strategy'];

    if (strategy == null) return;

    if (!mounted) return;

    // Confirm restore
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: Text(
          strategy == 'replace'
              ? 'This will replace all your current data with the backup. This action cannot be undone. Are you sure?'
              : 'This will merge the backup data with your current data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _restoreService.restoreFromBackup(
        filePath: backup.path,
        password: password?.isEmpty == true ? null : password,
        conflictStrategy: strategy,
      );

      if (mounted) {
        FeedbackService.showSuccess(context, 'Backup restored successfully!');
        _restorePasswordController.clear();
        // Reload backups
        await _loadBackups();
      }
    } catch (e) {
      if (mounted) {
        FeedbackService.showError(context, 'Failed to restore backup: $e');
      }
    }
  }

  Future<void> _deleteBackup(BackupFileInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup?'),
        content: const Text('Are you sure you want to delete this backup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _backupService.deleteBackup(backup.path);
      if (success && mounted) {
        FeedbackService.showSuccess(context, 'Backup deleted');
        await _loadBackups();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create Backup Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Backup',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Encrypt with password'),
                        const SizedBox(width: 8),
                        Switch(
                          value: _usePassword,
                          onChanged: (value) {
                            setState(() {
                              _usePassword = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_usePassword) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter backup password',
                        obscureText: true,
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isCreatingBackup ? null : _createBackup,
                        icon: _isCreatingBackup
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.backup),
                        label: Text(
                          _isCreatingBackup ? 'Creating...' : 'Create Backup',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Existing Backups Section
            Text(
              'Existing Backups',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_backups.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.backup_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No backups found',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first backup to get started',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._backups.map((backup) => _buildBackupCard(backup)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(BackupFileInfo backup) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.backup, size: 32),
        title: Text(backup.fileName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${backup.formattedSize}'),
            Text('Created: ${dateFormat.format(backup.modified)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () => _restoreBackup(backup),
              tooltip: 'Restore',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteBackup(backup),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

class _RestoreDialog extends StatefulWidget {
  final BackupFileInfo backup;
  final TextEditingController passwordController;

  const _RestoreDialog({
    required this.backup,
    required this.passwordController,
  });

  @override
  State<_RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<_RestoreDialog> {
  String _selectedStrategy = 'merge';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore Backup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter password if backup is encrypted:'),
            const SizedBox(height: 16),
            AppTextField(
              controller: widget.passwordController,
              label: 'Password (optional)',
              hint: 'Leave empty if not encrypted',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            const Text('Conflict Strategy:'),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _selectedStrategy,
              onChanged: (value) {
                setState(() {
                  _selectedStrategy = value!;
                });
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('Merge'),
                    subtitle: Text('Add backup data to existing data'),
                    value: 'merge',
                  ),
                  RadioListTile<String>(
                    title: Text('Replace'),
                    subtitle:
                        Text('Replace all existing data with backup'),
                    value: 'replace',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'password': widget.passwordController.text,
              'strategy': _selectedStrategy,
            });
          },
          child: const Text('Restore'),
        ),
      ],
    );
  }
}
