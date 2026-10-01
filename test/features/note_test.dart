import 'package:flutter_test/flutter_test.dart';
import 'package:patro/core/bs/bs_date.dart';
import 'package:patro/features/notes/models/note.dart';

void main() {
  const from = BsDate(2083, 1, 1);
  const to = BsDate(2085, 12, 30);

  test('one-off note occurs once', () {
    const note = Note(title: 'x', date: BsDate(2083, 6, 14));
    expect(note.occurrencesBetween(from, to), [const BsDate(2083, 6, 14)]);
    expect(note.nextOccurrence(const BsDate(2083, 6, 15)), isNull);
  });

  test('yearly BS repeats on the same BS date, clamped', () {
    const note = Note(title: 'x', date: BsDate(2082, 3, 32), repeat: RepeatRule.yearlyBs);
    final list = note.occurrencesBetween(from, to);
    expect(list.first, const BsDate(2083, 3, 32));
    expect(list.every((d) => d.month == 3), isTrue);
    for (final d in list) {
      expect(d.day, BsDate.daysInMonth(d.year, 3).clamp(0, 32));
    }
  });

  test('yearly AD repeats on the same AD date', () {
    final note = Note(title: 'x', date: BsDate.fromAd(DateTime(2020, 9, 30)), repeat: RepeatRule.yearlyAd);
    final list = note.occurrencesBetween(from, to);
    expect(list.map((d) => (d.toAd().month, d.toAd().day)).toSet(), {(9, 30)});
    expect(list.length, 3);
  });

  test('monthly BS repeats every month and never before the start date', () {
    const note = Note(title: 'x', date: BsDate(2083, 6, 14), repeat: RepeatRule.monthlyBs);
    final list = note.occurrencesBetween(from, const BsDate(2083, 12, 30));
    expect(list.first, const BsDate(2083, 6, 14));
    expect(list.length, 7);
  });

  test('nextOccurrence finds the upcoming birthday', () {
    const note = Note(title: 'x', date: BsDate(2050, 2, 10), repeat: RepeatRule.yearlyBs);
    expect(note.nextOccurrence(const BsDate(2083, 6, 14)), const BsDate(2084, 2, 10));
    expect(note.nextOccurrence(const BsDate(2083, 2, 10)), const BsDate(2083, 2, 10));
  });
}
