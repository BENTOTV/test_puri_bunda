import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_radius.dart';
import '../core/theme/app_sizes.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/med_ref_colors.dart';

enum DisclaimerVariant { info, warn, err }

/// Inline note banner: `info` (not-medical-advice), `warn` (rate-limit
/// countdown), `err` (offline / load-more failure).
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({
    required this.text,
    this.variant = DisclaimerVariant.info,
    super.key,
  });

  final String text;
  final DisclaimerVariant variant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.medRefColors;
    final (background, foreground, icon) = switch (variant) {
      DisclaimerVariant.info => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        LucideIcons.info,
      ),
      DisclaimerVariant.warn => (
        tokens.warningSoft,
        tokens.warning,
        LucideIcons.clock,
      ),
      DisclaimerVariant.err => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        LucideIcons.wifiOff,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.smRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: foreground),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
