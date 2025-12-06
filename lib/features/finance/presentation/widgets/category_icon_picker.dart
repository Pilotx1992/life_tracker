import 'package:flutter/material.dart';
import 'package:life_tracker/features/finance/domain/entities/category.dart';

class CategoryIconPicker extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category) onCategorySelected;

  const CategoryIconPicker({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'receipt':
        return Icons.receipt;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'face':
        return Icons.face;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'home':
        return Icons.home;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategory?.id == category.id;

        return InkWell(
          onTap: () => onCategorySelected(category),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? _getCategoryColor(category.color).withValues(alpha: 0.2)
                  : _getCategoryColor(category.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _getCategoryColor(category.color)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(category.icon),
                  color: _getCategoryColor(category.color),
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
