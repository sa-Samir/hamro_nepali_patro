import 'dart:math' as math;

/// Low-level astronomy used to *estimate* the calendar where no published
/// data exists. Formulas follow Jean Meeus, "Astronomical Algorithms" (2nd
/// ed.): sun ch. 25 (~0.01°), moon ch. 47 main terms (~10″), ΔT from the
/// Espenak–Meeus polynomials.
///
/// Times are Julian Days in Universal Time unless a name says TT.

const double _deg = math.pi / 180;

double _norm360(double x) => x - 360 * (x / 360).floorToDouble();

double _sinD(double d) => math.sin(d * _deg);
double _cosD(double d) => math.cos(d * _deg);

/// Julian Day (UT) of a UTC [DateTime].
double julianDay(DateTime utc) {
  final u = utc.toUtc();
  return u.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
}

DateTime dateTimeFromJulianDay(double jd) =>
    DateTime.fromMillisecondsSinceEpoch(((jd - 2440587.5) * 86400000).round(), isUtc: true);

/// TT − UT in seconds for a decimal year (valid ~1900–2150).
double deltaTSeconds(double year) {
  final y = year;
  if (y < 1920) {
    final t = y - 1900;
    return -2.79 + 1.494119 * t - 0.0598939 * t * t + 0.0061966 * t * t * t - 0.000197 * t * t * t * t;
  }
  if (y < 1941) {
    final t = y - 1920;
    return 21.20 + 0.84493 * t - 0.076100 * t * t + 0.0020936 * t * t * t;
  }
  if (y < 1961) {
    final t = y - 1950;
    return 29.07 + 0.407 * t - t * t / 233 + t * t * t / 2547;
  }
  if (y < 1986) {
    final t = y - 1975;
    return 45.45 + 1.067 * t - t * t / 260 - t * t * t / 718;
  }
  if (y < 2005) {
    final t = y - 2000;
    return 63.86 +
        0.3345 * t -
        0.060374 * t * t +
        0.0017275 * t * t * t +
        0.000651814 * math.pow(t, 4) +
        0.00002373599 * math.pow(t, 5);
  }
  if (y < 2050) {
    final t = y - 2000;
    return 62.92 + 0.32217 * t + 0.005589 * t * t;
  }
  final u = (y - 1820) / 100;
  return -20 + 32 * u * u - 0.5628 * (2150 - y);
}

double _ttFromUt(double jdUt) {
  final year = 2000 + (jdUt - 2451545.0) / 365.25;
  return jdUt + deltaTSeconds(year) / 86400;
}

/// Julian centuries of TT since J2000.0.
double _centuries(double jdTt) => (jdTt - 2451545.0) / 36525;

/// Apparent geocentric ecliptic longitude of the sun (degrees, tropical).
double sunLongitude(double jdUt) {
  final t = _centuries(_ttFromUt(jdUt));
  final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
  final m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
  final c =
      (1.914602 - 0.004817 * t - 0.000014 * t * t) * _sinD(m) +
      (0.019993 - 0.000101 * t) * _sinD(2 * m) +
      0.000289 * _sinD(3 * m);
  final omega = 125.04 - 1934.136 * t;
  return _norm360(l0 + c - 0.00569 - 0.00478 * _sinD(omega));
}

/// Sun's declination and equation of time (minutes) — for sunrise.
({double declination, double equationOfTime}) _sunForSunrise(double jdUt) {
  final t = _centuries(_ttFromUt(jdUt));
  final lambda = sunLongitude(jdUt);
  final omega = 125.04 - 1934.136 * t;
  final epsilon = 23.439291 - 0.0130042 * t + 0.00256 * _cosD(omega);
  final ra = _norm360(math.atan2(_cosD(epsilon) * _sinD(lambda), _cosD(lambda)) / _deg);
  final dec = math.asin(_sinD(epsilon) * _sinD(lambda)) / _deg;
  final l0 = _norm360(280.46646 + 36000.76983 * t + 0.0003032 * t * t);
  var e = l0 - 0.0057183 - ra;
  e = e - 360 * (e / 360).roundToDouble(); // into −180..180
  return (declination: dec, equationOfTime: e * 4);
}

