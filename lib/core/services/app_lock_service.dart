import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app lock functionality
class AppLockService {
  AppLockService._(); // Private constructor for singleton

  static final AppLockService instance = AppLockService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _pinHashKey = 'app_lock_pin_hash';
  static const String _pinSaltKey = 'app_lock_pin_salt';
  static const String _lockMethodKey =
      'app_lock_method'; // 'pin', 'biometric', 'both'
  static const String _autoLockTimeoutKey = 'app_lock_timeout'; // in seconds
  static const String _lastUnlockTimeKey = 'app_lock_last_unlock';
  static const String _failedAttemptsKey = 'app_lock_failed_attempts';
  static const String _lockoutUntilKey = 'app_lock_lockout_until';

  static const int _maxFailedAttempts = 5;
  static const int _lockoutDurationSeconds = 300; // 5 minutes
  static const int _defaultAutoLockTimeout = 300; // 5 minutes

  /// Generate a hash for the PIN
  Future<String> _hashPin(String pin, String salt) async {
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a random salt
  String _generateSalt() {
    final random = List<int>.generate(
      16,
      (i) => DateTime.now().millisecondsSinceEpoch % 256,
    );
    return base64UrlEncode(random);
  }

  /// Check if app lock is enabled
  Future<bool> isLockEnabled() async {
    final lockMethod = await _secureStorage.read(key: _lockMethodKey);
    return lockMethod != null && lockMethod.isNotEmpty;
  }

  /// Get the current lock method
  Future<String?> getLockMethod() async {
    return await _secureStorage.read(key: _lockMethodKey);
  }

  /// Set up PIN lock
  Future<bool> setupPin(String pin) async {
    if (pin.length < 4) {
      return false;
    }

    try {
      final salt = _generateSalt();
      final hashedPin = await _hashPin(pin, salt);

      await _secureStorage.write(key: _pinHashKey, value: hashedPin);
      await _secureStorage.write(key: _pinSaltKey, value: salt);

      // Set lock method to 'pin' if not already set
      final currentMethod = await getLockMethod();
      if (currentMethod == null) {
        await _secureStorage.write(key: _lockMethodKey, value: 'pin');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting up PIN: $e');
      }
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final storedHash = await _secureStorage.read(key: _pinHashKey);
      final storedSalt = await _secureStorage.read(key: _pinSaltKey);

      if (storedHash == null || storedSalt == null) {
        return false;
      }

      // Check lockout
      if (await _isLockedOut()) {
        return false;
      }

      final providedPinHash = await _hashPin(pin, storedSalt);
      final isValid = storedHash == providedPinHash;

      if (isValid) {
        await _onSuccessfulUnlock();
      } else {
        await _onFailedAttempt();
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verifying PIN: $e');
      }
      return false;
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking biometric availability: $e');
      }
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting available biometrics: $e');
      }
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometric({String? reason}) async {
    try {
      // Check lockout
      if (await _isLockedOut()) {
        return false;
      }

      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to unlock the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await _onSuccessfulUnlock();
      } else {
        await _onFailedAttempt();
      }

      return authenticated;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error authenticating with biometric: $e');
      }
      await _onFailedAttempt();
      return false;
    }
  }

  /// Set lock method
  Future<bool> setLockMethod(String method) async {
    if (!['pin', 'biometric', 'both'].contains(method)) {
      return false;
    }

    try {
      await _secureStorage.write(key: _lockMethodKey, value: method);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting lock method: $e');
      }
      return false;
    }
  }

  /// Get auto-lock timeout (in seconds)
  Future<int> getAutoLockTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_autoLockTimeoutKey) ?? _defaultAutoLockTimeout;
  }

  /// Set auto-lock timeout (in seconds)
  Future<bool> setAutoLockTimeout(int seconds) async {
    if (seconds < 0) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_autoLockTimeoutKey, seconds);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting auto-lock timeout: $e');
      }
      return false;
    }
  }

  /// Check if app should be locked based on timeout
  Future<bool> shouldLock() async {
    if (!await isLockEnabled()) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUnlockTime = prefs.getInt(_lastUnlockTimeKey);

      if (lastUnlockTime == null) {
        return true; // Never unlocked, should lock
      }

      final timeout = await getAutoLockTimeout();
      if (timeout == 0) {
        return false; // Auto-lock disabled
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final elapsed = now - lastUnlockTime;

      return elapsed >= timeout;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking if should lock: $e');
      }
      return true; // On error, lock for security
    }
  }

  /// Record successful unlock
  Future<void> _onSuccessfulUnlock() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await prefs.setInt(_lastUnlockTimeKey, now);
    await prefs.setInt(_failedAttemptsKey, 0);
    await prefs.remove(_lockoutUntilKey);
  }

  /// Handle failed unlock attempt
  Future<void> _onFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final failedAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
    final newFailedAttempts = failedAttempts + 1;

    await prefs.setInt(_failedAttemptsKey, newFailedAttempts);

    if (newFailedAttempts >= _maxFailedAttempts) {
      final lockoutUntil =
          DateTime.now().add(const Duration(seconds: _lockoutDurationSeconds));
      await prefs.setInt(
        _lockoutUntilKey,
        lockoutUntil.millisecondsSinceEpoch ~/ 1000,
      );
    }
  }

  /// Check if currently locked out
  Future<bool> _isLockedOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutUntil = prefs.getInt(_lockoutUntilKey);

      if (lockoutUntil == null) {
        return false;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (now >= lockoutUntil) {
        // Lockout expired, reset
        await prefs.remove(_lockoutUntilKey);
        await prefs.setInt(_failedAttemptsKey, 0);
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking lockout: $e');
      }
      return false;
    }
  }

  /// Get remaining lockout time (in seconds)
  Future<int> getRemainingLockoutTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutUntil = prefs.getInt(_lockoutUntilKey);

      if (lockoutUntil == null) {
        return 0;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final remaining = lockoutUntil - now;

      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get failed attempts count
  Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_failedAttemptsKey) ?? 0;
  }

  /// Disable app lock
  Future<bool> disableLock() async {
    try {
      await _secureStorage.delete(key: _pinHashKey);
      await _secureStorage.delete(key: _pinSaltKey);
      await _secureStorage.delete(key: _lockMethodKey);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUnlockTimeKey);
      await prefs.remove(_failedAttemptsKey);
      await prefs.remove(_lockoutUntilKey);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error disabling lock: $e');
      }
      return false;
    }
  }

  /// Change PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    if (newPin.length < 4) {
      return false;
    }

    // Verify old PIN first
    final isValid = await verifyPin(oldPin);
    if (!isValid) {
      return false;
    }

    // Set up new PIN
    return await setupPin(newPin);
  }

  // ==================== PIN STRENGTH VALIDATION ====================

  /// Check if PIN is weak (sequential or repeating patterns)
  bool isPinWeak(String pin) {
    if (pin.length != 4) return true;

    // Check for sequential (1234, 4321, etc.)
    if (_isSequential(pin)) return true;

    // Check for repeated (1111, 2222, etc.)
    if (_isRepeating(pin)) return true;

    // Check for common patterns
    if (_isCommonPattern(pin)) return true;

    return false;
  }

  /// Check if PIN is sequential (ascending or descending)
  bool _isSequential(String pin) {
    if (!_isNumeric(pin)) return false;
    
    final nums = pin.split('').map(int.parse).toList();

    // Ascending: 1234, 2345, etc.
    bool isAscending = true;
    for (int i = 0; i < nums.length - 1; i++) {
      if (nums[i + 1] != nums[i] + 1) {
        isAscending = false;
        break;
      }
    }

    // Descending: 4321, 5432, etc.
    bool isDescending = true;
    for (int i = 0; i < nums.length - 1; i++) {
      if (nums[i + 1] != nums[i] - 1) {
        isDescending = false;
        break;
      }
    }

    return isAscending || isDescending;
  }

  /// Check if PIN has all same digits (1111, 2222, etc.)
  bool _isRepeating(String pin) {
    return pin.split('').toSet().length == 1;
  }

  /// Check for common weak patterns
  bool _isCommonPattern(String pin) {
    const commonPatterns = [
      '0000', '1111', '2222', '3333', '4444',
      '5555', '6666', '7777', '8888', '9999',
      '1234', '4321', '2580', '0852', '1212',
      '1010', '2020', '1122', '2211', '0123',
      '3210', '9876', '6789', '1357', '2468',
    ];
    return commonPatterns.contains(pin);
  }

  /// Check if string is all numeric
  bool _isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  /// Get PIN strength description
  String getPinStrengthDescription(String pin) {
    if (pin.length != 4) return 'Too short';
    if (_isRepeating(pin)) return 'Very Weak - Repeating digits';
    if (_isSequential(pin)) return 'Weak - Sequential pattern';
    if (_isCommonPattern(pin)) return 'Weak - Common pattern';
    return 'Strong';
  }

  /// Get PIN strength level (0-3)
  /// 0 = Very Weak, 1 = Weak, 2 = Good, 3 = Strong
  int getPinStrengthLevel(String pin) {
    if (pin.length != 4) return 0;
    if (_isRepeating(pin)) return 0;
    if (_isSequential(pin)) return 1;
    if (_isCommonPattern(pin)) return 1;
    return 3;
  }

  // ==================== PUBLIC LOCKOUT STATUS ====================

  /// Check if currently locked out (public version)
  Future<bool> isLockedOut() async {
    return await _isLockedOut();
  }

  /// Get max failed attempts allowed
  int get maxFailedAttempts => _maxFailedAttempts;
}

