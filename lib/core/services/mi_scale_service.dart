import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Data class for stabilized weight readings from Mi Scale
class MiScaleWeightReading {
  final double weight; // in kg
  final bool isStabilized;
  final DateTime timestamp;
  final String? unit; // 'kg' or 'lb'
  final bool hasImpedance;

  MiScaleWeightReading({
    required this.weight,
    required this.isStabilized,
    required this.timestamp,
    this.unit = 'kg',
    this.hasImpedance = false,
  });

  @override
  String toString() =>
      'MiScaleWeightReading(weight: ${weight.toStringAsFixed(1)}kg, stabilized: $isStabilized)';
}

/// Service for connecting to Xiaomi Mi Body Composition Scale and Mi Smart Scale 2.
///
/// Key Features:
/// - Filters for Mi Scale devices by name pattern
/// - Uses Mi Scale proprietary Service UUID (0x181B)
/// - Checks stabilization flag to avoid saving fluctuating readings
/// - Parses Little Endian weight data correctly
///
/// Supported Models:
/// - Mi Body Composition Scale (XMTZC01HM, XMTZC02HM, XMTZC05HM)
/// - Mi Smart Scale 2 (XMTZC04HM)
class MiScaleService {
  static final MiScaleService _instance = MiScaleService._internal();
  factory MiScaleService() => _instance;
  MiScaleService._internal();

  // Mi Scale BLE UUIDs (Proprietary)
  // Note: Different from standard GATT Weight Scale Service (0x181D)!
  static final Guid miScaleServiceUuid =
      Guid("0000181B-0000-1000-8000-00805f9b34fb"); // Body Composition Service
  static final Guid miScaleWeightCharUuid =
      Guid("00002A9C-0000-1000-8000-00805f9b34fb"); // Weight Measurement

  // Device name patterns for Mi Scales
  static const List<String> miScaleNamePatterns = [
    'MI_SCALE',
    'MI SCALE',
    'MIBFS', // Mi Body Fat Scale
    'MIBCS', // Mi Body Composition Scale
    'MI BODY',
    'YUNMAI', // Some rebranded versions
  ];

  BluetoothDevice? _connectedDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;

  // Debounce to avoid saving multiple stabilized readings
  DateTime? _lastStabilizedReading;
  static const Duration _debounceInterval = Duration(seconds: 5);

  final StreamController<MiScaleWeightReading> _weightDataController =
      StreamController<MiScaleWeightReading>.broadcast();
  final StreamController<List<ScanResult>> _scanResultsController =
      StreamController<List<ScanResult>>.broadcast();
  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  /// Stream of STABILIZED weight measurements only
  /// Fluctuating readings are filtered out automatically
  Stream<MiScaleWeightReading> get stabilizedWeightStream =>
      _weightDataController.stream;

  /// Stream of scan results (filtered for Mi Scale devices)
  Stream<List<ScanResult>> get scanResultsStream =>
      _scanResultsController.stream;

  /// Stream of connection state
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

