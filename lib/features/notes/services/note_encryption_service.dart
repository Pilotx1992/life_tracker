import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Service for encrypting and decrypting note content
class NoteEncryptionService {
  static final NoteEncryptionService _instance =
      NoteEncryptionService._internal();
  factory NoteEncryptionService() => _instance;
  NoteEncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  static const String _pinKey = 'note_lock_pin';
  static const String _saltKey = 'note_lock_salt';

  /// Check if a PIN is set
  Future<bool> hasPIN() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
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
}
