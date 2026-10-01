import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patro/core/bs/bs_date.dart';
import 'package:patro/features/calendar/cubit/calendar_cubit.dart';
import 'package:patro/features/converter/cubit/converter_cubit.dart';
import 'package:patro/features/notes/cubit/note_editor_cubit.dart';
import 'package:patro/features/notes/models/note.dart';

void main() {
  const today = BsDate(2083, 6, 14);

  group('CalendarCubit', () {
    blocTest<CalendarCubit, CalendarState>(
      'next month selects its first day, today resets',
      build: () => CalendarCubit(clock: () => today),
      act: (c) => c
        ..nextMonth()
        ..goToToday(),
      expect: () => [
        const CalendarState(today: today, visibleMonth: BsDate(2083, 7, 1), selected: BsDate(2083, 7, 1)),
        const CalendarState(today: today, visibleMonth: BsDate(2083, 6, 1), selected: today),
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'refreshToday follows the date when today was selected',
      build: () {
        var now = today;
        final cubit = CalendarCubit(clock: () => now);
        now = const BsDate(2083, 6, 15);
        return cubit;
      },
      act: (c) => c.refreshToday(),
      expect: () => [
        const CalendarState(
          today: BsDate(2083, 6, 15),
          visibleMonth: BsDate(2083, 6, 1),
          selected: BsDate(2083, 6, 15),
        ),
      ],
    );

    test('month index round-trips', () {
      expect(monthAtIndex(monthIndexOf(today)), today.firstOfMonth);
      expect(monthAtIndex(monthCount - 1), BsDate.max.firstOfMonth);
    });
  });

  group('ConverterCubit', () {
    test('AD input converts to BS', () {
      final cubit = ConverterCubit(today: today)..setAdDate(DateTime(2026, 10, 20));
      expect(cubit.state.date, const BsDate(2083, 7, 3));
      expect(cubit.state.daysFromToday, 20);
    });

    test('bsDifference counts years, months and days', () {
      expect(bsDifference(const BsDate(2050, 2, 10), today), (years: 33, months: 4, days: 4));
      expect(bsDifference(const BsDate(2083, 5, 20), today), (years: 0, months: 0, days: 25));
    });
  });

  group('NoteEditorCubit', () {
    test('requires a title, then saves trimmed values', () async {
      Note? saved;
      final cubit = NoteEditorCubit(
        date: today,
        defaultReminderMinutes: 420,
        save: (n) async {
          saved = n;
          return 7;
        },
        delete: (_) async {},
      );
      expect(await cubit.save(), isFalse);
      expect(cubit.state.showErrors, isTrue);

      cubit
        ..setTitle('  Aama birthday ')
        ..setRepeat(RepeatRule.yearlyBs)
        ..toggleOffset(7)
        ..toggleOffset(0);
      expect(await cubit.save(), isTrue);
      expect(saved!.title, 'Aama birthday');
      expect(saved!.reminderOffsets, [1, 7]);
      expect(saved!.reminderMinutes, 420);
      expect(cubit.state.draft.id, 7);
      expect(cubit.state.status, EditorStatus.saved);
    });
  });
}
