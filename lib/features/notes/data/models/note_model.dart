import 'package:isar/isar.dart';
import 'package:life_tracker/features/notes/data/models/checklist_item_model.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';

part 'note_model.g.dart';

@collection
class NoteModel {
  Id id = Isar.autoIncrement;

  late String title;
  String? content;
  late String color; // Hex color code
  List<String> attachmentPaths = []; // File paths to attachments
  String? voiceNotePath; // Path to voice note audio file
  String? voiceNoteName; // Custom name for voice note
  List<ChecklistItemModel> checklistItems = []; // Embedded checklist items
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
      color: color,
      attachmentPaths: attachmentPaths,
      voiceNotePath: voiceNotePath,
      voiceNoteName: voiceNoteName,
      checklistItems: checklistItems.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NoteModel.fromEntity(Note entity) {
    final model = NoteModel()
      ..title = entity.title
      ..content = entity.content
      ..color = entity.color
      ..attachmentPaths = List<String>.from(entity.attachmentPaths)
      ..voiceNotePath = entity.voiceNotePath
      ..voiceNoteName = entity.voiceNoteName
      ..checklistItems = entity.checklistItems
          .map((item) => ChecklistItemModel.fromEntity(item))
          .toList()
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
    String? color,
    List<String>? attachmentPaths,
    String? voiceNotePath,
    String? voiceNoteName,
    List<ChecklistItemModel>? checklistItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final model = NoteModel()
      ..title = title ?? this.title
      ..content = content ?? this.content
      ..color = color ?? this.color
      ..attachmentPaths =
          attachmentPaths ?? List<String>.from(this.attachmentPaths)
      ..voiceNotePath = voiceNotePath ?? this.voiceNotePath
      ..voiceNoteName = voiceNoteName ?? this.voiceNoteName
      ..checklistItems =
          checklistItems ?? List<ChecklistItemModel>.from(this.checklistItems)
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
    if (id != null) {
      model.id = id;
    }
    return model;
  }
}
