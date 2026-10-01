import 'package:flutter_test/flutter_test.dart';
import 'package:patro/core/bs/bs_date.dart';
import 'package:patro/features/notes/models/note.dart';
import 'package:patro/services/reminder_scheduler.dart';

void main() {
  final now = DateTime(2026, 9, 30, 10); // 2083-06-14, 10:00

  test('plans each offset at the reminder time and skips the past', () {
    const note = Note(
      id: 1,
      title: 'Dashain',
      date: BsDate(2083, 6, 25),
      reminderOffsets: [0, 1, 7],
      reminderMinutes: 9 * 60,
    );
    final plan = planReminders([note], now);
    final ad = const BsDate(2083, 6, 25).toAd();
    expect(plan.map((r) => r.at), [
      DateTime(ad.year, ad.month, ad.day - 7, 9),
      DateTime(ad.year, ad.month, ad.day - 1, 9),
      DateTime(ad.year, ad.month, ad.day, 9),
    ]);
  });

  test('today at 8am is already past at 10am', () {
    const note = Note(id: 1, title: 'x', date: BsDate(2083, 6, 14), reminderOffsets: [0], reminderMinutes: 480);
    expect(planReminders([note], now), isEmpty);
  });

  test('ignores notes without reminders and caps the total', () {
    const silent = Note(id: 1, title: 'x', date: BsDate(2083, 7, 1), remind: false);
    const monthly = Note(
      id: 2,
      title: 'y',
      date: BsDate(2083, 6, 20),
      repeat: RepeatRule.monthlyBs,
      reminderOffsets: [0, 1, 3, 7],
    );
    final plan = planReminders([silent, monthly], now, limit: 10);
    expect(plan, hasLength(10));
    expect(plan.every((r) => r.note.id == 2), isTrue);
    for (var i = 1; i < plan.length; i++) {
      expect(plan[i].at.isBefore(plan[i - 1].at), isFalse);
    }
  });
}
