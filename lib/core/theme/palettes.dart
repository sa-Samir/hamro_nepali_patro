import 'package:flutter/material.dart';

/// The app's colour palette: light and dark variants of the maroon patro
/// look. Everything else in the theme is derived from these few colours.
/// (Alternative palettes live on the `palettes-experiment` branch.)

/// The handful of colours a palette variant chooses; see [AppTheme].
@immutable
class PaletteSpec {
  const PaletteSpec({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.highlight,
    required this.onHighlight,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.holiday,
    required this.deep,
    required this.deepest,
    required this.bright,
  });

  /// Page gradient.
  final Color backgroundTop;
  final Color backgroundBottom;

  /// Today, selections, active nav.
  final Color highlight;
  final Color onHighlight;

  /// Body text and secondary text.
  final Color ink;
  final Color muted;

  /// Saturdays and tithi.
  final Color accent;
  final Color holiday;

  /// Dark brand colours for the result card and photo washes.
  final Color deep;
  final Color deepest;

  /// Accent that reads on photos and dark cards in both modes.
  final Color bright;
}

/// Maroon with gold: the traditional patro.
const maroonPalette = (
  light: PaletteSpec(
    backgroundTop: Color(0xFFF1E1D6),
    backgroundBottom: Color(0xFFFBF5EC),
    highlight: Color(0xFF7A1F1F),
    onHighlight: Colors.white,
    ink: Color(0xFF2B1A14),
    muted: Color(0xFF8A6A5A),
    accent: Color(0xFFA8711A),
    holiday: Color(0xFFB3261E),
    deep: Color(0xFF7A1F1F),
    deepest: Color(0xFF3A0F0F),
    bright: Color(0xFFF2C66D),
  ),
  dark: PaletteSpec(
    backgroundTop: Color(0xFF3A1515),
    backgroundBottom: Color(0xFF120707),
    highlight: Color(0xFFF2C66D),
    onHighlight: Color(0xFF2A1006),
    ink: Color(0xFFF7EDE6),
    muted: Color(0xFFB9A193),
    accent: Color(0xFFE0B25C),
    holiday: Color(0xFFFF8A80),
    deep: Color(0xFF5E1A1A),
    deepest: Color(0xFF120707),
    bright: Color(0xFFF2C66D),
  ),
);
