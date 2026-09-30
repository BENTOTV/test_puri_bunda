import 'package:flutter/material.dart';

/// Tokens Material's [ColorScheme] has no slot for.
///
/// Access via `context.medRefColors`. Widgets must never use hex literals.
@immutable
class MedRefColors extends ThemeExtension<MedRefColors> {
  const MedRefColors({
    required this.favorite,
    required this.warning,
    required this.warningSoft,
    required this.inkMuted,
    required this.inkSubtle,
    required this.shadowCard,
  });

  final Color favorite;
  final Color warning;
  final Color warningSoft;
  final Color inkMuted;
  final Color inkSubtle;
  final List<BoxShadow> shadowCard;

  static const light = MedRefColors(
    favorite: Color(0xFFC2410C),
    warning: Color(0xFF7A4F00),
    warningSoft: Color(0xFFFFF3D6),
    inkMuted: Color(0xFF56636A),
    inkSubtle: Color(0xFF7C8A8F),
    shadowCard: [
      BoxShadow(color: Color(0x0F111A1A), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x0A111A1A), offset: Offset(0, 1), blurRadius: 1),
    ],
  );

  static const dark = MedRefColors(
    favorite: Color(0xFFFB8A4C),
    warning: Color(0xFFF5C255),
    warningSoft: Color(0xFF33280F),
    inkMuted: Color(0xFF9AA9AB),
    inkSubtle: Color(0xFF6B7A7C),
    shadowCard: [],
  );

  /// Readable label color for text/icons placed on a [favorite]-filled
  /// surface (e.g. the Favorites tab badge), computed from luminance rather
  /// than a hardcoded token since the design system doesn't define one.
  Color onFavorite() =>
      ThemeData.estimateBrightnessForColor(favorite) == Brightness.dark
          ? Colors.white
          : Colors.black;

  @override
  MedRefColors copyWith({
    Color? favorite,
    Color? warning,
    Color? warningSoft,
    Color? inkMuted,
    Color? inkSubtle,
    List<BoxShadow>? shadowCard,
  }) {
    return MedRefColors(
      favorite: favorite ?? this.favorite,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      inkMuted: inkMuted ?? this.inkMuted,
      inkSubtle: inkSubtle ?? this.inkSubtle,
      shadowCard: shadowCard ?? this.shadowCard,
    );
  }

  @override
  MedRefColors lerp(ThemeExtension<MedRefColors>? other, double t) {
    if (other is! MedRefColors) return this;
    return MedRefColors(
      favorite: Color.lerp(favorite, other.favorite, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkSubtle: Color.lerp(inkSubtle, other.inkSubtle, t)!,
      shadowCard: t < 0.5 ? shadowCard : other.shadowCard,
    );
  }
}

extension MedRefColorsContext on BuildContext {
  MedRefColors get medRefColors => Theme.of(this).extension<MedRefColors>()!;
}
