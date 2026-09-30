import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import 'failure.dart';

enum FailureTone { danger, warning }

class FailurePresentation {
  const FailurePresentation({
    required this.icon,
    required this.tone,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final FailureTone tone;
  final String title;
  final String message;
}

/// Maps a [Failure] to copy + iconography via the l10n mapper — never
/// `exception.toString()`.
FailurePresentation presentFailure(Failure failure, AppLocalizations l10n) {
  switch (failure.kind) {
    case FailureKind.network:
      return FailurePresentation(
        icon: LucideIcons.wifiOff,
        tone: FailureTone.danger,
        title: l10n.errorNetworkTitle,
        message: l10n.errorNetworkBody,
      );
    case FailureKind.server:
      return FailurePresentation(
        icon: LucideIcons.alertTriangle,
        tone: FailureTone.danger,
        title: l10n.errorServerTitle,
        message: l10n.errorServerBody,
      );
    case FailureKind.rateLimit:
      return FailurePresentation(
        icon: LucideIcons.clock,
        tone: FailureTone.warning,
        title: l10n.errorRateLimitTitle,
        message: l10n.errorRateLimitBody,
      );
    case FailureKind.invalidData:
      return FailurePresentation(
        icon: LucideIcons.alertTriangle,
        tone: FailureTone.danger,
        title: l10n.errorInvalidDataTitle,
        message: l10n.errorInvalidDataBody,
      );
  }
}
