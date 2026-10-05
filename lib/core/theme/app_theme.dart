import 'package:flutter/material.dart';

/// Design tokens beyond Material's ColorScheme.
///
/// Dark is "forest": deep green with lime highlights. Light is "sage mist":
/// airy frosted cards with deep-green highlights. Both share the same
/// components (glass cards, day tiles, pill buttons, floating nav).
@immutable
class PatroColors extends ThemeExtension<PatroColors> {
  const PatroColors({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.glow,
    required this.card,
    required this.cardBorder,
    required this.highlight,
    required this.onHighlight,
    required this.strongButton,
    required this.onStrongButton,
    required this.nav,
    required this.accent,
    required this.holiday,
    required this.muted,
    required this.tipBackground,
    required this.headerStart,
    required this.headerEnd,
    required this.onHeader,
  });

  /// Page background gradient.
  final Color backgroundTop;
  final Color backgroundBottom;

  /// Soft radial light near the top of pages.
  final Color glow;

  /// Translucent "glass" card fill and hairline border.
  final Color card;
  final Color cardBorder;

  /// Selected things: today, chosen chips, active nav item.
  final Color highlight;
  final Color onHighlight;

  /// The one primary pill button per view.
  final Color strongButton;
  final Color onStrongButton;

  /// Floating bottom navigation bar.
  final Color nav;

  /// Saturdays and small warm accents (tithi).
  final Color accent;

  /// Public holidays.
  final Color holiday;
  final Color muted;
  final Color tipBackground;

  /// Photo overlays (season header, converter result) and text on them.
  final Color headerStart;
  final Color headerEnd;
  final Color onHeader;

  static const dark = PatroColors(
    backgroundTop: Color(0xFF26331F),
    backgroundBottom: Color(0xFF0C1008),
    glow: Color(0x24BAD45F),
    card: Color(0x12FFFFFF),
    cardBorder: Color(0x1AFFFFFF),
    highlight: Color(0xFFBAD45F),
    onHighlight: Color(0xFF0C1008),
    strongButton: Color(0xFFF9F5F0),
    onStrongButton: Color(0xFF0C1008),
    nav: Color(0xF01A2216),
    accent: Color(0xFFD9C98A),
    holiday: Color(0xFFF2937D),
    muted: Color(0xFFA9ABA6),
    tipBackground: Color(0xFF3B4A2E),
    headerStart: Color(0xFF1E2A19),
    headerEnd: Color(0xFF0C1008),
    onHeader: Color(0xFFF9F5F0),
  );

  static const light = PatroColors(
    backgroundTop: Color(0xFFDDE6D3),
    backgroundBottom: Color(0xFFF7F4EE),
    glow: Color(0x99FFFFFF),
    card: Color(0xB3FFFFFF),
    cardBorder: Color(0xE6FFFFFF),
    highlight: Color(0xFF2E4A24),
    onHighlight: Color(0xFFF9F5F0),
    strongButton: Color(0xFF141A11),
    onStrongButton: Color(0xFFF9F5F0),
    nav: Color(0xF2FFFFFF),
    accent: Color(0xFF8A6D1F),
    holiday: Color(0xFFC4472F),
    muted: Color(0xFF5E665C),
    tipBackground: Color(0xFF2E4A24),
    headerStart: Color(0xFF2E4A24),
    headerEnd: Color(0xFF141A11),
    onHeader: Color(0xFFF9F5F0),
  );

  @override
  PatroColors copyWith() => this;

  @override
  PatroColors lerp(PatroColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PatroColors(
      backgroundTop: l(backgroundTop, other.backgroundTop),
      backgroundBottom: l(backgroundBottom, other.backgroundBottom),
      glow: l(glow, other.glow),
      card: l(card, other.card),
      cardBorder: l(cardBorder, other.cardBorder),
      highlight: l(highlight, other.highlight),
      onHighlight: l(onHighlight, other.onHighlight),
      strongButton: l(strongButton, other.strongButton),
      onStrongButton: l(onStrongButton, other.onStrongButton),
      nav: l(nav, other.nav),
      accent: l(accent, other.accent),
      holiday: l(holiday, other.holiday),
      muted: l(muted, other.muted),
      tipBackground: l(tipBackground, other.tipBackground),
      headerStart: l(headerStart, other.headerStart),
      headerEnd: l(headerEnd, other.headerEnd),
      onHeader: l(onHeader, other.onHeader),
    );
  }
}

extension PatroThemeX on BuildContext {
  PatroColors get patro => Theme.of(this).extension<PatroColors>()!;
}

/// Serif for display headings; Devanagari falls back to a matching serif.
const serifFamily = 'InstrumentSerif';
const serifFallback = ['NotoSerifDevanagari'];

TextStyle serif(double size, Color color, {FontWeight weight = FontWeight.w400, double height = 1.1}) => TextStyle(
  fontFamily: serifFamily,
  fontFamilyFallback: serifFallback,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: -0.2,
);

class AppTheme {
  static ThemeData light() => _build(
    const ColorScheme.light(
      primary: Color(0xFF2E4A24),
      onPrimary: Color(0xFFF9F5F0),
      primaryContainer: Color(0xFFD5E3C3),
      onPrimaryContainer: Color(0xFF141A11),
      secondaryContainer: Color(0xFFE3EBD8),
      onSecondaryContainer: Color(0xFF141A11),
      surface: Color(0xFFF7F4EE),
      onSurface: Color(0xFF141A11),
      surfaceContainerLow: Color(0xCCFFFFFF),
      surfaceContainer: Color(0xFFEFF2EA),
      surfaceContainerHigh: Color(0xFFE6EBE0),
      outlineVariant: Color(0xFFDCE3D5),
      error: Color(0xFFC4472F),
    ),
    PatroColors.light,
  );

  static ThemeData dark() => _build(
    const ColorScheme.dark(
      primary: Color(0xFFBAD45F),
      onPrimary: Color(0xFF0C1008),
      primaryContainer: Color(0xFF3B4A2E),
      onPrimaryContainer: Color(0xFFF9F5F0),
      secondaryContainer: Color(0xFF2E3A26),
      onSecondaryContainer: Color(0xFFF9F5F0),
      surface: Color(0xFF0C1008),
      onSurface: Color(0xFFF9F5F0),
      surfaceContainerLow: Color(0x14FFFFFF),
      surfaceContainer: Color(0xFF1A2216),
      surfaceContainerHigh: Color(0xFF232D1E),
      outlineVariant: Color(0x26FFFFFF),
      error: Color(0xFFF2937D),
    ),
    PatroColors.dark,
  );

  static ThemeData _build(ColorScheme scheme, PatroColors patro) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      // Pages inside the shell paint their own gradient; pushed routes use this.
      scaffoldBackgroundColor: patro.backgroundBottom,
      extensions: [patro],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: serif(28, scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: patro.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: patro.cardBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: patro.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: patro.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: patro.cardBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: patro.strongButton,
          foregroundColor: patro.onStrongButton,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: patro.card,
        selectedColor: patro.highlight,
        side: BorderSide(color: patro.cardBorder),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: patro.onHighlight),
        checkmarkColor: patro.onHighlight,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: patro.card,
          selectedBackgroundColor: patro.highlight,
          selectedForegroundColor: patro.onHighlight,
          side: BorderSide(color: patro.cardBorder),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? patro.onHighlight : patro.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? patro.highlight : patro.card,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: scheme.surfaceContainer),
      dialogTheme: DialogThemeData(backgroundColor: scheme.surfaceContainer),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
