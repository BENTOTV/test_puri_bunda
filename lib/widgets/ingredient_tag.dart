import 'package:flutter/material.dart';

import '../core/theme/app_radius.dart';
import '../core/theme/app_spacing.dart';
import '../data/models/medication_detail.dart';

/// Tag for one active ingredient, with strength when the label provides it.
class IngredientTag extends StatelessWidget {
  const IngredientTag({required this.ingredient, super.key});

  final ActiveIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label =
        ingredient.strength == null
            ? ingredient.name
            : '${ingredient.name} ${ingredient.strength}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppRadius.smRadius,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
