// Measures how well an astronomical calculation reproduces the BS month
// table. For every month it finds the Sankranti (sun entering the sidereal
// sign) and applies several traditional "which day does the month start"
// rules, under two sun models. Run: dart run tool/astro_experiment.dart
//
// Result (Oct 2026): the Surya Siddhanta sun with the rules in BsCalculator
// matches ~99% of months; modern (drik) positions top out around 80%.
// ignore_for_file: avoid_print
import 'package:patro/core/astro/astro.dart';
import 'package:patro/core/astro/bs_calculator.dart';
import 'package:patro/core/bs/bs_data.dart';

typedef Rule = DateTime Function(double instant, DateTime civilDate);

const _nptMinutes = 345;

DateTime _civil(double jd) {
  final local = dateTimeFromJulianDay(jd).add(const Duration(minutes: _nptMinutes));
  return DateTime.utc(local.year, local.month, local.day);
}

double _rise(DateTime d) => sunriseJd(d.year, d.month, d.day);
double _set(DateTime d) => sunsetJd(d.year, d.month, d.day);

final rules = <String, Rule>{
  'same civil day': (_, d) => d,
  'next civil day': (_, d) => d.add(const Duration(days: 1)),
  'first sunrise after': (t, d) => t < _rise(d) ? d : d.add(const Duration(days: 1)),
  'Hindu day containing it': (t, d) => t < _rise(d) ? d.subtract(const Duration(days: 1)) : d,
  'before sunset → same day': (t, d) => t < _set(d) ? d : d.add(const Duration(days: 1)),
  'Nepal rule (BsCalculator)': (_, _) => DateTime(0), // handled below
  'before 3/5 of daytime → same day': (t, d) {
    final rise = _rise(d);
    return t < rise + 0.6 * (_set(d) - rise) ? d : d.add(const Duration(days: 1));
  },
};

final models = <String, double Function(double)>{
  'Drik (Lahiri)': siderealSunLongitude,
  'Surya Siddhanta': suryaSiddhantaSunLongitude,
};

void main() {
  // AD start date of every month in the table.
  final starts = <(int, int), DateTime>{};
  var cursor = bsEpochAd;
  // Only the table's own rows; later years are generated from the calculator.
  for (var y = 0; y <= 2100 - bsFirstYear; y++) {
    for (var m = 0; m < 12; m++) {
      starts[(bsFirstYear + y, m + 1)] = cursor;
      cursor = cursor.add(Duration(days: bsMonthLengths[y][m]));
    }
  }

  for (final model in models.entries) {
    // Sankranti instants, computed once per model.
    final sankranti = <(int, int), double>{};
    starts.forEach((key, start) {
      final guess = julianDay(start);
      sankranti[key] = findAngleCrossing(model.value, (key.$2 - 1) * 30.0, guess - 4, guess + 4);
    });

    print('\n== ${model.key} ==');
    for (final rule in rules.entries) {
      final byPeriod = <String, List<int>>{
        '1970–2000': [0, 0],
        '2001–2083': [0, 0],
        '2084–2100': [0, 0],
      };
      final offsets = <int, int>{};
      starts.forEach((key, start) {
        final instant = sankranti[key]!;
        final predicted = rule.key.startsWith('Nepal')
            ? const BsCalculator().monthStart(key.$2, start)
            : rule.value(instant, _civil(instant));
        final diff = predicted.difference(start).inDays;
        offsets[diff] = (offsets[diff] ?? 0) + 1;
        final period = key.$1 <= 2000
            ? '1970–2000'
            : key.$1 <= 2083
            ? '2001–2083'
            : '2084–2100';
        byPeriod[period]![1]++;
        if (diff == 0) byPeriod[period]![0]++;
      });
      final parts = byPeriod.entries
          .map((e) => '${e.key}: ${(100 * e.value[0] / e.value[1]).toStringAsFixed(1)}%')
          .join('  ');
      final sortedOffsets = (offsets.keys.toList()..sort()).map((k) => '${k > 0 ? '+' : ''}$k:${offsets[k]}').join(' ');
      print('${rule.key.padRight(34)} $parts   offsets[$sortedOffsets]');
    }
  }
}
