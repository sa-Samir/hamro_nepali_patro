import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patro/core/astro/bs_calculator.dart';
import 'package:patro/core/bs/bs_data.dart';
import 'package:patro/core/bs/bs_date.dart';

void main() {
  const calculator = BsCalculator();

  test('reproduces at least 99% of published month starts (1970–2083)', () {
    var start = bsEpochAd;
    var matches = 0, total = 0;
    for (var year = bsFirstYear; year <= bsVerifiedThroughYear; year++) {
      final lengths = bsMonthLengths[year - bsFirstYear];
      var monthStart = start;
      for (var m = 1; m <= 12; m++) {
        if (m > 1 || year > bsFirstYear) {
          total++;
          if (calculator.monthStart(m, monthStart) == monthStart) matches++;
        }
        monthStart = monthStart.add(Duration(days: lengths[m - 1]));
      }
      start = monthStart;
    }
    expect(matches / total, greaterThan(0.99), reason: '$matches of $total');
  });

  test('agrees with the projected table rows 2084–2100', () {
    var start = BsDate(2084, 1, 1).toAd();
    for (var year = 2084; year <= 2100; year++) {
      final computed = calculator.year(DateTime.utc(start.year, start.month, start.day));
      expect(computed.lengths, bsMonthLengths[year - bsFirstYear], reason: 'BS $year');
      start = computed.nextYearStart;
    }
  });

  test('sunrise tithi matches published calendars wherever they agree', () {
    final reference = jsonDecode(File('test/fixtures/tithi_reference.json').readAsStringSync());
    final days = (reference['days'] as List).cast<Map<String, dynamic>>();
    final agreed = days.where((d) => d['sources_agree'] == true).toList();
    expect(agreed.length, greaterThan(250));
    for (final day in agreed) {
      final ad = DateTime.parse(day['ad'] as String);
      expect(calculator.tithiOn(ad).number, day['tithi'], reason: '${day['bs']} (${day['ad']})');
    }
  });

  test('Tithi helpers', () {
    expect(const Tithi(6).isShukla, isTrue);
    expect(const Tithi(21).dayOfPaksha, 6);
    expect(const Tithi(15).isPurnima, isTrue);
    expect(const Tithi(30).isAmavasya, isTrue);
  });
}
