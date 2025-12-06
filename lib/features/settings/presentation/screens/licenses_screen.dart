import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Screen displaying app licenses and open source attributions
class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key});

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Licenses'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info
          if (_packageInfo != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Life Tracker',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version ${_packageInfo!.version} (Build ${_packageInfo!.buildNumber})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Copyright © 2024',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // App License
          Card(
            child: ExpansionTile(
              title: const Text('App License'),
              subtitle: const Text('MIT License'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'MIT License\n\n'
                    'Copyright (c) 2024 Life Tracker\n\n'
                    'Permission is hereby granted, free of charge, to any person obtaining a copy '
                    'of this software and associated documentation files (the "Software"), to deal '
                    'in the Software without restriction, including without limitation the rights '
                    'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
                    'copies of the Software, and to permit persons to whom the Software is '
                    'furnished to do so, subject to the following conditions:\n\n'
                    'The above copyright notice and this permission notice shall be included in all '
                    'copies or substantial portions of the Software.\n\n'
                    'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
                    'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
                    'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
                    'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
                    'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
                    'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Open Source Licenses
          Card(
            child: ExpansionTile(
              title: const Text('Open Source Licenses'),
              subtitle: const Text('Third-party libraries'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This app uses the following open source packages:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildLicenseItem(
                        context,
                        'Flutter',
                        'BSD-style license',
                        'https://flutter.dev',
                      ),
                      _buildLicenseItem(
                        context,
                        'Riverpod',
                        'MIT License',
                        'https://riverpod.dev',
                      ),
                      _buildLicenseItem(
                        context,
                        'Isar',
                        'Apache License 2.0',
                        'https://isar.dev',
                      ),
                      _buildLicenseItem(
                        context,
                        'GoRouter',
                        'MIT License',
                        'https://pub.dev/packages/go_router',
                      ),
                      _buildLicenseItem(
                        context,
                        'Google Fonts',
                        'SIL Open Font License',
                        'https://fonts.google.com',
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          showLicensePage(
                            context: context,
                            applicationName: 'Life Tracker',
                            applicationVersion:
                                _packageInfo?.version ?? '1.0.0',
                            applicationIcon: const Icon(Icons.info),
                          );
                        },
                        icon: const Icon(Icons.description),
                        label: const Text('View Full License Details'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseItem(
    BuildContext context,
    String name,
    String license,
    String url,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            license,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
