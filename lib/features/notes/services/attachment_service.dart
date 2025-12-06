import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_tracker/core/utils/file_storage_service.dart';

/// Service for handling note attachments (images, files, voice notes)
class AttachmentService {
  final FileStorageService _fileStorage = FileStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from camera or gallery
  Future<String?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85, // Compress to reduce file size
      );

      if (image != null) {
        final file = File(image.path);
        final savedPath = await _fileStorage.saveFile(file);
        return savedPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Show dialog to choose image source
  Future<String?> pickImageWithSource(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      return await pickImage(source: source);
    }
    return null;
  }

  /// Pick a file (PDF, TXT, DOC, XLS, etc.)
  Future<String?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowedExtensions: null, // Allow all file types
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final savedPath = await _fileStorage.saveFile(file);
        return savedPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Get file name from relative path
  String getFileName(String relativePath) {
    return relativePath.split('/').last;
  }

  /// Get file extension
  String getFileExtension(String relativePath) {
    final fileName = getFileName(relativePath);
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Check if file is an image
  bool isImage(String relativePath) {
    final ext = getFileExtension(relativePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  /// Check if file is audio
  bool isAudio(String relativePath) {
    final ext = getFileExtension(relativePath);
    return ['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(ext);
  }

  /// Delete an attachment
  Future<bool> deleteAttachment(String relativePath) async {
    return await _fileStorage.deleteFile(relativePath);
  }

  /// Delete multiple attachments
  Future<void> deleteAttachments(List<String> relativePaths) async {
    await _fileStorage.deleteFiles(relativePaths);
  }

  /// Get full file path
  Future<String?> getFullPath(String relativePath) async {
    return await _fileStorage.getFullPath(relativePath);
  }

  /// Get File object
  Future<File?> getFile(String relativePath) async {
    return await _fileStorage.getFile(relativePath);
  }
}
