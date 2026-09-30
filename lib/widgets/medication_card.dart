import 'package:flutter/material.dart';

import '../core/theme/app_radius.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/med_ref_colors.dart';
import '../core/util/value_list.dart';
import '../data/models/medication_summary.dart';
import '../l10n/app_localizations.dart';
import 'favorite_button.dart';

/// List row for one label: brand name, generic name, manufacturer,
/// product-type badge and the favorite toggle. Takes a [MedicationSummary],
/// never raw JSON.
class MedicationCard extends StatelessWidget {
  const MedicationCard({
    required this.summary,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    super.key,
  });

  final MedicationSummary summary;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.medRefColors;
    String more(int n) => l10n.moreValues(n);

    final hasBrand = summary.brandNames.isNotEmpty;
    final hasGeneric = summary.genericNames.isNotEmpty;
    final ingredientName = summary.firstActiveIngredientName;
    final hasIngredientName =
        ingredientName != null && ingredientName.isNotEmpty;

    final String headline;
    final bool headlineIsFallback;
    if (hasBrand) {
      headline = firstPlusMore(summary.brandNames, more);
      headlineIsFallback = false;
    } else if (hasGeneric) {
      headline = firstPlusMore(summary.genericNames, more);
      headlineIsFallback = false;
    } else if (hasIngredientName) {
      // Neither brand nor generic name is enriched — the active
      // ingredient is structured, short, and a reliable stand-in.
      headline = ingredientName;
      headlineIsFallback = false;
    } else {
      headline = l10n.brandUnavailable;
      headlineIsFallback = true;
    }

    // Generic name gets its own line only when it wasn't already promoted
    // into the headline above.
    final showGenericLine = hasBrand && hasGeneric;
    final manufacturerText =
        summary.manufacturers.isNotEmpty
            ? firstPlusMore(summary.manufacturers, more)
            : l10n.unknownManufacturer;
    final manufacturerIsFallback = summary.manufacturers.isEmpty;

    final badgeLabel = switch (summary.productType) {
      'otc' => l10n.otcBadge,
      'rx' => l10n.rxBadge,
      _ => null,
    };

    final semanticParts = [
      headline,
      if (showGenericLine) firstPlusMore(summary.genericNames, more),
      manufacturerText,
    ];

    return Semantics(
      button: true,
      label: semanticParts.join(', '),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.mdRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              headline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                color:
                                    headlineIsFallback ? tokens.inkMuted : null,
                                fontStyle:
                                    headlineIsFallback
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                              ),
                            ),
                          ),
                          if (badgeLabel != null) ...[
                            const SizedBox(width: AppSpacing.s2),
                            _ProductTypeBadge(label: badgeLabel),
                          ],
                        ],
                      ),
                      if (showGenericLine) ...[
                        const SizedBox(height: AppSpacing.s1),
                        Text(
                          firstPlusMore(summary.genericNames, more),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: tokens.inkMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        manufacturerText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: tokens.inkMuted,
                          fontStyle:
                              manufacturerIsFallback
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                FavoriteButton(
                  isFavorite: isFavorite,
                  onToggle: onFavoriteToggle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductTypeBadge extends StatelessWidget {
  const _ProductTypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.medRefColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.smRadius,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tokens.inkMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
