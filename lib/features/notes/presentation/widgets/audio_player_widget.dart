import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:life_tracker/features/notes/services/attachment_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final AttachmentService attachmentService;
  final VoidCallback? onDelete;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    required this.attachmentService,
    this.onDelete,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    // Get full path and set source
    final fullPath =
        await widget.attachmentService.getFullPath(widget.audioPath);
    if (fullPath != null) {
      await _audioPlayer.setSource(DeviceFileSource(fullPath));
      final duration = await _audioPlayer.getDuration();
      if (duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      setState(() {
        _isLoading = true;
      });
      await _audioPlayer.resume();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.1),
              child: Icon(
                Icons.mic,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            title: Text(widget.attachmentService.getFileName(widget.audioPath)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onDelete,
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
          ),
          // Progress bar
          if (_duration.inSeconds > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Slider(
                    value: _position.inSeconds
                        .toDouble()
                        .clamp(0.0, _duration.inSeconds.toDouble()),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _seek(Duration(seconds: value.toInt()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
