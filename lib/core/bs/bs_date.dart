import 'bs_data.dart';

/// A calendar date in Bikram Sambat. Month is 1-based (1 = Baisakh).
///
/// Conversion walks a month-length table from the epoch (1 Baisakh 1970 BS =
/// 13 April 1913 AD). The bundled table ([bsMonthLengths]) can be corrected
/// at runtime with [BsDate.applyOverrides] when official data is published.
class BsDate implements Comparable<BsDate> {
  const BsDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// Converts the calendar date of [ad] (its time and time zone are ignored).
  factory BsDate.fromAd(DateTime ad) {
    var remaining = _dateOnly(ad).difference(bsEpochAd).inDays;
    if (remaining < 0) {
      throw RangeError('$ad is before the supported BS range');
    }
    final yearIndex = _yearIndexForOffset(remaining);
    remaining -= _yearStartOffsets[yearIndex];
    final months = _lengths[yearIndex];
    var month = 0;
    while (remaining >= months[month]) {
      remaining -= months[month];
      month++;
    }
    return BsDate(bsFirstYear + yearIndex, month + 1, remaining + 1);
  }

  /// Today's date in the device's local time zone.
  factory BsDate.today() => BsDate.fromAd(DateTime.now());

  static final DateTime minAd = bsEpochAd;
  static DateTime get maxAd => bsEpochAd.add(Duration(days: _yearStartOffsets.last - 1));
  static const BsDate min = BsDate(bsFirstYear, 1, 1);
  static BsDate get max => BsDate(bsLastYear, 12, daysInMonth(bsLastYear, 12));

  /// Whether [year]'s month lengths are a projection or calculation rather
  /// than a published calendar. Shown to users as "estimated".
  static bool isEstimatedYear(int year) => year > _verifiedThrough && !_officialOverrides.contains(year);

  /// Replaces month lengths for some years with official data, e.g. from a
  /// downloaded update. Rows that fail [isValidYearLengths] or fall outside
  /// the supported range are ignored. Returns the years actually applied.
  static Set<int> applyOverrides(Map<int, List<int>> overrides, {int? verifiedThrough}) {
    final lengths = [for (final row in bsMonthLengths) row];
    final applied = <int>{};
    overrides.forEach((year, row) {
      if (isSupportedYear(year) && isValidYearLengths(row)) {
        lengths[year - bsFirstYear] = List.unmodifiable(row);
        applied.add(year);
      }
    });
    _lengths = lengths;
    _yearStartOffsets = _offsetsFor(lengths);
    _officialOverrides = applied;
    _verifiedThrough = verifiedThrough != null && verifiedThrough > bsVerifiedThroughYear
        ? verifiedThrough
        : bsVerifiedThroughYear;
    return applied;
  }

  /// Month-length rows currently replacing the bundled table, by year.
  static Map<int, List<int>> get overrides => {for (final y in _officialOverrides) y: _lengths[y - bsFirstYear]};

  /// Last year treated as published (not estimated).
  static int get verifiedThroughYear => _verifiedThrough;

  /// Back to the bundled table (tests).
  static void resetOverrides() => applyOverrides(const {});

  /// 12 months of 29–32 days adding up to 365 or 366.
  static bool isValidYearLengths(List<int> row) {
    if (row.length != 12 || row.any((d) => d < 29 || d > 32)) return false;
    final total = row.fold<int>(0, (a, b) => a + b);
    return total == 365 || total == 366;
  }

  static bool isSupportedYear(int year) => year >= bsFirstYear && year <= bsLastYear;

  static bool isSupportedAd(DateTime ad) {
    final date = _dateOnly(ad);
    return !date.isBefore(minAd) && !date.isAfter(maxAd);
  }

  static int daysInMonth(int year, int month) {
    if (!isSupportedYear(year) || month < 1 || month > 12) {
      throw RangeError('BS $year/$month is outside the supported range');
    }
    return _lengths[year - bsFirstYear][month - 1];
  }

  bool get isValid => isSupportedYear(year) && month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth(year, month);

  /// The matching AD date as a local, midnight [DateTime].
  DateTime toAd() {
    if (!isValid) throw RangeError('Invalid BS date $this');
    var offset = _yearStartOffsets[year - bsFirstYear] + day - 1;
    final months = _lengths[year - bsFirstYear];
    for (var m = 0; m < month - 1; m++) {
      offset += months[m];
    }
    final utc = bsEpochAd.add(Duration(days: offset));
    return DateTime(utc.year, utc.month, utc.day);
  }

  /// 0 = Sunday … 6 = Saturday.
  int get weekday => toAd().weekday % 7;

  int get daysInThisMonth => daysInMonth(year, month);

  /// Same day in the month [count] months away, clamped to that month's
  /// length (e.g. 32 Asar → 31 Shrawan).
  BsDate addMonths(int count) {
    final index = year * 12 + (month - 1) + count;
    final y = index ~/ 12;
    final m = index % 12 + 1;
    final maxDay = daysInMonth(y, m);
    return BsDate(y, m, day > maxDay ? maxDay : day);
  }

  BsDate addDays(int count) => BsDate.fromAd(toAd().add(Duration(days: count)));

  /// Whole days from this date to [other] (positive if [other] is later).
  int daysUntil(BsDate other) => _dateOnly(other.toAd()).difference(_dateOnly(toAd())).inDays;

  BsDate get firstOfMonth => BsDate(year, month, 1);

  bool isSameMonth(BsDate other) => year == other.year && month == other.month;

  bool isBefore(BsDate other) => compareTo(other) < 0;

  bool isAfter(BsDate other) => compareTo(other) > 0;

  @override
  int compareTo(BsDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) => other is BsDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// Parses the `yyyy-mm-dd` form produced by [toString].
  static BsDate parse(String value) {
    final parts = value.split('-').map(int.parse).toList();
    return BsDate(parts[0], parts[1], parts[2]);
  }
}

/// Month lengths in use: the bundled table plus any applied overrides.
List<List<int>> _lengths = bsMonthLengths;

/// Day offset of 1 Baisakh of each year from the epoch, with one extra entry
/// marking the end of the table.
List<int> _yearStartOffsets = _offsetsFor(bsMonthLengths);

int _verifiedThrough = bsVerifiedThroughYear;
Set<int> _officialOverrides = const {};

List<int> _offsetsFor(List<List<int>> lengths) {
  final offsets = <int>[0];
  for (final months in lengths) {
    offsets.add(offsets.last + months.fold<int>(0, (a, b) => a + b));
  }
  return offsets;
}

int _yearIndexForOffset(int offset) {
  if (offset >= _yearStartOffsets.last) {
    throw RangeError('Date is after the supported BS range');
  }
  var low = 0;
  var high = _yearStartOffsets.length - 2;
  while (low < high) {
    final mid = (low + high + 1) ~/ 2;
    if (_yearStartOffsets[mid] <= offset) {
      low = mid;
    } else {
      high = mid - 1;
    }
  }
  return low;
}

DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);
