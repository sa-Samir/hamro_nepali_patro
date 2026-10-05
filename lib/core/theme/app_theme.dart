import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'palettes.dart';

/// Design tokens beyond Material's ColorScheme, derived from
/// [maroonPalette] in light or dark. Every palette shares the same
/// components: glass cards, day tiles, pill buttons, floating nav.
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
    required this.bright,
    required this.onBright,
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

  /// Text on the light pill buttons that sit on photos and dark cards.
  Color get deepInk => headerEnd;

  /// Accent for chips and buttons on photos and dark cards (both modes).
  final Color bright;
  final Color onBright;

  factory PatroColors.from(PaletteSpec c, {required bool dark}) => PatroColors(
    backgroundTop: c.backgroundTop,
    backgroundBottom: c.backgroundBottom,
    glow: dark ? c.highlight.withValues(alpha: 0.14) : const Color(0x99FFFFFF),
    card: dark ? const Color(0x12FFFFFF) : const Color(0xB3FFFFFF),
    cardBorder: dark ? const Color(0x1AFFFFFF) : const Color(0xE6FFFFFF),
    highlight: c.highlight,
    onHighlight: c.onHighlight,
    strongButton: dark ? c.ink : c.deepest,
    onStrongButton: dark ? c.deepest : const Color(0xFFF9F5F0),
    nav: dark
        ? Color.alphaBlend(const Color(0x14FFFFFF), c.backgroundBottom).withValues(alpha: 0.94)
        : const Color(0xF2FFFFFF),
    accent: c.accent,
    holiday: c.holiday,
    muted: c.muted,
    tipBackground: c.deep,
    headerStart: c.deep,
    headerEnd: c.deepest,
    onHeader: const Color(0xFFF9F5F0),
    bright: c.bright,
    onBright: Color.alphaBlend(const Color(0xCC000000), c.bright),
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
      bright: l(bright, other.bright),
      onBright: l(onBright, other.onBright),
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
  static ThemeData light() => _from(maroonPalette.light, dark: false);

  static ThemeData dark() => _from(maroonPalette.dark, dark: true);

  static ThemeData _from(PaletteSpec c, {required bool dark}) {
    Color over(Color tint, double a, Color base) => Color.alphaBlend(tint.withValues(alpha: a), base);
    final container = over(c.highlight, dark ? 0.22 : 0.14, c.backgroundBottom);
    final scheme = (dark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
      primary: c.highlight,
      onPrimary: c.onHighlight,
      primaryContainer: container,
      onPrimaryContainer: c.ink,
      secondaryContainer: container,
      onSecondaryContainer: c.ink,
      // Material's default tertiary is cyan (time picker AM/PM etc.).
      tertiary: c.accent,
      tertiaryContainer: dark ? c.highlight : container,
      onTertiaryContainer: dark ? c.onHighlight : c.ink,
      surface: c.backgroundBottom,
      onSurface: c.ink,
      surfaceContainerLow: dark ? const Color(0x14FFFFFF) : const Color(0xCCFFFFFF),
      surfaceContainer: over(c.highlight, dark ? 0.10 : 0.05, dark ? c.backgroundBottom : const Color(0xFFFBFAF7)),
      surfaceContainerHigh: over(c.highlight, dark ? 0.16 : 0.09, dark ? c.backgroundBottom : const Color(0xFFF7F6F2)),
      outlineVariant: dark ? const Color(0x26FFFFFF) : over(c.muted, 0.22, c.backgroundBottom),
      error: c.holiday,
    );
    return _build(scheme, PatroColors.from(c, dark: dark));
  }

  static ThemeData _build(ColorScheme scheme, PatroColors patro) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    // White hairlines vanish on the light background; use a visible one there.
    final hairline = scheme.brightness == Brightness.light ? scheme.outlineVariant : patro.cardBorder;
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
        // Transparent status bar with icons matching the page, the same as the
        // tab pages, so opening the editor doesn't flash a different bar.
        systemOverlayStyle:
            (scheme.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
              statusBarColor: Colors.transparent,
            ),
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
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: hairline),
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
        side: BorderSide(color: hairline),
        shape: const StadiumBorder(),
        // Chips resolve the label *colour* per state (not the whole style).
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected) ? patro.onHighlight : scheme.onSurface,
          ),
        ),
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
