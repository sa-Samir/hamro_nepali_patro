import 'package:intl/intl.dart';

import '../../features/settings/models/app_settings.dart';
import '../astro/bs_calculator.dart';
import 'bs_date.dart';

const _devanagariDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];

const bsMonthsNe = [
  'बैशाख', 'जेठ', 'असार', 'साउन', 'भदौ', 'असोज', //
  'कात्तिक', 'मंसिर', 'पुस', 'माघ', 'फागुन', 'चैत',
];
const bsMonthsEn = [
  'Baisakh', 'Jestha', 'Asar', 'Shrawan', 'Bhadra', 'Ashwin', //
  'Kartik', 'Mangsir', 'Poush', 'Magh', 'Falgun', 'Chaitra',
];
const _tithisNe = [
  'प्रतिपदा', 'द्वितीया', 'तृतीया', 'चतुर्थी', 'पञ्चमी', 'षष्ठी', 'सप्तमी', //
  'अष्टमी', 'नवमी', 'दशमी', 'एकादशी', 'द्वादशी', 'त्रयोदशी', 'चतुर्दशी',
];
const _tithisEn = [
  'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami', 'Shashthi', 'Saptami', //
  'Ashtami', 'Navami', 'Dashami', 'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi',
];
const _weekdaysShortNe = ['आइत', 'सोम', 'मंगल', 'बुध', 'बिहि', 'शुक्र', 'शनि'];
const _weekdaysShortEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _weekdaysNe = ['आइतबार', 'सोमबार', 'मंगलबार', 'बुधबार', 'बिहीबार', 'शुक्रबार', 'शनिबार'];
const _weekdaysEn = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

/// Converts any ASCII or Devanagari digits in [input] to the requested style.
String convertDigits(String input, NumeralStyle style) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final ascii = rune - 0x30;
    final devanagari = rune - 0x966;
    if (style == NumeralStyle.devanagari && ascii >= 0 && ascii <= 9) {
      buffer.write(_devanagariDigits[ascii]);
    } else if (style == NumeralStyle.western && devanagari >= 0 && devanagari <= 9) {
      buffer.write(devanagari);
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

/// Formats BS/AD dates and numbers according to the user's language and
/// numeral preferences. Pure Dart so it can be used outside the widget tree
/// (notifications, widgets sync).
class DateFormatter {
  const DateFormatter({required this.language, required this.numerals});

  factory DateFormatter.of(AppSettings settings) =>
      DateFormatter(language: settings.language, numerals: settings.numerals);

  final AppLanguage language;
  final NumeralStyle numerals;

  bool get _ne => language == AppLanguage.ne;

  String number(int value) => convertDigits('$value', numerals);

  String digits(String value) => convertDigits(value, numerals);

  String monthName(int month) => (_ne ? bsMonthsNe : bsMonthsEn)[month - 1];

  /// The month name in the language that is *not* active, used as a subtitle.
  String otherMonthName(int month) => (_ne ? bsMonthsEn : bsMonthsNe)[month - 1];

  /// [weekday]: 0 = Sunday … 6 = Saturday.
  String weekdayShort(int weekday) => (_ne ? _weekdaysShortNe : _weekdaysShortEn)[weekday];

  String weekday(int weekday) => (_ne ? _weekdaysNe : _weekdaysEn)[weekday];

  /// "असोज १४, २०८३" / "Ashwin 14, 2083".
  String bsDate(BsDate date) => '${monthName(date.month)} ${number(date.day)}, ${number(date.year)}';

  /// "असोज २०८३" / "Ashwin 2083".
  String bsMonthYear(int year, int month) => '${monthName(month)} ${number(year)}';

  /// "बुधबार, असोज १४, २०८३".
  String bsDateWithWeekday(BsDate date) => '${weekday(date.weekday)}, ${bsDate(date)}';

  /// "Wednesday, September 30, 2026" in the active language.
  String adDateLong(DateTime date) => digits(DateFormat.yMMMMEEEEd(language.name).format(date));

  /// "Sep 30, 2026".
  String adDate(DateTime date) => digits(DateFormat.yMMMd(language.name).format(date));

  /// AD month span of a BS month, e.g. "Sep/Oct 2026".
  String adSpan(BsDate firstOfMonth) {
    final start = firstOfMonth.toAd();
    final end = BsDate(firstOfMonth.year, firstOfMonth.month, firstOfMonth.daysInThisMonth).toAd();
    final fmt = DateFormat.MMM(language.name);
    final years = start.year == end.year ? '${end.year}' : '${start.year}/${end.year}';
    return digits('${fmt.format(start)}/${fmt.format(end)} $years');
  }

  /// "शुक्ल षष्ठी" / "Shukla Shashthi"; full and new moon stand alone.
  String tithi(Tithi t) {
    if (t.isPurnima) return _ne ? 'पूर्णिमा' : 'Purnima';
    if (t.isAmavasya) return _ne ? 'औंसी' : 'Aunsi';
    final paksha = t.isShukla ? (_ne ? 'शुक्ल' : 'Shukla') : (_ne ? 'कृष्ण' : 'Krishna');
    return '$paksha ${(_ne ? _tithisNe : _tithisEn)[t.dayOfPaksha - 1]}';
  }

  /// "8:00 AM" style time from minutes after midnight.
  String time(int minutesOfDay) {
    final dt = DateTime(2000, 1, 1, minutesOfDay ~/ 60, minutesOfDay % 60);
    return digits(DateFormat.jm(language.name).format(dt));
  }
}
