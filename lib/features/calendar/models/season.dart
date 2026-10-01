import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

/// The six ritus of the Nepali year, two BS months each, with the header
/// photo shown for them (credits in assets/seasons/credits.json).
enum Season {
  basanta(Alignment(0.2, 0)), // Chaitra–Baisakh: rhododendron
  grishma(Alignment.center), // Jestha–Asar: rice planting
  barsha(Alignment(0, 0.3)), // Shrawan–Bhadra: monsoon terraces
  sharad(Alignment(0.2, -0.2)), // Asoj–Kartik: Machhapuchhre
  hemanta(Alignment(-0.3, 0)), // Mangsir–Poush: Swayambhu
  shishir(Alignment(0, -0.3)); // Magh–Falgun: Everest

  const Season(this.focus);

  /// Keeps the photo's subject in view when cropped to the header.
  final Alignment focus;

  String get asset => 'assets/seasons/$name.jpg';

  /// Chaitra (12) and Baisakh (1) are Basanta, then two months per ritu.
  static Season ofMonth(int month) => values[(month % 12) ~/ 2];
}

String seasonName(AppLocalizations l10n, Season season) => switch (season) {
  Season.basanta => l10n.seasonBasanta,
  Season.grishma => l10n.seasonGrishma,
  Season.barsha => l10n.seasonBarsha,
  Season.sharad => l10n.seasonSharad,
  Season.hemanta => l10n.seasonHemanta,
  Season.shishir => l10n.seasonShishir,
};
