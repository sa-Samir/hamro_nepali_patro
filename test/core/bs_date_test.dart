import 'package:flutter_test/flutter_test.dart';
import 'package:patro/core/bs/bs_date.dart';

void main() {
  group('BsDate conversion', () {
    final knownPairs = {
      DateTime(1913, 4, 13): const BsDate(1970, 1, 1),
      DateTime(2025, 4, 14): const BsDate(2082, 1, 1),
      DateTime(2026, 4, 13): const BsDate(2082, 12, 30),
      DateTime(2026, 4, 14): const BsDate(2083, 1, 1),
      DateTime(2026, 9, 17): const BsDate(2083, 6, 1),
      DateTime(2026, 9, 30): const BsDate(2083, 6, 14),
      DateTime(2027, 4, 13): const BsDate(2083, 12, 30),
      DateTime(2027, 4, 14): const BsDate(2084, 1, 1),
      DateTime(2028, 4, 13): const BsDate(2084, 12, 31),
      DateTime(2028, 4, 14): const BsDate(2085, 1, 1),
    };

    knownPairs.forEach((ad, bs) {
      test('$ad <-> $bs', () {
        expect(BsDate.fromAd(ad), bs);
        expect(bs.toAd(), ad);
      });
    });

    test('round-trips every day of the supported range', () {
      var ad = BsDate.minAd;
      var expected = BsDate.min;
      while (!ad.isAfter(BsDate.maxAd)) {
        final bs = BsDate.fromAd(ad);
        expect(bs, expected);
        final back = bs.toAd();
        expect(DateTime.utc(back.year, back.month, back.day), ad);
        expected = expected.day < expected.daysInThisMonth
            ? BsDate(expected.year, expected.month, expected.day + 1)
            : expected.month < 12
            ? BsDate(expected.year, expected.month + 1, 1)
            : BsDate(expected.year + 1, 1, 1);
        ad = ad.add(const Duration(days: 1));
      }
      expect(expected, BsDate(BsDate.max.year + 1, 1, 1));
    });

    test('ignores time of day', () {
      expect(BsDate.fromAd(DateTime(2026, 9, 30, 23, 59)), const BsDate(2083, 6, 14));
    });

    test('rejects dates outside the table', () {
      expect(() => BsDate.fromAd(DateTime(1900)), throwsRangeError);
      expect(() => BsDate.fromAd(DateTime(2150)), throwsRangeError);
      expect(() => const BsDate(2083, 6, 32).toAd(), throwsRangeError); // Asoj 2083 has 31 days
    });
  });

  test('weekday is 0 for Sunday … 6 for Saturday', () {
    expect(const BsDate(2083, 6, 1).weekday, 4); // Thursday
    expect(const BsDate(2083, 6, 14).weekday, 3); // Wednesday
    expect(const BsDate(1970, 1, 1).weekday, 0); // Sunday
  });

  test('addMonths clamps the day to the target month', () {
    expect(const BsDate(2083, 3, 32).addMonths(1), const BsDate(2083, 4, 31));
    expect(const BsDate(2083, 12, 15).addMonths(1), const BsDate(2084, 1, 15));
    expect(const BsDate(2083, 1, 15).addMonths(-1), const BsDate(2082, 12, 15));
  });

  test('daysUntil and parse', () {
    expect(const BsDate(2083, 6, 1).daysUntil(const BsDate(2083, 6, 14)), 13);
    expect(const BsDate(2083, 6, 14).daysUntil(const BsDate(2083, 6, 1)), -13);
    expect(BsDate.parse('2083-06-14'), const BsDate(2083, 6, 14));
    expect(const BsDate(2083, 6, 14).toString(), '2083-06-14');
  });
}
