/// The 4 failure kinds the design system maps to a `StateView` / banner.
///
/// UI never shows `exception.toString()` — a [Failure] always goes through
/// the l10n mapper in the widget layer instead.
enum FailureKind { network, server, rateLimit, invalidData }

class Failure implements Exception {
  const Failure(this.kind, {this.retryAfter});

  final FailureKind kind;

  /// Only set for [FailureKind.rateLimit]; how long the caller already
  /// backed off before giving up.
  final Duration? retryAfter;

  @override
  String toString() => 'Failure(${kind.name})';
}
