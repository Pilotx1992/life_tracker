import 'package:isar/isar.dart';
import 'package:life_tracker/features/notes/domain/entities/checklist_item.dart';

part 'checklist_item_model.g.dart';

@embedded
class ChecklistItemModel {
  late String text;
  bool isChecked = false;

  ChecklistItemModel();

  ChecklistItem toEntity() {
    return ChecklistItem(
      text: text,
      isChecked: isChecked,
    );
  }

  factory ChecklistItemModel.fromEntity(ChecklistItem entity) {
    return ChecklistItemModel()
      ..text = entity.text
      ..isChecked = entity.isChecked;
  }

  ChecklistItemModel copyWith({
    String? text,
    bool? isChecked,
  }) {
    return ChecklistItemModel()
      ..text = text ?? this.text
      ..isChecked = isChecked ?? this.isChecked;
  }
}
