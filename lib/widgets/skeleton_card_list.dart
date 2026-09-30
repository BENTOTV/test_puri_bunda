import 'package:flutter/material.dart';

import '../core/theme/app_radius.dart';
import '../core/theme/app_sizes.dart';
import '../core/theme/app_spacing.dart';

/// 6 skeleton cards shown on first load — never a blank screen. Sized to
/// match a loaded [MedicationCard] (same padding, same trailing favorite
/// hit-area, bar heights taken from the real text styles' line-height, not
/// their font size) so the layout doesn't jump once data arrives.
class SkeletonCardList extends StatelessWidget {
  const SkeletonCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        0,
        AppSpacing.s4,
        AppSpacing.s8,
      ),
      child: Column(
        children: [
          for (var i = 0; i < 6; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s3),
            const _SkeletonCard(),
          ],
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  // A style's rendered line height, not just its font size — AppTheme's
  // styles carry a height multiplier (e.g. titleMedium is 17px/22px).
  static double _lineHeight(TextStyle? style) =>
      (style?.fontSize ?? 14) * (style?.height ?? 1.2);

  @override
  Widget build(BuildContext context) {
    final fill = Theme.of(context).colorScheme.surfaceContainerHighest;
    final textTheme = Theme.of(context).textTheme;

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: fill, borderRadius: AppRadius.smRadius),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(160, _lineHeight(textTheme.titleMedium)),
                const SizedBox(height: AppSpacing.s1),
                bar(120, _lineHeight(textTheme.bodyMedium)),
                const SizedBox(height: AppSpacing.s1),
                bar(180, _lineHeight(textTheme.bodySmall)),
              ],
            ),
          ),
          SizedBox(
            width: AppSizes.tapMin,
            height: AppSizes.tapMin,
            child: Center(
              child: Container(
                width: AppSizes.iconMd,
                height: AppSizes.iconMd,
                decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small spinner appended below the list while loading the next page.
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
