import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Service for encrypting and decrypting note content
class NoteEncryptionService {
  static final NoteEncryptionService _instance =
      NoteEncryptionService._internal();
  factory NoteEncryptionService() => _instance;
  NoteEncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  static const String _pinKey = 'note_lock_pin';
  static const String _saltKey = 'note_lock_salt';
  static const String _biometricEnabledKey = 'note_biometric_enabled';
  static const String _storedPinForBiometricKey = 'note_stored_pin';

  /// Check if a PIN is set
  Future<bool> hasPIN() async {
    final pin = await _secureStorage.read(key: _pinKey);
    final result = pin != null && pin.isNotEmpty;
    if (kDebugMode) {
      debugPrint('🔐 NoteEncryptionService.hasPIN() = $result (pin exists: ${pin != null})');
    }
    return result;
  }

  /// Clear stored PIN (for debugging/reset)
  Future<void> clearPIN() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _saltKey);
    if (kDebugMode) {
      debugPrint('🗑️ NoteEncryptionService: PIN cleared');
    }
  }

  /// Set or update the PIN for note locking
  Future<bool> setPIN(String pin) async {
    try {
      if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
        return false;
      }

      // Generate a salt
      final salt = _generateSalt();
      await _secureStorage.write(key: _saltKey, value: salt);

      // Hash the PIN with salt
      final hashedPIN = _hashPIN(pin, salt);
      await _secureStorage.write(key: _pinKey, value: hashedPIN);

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error setting PIN: $e');
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPIN(String pin) async {
    try {
      final storedHash = await _secureStorage.read(key: _pinKey);
      final salt = await _secureStorage.read(key: _saltKey);

      if (storedHash == null || salt == null) {
        return false;
      }

      final hashedPIN = _hashPIN(pin, salt);
      return hashedPIN == storedHash;
    } catch (e) {
      if (kDebugMode) debugPrint('Error verifying PIN: $e');
      return false;
    }
  }

  /// Generate encryption key from PIN
  Future<String?> _getEncryptionKey(String pin) async {
    try {
      final salt = await _secureStorage.read(key: _saltKey);
      if (salt == null) return null;

      // Use PIN + salt to generate a key
      final keyMaterial = '$pin$salt';
      final bytes = utf8.encode(keyMaterial);
      final hash = sha256.convert(bytes);
      return hash.toString();
    } catch (e) {
      if (kDebugMode) debugPrint('Error generating encryption key: $e');
      return null;
    }
  }

  /// Encrypt note content
  Future<String?> encryptContent(String content, String pin) async {
    try {
      final key = await _getEncryptionKey(pin);
      if (key == null) return null;

      // Simple XOR encryption (for MVP - can be enhanced with AES later)
      final keyBytes = utf8.encode(key.substring(0, 32));
      final contentBytes = utf8.encode(content);
      final encrypted = <int>[];

      for (var i = 0; i < contentBytes.length; i++) {
        encrypted.add(contentBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64Encode(encrypted);
    } catch (e) {
      if (kDebugMode) debugPrint('Error encrypting content: $e');
      return null;
    }
  }

  /// Decrypt note content
  Future<String?> decryptContent(String encryptedContent, String pin) async {
    try {
      final key = await _getEncryptionKey(pin);
      if (key == null) return null;

      final encryptedBytes = base64Decode(encryptedContent);
      final keyBytes = utf8.encode(key.substring(0, 32));
      final decrypted = <int>[];

      for (var i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      if (kDebugMode) debugPrint('Error decrypting content: $e');
      return null;
    }
  }

  String _generateSalt() {
    final random = List<int>.generate(
      16,
      (i) => DateTime.now().millisecondsSinceEpoch % 256,
    );
    return base64Encode(random);
  }

  String _hashPIN(String pin, String salt) {
    final bytes = utf8.encode('$pin$salt');
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // ==================== BIOMETRIC AUTHENTICATION ====================

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if biometric is enabled for notes
  Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// Enable biometric authentication for notes
  /// Stores the PIN securely to use after biometric verification
  Future<bool> enableBiometric(String pin) async {
    try {
      // First verify the PIN is correct
      final isValid = await verifyPIN(pin);
      if (!isValid) {
        if (kDebugMode) debugPrint('❌ Cannot enable biometric: Invalid PIN');
        return false;
      }

      // Store the PIN for later retrieval after biometric auth
      await _secureStorage.write(key: _storedPinForBiometricKey, value: pin);
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      
      if (kDebugMode) debugPrint('✅ Biometric enabled for notes');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error enabling biometric: $e');
      return false;
    }
  }

  /// Disable biometric authentication for notes
  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: _biometricEnabledKey);
    await _secureStorage.delete(key: _storedPinForBiometricKey);
    if (kDebugMode) debugPrint('🗑️ Biometric disabled for notes');
  }

  /// Authenticate using biometric and return the stored PIN if successful
  /// Returns null if authentication fails or biometric is not enabled
  Future<String?> authenticateWithBiometric({
    String reason = 'Authenticate to unlock note',
  }) async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        if (kDebugMode) debugPrint('⚠️ Biometric not enabled for notes');
        return null;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Return the stored PIN for decryption
        final storedPin = await _secureStorage.read(key: _storedPinForBiometricKey);
        if (kDebugMode) debugPrint('✅ Biometric authenticated, PIN retrieved');
        return storedPin;
      } else {
        if (kDebugMode) debugPrint('❌ Biometric authentication failed');
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error during biometric auth: $e');
      return null;
    }
  }
}

