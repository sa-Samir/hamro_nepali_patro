// Checks a calendar data file before it is published, using the same parser
// as the app. Run: dart run tool/validate_calendar_data.dart [data/patro-data.json]
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:patro/core/astro/bs_calculator.dart';
import 'package:patro/core/bs/bs_date.dart';
import 'package:patro/data/remote/calendar_data_bundle.dart';

void main(List<String> args) {
  final path = args.isEmpty ? 'data/patro-data.json' : args.first;
  final CalendarDataBundle bundle;
  try {
    bundle = CalendarDataBundle.parse(File(path).readAsStringSync());
  } on FormatException catch (e) {
    print('INVALID: ${e.message}');
    exit(1);
  }
  print('revision ${bundle.revision}, verified through ${bundle.verifiedThrough}');

  // Official data may legitimately differ from the calculation, but a
  // difference deserves a second look before thousands of phones get it.
  const calculator = BsCalculator();
  for (final MapEntry(key: year, value: row) in bundle.monthLengths.entries) {
    final start = BsDate(year, 1, 1).toAd();
    final computed = calculator.year(DateTime.utc(start.year, start.month, start.day)).lengths;
    final note = computed.toString() == row.toString() ? 'matches calculation' : 'DIFFERS from calculation $computed';
    print('month lengths $year: $row ($note)');
  }
  for (final MapEntry(key: year, value: list) in bundle.holidays.entries) {
    print('holidays $year: ${list.length} events, ${list.where((h) => h.isPublicHoliday).length} public holidays');
  }
  print('OK');
}