  /// Check if a device is a Mi Scale based on name pattern
  bool isMiScaleDevice(ScanResult result) {
    final deviceName = result.device.platformName.toUpperCase();
    final advertisementName = result.advertisementData.advName.toUpperCase();

    for (final pattern in miScaleNamePatterns) {
      if (deviceName.contains(pattern) || advertisementName.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Start scanning specifically for Mi Scale devices
  Future<void> startScanForMiScale({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final isAvailable = await isBluetoothAvailable();
      if (!isAvailable) {
        throw Exception('Bluetooth is not available or not enabled');
      }

      // Stop any existing scan
      await FlutterBluePlus.stopScan();

      // Listen to scan results and filter for Mi Scales
      FlutterBluePlus.scanResults.listen((scanResults) {
        final miScaleDevices =
            scanResults.where((r) => isMiScaleDevice(r)).toList();
        _scanResultsController.add(miScaleDevices);
      });

      // Start scanning with service filter for Mi Scale
      await FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: [miScaleServiceUuid], // Filter by Mi Scale service
        androidUsesFineLocation: true,
      );
    } catch (e) {
      throw Exception('Failed to start scan for Mi Scale: $e');
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      // Ignore errors when stopping scan
    }
  }

  /// Connect to a Mi Scale device
  Future<void> connectToMiScale(BluetoothDevice device) async {
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

      // Connect to device with timeout
      await device.connect(timeout: const Duration(seconds: 10));

      // Discover services
      final services = await device.discoverServices();

      // Find Mi Scale service
      for (final service in services) {
        if (service.uuid == miScaleServiceUuid) {
          // Find weight measurement characteristic
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid == miScaleWeightCharUuid) {
              // Subscribe to notifications
              await characteristic.setNotifyValue(true);

              _characteristicSubscription =
                  characteristic.lastValueStream.listen((value) {
                final reading = _parseMiScaleData(value);

                // ⚠️ CRITICAL: Only emit STABILIZED readings
                if (reading != null && reading.isStabilized) {
                  // Debounce to avoid duplicates
                  if (_lastStabilizedReading == null ||
                      DateTime.now().difference(_lastStabilizedReading!) >
                          _debounceInterval) {
                    _lastStabilizedReading = DateTime.now();
                    _weightDataController.add(reading);
                  }
                }
              });
            }
          }
        }
      }
    } catch (e) {
      await disconnectDevice();
      throw Exception('Failed to connect to Mi Scale: $e');
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

  /// Parse Mi Scale data with proper stabilization check
  ///
  /// Mi Scale Data Format (Little Endian):
  ///
  /// Byte 0: Control Flags
  ///   - Bit 0: Unit (0 = SI/kg, 1 = Imperial/lb or catty)
  ///   - Bit 1: Has impedance data
  ///   - Bit 4: Weight stabilized
  ///   - Bit 5: Weight removed (measurement complete)
  ///   - Bit 6: Impedance stabilized
  ///
  /// Bytes 1-2: Year (Little Endian)
  /// Byte 3: Month
  /// Byte 4: Day
  /// Byte 5: Hour
  /// Byte 6: Minute
  /// Byte 7: Second
  ///
  /// Bytes 8-9: Impedance (Little Endian, if present)
  ///
  /// Bytes 10-11 (or 8-9 if no impedance): Weight * 200 (Little Endian)
  ///
  /// For Mi Scale 2 (simpler format):
  /// Byte 0: Control
  /// Bytes 1-2: Weight * 200 (Little Endian)
  MiScaleWeightReading? _parseMiScaleData(List<int> data) {
    try {
      if (data.isEmpty || data.length < 3) return null;

      final controlByte = data[0];

      // Parse unit
      final isImperial = (controlByte & 0x01) != 0;
      final unit = isImperial ? 'lb' : 'kg';

      // Check impedance flag
      final hasImpedance = (controlByte & 0x02) != 0;

      // ⚠️ CRITICAL: Check stabilization flags
      // Bit 4 (0x10): Weight measuring in progress (NOT stabilized)
      // Bit 5 (0x20): Weight stabilized and removed (FINAL reading)
      final isStabilized = (controlByte & 0x20) != 0;
      final isMeasuring = (controlByte & 0x10) != 0;

      // Only accept stabilized readings
      // Ignore measurements in progress (fluctuating values)
      if (isMeasuring && !isStabilized) {
        return null; // Still fluctuating - ignore
      }

      // Parse weight based on data format
      int weightRaw;

      if (data.length >= 13 && hasImpedance) {
        // Full Mi Body Composition Scale format with timestamp
        // Weight is at bytes 10-11 (after timestamp and impedance)
        weightRaw = data[10] | (data[11] << 8);
      } else if (data.length >= 11) {
        // Format with timestamp but no impedance
        weightRaw = data[8] | (data[9] << 8);
      } else if (data.length >= 3) {
        // Simple Mi Scale 2 format (just control + weight)
        weightRaw = data[1] | (data[2] << 8);
      } else {
        return null;
      }

      // Convert to kg (scale factor is 200)
      double weight = weightRaw / 200.0;

      // Convert from lb to kg if needed
      if (isImperial) {
        weight = weight * 0.453592;
      }

      // Validate weight range (reasonable human weight: 20-300 kg)
      if (weight < 20 || weight > 300) {
        return null; // Invalid reading
      }

      return MiScaleWeightReading(
        weight: weight,
        isStabilized: isStabilized,
        timestamp: DateTime.now(),
        unit: unit,
        hasImpedance: hasImpedance,
      );
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
    _lastStabilizedReading = null;
  }

  /// Dispose all resources
  void dispose() {
    _cleanup();
    _weightDataController.close();
    _scanResultsController.close();
    _connectionStateController.close();
  }
}

/// Provider for Mi Scale Service
final miScaleServiceProvider = Provider<MiScaleService>((ref) {
  final service = MiScaleService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for Mi Scale scan state
final miScaleScanProvider = StreamProvider<List<ScanResult>>((ref) {
  final service = ref.watch(miScaleServiceProvider);
  return service.scanResultsStream;
});

/// Provider for stabilized weight readings from Mi Scale
final miScaleWeightProvider = StreamProvider<MiScaleWeightReading>((ref) {
  final service = ref.watch(miScaleServiceProvider);
  return service.stabilizedWeightStream;
});

/// Provider for Mi Scale connection state
final miScaleConnectionProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(miScaleServiceProvider);
  return service.connectionStateStream;
});
