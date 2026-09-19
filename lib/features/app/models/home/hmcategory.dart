import 'package:flutter/material.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';

class HmCategory extends StatelessWidget {
  const HmCategory({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final Map<String, int> categories;
  final String? selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final category = categories.keys.elementAt(index);
          final selected = category == selectedCategory;
          return Container(
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryBlue
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelected(category),
              child: Text(
                '$category (${categories[category]})',
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
