import 'astro.dart';

/// Computes the Bikram Sambat calendar where no published table exists.
///
/// Month starts follow the Sankranti of the Surya Siddhanta sun — the model
/// Nepal's panchanga still uses — with the day rules measured against the
/// published table (tool/astro_experiment.dart; ~99% of months 1970–2100):
/// - the month starts on the Nepal civil day of the Sankranti, counting the
///   first [_midnightGraceMinutes] after midnight as the previous day;
/// - Karka Sankranti (Shrawan) before sunrise starts the previous day;
/// - Makara Sankranti (Magh) after sunset starts the next day.
class BsCalculator {
  const BsCalculator();

  static const _nepalUtcOffsetMinutes = 345;
  static const _midnightGraceMinutes = 10;

  /// AD date (UTC midnight) on which BS [month] (1–12) of [year] begins.
  /// [near] must be within a few days of the answer.
  DateTime monthStart(int month, DateTime near) {
    final guess = julianDay(near);
    final instant = findAngleCrossing(suryaSiddhantaSunLongitude, (month - 1) * 30.0, guess - 6, guess + 6);
    final local = dateTimeFromJulianDay(
      instant,
    ).add(const Duration(minutes: _nepalUtcOffsetMinutes - _midnightGraceMinutes));
    var day = DateTime.utc(local.year, local.month, local.day);
    if (month == 4 && instant < sunriseJd(day.year, day.month, day.day)) {
      day = day.subtract(const Duration(days: 1));
    }
    if (month == 10 && instant > sunsetJd(day.year, day.month, day.day)) {
      day = day.add(const Duration(days: 1));
    }
    return day;
  }

  /// Month lengths of BS [year], given the AD date of its 1 Baisakh.
  /// Also returns the start of the following year so callers can chain.
  ({List<int> lengths, DateTime nextYearStart}) year(DateTime baisakhFirst) {
    final starts = <DateTime>[baisakhFirst];
    for (var m = 2; m <= 13; m++) {
      starts.add(monthStart((m - 1) % 12 + 1, starts.last.add(const Duration(days: 30))));
    }
    return (
      lengths: [for (var i = 0; i < 12; i++) starts[i + 1].difference(starts[i]).inDays],
      nextYearStart: starts.last,
    );
  }

  /// Tithi in effect at sunrise in Kathmandu on the given AD calendar date.
  Tithi tithiOn(DateTime adDate) => Tithi(tithiAt(sunriseJd(adDate.year, adDate.month, adDate.day)));
}

/// A lunar day, 1–30: 1–15 shukla paksha (15 = purnima), 16–30 krishna
/// paksha (30 = amavasya / aunsi).
class Tithi {
  const Tithi(this.number) : assert(number >= 1 && number <= 30);

  final int number;

  bool get isShukla => number <= 15;

  /// 1–15 within the fortnight.
  int get dayOfPaksha => isShukla ? number : number - 15;

  bool get isPurnima => number == 15;

  bool get isAmavasya => number == 30;

  @override
  bool operator ==(Object other) => other is Tithi && other.number == number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Tithi($number)';
}
