import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:patro/core/bs/bs_date.dart';
import 'package:patro/core/bs/date_formatter.dart';
import 'package:patro/features/settings/models/app_settings.dart';

void main() {
  setUpAll(initializeDateFormatting);

  const ne = DateFormatter(language: AppLanguage.ne, numerals: NumeralStyle.devanagari);
  const en = DateFormatter(language: AppLanguage.en, numerals: NumeralStyle.western);
  const date = BsDate(2083, 6, 14);

  test('converts digits both ways', () {
    expect(convertDigits('2083-06', NumeralStyle.devanagari), '२०८३-०६');
    expect(convertDigits('२०८३ abc', NumeralStyle.western), '2083 abc');
  });

  test('formats BS dates', () {
    expect(ne.bsDate(date), 'असोज १४, २०८३');
    expect(en.bsDate(date), 'Ashwin 14, 2083');
    expect(ne.bsDateWithWeekday(date), 'बुधबार, असोज १४, २०८३');
    expect(en.weekdayShort(6), 'Sat');
  });

  test('formats AD dates with the chosen digits', () {
    expect(en.adDateLong(DateTime(2026, 9, 30)), 'Wednesday, September 30, 2026');
    expect(ne.adDateLong(DateTime(2026, 9, 30)), contains('३०'));
    expect(en.adSpan(const BsDate(2083, 6, 1)), 'Sep/Oct 2026');
    expect(en.adSpan(const BsDate(2083, 9, 1)), 'Dec/Jan 2026/2027');
  });
}
