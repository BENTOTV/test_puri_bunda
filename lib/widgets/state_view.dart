import 'package:flutter/material.dart';

import '../core/error/failure_l10n.dart';
import '../core/theme/app_sizes.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/med_ref_colors.dart';
import 'app_button.dart';

/// Full-area feedback for empty / error / rate-limited states: a 56px icon
/// disc, title, message and one action. Never a blank screen.
class StateView extends StatelessWidget {
  const StateView({
    required this.icon,
    required this.discColor,
    required this.iconColor,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
    super.key,
  });

  factory StateView.failure(
    BuildContext context, {
    required FailurePresentation presentation,
    String? buttonLabel,
    VoidCallback? onButtonPressed,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.medRefColors;
    final (disc, fg) = switch (presentation.tone) {
      FailureTone.danger => (scheme.errorContainer, scheme.error),
      FailureTone.warning => (tokens.warningSoft, tokens.warning),
    };
    return StateView(
      icon: presentation.icon,
      discColor: disc,
      iconColor: fg,
      title: presentation.title,
      message: presentation.message,
      buttonLabel: buttonLabel,
      onButtonPressed: onButtonPressed,
    );
  }

  final IconData icon;
  final Color discColor;
  final Color iconColor;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.iconState,
                height: AppSizes.iconState,
                decoration: BoxDecoration(
                  color: discColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                title,
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                message,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (buttonLabel != null) ...[
                const SizedBox(height: AppSpacing.s6),
                AppButton(
                  label: buttonLabel!,
                  onPressed: onButtonPressed,
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
