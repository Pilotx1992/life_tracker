import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              '1. Acceptance of Terms',
              'By downloading, installing, or using Life Tracker ("the App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App.',
            ),
            _buildSection(
              context,
              '2. Description of Service',
              'Life Tracker is a personal life management application that allows you to:\n'
                  '- Track your health metrics (weight, medications)\n'
                  '- Manage your finances (expenses, income, accounts, debts, bills)\n'
                  '- Create and organize notes\n'
                  '- Set reminders for important tasks\n'
                  '- Backup and restore your data',
            ),
            _buildSection(
              context,
              '3. User Responsibilities',
              '3.1 Account and Data\n'
                  '- You are responsible for maintaining the confidentiality of your app lock PIN/biometric authentication\n'
                  '- You are responsible for backing up your data regularly\n'
                  '- You are responsible for all activities that occur under your use of the App\n\n'
                  '3.2 Acceptable Use\n'
                  'You agree not to:\n'
                  '- Use the App for any illegal purpose\n'
                  '- Attempt to reverse engineer, decompile, or disassemble the App\n'
                  '- Interfere with or disrupt the App\'s functionality\n'
                  '- Use automated systems to access the App',
            ),
            _buildSection(
              context,
              '4. Data and Privacy',
              '4.1 Local Storage\n'
                  '- All your data is stored locally on your device\n'
                  '- We do not collect, transmit, or store your personal data on our servers\n'
                  '- You have full control over your data\n\n'
                  '4.2 Backup and Restore\n'
                  '- Backup functionality is optional and stores encrypted data on your device or cloud storage (e.g., Google Drive)\n'
                  '- You are responsible for maintaining the security of your backup passwords\n'
                  '- We are not responsible for lost or corrupted backups\n\n'
                  '4.3 Data Deletion\n'
                  '- You can delete all app data at any time through the App settings\n'
                  '- Uninstalling the App will remove all local data\n'
                  '- We are not responsible for data loss due to device failure, loss, or theft',
            ),
            _buildSection(
              context,
              '5. Intellectual Property',
              '5.1 App Ownership\n'
                  '- The App and its original content, features, and functionality are owned by Life Tracker and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws\n\n'
                  '5.2 User Content\n'
                  '- You retain ownership of all data you create using the App\n'
                  '- By using the App, you grant us a limited license to process your data locally on your device to provide the App\'s functionality',
            ),
            _buildSection(
              context,
              '6. Disclaimers',
              '6.1 No Medical Advice\n'
                  '- The App is not a medical device and does not provide medical advice\n'
                  '- Health-related features (weight tracking, medication reminders) are for informational purposes only\n'
                  '- Always consult with healthcare professionals for medical decisions\n\n'
                  '6.2 No Financial Advice\n'
                  '- The App is not a financial advisor\n'
                  '- Financial tracking features are for personal record-keeping only\n'
                  '- We do not provide investment, tax, or financial advice\n\n'
                  '6.3 Service Availability\n'
                  '- The App is provided "as is" and "as available"\n'
                  '- We do not guarantee that the App will be available at all times or error-free\n'
                  '- We reserve the right to modify, suspend, or discontinue the App at any time',
            ),
            _buildSection(
              context,
              '7. Limitation of Liability',
              'To the maximum extent permitted by law:\n'
                  '- We shall not be liable for any indirect, incidental, special, consequential, or punitive damages\n'
                  '- We shall not be liable for any loss of data, profits, or business opportunities\n'
                  '- Our total liability shall not exceed the amount you paid for the App (if any)',
            ),
            _buildSection(
              context,
              '8. Indemnification',
              'You agree to indemnify and hold harmless Life Tracker and its developers from any claims, damages, losses, liabilities, and expenses (including legal fees) arising from:\n'
                  '- Your use of the App\n'
                  '- Your violation of these Terms\n'
                  '- Your violation of any third-party rights',
            ),
            _buildSection(
              context,
              '9. Modifications to Terms',
              'We reserve the right to modify these Terms at any time. We will notify you of any material changes by:\n'
                  '- Posting the updated Terms in the App\n'
                  '- Updating the "Effective Date" at the top of this document\n\n'
                  'Your continued use of the App after changes constitutes acceptance of the modified Terms.',
            ),
            _buildSection(
              context,
              '10. Termination',
              '10.1 By You\n'
                  '- You may stop using the App at any time\n'
                  '- You may delete the App and all associated data\n\n'
                  '10.2 By Us\n'
                  '- We may terminate or suspend your access to the App at any time, with or without cause or notice\n'
                  '- Upon termination, your right to use the App will immediately cease',
            ),
            _buildSection(
              context,
              '11. Open Source',
              'Life Tracker uses open source software. For information about open source licenses, please see the Licenses section in the App settings.',
            ),
            _buildSection(
              context,
              '12. Governing Law',
              'These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which the App is used, without regard to its conflict of law provisions.',
            ),
            _buildSection(
              context,
              '13. Severability',
              'If any provision of these Terms is found to be unenforceable or invalid, that provision shall be limited or eliminated to the minimum extent necessary, and the remaining provisions shall remain in full force and effect.',
            ),
            _buildSection(
              context,
              '14. Entire Agreement',
              'These Terms constitute the entire agreement between you and Life Tracker regarding the use of the App and supersede all prior agreements and understandings.',
            ),
            _buildSection(
              context,
              '15. Contact Information',
              'If you have any questions about these Terms, please contact us at:\n'
                  '- Email: support@lifetracker.app\n'
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
