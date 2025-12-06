import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/providers/ble_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';

/// Screen for managing connected devices (BLE scales, etc.)
class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    // Check Bluetooth availability on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBluetoothAvailability();
    });
  }

  Future<void> _checkBluetoothAvailability() async {
    final isAvailable = await ref.read(bluetoothAvailabilityProvider.future);
    if (!isAvailable && mounted) {
      FeedbackService.showWarning(
        context,
        'Bluetooth is not available. Please enable Bluetooth.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bleScanState = ref.watch(bleScanProvider);
    final bleConnectionState = ref.watch(bleConnectionProvider);
    final bluetoothAvailable = ref.watch(bluetoothAvailabilityProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Connected Devices'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: bluetoothAvailable.when(
        data: (isAvailable) {
          if (!isAvailable) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bluetooth_disabled,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bluetooth is not available',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enable Bluetooth to connect to devices',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Connected Device Section
              if (bleConnectionState.isConnected &&
                  bleConnectionState.connectedDevice != null)
                _buildConnectedDeviceCard(
                  context,
                  theme,
                  bleConnectionState.connectedDevice!,
                  bleConnectionState.latestWeight,
                ),

              // Scan Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Devices',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (bleScanState.isScanning)
                          Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Scanning...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: bleScanState.isScanning
                                ? () => ref
                                    .read(bleScanProvider.notifier)
                                    .stopScan()
                                : () => ref
                                    .read(bleScanProvider.notifier)
                                    .startScan(),
                            icon: Icon(
                              bleScanState.isScanning
                                  ? Icons.stop
                                  : Icons.search,
                            ),
                            label: Text(
                              bleScanState.isScanning
                                  ? 'Stop Scan'
                                  : 'Scan for Devices',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Scan Results
              Expanded(
                child: bleScanState.scanResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bluetooth_searching,
                              size: 64,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              bleScanState.isScanning
                                  ? 'Searching for devices...'
                                  : 'No devices found. Tap "Scan for Devices" to search.',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        cacheExtent: 500,
                        itemCount: bleScanState.scanResults.length,
                        itemBuilder: (context, index) {
                          final scanResult = bleScanState.scanResults[index];
                          final device = scanResult.device;
                          final isConnected =
                              bleConnectionState.connectedDevice?.remoteId ==
                                  device.remoteId;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                Icons.scale,
                                color: isConnected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                              ),
                              title: Text(
                                device.platformName.isNotEmpty
                                    ? device.platformName
                                    : 'Unknown Device',
                                style: TextStyle(
                                  fontWeight: isConnected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.remoteId.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  if (scanResult.rssi != 0)
                                    Text(
                                      'Signal: ${scanResult.rssi} dBm',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: isConnected
                                  ? FilledButton(
                                      onPressed: () async {
                                        await ref
                                            .read(
                                              bleConnectionProvider.notifier,
                                            )
                                            .disconnectDevice();
                                        if (context.mounted) {
                                          FeedbackService.showSuccess(
                                            context,
                                            'Device disconnected',
                                          );
                                        }
                                      },
                                      child: const Text('Disconnect'),
                                    )
                                  : OutlinedButton(
                                      onPressed: () async {
                                        try {
                                          await ref
                                              .read(
                                                bleConnectionProvider.notifier,
                                              )
                                              .connectToDevice(device);
                                          if (context.mounted) {
                                            FeedbackService.showSuccess(
                                              context,
                                              'Connected to ${device.platformName.isNotEmpty ? device.platformName : "device"}',
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            FeedbackService.showError(
                                              context,
                                              'Failed to connect: $e',
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Connect'),
                                    ),
                            ),
                          );
                        },
                      ),
              ),

              // Error Display
              if (bleScanState.error != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bleScanState.error!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceCard(
    BuildContext context,
    ThemeData theme,
    BluetoothDevice device,
    double? latestWeight,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected Device',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.platformName.isNotEmpty
                          ? device.platformName
                          : 'Unknown Device',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                onPressed: () async {
                  await ref
                      .read(bleConnectionProvider.notifier)
                      .disconnectDevice();
                  if (context.mounted) {
                    FeedbackService.showSuccess(context, 'Device disconnected');
                  }
                },
              ),
            ],
          ),
          if (latestWeight != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monitor_weight,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Latest Weight: ${latestWeight.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
