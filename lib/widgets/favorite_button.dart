import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_sizes.dart';
import '../core/theme/med_ref_colors.dart';
import '../l10n/app_localizations.dart';

/// 44x44 hit area heart toggle. Never color-only: the fill changes too.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.isFavorite,
    required this.onToggle,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.medRefColors;

    return Semantics(
      toggled: isFavorite,
      label: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
      child: SizedBox(
        width: AppSizes.tapMin,
        height: AppSizes.tapMin,
        child: IconButton(
          onPressed: onToggle,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isFavorite ? Icons.favorite : LucideIcons.heart,
              key: ValueKey(isFavorite),
              size: AppSizes.iconMd,
              color: isFavorite ? tokens.favorite : tokens.inkSubtle,
            ),
          ),
        ),
      ),
    );
  }
}
