import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/providers/ble_provider.dart';
import 'package:life_tracker/core/providers/health_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/shared/widgets/buttons/app_button.dart';
import 'package:intl/intl.dart';

class DeviceSetupScreen extends ConsumerWidget {
  const DeviceSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Integration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Connect Devices',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Sync your weight and health data from smart scales and fitness trackers',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 24),

            // BLE Digital Scales Section
            _buildScaleSection(context, ref),

            const SizedBox(height: 32),

            // Health Connect Section
            _buildHealthConnectSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleSection(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(bleScanProvider);
    final connectionState = ref.watch(bleConnectionProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_weight,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Digital Scale (Bluetooth)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Connection Status
            if (connectionState.isConnected &&
                connectionState.connectedDevice != null)
              Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.primary),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Connected'),
                              Text(
                                connectionState.connectedDevice!.platformName,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(bleConnectionProvider.notifier)
                                .disconnectDevice();
                          },
                          child: const Text('Disconnect'),
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              AppButton(
                text: scanState.isScanning ? 'Scanning...' : 'Scan for Scales',
                onPressed: scanState.isScanning
                    ? null
                    : () => ref.read(bleScanProvider.notifier).startScan(),
                loading: scanState.isScanning,
                icon: Icons.bluetooth_searching,
              ),

            if (scanState.error != null) ...[
              const SizedBox(height: 12),
              _buildErrorMessage(context, scanState.error!),
            ],

            if (connectionState.error != null) ...[
              const SizedBox(height: 12),
              _buildErrorMessage(context, connectionState.error!),
            ],

            if (scanState.scanResults.isNotEmpty &&
                !connectionState.isConnected) ...[
              const SizedBox(height: 16),
              Text(
                'Available Devices',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...scanState.scanResults.map(
                (result) => _buildDeviceCard(context, ref, result),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(bleScanProvider.notifier).stopScan(),
                child: const Text('Stop Scanning'),
              ),
            ],

            // Latest Weight from Scale
            if (connectionState.latestWeight != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.scale),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Latest Measurement'),
                          Text(
                            '${connectionState.latestWeight!.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthConnectSection(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthConnectProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Health Connect',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sync data from your smart watch or fitness apps',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),

            // Authorization Status
            Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                final statusColor = healthState.isAuthorized
                    ? colorScheme.primary
                    : colorScheme.tertiary;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        healthState.isAuthorized
                            ? Icons.check_circle
                            : Icons.warning,
                        color: statusColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          healthState.isAuthorized
                              ? 'Connected to Health Connect'
                              : 'Not connected',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            if (!healthState.isAuthorized)
              AppButton(
                text: 'Connect to Health',
                onPressed: () async {
                  final granted = await ref
                      .read(healthConnectProvider.notifier)
                      .requestPermissions();
                  if (granted && context.mounted) {
                    FeedbackService.showSuccess(
                      context,
                      'Health permissions granted!',
                    );
                  }
                },
                icon: Icons.link,
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: healthState.isSyncing ? 'Syncing...' : 'Sync Now',
                      onPressed: healthState.isSyncing
                          ? null
                          : () async {
                              await ref
                                  .read(healthConnectProvider.notifier)
                                  .syncAllData();
                              if (context.mounted) {
                                FeedbackService.showSuccess(
                                  context,
                                  'Health data synced!',
                                );
                              }
                            },
                      loading: healthState.isSyncing,
                      icon: Icons.sync,
                    ),
                  ),
                ],
              ),
              if (healthState.lastSyncTime != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Last synced: ${DateFormat('MMM dd, yyyy h:mm a').format(healthState.lastSyncTime!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
              if (healthState.weightData.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSyncedDataSummary(
                  context,
                  'Weight',
                  '${healthState.weightData.length} entries',
                  Icons.monitor_weight,
                ),
              ],
              if (healthState.stepsData.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSyncedDataSummary(
                  context,
                  'Steps',
                  '${healthState.stepsData.length} entries',
                  Icons.directions_walk,
                ),
              ],
              if (healthState.heartRateData.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSyncedDataSummary(
                  context,
                  'Heart Rate',
                  '${healthState.heartRateData.length} entries',
                  Icons.favorite,
                ),
              ],
            ],

            if (healthState.error != null) ...[
              const SizedBox(height: 12),
              _buildErrorMessage(context, healthState.error!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    WidgetRef ref,
    ScanResult result,
  ) {
    final device = result.device;
    final hasName = device.platformName.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.bluetooth),
        title: Text(hasName ? device.platformName : 'Unknown Device'),
        subtitle: Text(device.remoteId.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.link),
          onPressed: () {
            ref.read(bleConnectionProvider.notifier).connectToDevice(device);
            ref.read(bleScanProvider.notifier).stopScan();
          },
        ),
      ),
    );
  }

  Widget _buildSyncedDataSummary(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
