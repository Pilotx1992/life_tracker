import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service for managing file storage for notes attachments
class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();
  factory FileStorageService() => _instance;
  FileStorageService._internal();

  final _uuid = const Uuid();

  /// Get the app's documents directory for storing attachments
  Future<Directory> getAttachmentsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory(path.join(appDocDir.path, 'attachments'));

    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    return attachmentsDir;
  }

  /// Save a file to the attachments directory with a unique name
  /// Returns the relative path that should be stored in the database
  Future<String> saveFile(File sourceFile, {String? customExtension}) async {
    final attachmentsDir = await getAttachmentsDirectory();
    final extension = customExtension ?? path.extension(sourceFile.path);
    final uniqueFileName = '${_uuid.v4()}$extension';
    final destinationPath = path.join(attachmentsDir.path, uniqueFileName);

    await sourceFile.copy(destinationPath);

    // Return relative path for storage in database
    return path.join('attachments', uniqueFileName);
  }

  /// Get the full file path from a relative path stored in database
  Future<String?> getFullPath(String relativePath) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final fullPath = path.join(appDocDir.path, relativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        return fullPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get File object from relative path
  Future<File?> getFile(String relativePath) async {
    final fullPath = await getFullPath(relativePath);
    if (fullPath != null) {
      final file = File(fullPath);
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  /// Delete a file by its relative path
  Future<bool> deleteFile(String relativePath) async {
    try {
      final file = await getFile(relativePath);
      if (file != null) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete multiple files
  Future<void> deleteFiles(List<String> relativePaths) async {
    for (final path in relativePaths) {
      await deleteFile(path);
    }
  }

  /// Check if a file exists
  Future<bool> fileExists(String relativePath) async {
    final file = await getFile(relativePath);
    return file != null;
  }

  /// Get file size in bytes
  Future<int?> getFileSize(String relativePath) async {
    final file = await getFile(relativePath);
    if (file != null) {
      return await file.length();
    }
    return null;
  }
}
