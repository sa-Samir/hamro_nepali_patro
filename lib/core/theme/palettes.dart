import 'package:flutter/material.dart';

/// Colour palettes the user can pick under Settings → Look. Each defines a
/// light and a dark variant; everything else in the theme is derived.
enum AppPalette { forest, himalaya, terracotta, rhododendron, lake, maroon }

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

const _cream = Color(0xFFF9F5F0);

/// Light / dark variants of every palette.
const Map<AppPalette, ({PaletteSpec light, PaletteSpec dark})> palettes = {
  AppPalette.forest: (
    light: PaletteSpec(
      backgroundTop: Color(0xFFDDE6D3),
      backgroundBottom: Color(0xFFF7F4EE),
      highlight: Color(0xFF2E4A24),
      onHighlight: _cream,
      ink: Color(0xFF141A11),
      muted: Color(0xFF5E665C),
      accent: Color(0xFF8A6D1F),
      holiday: Color(0xFFC4472F),
      deep: Color(0xFF2E4A24),
      deepest: Color(0xFF141A11),
      bright: Color(0xFFBAD45F),
    ),
    dark: PaletteSpec(
      backgroundTop: Color(0xFF26331F),
      backgroundBottom: Color(0xFF0C1008),
      highlight: Color(0xFFBAD45F),
      onHighlight: Color(0xFF0C1008),
      ink: _cream,
      muted: Color(0xFFA9ABA6),
      accent: Color(0xFFD9C98A),
      holiday: Color(0xFFF2937D),
      deep: Color(0xFF1E2A19),
      deepest: Color(0xFF0C1008),
      bright: Color(0xFFBAD45F),
    ),
  ),
  // Night sky over the Himalaya: indigo with saffron.
  AppPalette.himalaya: (
    light: PaletteSpec(
      backgroundTop: Color(0xFFDCE2F1),
      backgroundBottom: Color(0xFFF6F5F1),
      highlight: Color(0xFF2C3E7A),
      onHighlight: Colors.white,
      ink: Color(0xFF141830),
      muted: Color(0xFF5D6378),
      accent: Color(0xFFB0701A),
      holiday: Color(0xFFC4472F),
      deep: Color(0xFF2C3E7A),
      deepest: Color(0xFF141B33),
      bright: Color(0xFFF2A65A),
    ),
    dark: PaletteSpec(
      backgroundTop: Color(0xFF1C2444),
      backgroundBottom: Color(0xFF090C18),
      highlight: Color(0xFFF2A65A),
      onHighlight: Color(0xFF1C1106),
      ink: Color(0xFFF3F1EC),
      muted: Color(0xFFA3A9BF),
      accent: Color(0xFFE8C77A),
      holiday: Color(0xFFFF8F7A),
      deep: Color(0xFF1E2A50),
      deepest: Color(0xFF090C18),
      bright: Color(0xFFF2A65A),
    ),
  ),
  // Clay pots and brick: terracotta with peach.
  AppPalette.terracotta: (
    light: PaletteSpec(
      backgroundTop: Color(0xFFF1DDCF),
      backgroundBottom: Color(0xFFFAF5EF),
      highlight: Color(0xFFA8482A),
      onHighlight: Colors.white,
      ink: Color(0xFF2A1810),
      muted: Color(0xFF7A6258),
      accent: Color(0xFF8E6514),
      holiday: Color(0xFFB3261E),
      deep: Color(0xFF8E3A20),
      deepest: Color(0xFF2A130A),
      bright: Color(0xFFF2B48C),
    ),
    dark: PaletteSpec(
      backgroundTop: Color(0xFF3A2219),
      backgroundBottom: Color(0xFF130A06),
      highlight: Color(0xFFEBA27A),
      onHighlight: Color(0xFF221007),
      ink: Color(0xFFF7EEE8),
      muted: Color(0xFFB8A49A),
      accent: Color(0xFFE4C48A),
      holiday: Color(0xFFFF8A80),
      deep: Color(0xFF4A2A1E),
      deepest: Color(0xFF130A06),
      bright: Color(0xFFEBA27A),
    ),
  ),
  // Lali gurans: plum with rhododendron pink.
  AppPalette.rhododendron: (
    light: PaletteSpec(
      backgroundTop: Color(0xFFF2DCE5),
      backgroundBottom: Color(0xFFFBF6F7),
      highlight: Color(0xFFA3235A),
      onHighlight: Colors.white,
      ink: Color(0xFF2A1220),
      muted: Color(0xFF7A6070),
      accent: Color(0xFF9A6A16),
      holiday: Color(0xFFC62828),
      deep: Color(0xFF8A1E4C),
      deepest: Color(0xFF2A0A1A),
      bright: Color(0xFFF59BB8),
    ),
    dark: PaletteSpec(
      backgroundTop: Color(0xFF3A1A2E),
      backgroundBottom: Color(0xFF110710),
      highlight: Color(0xFFF285A8),
      onHighlight: Color(0xFF2A0716),
      ink: Color(0xFFF7EEF2),
      muted: Color(0xFFB6A0AE),
      accent: Color(0xFFF2C46D),
      holiday: Color(0xFFFF8A80),
      deep: Color(0xFF4A1E38),
      deepest: Color(0xFF110710),
      bright: Color(0xFFF285A8),
    ),
  ),
  // Phewa lake: deep teal with aqua.
  AppPalette.lake: (
    light: PaletteSpec(
      backgroundTop: Color(0xFFD2E8E6),
      backgroundBottom: Color(0xFFF5F8F7),
      highlight: Color(0xFF0F6B66),
      onHighlight: Colors.white,
      ink: Color(0xFF0E2422),
      muted: Color(0xFF55706F),
      accent: Color(0xFF8A6D1F),
      holiday: Color(0xFFC4472F),
      deep: Color(0xFF0F5A56),
      deepest: Color(0xFF06201E),
      bright: Color(0xFF7EDACD),
    ),
    dark: PaletteSpec(
      backgroundTop: Color(0xFF12333A),
      backgroundBottom: Color(0xFF051214),
      highlight: Color(0xFF6FD3C6),
      onHighlight: Color(0xFF04201C),
      ink: Color(0xFFEEF6F5),
      muted: Color(0xFF9FB3B5),
      accent: Color(0xFFE8C77A),
      holiday: Color(0xFFFF9A85),
      deep: Color(0xFF164049),
      deepest: Color(0xFF051214),
      bright: Color(0xFF6FD3C6),
    ),
  ),
  // The traditional patro: maroon with gold.
  AppPalette.maroon: (
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
  ),
};
