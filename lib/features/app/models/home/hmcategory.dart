import 'package:flutter/material.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';
import 'package:manuals_hub/features/manuals/models/category.dart';

class HmCategory extends StatelessWidget {
  const HmCategory({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(color: cardColor),
      padding: const EdgeInsets.only(top: 10, left: 14, bottom: 2),
      // 4 个分类在导航栏内动态平分宽度，不再横向滚动。
      child: Row(
        children: [
          for (final category in categories)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _CategoryChip(
                  label: category.category,
                  selected: category.categoryId == selectedCategoryId,
                  onTap: () => onSelected(category.categoryId),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryBlue
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 28,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
