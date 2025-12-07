import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:life_tracker/core/utils/file_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Recording state enum
enum RecordingState {
  idle,
  recording,
  recorded, // Recording finished, waiting for name input
}

/// A beautiful voice recorder widget with modern UI
class VoiceRecorderWidget extends StatefulWidget {
  final Function(String recordingPath, String? recordingName)
      onRecordingComplete;
  final VoidCallback? onCancel;

  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.onCancel,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with TickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  bool _isRecorderInitialized = false;
  bool _hasPermission = false;
  bool _isDisposing = false;
  bool _isInitializing = false;
  RecordingState _recordingState = RecordingState.idle;
  String? _tempRecordingPath;
  Timer? _timer;
  int _recordDuration = 0;
  int _finalDuration = 0;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Waveform data
  final List<double> _waveformData = List.generate(40, (index) => 0.1);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    // Add delay to ensure any previous recorder is fully closed
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposing) {
        _initRecorder();
      }
    });
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initRecorder() async {
    if (_isInitializing || _isDisposing) return;
    
    _isInitializing = true;
    
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted && !_isDisposing) {
          setState(() {
            _hasPermission = false;
            _isRecorderInitialized = true;
            _isInitializing = false;
          });
        }
        return;
      }

      if (mounted && !_isDisposing) {
        setState(() {
          _hasPermission = true;
        });
      }

      await _recorder.openRecorder();
      
      if (mounted && !_isDisposing) {
        setState(() {
          _isRecorderInitialized = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error opening recorder: $e');
      if (mounted && !_isDisposing) {
        setState(() {
          _isRecorderInitialized = true;
          _hasPermission = false;
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    _timer?.cancel();
    _pulseController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    
    // Close recorder safely
    if (_isRecorderInitialized) {
      _closeRecorderSafely();
    }
    
    super.dispose();
  }
  
  Future<void> _closeRecorderSafely() async {
    try {
      // Stop recording if still recording
      if (_recordingState == RecordingState.recording) {
        await _recorder.stopRecorder().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            if (kDebugMode) debugPrint('Timeout stopping recorder');
            return null;
          },
        ).catchError((e) {
          if (kDebugMode) debugPrint('Error stopping recorder: $e');
          return null;
        });
      }
      
      // Close recorder
      await _recorder.closeRecorder().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
            if (kDebugMode) debugPrint('Timeout closing recorder');
          return null;
        },
      ).catchError((e) {
        if (kDebugMode) debugPrint('Error closing recorder: $e');
        return null;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error in _closeRecorderSafely: $e');
    }
  }

  void _updateWaveform() {
    if (_recordingState != RecordingState.recording) return;
    setState(() {
      for (int i = _waveformData.length - 1; i > 0; i--) {
        _waveformData[i] = _waveformData[i - 1];
      }
      _waveformData[0] = 0.2 + _random.nextDouble() * 0.8;
    });
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized || !_hasPermission || _isDisposing) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _tempRecordingPath = '${tempDir.path}/voice_note_$timestamp.aac';

      await _recorder.startRecorder(
        toFile: _tempRecordingPath,
        codec: Codec.aacADTS,
      );

      if (mounted && !_isDisposing) {
        setState(() {
          _recordingState = RecordingState.recording;
          _recordDuration = 0;
        });

        _pulseController.repeat(reverse: true);

        _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (_isDisposing || !mounted) {
            timer.cancel();
            return;
          }
          if (timer.tick % 10 == 0) {
            setState(() {
              _recordDuration++;
            });
          }
          _updateWaveform();
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error starting recording: $e');
      if (mounted && !_isDisposing) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecorderInitialized || _isDisposing) return;

    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
      await _recorder.stopRecorder();

      if (mounted && !_isDisposing) {
        setState(() {
          _recordingState = RecordingState.recorded;
          _finalDuration = _recordDuration;
          // Generate default name
          _nameController.text =
              'Voice Note ${DateTime.now().day}/${DateTime.now().month}';
        });

        // Focus the name field
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_isDisposing) {
            _nameFocusNode.requestFocus();
            _nameController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _nameController.text.length,
            );
          }
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error stopping recording: $e');
      if (mounted && !_isDisposing) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveRecording() async {
    if (_tempRecordingPath == null) return;

    try {
      final file = File(_tempRecordingPath!);
      final fileStorage = FileStorageService();
      final savedPath = await fileStorage.saveFile(file);
      await file.delete();

      final recordingName = _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim();

      widget.onRecordingComplete(savedPath, recordingName);
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save recording: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _discardRecording() async {
    // Delete temp file
    if (_tempRecordingPath != null) {
      final file = File(_tempRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    setState(() {
      _recordingState = RecordingState.idle;
      _recordDuration = 0;
      _nameController.clear();
      // Reset waveform
      for (int i = 0; i < _waveformData.length; i++) {
        _waveformData[i] = 0.1;
      }
    });
  }

  Future<void> _cancelRecording() async {
    if (_isDisposing) return;
    
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    // Stop recording if still recording
    if (_recordingState == RecordingState.recording && _isRecorderInitialized) {
      try {
        await _recorder.stopRecorder().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            if (kDebugMode) debugPrint('Timeout stopping recorder in cancel');
            return null;
          },
        ).catchError((e) {
          if (kDebugMode) debugPrint('Error stopping recorder in cancel: $e');
          return null;
        });
      } catch (e) {
        if (kDebugMode) debugPrint('Error stopping recorder: $e');
      }
    }

    // Delete temp file if exists
    if (_tempRecordingPath != null) {
      try {
        final file = File(_tempRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Error deleting temp file: $e');
      }
    }

    if (mounted && !_isDisposing) {
      setState(() {
        _recordingState = RecordingState.idle;
        _recordDuration = 0;
        _nameController.clear();
        for (int i = 0; i < _waveformData.length; i++) {
          _waveformData[i] = 0.1;
        }
        _tempRecordingPath = null;
      });
    }

    // Call onCancel after cleanup
    widget.onCancel?.call();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Permission denied state
    if (!_hasPermission && _isRecorderInitialized) {
      return _buildPermissionDenied(context, colorScheme);
    }

    // Loading state
    if (!_isRecorderInitialized) {
      return _buildLoading(context, colorScheme);
    }

    // Show naming UI after recording
    if (_recordingState == RecordingState.recorded) {
      return _buildNamingUI(context, colorScheme);
    }

    // Recording UI
    return _buildRecordingUI(context, colorScheme);
  }

  Widget _buildRecordingUI(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRecording = _recordingState == RecordingState.recording;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surface,
                  colorScheme.surface.withValues(alpha: 0.95),
                ]
              : [
                  colorScheme.surface,
                  colorScheme.primaryContainer.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          _buildMicrophoneButton(colorScheme, isRecording),
          const SizedBox(height: 24),
          _buildWaveform(colorScheme, isRecording),
          const SizedBox(height: 20),
          _buildDurationDisplay(context, colorScheme, isRecording),
          const SizedBox(height: 8),
          Text(
            isRecording ? 'Recording...' : 'Tap to start recording',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 24),
          _buildRecordingButtons(context, colorScheme, isRecording),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNamingUI(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.primaryContainer.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),

          // Success icon with checkmark
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.tertiary,
                  colorScheme.tertiary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.tertiary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // Recording complete text
          Text(
            'Recording Complete!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          // Duration badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(_finalDuration),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Name input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recording Name',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Enter a name for your recording',
                    prefixIcon: Icon(
                      Icons.mic_rounded,
                      color: colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveRecording(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Discard button
                Expanded(
                  child: TextButton.icon(
                    onPressed: _discardRecording,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      'Discard',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Save button
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _saveRecording,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: const Text(
                      'Save Recording',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMicrophoneButton(ColorScheme colorScheme, bool isRecording) {
    return GestureDetector(
      onTap: isRecording ? _stopRecording : _startRecording,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isRecording
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.error,
                          colorScheme.error.withValues(alpha: 0.8),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isRecording ? colorScheme.error : colorScheme.primary)
                            .withValues(alpha: 0.4),
                    blurRadius: isRecording ? 30 : 20,
                    spreadRadius: isRecording ? 5 : 2,
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaveform(ColorScheme colorScheme, bool isRecording) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_waveformData.length, (index) {
          final height = _waveformData[index] * 50;
          final isCenter = index >= 15 && index <= 24;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 4,
            height: max(4, height),
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isRecording
                    ? [
                        colorScheme.error
                            .withValues(alpha: isCenter ? 1.0 : 0.6),
                        colorScheme.error
                            .withValues(alpha: isCenter ? 0.8 : 0.4),
                      ]
                    : [
                        colorScheme.primary.withValues(alpha: 0.3),
                        colorScheme.primary.withValues(alpha: 0.1),
                      ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDurationDisplay(
    BuildContext context,
    ColorScheme colorScheme,
    bool isRecording,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isRecording
              ? colorScheme.error.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRecording)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.error,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.error.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          Text(
            _formatDuration(_recordDuration),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isRecording ? colorScheme.error : colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingButtons(
    BuildContext context,
    ColorScheme colorScheme,
    bool isRecording,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _cancelRecording,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isRecording ? _stopRecording : _startRecording,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor:
                    isRecording ? colorScheme.error : colorScheme.primary,
                foregroundColor:
                    isRecording ? colorScheme.onError : colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRecording
                        ? Icons.stop_rounded
                        : Icons.fiber_manual_record_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRecording ? 'Stop Recording' : 'Start Recording',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.errorContainer,
            ),
            child: Icon(
              Icons.mic_off_rounded,
              size: 48,
              color: colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Microphone Access Required',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'To record voice notes, please allow microphone access in your device settings.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _cancelRecording(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => openAppSettings(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.settings_rounded, size: 20),
                  label: const Text('Open Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Initializing recorder...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

/// Result of voice recording containing the path and optional name
typedef VoiceRecordingResult = ({String path, String? name});

/// Shows a bottom sheet with the voice recorder
/// Returns a [VoiceRecordingResult] with path and optional name, or null if cancelled
Future<VoiceRecordingResult?> showVoiceRecorderSheet(
  BuildContext context,
) async {
  VoiceRecordingResult? result;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Give more time for recorder to close properly
        await Future.delayed(const Duration(milliseconds: 300));
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Voice Note',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),

                // Voice recorder widget
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: VoiceRecorderWidget(
                    onRecordingComplete: (path, name) {
                      result = (path: path, name: name);
                      Navigator.of(context).pop();
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    ),
  );

  return result;
}
