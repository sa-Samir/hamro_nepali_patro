import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/bs/bs_date.dart';
import '../repositories/holiday_repository.dart';
import 'calendar_data_bundle.dart';

/// Keeps the calendar current without app updates: downloads the published
/// data file (no account, nothing personal sent — a plain GET), keeps the
/// last good copy for offline use and applies it to [BsDate] and [holidays].
class CalendarDataService {
  CalendarDataService({
    required this.holidays,
    Uri? source,
    http.Client? client,
    Future<Directory> Function()? storage,
    DateTime Function()? clock,
  }) : source = source ?? _configuredSource,
       _client = client ?? http.Client(),
       _storage = storage ?? getApplicationSupportDirectory,
       _clock = clock ?? DateTime.now;

  /// Set at build time: `--dart-define=PATRO_DATA_URL=https://…/patro-data.json`.
  static final Uri? _configuredSource = switch (const String.fromEnvironment('PATRO_DATA_URL')) {
    '' => null,
    final url => Uri.parse(url),
  };

  static const checkInterval = Duration(hours: 12);

  final HolidayRepository holidays;
  final Uri? source;
  final http.Client _client;
  final Future<Directory> Function() _storage;
  final DateTime Function() _clock;

  CalendarDataBundle? _current;

  /// Revision of the applied data, or 0 when only bundled data is in use.
  int get revision => _current?.revision ?? 0;

  /// Applies the cached copy, if any. Fast and offline.
  Future<void> loadCached() async {
    try {
      final file = await _file('calendar_data.json');
      if (await file.exists()) _apply(CalendarDataBundle.parse(await file.readAsString()));
    } on Object catch (e) {
      debugPrint('Ignoring cached calendar data: $e');
    }
  }

  /// Downloads newer data if the last check is older than [checkInterval]
  /// (or [force]). Returns true when new data was applied.
  Future<bool> refresh({bool force = false}) async {
    final url = source;
    if (url == null) return false;
    try {
      final stamp = await _file('calendar_data.checked');
      final etagFile = await _file('calendar_data.etag');
      if (!force && await stamp.exists()) {
        final last = DateTime.tryParse(await stamp.readAsString());
        if (last != null && _clock().difference(last) < checkInterval) return false;
      }
      final etag = await etagFile.exists() ? await etagFile.readAsString() : null;
      final response = await _client
          .get(url, headers: {if (etag != null && _current != null) 'If-None-Match': etag})
          .timeout(const Duration(seconds: 15));
      await stamp.writeAsString(_clock().toIso8601String());
      if (response.statusCode == 304 || response.statusCode != 200) return false;

      final body = response.body;
      final bundle = CalendarDataBundle.parse(body);
      if (bundle.revision <= revision) return false;
      await (await _file('calendar_data.json')).writeAsString(body);
      final newEtag = response.headers['etag'];
      if (newEtag != null) await etagFile.writeAsString(newEtag);
      _apply(bundle);
      return true;
    } on Object catch (e) {
      // Offline, timeouts, bad uploads: keep what we have.
      debugPrint('Calendar data refresh failed: $e');
      return false;
    }
  }

  void _apply(CalendarDataBundle bundle) {
    BsDate.applyOverrides(bundle.monthLengths, verifiedThrough: bundle.verifiedThrough);
    holidays.applyDownloaded(bundle.holidays);
    _current = bundle;
  }

  Future<File> _file(String name) async => File('${(await _storage()).path}/$name');
}
