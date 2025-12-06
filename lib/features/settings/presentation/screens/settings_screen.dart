import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
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
            ),
            RadioListTile<String>(
              title: const Text('العربية (Arabic)'),
              value: 'ar',
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
            ),
          ],
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
        content: SizedBox(
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
                groupValue: currentCurrency,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .setDefaultCurrency(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            },
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) {
            return RadioListTile<String>(
              title: Text(format['label']!),
              value: format['value']!,
              groupValue: currentFormat,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setDateFormat(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimeFormatDialog(String currentFormat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Time Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('12-hour (AM/PM)'),
              value: '12h',
              groupValue: currentFormat,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setTimeFormat(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('24-hour'),
              value: '24h',
              groupValue: currentFormat,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setTimeFormat(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
