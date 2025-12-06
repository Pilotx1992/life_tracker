import 'dart:io';
import 'package:flutter/material.dart';
import 'package:life_tracker/features/notes/presentation/widgets/audio_player_widget.dart';
import 'package:life_tracker/features/notes/services/attachment_service.dart';

class AttachmentWidget extends StatelessWidget {
  final String attachmentPath;
  final VoidCallback? onDelete;
  final AttachmentService _attachmentService = AttachmentService();

  AttachmentWidget({
    super.key,
    required this.attachmentPath,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = _attachmentService.getFileName(attachmentPath);
    final isImage = _attachmentService.isImage(attachmentPath);
    final isAudio = _attachmentService.isAudio(attachmentPath);

    return FutureBuilder<String?>(
      future: _attachmentService.getFullPath(attachmentPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final fullPath = snapshot.data!;
        final file = File(fullPath);

        if (isImage) {
          return _buildImageAttachment(context, file, fileName);
        } else if (isAudio) {
          return AudioPlayerWidget(
            audioPath: attachmentPath,
            attachmentService: _attachmentService,
            onDelete: onDelete,
          );
        } else {
          return _buildFileAttachment(context, file, fileName);
        }
      },
    );
  }

  Widget _buildImageAttachment(
    BuildContext context,
    File file,
    String fileName,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),
          if (onDelete != null)
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.white),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileAttachment(
    BuildContext context,
    File file,
    String fileName,
  ) {
    final ext = _attachmentService.getFileExtension(attachmentPath);
    final IconData icon = _getFileIcon(ext);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: FutureBuilder<int?>(
          future: _getFileSize(file),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(_formatFileSize(snapshot.data!));
            }
            return const Text('Unknown size');
          },
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: Theme.of(context).colorScheme.error,
              )
            : null,
      ),
    );
  }

  IconData _getFileIcon(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<int?> _getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      return null;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
