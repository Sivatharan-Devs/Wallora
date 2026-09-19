import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallpaper_provider.dart';
import '../utils/categories.dart';

/// A horizontal, scrollable row of filter chips. Wrapped in its own
/// Consumer (rather than relying on a parent Consumer) so tapping a
/// category only rebuilds this row's selection highlight — not the
/// whole screen — even though in practice the grid below also needs
/// to update; Consumer granularity is about intent, not a hard rule
/// here since the grid's own Consumer handles its part independently.
class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WallpaperProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: WallpaperCategories.all.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = WallpaperCategories.all[index];
              final isSelected = provider.selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => provider.selectCategory(category),
              );
            },
          ),
        );
      },
    );
  }
}
