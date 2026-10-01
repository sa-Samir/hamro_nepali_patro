import 'dart:convert';

import '../../core/bs/bs_date.dart';
import '../models/holiday.dart';

/// Calendar data published after the app was built: official month lengths
/// and holiday lists. See docs/CALENDAR_DATA.md for the file format.
class CalendarDataBundle {
  const CalendarDataBundle({
    required this.revision,
    required this.verifiedThrough,
    required this.monthLengths,
    required this.holidays,
    this.publishedAt,
  });

  static const format = 'patro-data';
  static const schemaVersion = 1;

  /// Increases with every published change; older revisions are ignored.
  final int revision;
  final int verifiedThrough;
  final Map<int, List<int>> monthLengths;
  final Map<int, List<Holiday>> holidays;
  final String? publishedAt;

  /// Throws [FormatException] for anything that isn't a valid bundle, so a
  /// bad upload can never corrupt the calendar.
  factory CalendarDataBundle.parse(String source) {
    try {
      final json = jsonDecode(source) as Map<String, dynamic>;
      if (json['format'] != format) throw const FormatException('Not a Patro data file');
      if ((json['schema'] as int) > schemaVersion) {
        throw const FormatException('Data file needs a newer app version');
      }
      final monthLengths = <int, List<int>>{};
      (json['monthLengths'] as Map<String, dynamic>? ?? const {}).forEach((key, value) {
        final year = int.parse(key);
        final row = (value as List).cast<int>();
        if (!BsDate.isSupportedYear(year) || !BsDate.isValidYearLengths(row)) {
          throw FormatException('Invalid month lengths for $year');
        }
        monthLengths[year] = row;
      });
      final holidays = <int, List<Holiday>>{};
      (json['holidays'] as Map<String, dynamic>? ?? const {}).forEach((key, value) {
        final year = int.parse(key);
        holidays[year] = parseHolidayYear(year, value as Map<String, dynamic>, monthLengths: monthLengths[year]);
      });
      return CalendarDataBundle(
        revision: json['revision'] as int,
        verifiedThrough: json['verifiedThrough'] as int,
        monthLengths: monthLengths,
        holidays: holidays,
        publishedAt: json['publishedAt'] as String?,
      );
    } on FormatException {
      rethrow;
    } on Object catch (e) {
      throw FormatException('Malformed Patro data file: $e');
    }
  }
}
