import 'package:flutter/material.dart';

/// Colours from the design, plus calendar-specific roles Material's
/// ColorScheme doesn't cover.
@immutable
class PatroColors extends ThemeExtension<PatroColors> {
  const PatroColors({
    required this.headerStart,
    required this.headerEnd,
    required this.onHeader,
    required this.accent,
    required this.holiday,
    required this.muted,
    required this.tipBackground,
  });

  final Color headerStart;
  final Color headerEnd;
  final Color onHeader;

  /// Gold, used for Saturdays and highlights.
  final Color accent;

  /// Public holidays.
  final Color holiday;
  final Color muted;
  final Color tipBackground;

  static const light = PatroColors(
    headerStart: Color(0xFF7A1F1F),
    headerEnd: Color(0xFF5C1616),
    onHeader: Colors.white,
    accent: Color(0xFFB57F24),
    holiday: Color(0xFFB3261E),
    muted: Color(0xFF8A6A5A),
    tipBackground: Color(0xFFB9862F),
  );

  static const dark = PatroColors(
    headerStart: Color(0xFF5E1A1A),
    headerEnd: Color(0xFF3A0F0F),
    onHeader: Color(0xFFFBEFE6),
    accent: Color(0xFFE0B25C),
    holiday: Color(0xFFFF8A80),
    muted: Color(0xFFB9A193),
    tipBackground: Color(0xFF7D5A1F),
  );

  @override
  PatroColors copyWith() => this;

  @override
  PatroColors lerp(PatroColors? other, double t) {
    if (other == null) return this;
    return PatroColors(
      headerStart: Color.lerp(headerStart, other.headerStart, t)!,
      headerEnd: Color.lerp(headerEnd, other.headerEnd, t)!,
      onHeader: Color.lerp(onHeader, other.onHeader, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      holiday: Color.lerp(holiday, other.holiday, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      tipBackground: Color.lerp(tipBackground, other.tipBackground, t)!,
    );
  }
}

extension PatroThemeX on BuildContext {
  PatroColors get patro => Theme.of(this).extension<PatroColors>()!;
}

class AppTheme {
  static const _maroon = Color(0xFF7A1F1F);

  static ThemeData light() => _build(
    ColorScheme.fromSeed(
      seedColor: _maroon,
      primary: _maroon,
      onPrimary: Colors.white,
      surface: const Color(0xFFFBF5EC),
      onSurface: const Color(0xFF2B1A14),
      surfaceContainerLow: const Color(0xFFF5ECDF),
      surfaceContainer: const Color(0xFFF1E6D6),
      surfaceContainerHigh: const Color(0xFFEDE0CD),
      secondaryContainer: const Color(0xFFF2E3C6),
      onSecondaryContainer: const Color(0xFF3A2A12),
      outlineVariant: const Color(0xFFE6D8C6),
    ),
    PatroColors.light,
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(
      seedColor: _maroon,
      brightness: Brightness.dark,
      primary: const Color(0xFFE8A39A),
      onPrimary: const Color(0xFF4A0E0E),
      primaryContainer: const Color(0xFF7A1F1F),
      onPrimaryContainer: Colors.white,
      surface: const Color(0xFF1C1512),
      onSurface: const Color(0xFFF1E6DC),
      surfaceContainerLow: const Color(0xFF241C18),
      surfaceContainer: const Color(0xFF2A211C),
      surfaceContainerHigh: const Color(0xFF342A24),
    ),
    PatroColors.dark,
  );

  static ThemeData _build(ColorScheme scheme, PatroColors patro) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      extensions: [patro],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(base.textTheme.labelMedium),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(selectedBackgroundColor: scheme.secondaryContainer),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
