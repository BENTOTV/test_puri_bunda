import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text }

/// One action per screen state: [AppButtonVariant.primary] for the single
/// main action, [AppButtonVariant.secondary] for a recovery/alternative,
/// [AppButtonVariant.text] for inline actions like "Show more".
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        child: Text(label),
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: onPressed,
        child: Text(label),
      ),
      AppButtonVariant.text => TextButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    };
    return fullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }
}
