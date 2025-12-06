import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final String selectedColor;
  final Function(String) onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  // Default note colors
  static const List<String> noteColors = [
    '#FFFFFF', // White
    '#FFE5E5', // Light Red
    '#FFE5F1', // Light Pink
    '#F0E5FF', // Light Purple
    '#E5F0FF', // Light Blue
    '#E5F5FF', // Light Cyan
    '#E5FFE5', // Light Green
    '#F5FFE5', // Light Yellow
    '#FFF5E5', // Light Orange
    '#F5E5FF', // Light Lavender
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: noteColors.map((color) {
            final isSelected = color == selectedColor;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hexToColor(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: _getContrastColor(color),
                          size: 20,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Color _getContrastColor(String hex) {
    final color = _hexToColor(hex);
    // Calculate luminance to determine if we need dark or light icon
    // Using new color.r, color.g, color.b (normalized 0.0-1.0 values)
    final luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
