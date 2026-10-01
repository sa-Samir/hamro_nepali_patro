import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:patro/core/bs/bs_date.dart';
import 'package:patro/data/remote/calendar_data_bundle.dart';
import 'package:patro/data/remote/calendar_data_service.dart';
import 'package:patro/data/repositories/holiday_repository.dart';

// A plausible "official" 2084 that differs from the bundled one.
const _official2084 = [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30];

String _bundle({int revision = 1, List<int> lengths = _official2084}) => jsonEncode({
  'format': 'patro-data',
  'schema': 1,
  'revision': revision,
  'verifiedThrough': 2084,
  'monthLengths': {'2084': lengths},
  'holidays': {
    '2084': {
      'events': [
        {'month': 1, 'day': 1, 'en': 'Nepali New Year', 'ne': 'नयाँ वर्ष', 'holiday': true},
        {'month': 3, 'day': 32, 'en': 'Only valid with the new lengths', 'ne': 'परीक्षण', 'holiday': false},
      ],
    },
  },
});

void main() {
  tearDown(BsDate.resetOverrides);

  group('BsDate overrides', () {
    test('replace a year and mark it verified', () {
      expect(BsDate.isEstimatedYear(2084), isTrue);
      final before = const BsDate(2084, 3, 1).toAd();
      BsDate.applyOverrides({2084: _official2084}, verifiedThrough: 2084);
      expect(BsDate.isEstimatedYear(2084), isFalse);
      expect(BsDate.isEstimatedYear(2085), isTrue);
      expect(const BsDate(2084, 3, 32).isValid, isTrue);
      expect(const BsDate(2084, 3, 1).toAd(), before.subtract(const Duration(days: 1)));
      expect(BsDate.overrides, {2084: _official2084});
    });

    test('ignore invalid rows', () {
      final applied = BsDate.applyOverrides({
        2084: [30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30], // 360 days
        1800: _official2084, // out of range
      });
      expect(applied, isEmpty);
      expect(BsDate.isEstimatedYear(2084), isTrue);
    });
  });

  group('CalendarDataBundle', () {
    test('parses month lengths and holidays checked against the new lengths', () {
      final bundle = CalendarDataBundle.parse(_bundle());
      expect(bundle.revision, 1);
      expect(bundle.monthLengths[2084], _official2084);
      expect(bundle.holidays[2084]!.map((h) => h.titleEn), contains('Only valid with the new lengths'));
    });

    test('rejects broken files', () {
      expect(() => CalendarDataBundle.parse('nope'), throwsFormatException);
      expect(() => CalendarDataBundle.parse('{"format":"other"}'), throwsFormatException);
      expect(() => CalendarDataBundle.parse(_bundle(lengths: [31, 31])), throwsFormatException);
      expect(
        () => CalendarDataBundle.parse(jsonEncode({...jsonDecode(_bundle()) as Map, 'schema': 99})),
        throwsFormatException,
      );
    });
  });

  group('CalendarDataService', () {
    late Directory dir;
    late HolidayRepository holidays;
    late int requests;
    late DateTime now;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('patro_data');
      holidays = HolidayRepository.fromList(const []);
      requests = 0;
      now = DateTime(2026, 10, 1, 9);
    });
    tearDown(() => dir.delete(recursive: true));

    CalendarDataService service(http.Client client) => CalendarDataService(
      holidays: holidays,
      source: Uri.parse('https://example.test/patro-data.json'),
      client: client,
      storage: () async => dir,
      clock: () => now,
    );

    MockClient serving(String body, {String etag = '"v1"'}) => MockClient((request) async {
      requests++;
      if (request.headers['If-None-Match'] == etag) return http.Response('', 304);
      return http.Response.bytes(utf8.encode(body), 200, headers: {'etag': etag});
    });

    test('downloads, applies, caches and throttles', () async {
      final s = service(serving(_bundle()));
      expect(await s.refresh(), isTrue);
      expect(s.revision, 1);
      expect(BsDate.isEstimatedYear(2084), isFalse);
      expect(holidays.on(const BsDate(2084, 1, 1)).single.titleEn, 'Nepali New Year');

      expect(await s.refresh(), isFalse, reason: 'checked recently');
      expect(requests, 1);

      now = now.add(const Duration(hours: 13));
      expect(await s.refresh(), isFalse, reason: 'unchanged (304)');
      expect(requests, 2);

      // A fresh start uses the cached copy without the network.
      BsDate.resetOverrides();
      final restarted = service(serving('should not be fetched'));
      await restarted.loadCached();
      expect(restarted.revision, 1);
      expect(BsDate.isEstimatedYear(2084), isFalse);
    });

    test('keeps current data when the download is bad or older', () async {
      final s = service(serving(_bundle(revision: 3)));
      await s.refresh();
      now = now.add(const Duration(days: 1));
      final bad = service(serving('{"format":"patro-data","schema":1,"revision":9}', etag: '"v2"'));
      await bad.loadCached();
      expect(await bad.refresh(), isFalse);
      expect(bad.revision, 3);

      final older = service(serving(_bundle(revision: 2), etag: '"v3"'));
      await older.loadCached();
      expect(await older.refresh(force: true), isFalse);
      expect(older.revision, 3);
    });

    test('does nothing offline', () async {
      final s = service(MockClient((_) async => throw const SocketException('offline')));
      expect(await s.refresh(), isFalse);
      expect(s.revision, 0);
    });
  });
}
