import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/bs/bs_date.dart';
import '../models/holiday.dart';

export '../models/holiday.dart';

/// Holidays and festivals: bundled under `assets/holidays/<year>.json`,
/// optionally replaced per year by downloaded data ([applyDownloaded]).
class HolidayRepository {
  HolidayRepository._(this._bundled) {
    _reindex();
  }

  static const _dir = 'assets/holidays/';

  /// Loads every bundled holiday file.
  static Future<HolidayRepository> load([AssetBundle? bundle]) async {
    bundle ??= rootBundle;
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final files = manifest.listAssets().where((p) => p.startsWith(_dir) && p.endsWith('.json'));
    final byYear = <int, List<Holiday>>{};
    for (final path in files) {
      final json = jsonDecode(await bundle.loadString(path)) as Map<String, dynamic>;
      final year = json['year'] as int;
      byYear[year] = parseHolidayYear(year, json);
    }
    return HolidayRepository._(byYear);
  }

  /// For tests.
  HolidayRepository.fromList(List<Holiday> holidays) : _bundled = {} {
    for (final h in holidays) {
      _bundled.putIfAbsent(h.date.year, () => []).add(h);
    }
    _reindex();
  }

  final Map<int, List<Holiday>> _bundled;
  Map<int, List<Holiday>> _downloaded = const {};
  final Map<BsDate, List<Holiday>> _byDate = {};

  /// BS years that have holiday data.
  List<int> get years => ({..._bundled.keys, ..._downloaded.keys}.toList()..sort());

  /// Replaces whole years with downloaded data; years not listed keep the
  /// bundled data.
  void applyDownloaded(Map<int, List<Holiday>> byYear) {
    _downloaded = Map.unmodifiable(byYear);
    _reindex();
  }

  void _reindex() {
    _byDate.clear();
    for (final year in years) {
      for (final h in _downloaded[year] ?? _bundled[year]!) {
        _byDate.putIfAbsent(h.date, () => []).add(h);
      }
    }
  }

  List<Holiday> on(BsDate date) => _byDate[date] ?? const [];

  bool isPublicHoliday(BsDate date) => on(date).any((h) => h.isPublicHoliday);
}
