import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/notes/services/note_encryption_service.dart';
import 'package:life_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:life_tracker/features/settings/presentation/screens/device_setup_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:life_tracker/features/settings/presentation/widgets/settings_section.dart';
import 'package:life_tracker/features/settings/presentation/widgets/settings_tile.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text('Settings'),
            centerTitle: false,
            backgroundColor: colorScheme.surface,
            scrolledUnderElevation: 0,
            actions: [
               IconButton(
                 icon: const Icon(Icons.help_outline),
                 onPressed: () => context.push(AppRoutes.termsOfService),
               ),
            ],
          ),
          
          SliverList(
            delegate: SliverChildListDelegate([
              // General Settings
              SettingsSection(
                title: 'General',
                children: [
                   SettingsTile(
                    icon: const Icon(Icons.palette_outlined),
                    iconColor: Colors.blue,
                    title: 'App Theme',
                    subtitle: _getThemeModeLabel(settings.themeMode),
                    onTap: () => _showThemeDialog(settings.themeMode),
                  ),
                  SettingsTile(
                    icon: const Icon(Icons.language),
                    iconColor: Colors.purple,
                    title: 'Language',
                    subtitle: _getLanguageLabel(settings.language),
                    onTap: () => _showLanguageDialog(settings.language),
                  ),
                ],
              ),

              // Account & Security
              SettingsSection(
                title: 'Account & Security',
                children: [
                  SettingsTile(
                    icon: const Icon(Icons.lock_outline),
                    iconColor: Colors.orange,
                    title: 'App Lock',
                    subtitle: 'Secure your app access',
                    onTap: () => context.push(AppRoutes.appLockSetup),
                  ),
                  SettingsTile(
                    icon: const Icon(Icons.fingerprint),
                    iconColor: Colors.teal,
                    title: 'Fingerprint for Notes',
                    subtitle: 'Quick unlock for notes',
                    trailing: Switch(
                      value: true, // TODO: Bind to actual state
                      onChanged: (v) => _showEnableFingerprintDialog(),
                    ),
                    showChevron: false,
                    onTap: () => _showEnableFingerprintDialog(),
                  ),
                   SettingsTile(
                    icon: const Icon(Icons.lock_reset),
                    iconColor: Colors.red,
                    title: 'Reset Note PIN',
                    subtitle: 'Clear saved PIN',
                    onTap: () => _showResetNotePinDialog(),
                  ),
                ],
              ),

              // Notifications
              SettingsSection(
                title: 'Notifications',
                children: [
                  SettingsTile(
                    icon: const Icon(Icons.notifications_outlined),
                    iconColor: Colors.amber,
                    title: 'Notifications',
                    subtitle: settings.notificationsEnabled ? 'On' : 'Off',
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (value) {
                         ref
                          .read(settingsProvider.notifier)
                          .setNotificationsEnabled(value);
                      },
                    ),
                    showChevron: false,
                  ),
                  if (settings.notificationsEnabled) ...[
                     SettingsTile(
                      icon: const Icon(Icons.volume_up_outlined),
                      iconColor: Colors.amber,
                      title: 'Sound',
                      trailing: Switch(
                        value: settings.notificationSound,
                         onChanged: (value) {
                          ref
                              .read(settingsProvider.notifier)
                              .setNotificationSound(value);
                        },
                      ),
                      showChevron: false,
                    ),
                     SettingsTile(
                      icon: const Icon(Icons.vibration),
                      iconColor: Colors.amber,
                      title: 'Vibration',
                      trailing: Switch(
                        value: settings.notificationVibration,
                         onChanged: (value) {
                          ref
                              .read(settingsProvider.notifier)
                              .setNotificationVibration(value);
                        },
                      ),
                      showChevron: false,
                    ),
                  ],
                ],
              ),

              // Data & Integrations
              SettingsSection(
                title: 'Data & Integrations',
                children: [
                   SettingsTile(
                    icon: const Icon(Icons.cloud_upload_outlined),
                    iconColor: Colors.indigo,
                    title: 'Backup & Restore',
                    subtitle: 'Manage your data',
                    onTap: () => context.push(AppRoutes.backup),
                  ),
                  SettingsTile(
                    icon: const Icon(Icons.devices_other),
                    iconColor: Colors.green,
                    title: 'Connected Devices',
                    subtitle: 'Health connect & sensors',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DeviceSetupScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              // Preferences (Finance/Time)
              SettingsSection(
                title: 'Regional Format',
                children: [
                   SettingsTile(
                    icon: const Icon(Icons.currency_exchange),
                    iconColor: Colors.green.shade700,
                    title: 'Currency',
                    subtitle: settings.defaultCurrency,
                    onTap: () => _showCurrencyDialog(settings.defaultCurrency),
                  ),
                   SettingsTile(
                    icon: const Icon(Icons.calendar_month),
                    iconColor: Colors.blueGrey,
                    title: 'Date Format',
                    subtitle: settings.dateFormat,
                    onTap: () => _showDateFormatDialog(settings.dateFormat),
                  ),
                   SettingsTile(
                    icon: const Icon(Icons.access_time),
                    iconColor: Colors.blueGrey,
                    title: 'Time Format',
                    subtitle: settings.timeFormat == '12h' ? '12-hour' : '24-hour',
                    onTap: () => _showTimeFormatDialog(settings.timeFormat),
                  ),
                ],
              ),

              // About
              SettingsSection(
                title: 'About',
                children: [
                  SettingsTile(
                    icon: const Icon(Icons.info_outline),
                    title: 'Version',
                    subtitle: _packageInfo != null 
                        ? '${_packageInfo!.version} (${_packageInfo!.buildNumber})' 
                        : 'Loading...',
                    showChevron: false,
                  ),
                  SettingsTile(
                    icon: const Icon(Icons.policy_outlined),
                    title: 'Privacy Policy',
                    onTap: () => context.push(AppRoutes.privacyPolicy),
                  ),
                  SettingsTile(
                    icon: const Icon(Icons.gavel_outlined),
                    title: 'Terms of Service',
                    onTap: () => context.push(AppRoutes.termsOfService),
                  ),
                  SettingsTile(
                    icon: const Icon(Icons.code),
                    title: 'Open Source Licenses',
                    onTap: () => context.push(AppRoutes.licenses),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
            ]),
          ),
        ],
      ),
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
