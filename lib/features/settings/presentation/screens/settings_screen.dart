import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/notes/services/note_encryption_service.dart';
import 'package:life_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:life_tracker/features/settings/presentation/screens/device_setup_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Setting
          _buildSection(
            title: 'Appearance',
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeLabel(settings.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(settings.themeMode),
              ),
            ],
          ),
          // Language Setting
          _buildSection(
            title: 'Language',
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: Text(_getLanguageLabel(settings.language)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(settings.language),
              ),
            ],
          ),
          // Finance Settings
          _buildSection(
            title: 'Finance',
            children: [
              ListTile(
                leading: const Icon(Icons.currency_exchange),
                title: const Text('Default Currency'),
                subtitle: Text(settings.defaultCurrency),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCurrencyDialog(settings.defaultCurrency),
              ),
            ],
          ),
          // Date & Time Settings
          _buildSection(
            title: 'Date & Time',
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date Format'),
                subtitle: Text(settings.dateFormat),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDateFormatDialog(settings.dateFormat),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time Format'),
                subtitle:
                    Text(settings.timeFormat == '12h' ? '12-hour' : '24-hour'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTimeFormatDialog(settings.timeFormat),
              ),
            ],
          ),
          // Notification Settings
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive app notifications'),
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setNotificationsEnabled(value);
                },
              ),
              if (settings.notificationsEnabled) ...[
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up),
                  title: const Text('Notification Sound'),
                  subtitle: const Text('Play sound for notifications'),
                  value: settings.notificationSound,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .setNotificationSound(value);
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration),
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate for notifications'),
                  value: settings.notificationVibration,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .setNotificationVibration(value);
                  },
                ),
              ],
            ],
          ),
          // Device Integration
          _buildSection(
            title: 'Devices',
            children: [
              ListTile(
                leading: const Icon(Icons.devices),
                title: const Text('Device Integration'),
                subtitle:
                    const Text('Connect smart scales and fitness trackers'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DeviceSetupScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          // Security Settings
          _buildSection(
            title: 'Security',
            children: [
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('App Lock'),
                subtitle: const Text('Manage app lock settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.appLockSetup),
              ),
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Fingerprint for Notes'),
                subtitle: const Text('Use fingerprint to unlock locked notes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showEnableFingerprintDialog(),
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Reset Note PIN'),
                subtitle: const Text('Clear saved PIN for locked notes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showResetNotePinDialog(),
              ),
            ],
          ),
          // Backup & Restore
          _buildSection(
            title: 'Data',
            children: [
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                subtitle: const Text('Create and restore backups'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.backup),
              ),
            ],
          ),
          // About Section
          _buildSection(
            title: 'About',
            children: [
              if (_packageInfo != null) ...[
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('App Version'),
                  subtitle: Text(
                    '${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('Package Name'),
                  subtitle: Text(_packageInfo!.packageName),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Privacy Policy'),
                subtitle: const Text('View privacy policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.privacyPolicy),
              ),
              ListTile(
                leading: const Icon(Icons.gavel),
                title: const Text('Terms of Service'),
                subtitle: const Text('View terms and conditions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.termsOfService),
              ),
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text('Licenses'),
                subtitle: const Text('View open source licenses'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.licenses),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية (Arabic)';
      default:
        return code;
    }
  }

  void _showThemeDialog(ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: RadioGroup<ThemeMode>(
          groupValue: currentMode,
          onChanged: (value) {
            if (value != null) {
              ref.read(settingsProvider.notifier).setThemeMode(value);
              Navigator.of(context).pop();
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text('Light'),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text('Dark'),
                value: ThemeMode.dark,
              ),
              RadioListTile<ThemeMode>(
                title: Text('System Default'),
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: RadioGroup<String>(
          groupValue: currentLanguage,
          onChanged: (value) {
            if (value != null) {
              ref.read(settingsProvider.notifier).setLanguage(value);
              Navigator.of(context).pop();
              FeedbackService.showInfo(
                context,
                'Language changed. Restart app to apply.',
              );
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('English'),
                value: 'en',
              ),
              RadioListTile<String>(
                title: Text('العربية (Arabic)'),
                value: 'ar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(String currentCurrency) {
    final currencies = [
      'USD',
      'EUR',
      'GBP',
      'JPY',
      'CNY',
      'INR',
      'AED',
      'SAR',
      'EGP',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Default Currency'),
        content: RadioGroup<String>(
          groupValue: currentCurrency,
          onChanged: (value) {
            if (value != null) {
              ref.read(settingsProvider.notifier).setDefaultCurrency(value);
              Navigator.of(context).pop();
            }
          },
          child: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              cacheExtent: 500,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                return RadioListTile<String>(
                  title: Text(currency),
                  value: currency,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDateFormatDialog(String currentFormat) {
    final formats = [
      {'label': 'MM/DD/YYYY', 'value': 'MM/dd/yyyy'},
      {'label': 'DD/MM/YYYY', 'value': 'dd/MM/yyyy'},
      {'label': 'YYYY-MM-DD', 'value': 'yyyy-MM-dd'},
      {'label': 'DD MMM YYYY', 'value': 'dd MMM yyyy'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Format'),
        content: RadioGroup<String>(
          groupValue: currentFormat,
          onChanged: (value) {
            if (value != null) {
              ref.read(settingsProvider.notifier).setDateFormat(value);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: formats.map((format) {
              return RadioListTile<String>(
                title: Text(format['label']!),
                value: format['value']!,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showTimeFormatDialog(String currentFormat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Time Format'),
        content: RadioGroup<String>(
          groupValue: currentFormat,
          onChanged: (value) {
            if (value != null) {
              ref.read(settingsProvider.notifier).setTimeFormat(value);
              Navigator.of(context).pop();
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('12-hour (AM/PM)'),
                value: '12h',
              ),
              RadioListTile<String>(
                title: Text('24-hour'),
                value: '24h',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showResetNotePinDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Note PIN?'),
        content: const Text(
          'This will clear your saved PIN for locked notes. '
          'You will need to set a new PIN next time you lock a note.\n\n'
          'Warning: Existing locked notes may become inaccessible if you forgot the PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset PIN'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NoteEncryptionService().clearPIN();
      if (mounted) {
        FeedbackService.showSuccess(context, 'Note PIN has been reset');
      }
    }
  }

  Future<void> _showEnableFingerprintDialog() async {
    final encryptionService = NoteEncryptionService();
    
    // Check prerequisites
    final isAvailable = await encryptionService.isBiometricAvailable();
    if (!isAvailable) {
      if (mounted) {
        FeedbackService.showWarning(
          context,
          'Biometric authentication is not available on this device',
        );
      }
      return;
    }

    final hasPIN = await encryptionService.hasPIN();
    if (!hasPIN) {
      if (mounted) {
        FeedbackService.showWarning(
          context,
          'Please set up a Note PIN first by locking a note',
        );
      }
      return;
    }

    final isEnabled = await encryptionService.isBiometricEnabled();
    if (!mounted) return;

    if (isEnabled) {
      // Show disable dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disable Fingerprint?'),
          content: const Text(
            'You will need to enter your PIN to unlock locked notes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await encryptionService.disableBiometric();
        if (mounted) {
          FeedbackService.showSuccess(context, 'Fingerprint disabled for notes');
        }
      }
    } else {
      // Show enable dialog - requires PIN verification
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Fingerprint?'),
          content: const Text(
            'Use your fingerprint to quickly unlock locked notes.\n\n'
            'You will need to enter your PIN to enable this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.fingerprint),
              label: const Text('Enable'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        // Ask for PIN to enable biometric
        final pin = await showDialog<String>(
          context: context,
          builder: (context) => const _SimplePinDialog(
            title: 'Enter PIN',
            message: 'Enter your Note PIN to enable fingerprint',
          ),
        );

        if (pin != null && mounted) {
          final success = await encryptionService.enableBiometric(pin);
          if (mounted) {
            if (success) {
              FeedbackService.showSuccess(context, 'Fingerprint enabled for notes');
            } else {
              FeedbackService.showError(context, 'Invalid PIN');
            }
          }
        }
      }
    }
  }
}

/// Simple PIN input dialog for Settings (doesn't trigger biometric)
class _SimplePinDialog extends StatefulWidget {
  final String title;
  final String? message;

  const _SimplePinDialog({
    required this.title,
    this.message,
  });

  @override
  State<_SimplePinDialog> createState() => _SimplePinDialogState();
}

class _SimplePinDialogState extends State<_SimplePinDialog> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (index == 3 && value.isNotEmpty) {
      final pin = _controllers.map((c) => c.text).join();
      Navigator.of(context).pop(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.message != null) ...[
            Text(widget.message!),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) {
              return SizedBox(
                width: 50,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  obscureText: true,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => _onChanged(i, v),
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
