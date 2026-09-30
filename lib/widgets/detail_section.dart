import 'package:flutter/material.dart';

import '../core/theme/app_radius.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/med_ref_colors.dart';
import '../l10n/app_localizations.dart';

const _clampLines = 6;

/// Card for one label field on the detail screen (Purpose, Dosage,
/// Warnings, …). Missing field: hides itself unless [fallbackText] is
/// given, in which case it shows that fallback in a quiet italic tone.
class DetailSection extends StatefulWidget {
  const DetailSection({
    required this.title,
    required this.icon,
    required this.paragraphs,
    this.fallbackText,
    this.isWarning = false,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<String> paragraphs;
  final String? fallbackText;
  final bool isWarning;

  @override
  State<DetailSection> createState() => _DetailSectionState();
}

class _DetailSectionState extends State<DetailSection> {
  bool _expanded = false;

  static final _leadingLabelPattern = RegExp(r'^[A-Za-z][A-Za-z /]*:\s*');

  List<String> get _cleanedParagraphs => widget.paragraphs
      .map((p) => p.replaceFirst(_leadingLabelPattern, '').trim())
      .where((p) => p.isNotEmpty)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final cleaned = _cleanedParagraphs;
    if (cleaned.isEmpty && widget.fallbackText == null) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final tokens = context.medRefColors;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final isFallback = cleaned.isEmpty;
    final bodyText = isFallback ? widget.fallbackText! : cleaned.join('\n\n');
    final headerColor = widget.isWarning ? tokens.warning : tokens.inkMuted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.lgRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: widget.isWarning ? tokens.warningSoft : null,
                borderRadius: AppRadius.smRadius,
              ),
              child: Padding(
                padding:
                    widget.isWarning
                        ? const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s2,
                          vertical: AppSpacing.s1,
                        )
                        : EdgeInsets.zero,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 20, color: headerColor),
                    const SizedBox(width: AppSpacing.s2),
                    Text(
                      widget.title.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(color: headerColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            if (isFallback)
              Text(
                bodyText,
                style: textTheme.bodyLarge?.copyWith(
                  color: tokens.inkMuted,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              _ClampedBody(
                text: bodyText,
                style: textTheme.bodyLarge,
                expanded: _expanded,
                onToggle: () => setState(() => _expanded = !_expanded),
                showLessLabel: l10n.showLess,
                showMoreLabel: l10n.showMore,
              ),
          ],
        ),
      ),
    );
  }
}

class _ClampedBody extends StatelessWidget {
  const _ClampedBody({
    required this.text,
    required this.style,
    required this.expanded,
    required this.onToggle,
    required this.showLessLabel,
    required this.showMoreLabel,
  });

  final String text;
  final TextStyle? style;
  final bool expanded;
  final VoidCallback onToggle;
  final String showLessLabel;
  final String showMoreLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: _clampLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: style,
                maxLines: expanded ? null : _clampLines,
                overflow:
                    expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              if (overflows)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s1),
                  child: GestureDetector(
                    onTap: onToggle,
                    child: Text(
                      expanded ? showLessLabel : showMoreLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
