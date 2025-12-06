import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for managing Bluetooth Low Energy connections to digital scales.
///
/// Supports standard GATT Weight Scale Service (UUID: 0x181D)
/// Weight Measurement Characteristic (UUID: 0x2A9D)
class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // GATT Service and Characteristic UUIDs
  static final Guid weightScaleServiceUuid =
      Guid("0000181D-0000-1000-8000-00805f9b34fb");
  static final Guid weightMeasurementCharUuid =
      Guid("00002A9D-0000-1000-8000-00805f9b34fb");

  BluetoothDevice? _connectedDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;

  final StreamController<double> _weightDataController =
      StreamController<double>.broadcast();
  final StreamController<List<ScanResult>> _scanResultsController =
      StreamController<List<ScanResult>>.broadcast();
  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  /// Stream of weight measurements in kilograms
  Stream<double> get weightDataStream => _weightDataController.stream;

  /// Stream of scan results
  Stream<List<ScanResult>> get scanResultsStream =>
      _scanResultsController.stream;

  /// Stream of connection state (true = connected, false = disconnected)
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  /// Check if Bluetooth is available and enabled
  Future<bool> isBluetoothAvailable() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      return false;
    }
  }

  /// Start scanning for BLE devices
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final isAvailable = await isBluetoothAvailable();
      if (!isAvailable) {
        throw Exception('Bluetooth is not available or not enabled');
      }

      // Stop any existing scan
      await FlutterBluePlus.stopScan();

      final List<ScanResult> results = [];

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((scanResults) {
        results.clear();
        results.addAll(scanResults);
        _scanResultsController.add(List.from(results));
      });

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );
    } catch (e) {
      throw Exception('Failed to start scan: $e');
    }
  }

  /// Stop scanning for BLE devices
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      // Ignore errors when stopping scan
    }
  }

  /// Connect to a BLE device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Disconnect from any existing device
      await disconnectDevice();

      _connectedDevice = device;

      // Listen to connection state
      _connectionSubscription = device.connectionState.listen((state) {
        _connectionStateController
            .add(state == BluetoothConnectionState.connected);

        if (state == BluetoothConnectionState.disconnected) {
          _cleanup();
        }
      });

      // Connect to device
      await device.connect(timeout: const Duration(seconds: 15));

      // Discover services
      final services = await device.discoverServices();

      // Find weight scale service
      for (final service in services) {
        if (service.uuid == weightScaleServiceUuid) {
          // Find weight measurement characteristic
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid == weightMeasurementCharUuid) {
              // Subscribe to notifications
              await characteristic.setNotifyValue(true);

              _characteristicSubscription =
                  characteristic.lastValueStream.listen((value) {
                final weight = _parseWeightMeasurement(value);
                if (weight != null) {
                  _weightDataController.add(weight);
                }
              });
            }
          }
        }
      }
    } catch (e) {
      await disconnectDevice();
      throw Exception('Failed to connect to device: $e');
    }
  }

  /// Disconnect from the currently connected device
  Future<void> disconnectDevice() async {
    try {
      await _connectedDevice?.disconnect();
      _cleanup();
    } catch (e) {
      // Ignore errors when disconnecting
    }
  }

  /// Get the currently connected device
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Check if a device is currently connected
  bool get isConnected => _connectedDevice != null;

  /// Parse weight measurement data from GATT characteristic
  ///
  /// Weight Measurement Characteristic Format:
  /// Byte 0: Flags
  ///   Bit 0: Weight in SI (0 = kg, 1 = lb)
  ///   Bit 1: Timestamp present
  ///   Bit 2: User ID present
  ///   Bit 3: BMI and Height present
  /// Bytes 1-2: Weight (uint16, resolution 0.005 kg or 0.01 lb)
  double? _parseWeightMeasurement(List<int> data) {
    try {
      if (data.isEmpty) return null;

      final flags = data[0];
      final isImperial = (flags & 0x01) != 0;

      if (data.length < 3) return null;

      // Parse weight (little-endian uint16)
      final weightRaw = data[1] | (data[2] << 8);

      // Convert to kg (resolution is 0.005 kg or 0.01 lb)
      double weight;
      if (isImperial) {
        final pounds = weightRaw * 0.01;
        weight = pounds * 0.453592; // Convert to kg
      } else {
        weight = weightRaw * 0.005;
      }

      return weight;
    } catch (e) {
      return null;
    }
  }

  void _cleanup() {
    _connectedDevice = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
  }

  /// Dispose all resources
  void dispose() {
    _cleanup();
    _weightDataController.close();
    _scanResultsController.close();
    _connectionStateController.close();
  }
}

/// Provider for BLE Service
final bleServiceProvider = Provider<BleService>((ref) {
  final service = BleService();
  ref.onDispose(() => service.dispose());
  return service;
});
