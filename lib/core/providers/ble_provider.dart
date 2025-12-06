import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/services/ble_service.dart';

/// State for BLE scanning
class BleScanState {
  final bool isScanning;
  final List<ScanResult> scanResults;
  final String? error;

  BleScanState({
    this.isScanning = false,
    this.scanResults = const [],
    this.error,
  });

  BleScanState copyWith({
    bool? isScanning,
    List<ScanResult>? scanResults,
    String? error,
  }) {
    return BleScanState(
      isScanning: isScanning ?? this.isScanning,
      scanResults: scanResults ?? this.scanResults,
      error: error ?? this.error,
    );
  }
}

/// State for BLE connection
class BleConnectionState {
  final BluetoothDevice? connectedDevice;
  final bool isConnected;
  final double? latestWeight;
  final String? error;

  BleConnectionState({
    this.connectedDevice,
    this.isConnected = false,
    this.latestWeight,
    this.error,
  });

  BleConnectionState copyWith({
    BluetoothDevice? connectedDevice,
    bool? isConnected,
    double? latestWeight,
    String? error,
  }) {
    return BleConnectionState(
      connectedDevice: connectedDevice ?? this.connectedDevice,
      isConnected: isConnected ?? this.isConnected,
      latestWeight: latestWeight ?? this.latestWeight,
      error: error ?? this.error,
    );
  }
}

/// Notifier for BLE scanning
class BleScanNotifier extends StateNotifier<BleScanState> {
  final BleService _bleService;

  BleScanNotifier(this._bleService) : super(BleScanState()) {
    _bleService.scanResultsStream.listen((results) {
      state = state.copyWith(
        scanResults: results,
        error: null,
      );
    });
  }

  Future<void> startScan() async {
    try {
      state = state.copyWith(isScanning: true, error: null);
      await _bleService.startScan();
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: e.toString(),
      );
    }
  }

  Future<void> stopScan() async {
    await _bleService.stopScan();
    state = state.copyWith(isScanning: false);
  }
}

/// Notifier for BLE connection
class BleConnectionNotifier extends StateNotifier<BleConnectionState> {
  final BleService _bleService;

  BleConnectionNotifier(this._bleService) : super(BleConnectionState()) {
    _bleService.connectionStateStream.listen((isConnected) {
      state = state.copyWith(isConnected: isConnected);
    });

    _bleService.weightDataStream.listen((weight) {
      state = state.copyWith(latestWeight: weight);
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      state = state.copyWith(error: null);
      await _bleService.connectToDevice(device);
      state = state.copyWith(connectedDevice: device);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> disconnectDevice() async {
    await _bleService.disconnectDevice();
    state = BleConnectionState();
  }
}

/// Provider for BLE scan state
final bleScanProvider =
    StateNotifierProvider<BleScanNotifier, BleScanState>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return BleScanNotifier(bleService);
});

/// Provider for BLE connection state
final bleConnectionProvider =
    StateNotifierProvider<BleConnectionNotifier, BleConnectionState>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return BleConnectionNotifier(bleService);
});

/// Provider to check if Bluetooth is available
final bluetoothAvailabilityProvider = FutureProvider<bool>((ref) async {
  final bleService = ref.watch(bleServiceProvider);
  return await bleService.isBluetoothAvailable();
});
