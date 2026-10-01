import 'package:flutter_test/flutter_test.dart';
import 'package:patro/core/bs/bs_date.dart';
import 'package:patro/data/repositories/holiday_repository.dart';
import 'package:patro/features/calendar/models/day_event.dart';
import 'package:patro/features/notes/models/note.dart';
import 'package:patro/features/settings/models/app_settings.dart';

void main() {
  final holidays = HolidayRepository.fromList(const [
    Holiday(date: BsDate(2083, 6, 25), titleEn: 'Ghatasthapana', titleNe: 'घटस्थापना', isPublicHoliday: true),
    Holiday(date: BsDate(2083, 6, 25), titleEn: 'Some observance', titleNe: 'पर्व', isPublicHoliday: false),
  ]);
  const birthday = Note(id: 1, title: 'Birthday', date: BsDate(2060, 6, 25), repeat: RepeatRule.yearlyBs);

  test('merges holidays and notes, holidays first, in the chosen language', () {
    final index = EventIndex(holidays: holidays, notes: const [birthday], language: AppLanguage.ne);
    final events = index.on(const BsDate(2083, 6, 25));
    expect(events.map((e) => e.kind), [DayEventKind.holiday, DayEventKind.festival, DayEventKind.note]);
    expect(events.first.title, 'घटस्थापना');
    expect(events.last.note, birthday);
    expect(index.on(const BsDate(2083, 6, 24)), isEmpty);
  });

  test('ranges are sorted by date', () {
    final index = EventIndex(
      holidays: holidays,
      notes: const [Note(id: 2, title: 'Earlier', date: BsDate(2083, 6, 20))],
      language: AppLanguage.en,
    );
    final events = index.between(const BsDate(2083, 6, 1), const BsDate(2083, 6, 31));
    expect(events.map((e) => e.title), ['Earlier', 'Ghatasthapana', 'Some observance']);
    expect(holidays.years, [2083]);
    expect(holidays.isPublicHoliday(const BsDate(2083, 6, 25)), isTrue);
  });
}
