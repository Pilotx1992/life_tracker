import 'package:isar/isar.dart';
import 'package:life_tracker/features/notes/data/models/checklist_item_model.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';

part 'note_model.g.dart';

@collection
class NoteModel {
  Id id = Isar.autoIncrement;

  late String title;
  String? content;
  String? encryptedContent; // Encrypted content when note is locked
  late String color; // Hex color code
  List<String> attachmentPaths = []; // File paths to attachments
  String? voiceNotePath; // Path to voice note audio file
  List<ChecklistItemModel> checklistItems = []; // Embedded checklist items
  bool isLocked = false;
  @Index()
  late DateTime createdAt;
  @Index()
  late DateTime updatedAt;

  NoteModel();

  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      encryptedContent: encryptedContent,
      color: color,
      attachmentPaths: attachmentPaths,
      voiceNotePath: voiceNotePath,
      checklistItems: checklistItems.map((item) => item.toEntity()).toList(),
      isLocked: isLocked,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NoteModel.fromEntity(Note entity) {
    final model = NoteModel()
      ..title = entity.title
      ..content = entity.content
      ..encryptedContent = entity.encryptedContent
      ..color = entity.color
      ..attachmentPaths = List<String>.from(entity.attachmentPaths)
      ..voiceNotePath = entity.voiceNotePath
      ..checklistItems = entity.checklistItems
          .map((item) => ChecklistItemModel.fromEntity(item))
          .toList()
      ..isLocked = entity.isLocked
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  NoteModel copyWith({
    Id? id,
    String? title,
    String? content,
    String? encryptedContent,
    String? color,
    List<String>? attachmentPaths,
    String? voiceNotePath,
    List<ChecklistItemModel>? checklistItems,
    bool? isLocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final model = NoteModel()
      ..title = title ?? this.title
      ..content = content ?? this.content
      ..encryptedContent = encryptedContent ?? this.encryptedContent
      ..color = color ?? this.color
      ..attachmentPaths =
          attachmentPaths ?? List<String>.from(this.attachmentPaths)
      ..voiceNotePath = voiceNotePath ?? this.voiceNotePath
      ..checklistItems =
          checklistItems ?? List<ChecklistItemModel>.from(this.checklistItems)
      ..isLocked = isLocked ?? this.isLocked
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
