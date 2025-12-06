import 'package:equatable/equatable.dart';

class ChecklistItem extends Equatable {
  final String text;
  final bool isChecked;

  const ChecklistItem({
    required this.text,
    this.isChecked = false,
  });

  @override
  List<Object?> get props => [text, isChecked];

  ChecklistItem copyWith({
    String? text,
    bool? isChecked,
  }) {
    return ChecklistItem(
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
