import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/nutrition_food.dart';

/// A card widget displaying food information.
class FoodCard extends StatelessWidget {
  final NutritionFood food;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FoodCard({
    super.key,
    required this.food,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 24),
            _buildNutritionMetrics(context),
            const SizedBox(height: 12),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: context.colorScheme.primaryContainer,
          child: Icon(
            Icons.restaurant_outlined,
            color: context.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                food.label,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  _CategoryChip(category: food.category),
                  const SizedBox(width: 8),
                  _MealTypeChip(mealType: food.mealType),
                ],
              ),
            ],
          ),
        ),
        if (onEdit != null || onDelete != null)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit?.call();
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined),
                      const SizedBox(width: 8),
                      Text(l10n.foodFormEditTitle),
                    ],
                  ),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outlined,
                        color: context.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.foodDeleteDialogConfirmButton,
                        style: TextStyle(color: context.colorScheme.error),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildNutritionMetrics(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _MetricItem(
          icon: Icons.local_fire_department,
          label: l10n.foodCardCalories,
          value: '${food.calories} kcal',
        ),
        _MetricItem(
          icon: Icons.egg_outlined,
          label: l10n.foodCardProtein,
          value: '${food.protein.toStringAsFixed(1)}g',
        ),
        _MetricItem(
          icon: Icons.grain,
          label: l10n.foodCardCarbs,
          value: '${food.carbohydrates.toStringAsFixed(1)}g',
        ),
        _MetricItem(
          icon: Icons.opacity_outlined,
          label: l10n.foodCardFat,
          value: '${food.fat.toStringAsFixed(1)}g',
        ),
        _MetricItem(
          icon: Icons.fiber_manual_record_outlined,
          label: l10n.foodCardFiber,
          value: '${food.fiber.toStringAsFixed(1)}g',
        ),
        _MetricItem(
          icon: Icons.water_drop_outlined,
          label: l10n.foodCardWaterIntake,
          value: '${food.waterIntake} ml',
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Text(
          '#${food.id}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = category.toLowerCase().contains('fruit')
        ? Colors.orange
        : category.toLowerCase().contains('vegetable') || category.toLowerCase().contains('veggie')
            ? Colors.green
            : category.toLowerCase().contains('protein') || category.toLowerCase().contains('meat')
                ? Colors.red
                : category.toLowerCase().contains('dairy')
                    ? Colors.blue
                    : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        category,
        style: context.textTheme.labelSmall?.copyWith(
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MealTypeChip extends StatelessWidget {
  final String mealType;

  const _MealTypeChip({required this.mealType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        mealType,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}