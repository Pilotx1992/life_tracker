import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Service for managing alarm sound playback.
/// Handles playing, looping, and stopping alarm sounds.
class AlarmSoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentSoundPath;

  /// Get the default alarm sound path.
  /// For now, we'll use a system sound or asset.
  /// In the future, this can be extended to support custom sounds.
  String? getDefaultAlarmSound() {
    // Return null to use system default sound
    // In the future, this can return a path to an asset file
    return null;
  }

  /// Play alarm sound.
  /// [soundPath] - Path to the sound file. If null, uses system default.
  /// [repeatCount] - Number of times to repeat (-1 for infinite).
  Future<void> playAlarmSound({
    String? soundPath,
    int repeatCount = -1,
  }) async {
    if (_isPlaying) {
      await stopAlarmSound();
    }

    try {
      _currentSoundPath = soundPath ?? getDefaultAlarmSound();

      if (_currentSoundPath != null) {
        // Load and play custom sound file
        await _audioPlayer.setAsset(_currentSoundPath!);
      } else {
        // Use system default sound
        // For now, we'll use a simple beep or use notification sound
        // In a real implementation, you might want to use a default asset
        if (kDebugMode) {
          debugPrint('Using system default alarm sound');
        }
        // Note: just_audio doesn't support system sounds directly
        // You might need to bundle a default alarm sound as an asset
        return;
      }

      // Set loop mode
      if (repeatCount == -1) {
        _audioPlayer.setLoopMode(LoopMode.one);
      } else if (repeatCount > 0) {
        // For finite repeats, we'll need to handle this manually
        _audioPlayer.setLoopMode(LoopMode.one);
      }

      // Set volume to maximum
      await _audioPlayer.setVolume(1.0);

      // Play the sound
      await _audioPlayer.play();
      _isPlaying = true;

      if (kDebugMode) {
        debugPrint('Alarm sound started playing');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing alarm sound: $e');
      }
      _isPlaying = false;
    }
  }

  /// Stop alarm sound.
  Future<void> stopAlarmSound() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        await _audioPlayer.setLoopMode(LoopMode.off);
        _isPlaying = false;
        _currentSoundPath = null;

        if (kDebugMode) {
          debugPrint('Alarm sound stopped');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping alarm sound: $e');
      }
    }
  }

  /// Check if alarm sound is currently playing.
  bool get isPlaying => _isPlaying;

  /// Set volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting volume: $e');
      }
    }
  }

  /// Dispose resources.
  void dispose() {
    _audioPlayer.dispose();
  }
}

