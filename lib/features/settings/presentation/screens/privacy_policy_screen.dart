import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Effective Date: January 1, 2024',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Introduction',
              'LifeMate ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle your data when you use our mobile application.',
            ),
            _buildSection(
              context,
              'Data Collection',
              'We do not collect, store, or transmit any personal data.\n\n'
                  'LifeMate is designed as an offline-first application. All your data is stored locally on your device and never leaves your device unless you explicitly choose to:\n\n'
                  '1. Backup to Google Drive - When you enable backup, your data is encrypted (AES-256-GCM) before being uploaded to your personal Google Drive account\n'
                  '2. Export Data - When you export data to CSV/PDF, you choose where to save or share the files',
            ),
            _buildSection(
              context,
              'Data Storage',
              'Local Storage:\n'
                  '- All data is stored locally on your device using Isar database\n'
                  '- Data includes: weight entries, finance records, medications, reminders, and notes\n'
                  '- This data never leaves your device unless you explicitly backup or export it\n\n'
                  'Cloud Backup (Optional):\n'
                  '- If you choose to backup to Google Drive:\n'
                  '  - Your data is encrypted with AES-256-GCM before upload\n'
                  '  - Only you can access your backups (stored in Google Drive AppData folder)\n'
                  '  - We do not have access to your backup data\n'
                  '  - You can delete backups at any time',
            ),
            _buildSection(
              context,
              'Third-Party Services',
              'Google Drive:\n'
                  '- Purpose: Cloud backup (optional)\n'
                  '- Data: Encrypted backups of your app data\n'
                  '- Privacy: Your backups are stored in your Google Drive AppData folder, which is private to your account\n\n'
                  'Google Fonts:\n'
                  '- Purpose: Typography\n'
                  '- Data: None (fonts are downloaded locally)\n'
                  '- Privacy: No user data is transmitted',
            ),
            _buildSection(
              context,
              'Permissions',
              'LifeMate requests the following permissions:\n\n'
                  'Android:\n'
                  '- Internet: Required for Google Drive backup (optional feature)\n'
                  '- Storage: Required for exporting files\n'
                  '- Notifications: Required for reminder notifications',
            ),
            _buildSection(
              context,
              'Data Security',
              '- Encryption: All backups are encrypted with AES-256-GCM\n'
                  '- Local Storage: Data is stored securely on your device\n'
                  '- No Network Calls: The app does not make any network calls except for optional Google Drive backup\n'
                  '- No Analytics: We do not use any analytics or tracking services',
            ),
            _buildSection(
              context,
              'Data Deletion',
              '- Delete App Data: You can delete all app data from Settings > Clear All Data\n'
                  '- Delete Backups: You can delete backups from Settings > Backup & Restore\n'
                  '- Uninstall App: Uninstalling the app removes all local data',
            ),
            _buildSection(
              context,
              'Children\'s Privacy',
              'LifeMate is not intended for children under 13. We do not knowingly collect data from children.',
            ),
            _buildSection(
              context,
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the app.',
            ),
            _buildSection(
              context,
              'Your Rights',
              'You have the following rights regarding your data:\n\n'
                  '- Access: View all your data within the app\n'
                  '- Export: Export your data to CSV/PDF\n'
                  '- Delete: Delete all your data at any time\n'
                  '- Backup: Create encrypted backups to Google Drive\n'
                  '- Restore: Restore from backups',
            ),
            _buildSection(
              context,
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                  '- Email: privacy@lifemate.app\n'
                  '- GitHub: https://github.com/yourusername/life_tracker/issues',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
