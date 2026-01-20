import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/features/notes/domain/entities/checklist_item.dart';

class Note extends Equatable {
  final Id? id;
  final String title;
  final String? content;
  final String color; // Hex color code
  final List<String> attachmentPaths; // File paths to attachments
  final String? voiceNotePath; // Path to voice note audio file
  final String? voiceNoteName; // Custom name for voice note
  final List<ChecklistItem> checklistItems; // Checklist items
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    this.id,
    required this.title,
    this.content,
    required this.color,
    this.attachmentPaths = const [],
    this.voiceNotePath,
    this.voiceNoteName,
    this.checklistItems = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the note has a checklist
  bool get hasChecklist => checklistItems.isNotEmpty;

  /// Progress of checklist (0.0 to 1.0)
  double get checklistProgress {
    if (!hasChecklist) return 0.0;
    final checkedCount = checklistItems.where((item) => item.isChecked).length;
    return checkedCount / checklistItems.length;
  }

  /// Whether all checklist items are checked
  bool get isChecklistComplete => hasChecklist && checklistProgress == 1.0;

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        color,
        attachmentPaths,
        voiceNotePath,
        voiceNoteName,
        checklistItems,
        createdAt,
        updatedAt,
      ];

  Note copyWith({
    Id? id,
    String? title,
    String? content,
    String? color,
    List<String>? attachmentPaths,
    String? voiceNotePath,
    String? voiceNoteName,
    List<ChecklistItem>? checklistItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      voiceNoteName: voiceNoteName ?? this.voiceNoteName,
      checklistItems: checklistItems ?? this.checklistItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
