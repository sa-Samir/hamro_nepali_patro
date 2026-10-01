import '../../../core/bs/bs_date.dart';
import '../../../data/repositories/holiday_repository.dart';
import '../../notes/models/note.dart';
import '../../settings/models/app_settings.dart';

enum DayEventKind { holiday, festival, note }

/// Anything shown on a calendar day: a bundled holiday/festival or a user note.
class DayEvent {
  const DayEvent({required this.date, required this.kind, required this.title, this.note});

  final BsDate date;
  final DayEventKind kind;
  final String title;

  /// Set for [DayEventKind.note].
  final Note? note;
}

/// Combines bundled holidays and user notes into per-day events.
class EventIndex {
  const EventIndex({required this.holidays, required this.notes, required this.language});

  final HolidayRepository holidays;
  final List<Note> notes;
  final AppLanguage language;

  List<DayEvent> on(BsDate date) => between(date, date);

  /// Events in the inclusive range, sorted by date with holidays first.
  List<DayEvent> between(BsDate from, BsDate to) {
    final result = <DayEvent>[];
    for (var d = from; !d.isAfter(to); d = d.addDays(1)) {
      for (final h in holidays.on(d)) {
        result.add(
          DayEvent(
            date: d,
            kind: h.isPublicHoliday ? DayEventKind.holiday : DayEventKind.festival,
            title: language == AppLanguage.ne ? h.titleNe : h.titleEn,
          ),
        );
      }
    }
    for (final note in notes) {
      for (final d in note.occurrencesBetween(from, to)) {
        result.add(DayEvent(date: d, kind: DayEventKind.note, title: note.title, note: note));
      }
    }
    result.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.kind.index.compareTo(b.kind.index);
    });
    return result;
  }
}
