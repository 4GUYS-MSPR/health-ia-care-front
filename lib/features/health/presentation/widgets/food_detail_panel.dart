import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/nutrition_food.dart';

/// A panel widget displaying detailed food information.
class FoodDetailsPanel extends StatelessWidget {
  const FoodDetailsPanel({
    super.key,
    required this.food,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  final NutritionFood food;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, l10n),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNutritionSection(context, l10n),
                  const SizedBox(height: 24),
                  _buildDetailsSection(context, l10n),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          _buildActions(context, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
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
                Text(
                  '${food.category} • ${food.mealType}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.foodDetailsNutrition,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          Icons.local_fire_department,
          l10n.foodCardCalories,
          '${food.calories} kcal',
        ),
        _buildInfoRow(
          context,
          Icons.egg_outlined,
          l10n.foodCardProtein,
          '${food.protein.toStringAsFixed(1)}g',
        ),
        _buildInfoRow(
          context,
          Icons.grain,
          l10n.foodCardCarbs,
          '${food.carbohydrates.toStringAsFixed(1)}g',
        ),
        _buildInfoRow(
          context,
          Icons.opacity_outlined,
          l10n.foodCardFat,
          '${food.fat.toStringAsFixed(1)}g',
        ),
        _buildInfoRow(
          context,
          Icons.fiber_manual_record_outlined,
          l10n.foodCardFiber,
          '${food.fiber.toStringAsFixed(1)}g',
        ),
        _buildInfoRow(
          context,
          Icons.water_drop_outlined,
          l10n.foodCardWaterIntake,
          '${food.waterIntake} ml',
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.foodDetailsInfo,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          Icons.tag_outlined,
          l10n.foodTableColumnLabel,
          food.label,
        ),
        _buildInfoRow(
          context,
          Icons.category_outlined,
          l10n.foodCardCategory,
          food.category,
        ),
        _buildInfoRow(
          context,
          Icons.restaurant_menu,
          l10n.foodCardMealType,
          food.mealType,
        ),
        _buildInfoRow(
          context,
          Icons.info_outline,
          l10n.foodTableColumnId,
          '#${food.id}',
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outlined, color: context.colorScheme.error),
              label: Text(
                l10n.foodDetailsDelete,
                style: TextStyle(color: context.colorScheme.error),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.foodDetailsEdit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}