// Meeus table 47.A (longitude terms): D, M, M′, F, coefficient (1e-6 °).
const _moonTerms = <List<int>>[
  [0, 0, 1, 0, 6288774], [2, 0, -1, 0, 1274027], [2, 0, 0, 0, 658314], //
  [0, 0, 2, 0, 213618], [0, 1, 0, 0, -185116], [0, 0, 0, 2, -114332],
  [2, 0, -2, 0, 58793], [2, -1, -1, 0, 57066], [2, 0, 1, 0, 53322],
  [2, -1, 0, 0, 45758], [0, 1, -1, 0, -40923], [1, 0, 0, 0, -34720],
  [0, 1, 1, 0, -30383], [2, 0, 0, -2, 15327], [0, 0, 1, 2, -12528],
  [0, 0, 1, -2, 10980], [4, 0, -1, 0, 10675], [0, 0, 3, 0, 10034],
  [4, 0, -2, 0, 8548], [2, 1, -1, 0, -7888], [2, 1, 0, 0, -6766],
  [1, 0, -1, 0, -5163], [1, 1, 0, 0, 4987], [2, -1, 1, 0, 4036],
  [2, 0, 2, 0, 3994], [4, 0, 0, 0, 3861], [2, 0, -3, 0, 3665],
  [0, 1, -2, 0, -2689], [2, 0, -1, 2, -2602], [2, -1, -2, 0, 2390],
  [1, 0, 1, 0, -2348], [2, -2, 0, 0, 2236], [0, 1, 2, 0, -2120],
  [0, 2, 0, 0, -2069], [2, -2, -1, 0, 2048], [2, 0, 1, -2, -1773],
  [2, 0, 0, 2, -1595], [4, -1, -1, 0, 1215], [0, 0, 2, 2, -1110],
  [3, 0, -1, 0, -892], [2, 1, 1, 0, -810], [4, -1, -2, 0, 759],
  [0, 2, -1, 0, -713], [2, 2, -1, 0, -700], [2, 1, -2, 0, 691],
  [2, -1, 0, -2, 596], [4, 0, 1, 0, 549], [0, 0, 4, 0, 537],
  [4, -1, 0, 0, 520], [1, 0, -2, 0, -487], [2, 1, 0, -2, -399],
  [0, 0, 2, -2, -381], [1, 1, 1, 0, 351], [3, 0, -2, 0, -340],
  [4, 0, -3, 0, 330], [2, -1, 2, 0, 327], [0, 2, 1, 0, -323],
  [1, 1, -1, 0, 299], [2, 0, 3, 0, 294],
];

/// Geocentric ecliptic longitude of the moon (degrees, tropical, with the
/// same nutation approximation as [sunLongitude] so they can be differenced).
double moonLongitude(double jdUt) {
  final t = _centuries(_ttFromUt(jdUt));
  final t2 = t * t, t3 = t2 * t, t4 = t3 * t;
  final lp = 218.3164477 + 481267.88123421 * t - 0.0015786 * t2 + t3 / 538841 - t4 / 65194000;
  final d = 297.8501921 + 445267.1114034 * t - 0.0018819 * t2 + t3 / 545868 - t4 / 113065000;
  final m = 357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000;
  final mp = 134.9633964 + 477198.8675055 * t + 0.0087414 * t2 + t3 / 69699 - t4 / 14712000;
  final f = 93.2720950 + 483202.0175233 * t - 0.0036539 * t2 - t3 / 3526000 + t4 / 863310000;
  final e = 1 - 0.002516 * t - 0.0000074 * t2;
  final a1 = 119.75 + 131.849 * t;
  final a2 = 53.09 + 479264.290 * t;

  var sum = 0.0;
  for (final term in _moonTerms) {
    var coefficient = term[4].toDouble();
    final mCount = term[1].abs();
    if (mCount == 1) coefficient *= e;
    if (mCount == 2) coefficient *= e * e;
    sum += coefficient * _sinD(term[0] * d + term[1] * m + term[2] * mp + term[3] * f);
  }
  sum += 3958 * _sinD(a1) + 1962 * _sinD(lp - f) + 318 * _sinD(a2);
  final omega = 125.04 - 1934.136 * t;
  return _norm360(lp + sum / 1e6 - 0.00478 * _sinD(omega));
}

