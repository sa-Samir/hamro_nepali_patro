import 'package:flutter_test/flutter_test.dart';
import 'package:patro/core/astro/astro.dart';

/// Julian Day (UT) for an instant given in Terrestrial Time, as Meeus's
/// worked examples are.
double _utFromTt(double jdTt, double year) => jdTt - deltaTSeconds(year) / 86400;

DateTime _nepalTime(double jd) => dateTimeFromJulianDay(jd).add(const Duration(minutes: 345));

void main() {
  test('sun longitude matches Meeus example 25.a', () {
    final jd = _utFromTt(2448908.5, 1992.8); // 1992 Oct 13.0 TD
    expect(sunLongitude(jd), closeTo(199.90895, 0.01));
  });

  test('moon longitude matches Meeus example 47.a', () {
    final jd = _utFromTt(2448724.5, 1992.3); // 1992 Apr 12.0 TD
    expect(moonLongitude(jd), closeTo(133.1627, 0.01));
  });

  test('new moon of 2000 Jan 6 (Meeus example 49.a) is within minutes', () {
    final expected = _utFromTt(2451550.25965, 2000.0);
    final found = findAngleCrossing(elongation, 0, expected - 1, expected + 1);
    expect((found - expected).abs() * 1440, lessThan(5));
  });

  test('Kathmandu sunrise and sunset are plausible', () {
    final juneSunrise = _nepalTime(sunriseJd(2026, 6, 21));
    final decemberSunrise = _nepalTime(sunriseJd(2026, 12, 21));
    final octoberSunset = _nepalTime(sunsetJd(2026, 10, 1));
    expect(juneSunrise.hour * 60 + juneSunrise.minute, inInclusiveRange(5 * 60 + 3, 5 * 60 + 13));
    expect(decemberSunrise.hour * 60 + decemberSunrise.minute, inInclusiveRange(6 * 60 + 47, 6 * 60 + 58));
    expect(octoberSunset.hour * 60 + octoberSunset.minute, inInclusiveRange(17 * 60 + 40, 17 * 60 + 54));
  });

  test('Lahiri ayanamsa is about 24°13′ in 2026', () {
    expect(lahiriAyanamsa(julianDay(DateTime.utc(2026))), closeTo(24.22, 0.02));
  });

  test('tithi values stay within 1–30', () {
    for (var d = 0; d < 60; d++) {
      expect(tithiAt(julianDay(DateTime.utc(2026, 9, 1 + d, 1))), inInclusiveRange(1, 30));
    }
  });
}