/// Lahiri (Chitrapaksha) ayanamsa in degrees: 23°51′25.5″ at J2000 plus
/// general precession in longitude.
double lahiriAyanamsa(double jdUt) {
  final t = _centuries(_ttFromUt(jdUt));
  return 23.857092 + (5029.0966 * t + 1.11113 * t * t) / 3600;
}

/// Sidereal (nirayana) longitude of the sun using the Lahiri ayanamsa.
double siderealSunLongitude(double jdUt) => _norm360(sunLongitude(jdUt) - lahiriAyanamsa(jdUt));

/// True sidereal sun of the Surya Siddhanta (the traditional Hindu model).
/// Mean motion from the Siddhanta's sidereal year, manda (equation of
/// centre) correction with the epicycle shrinking from 14° to 13°40′.
double suryaSiddhantaSunLongitude(double jdUt) {
  const kaliEpochUjjainMidnight = 588465.5 - 75.77 / 360;
  const civilDaysPerMahayuga = 1577917828.0;
  const sunRevolutionsPerMahayuga = 4320000.0;
  const apogee = 77.28; // 77°17′, near-stationary
  final ahargana = jdUt - kaliEpochUjjainMidnight;
  final mean = _norm360(360 * (ahargana * sunRevolutionsPerMahayuga / civilDaysPerMahayuga % 1));
  final anomaly = mean - apogee;
  final periphery = 14 - (20 / 60) * _sinD(anomaly).abs();
  final equation = math.asin(periphery / 360 * _sinD(anomaly)) / _deg;
  return _norm360(mean - equation);
}

/// Moon − sun elongation, 0–360°.
double elongation(double jdUt) => _norm360(moonLongitude(jdUt) - sunLongitude(jdUt));

/// Tithi in effect at [jdUt]: 1–15 shukla (15 = purnima), 16–30 krishna
/// (30 = amavasya).
int tithiAt(double jdUt) => (elongation(jdUt) / 12).floor() + 1;

/// Observer used for sunrise (Kathmandu by default).
class Place {
  const Place(this.latitude, this.longitude, this.utcOffsetMinutes);

  final double latitude;
  final double longitude;
  final int utcOffsetMinutes;

  static const kathmandu = Place(27.7172, 85.3240, 345);
}

/// Sunrise (Julian Day, UT) on the local civil date [year]-[month]-[day].
/// Standard altitude −0.833° (upper limb with refraction).
double sunriseJd(int year, int month, int day, {Place place = Place.kathmandu}) =>
    _riseOrSet(year, month, day, place, rising: true);

/// Sunset (Julian Day, UT) on the local civil date.
double sunsetJd(int year, int month, int day, {Place place = Place.kathmandu}) =>
    _riseOrSet(year, month, day, place, rising: false);

double _riseOrSet(int year, int month, int day, Place place, {required bool rising}) {
  final utcMidnight = julianDay(DateTime.utc(year, month, day));
  var jd = utcMidnight - place.utcOffsetMinutes / 1440 + (rising ? 0.25 : 0.75);
  for (var i = 0; i < 3; i++) {
    final s = _sunForSunrise(jd);
    final cosH =
        (_sinD(-0.833) - _sinD(place.latitude) * _sinD(s.declination)) / (_cosD(place.latitude) * _cosD(s.declination));
    final hourAngle = math.acos(cosH.clamp(-1.0, 1.0)) / _deg;
    final noonUtMinutes = 720 - 4 * place.longitude - s.equationOfTime;
    jd = utcMidnight + (noonUtMinutes + (rising ? -4 : 4) * hourAngle) / 1440;
  }
  return jd;
}

/// Finds when [f] (an angle in degrees that increases with time) reaches
/// [target], searching [start]..[end] (Julian Days). [f] must cross [target]
/// exactly once in the window.
double findAngleCrossing(double Function(double jd) f, double target, double start, double end) {
  double diff(double jd) {
    final d = _norm360(f(jd) - target);
    return d > 180 ? d - 360 : d;
  }

  var lo = start, hi = end;
  for (var i = 0; i < 60; i++) {
    final mid = (lo + hi) / 2;
    if (diff(mid) < 0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}
