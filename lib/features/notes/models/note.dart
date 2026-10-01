import 'package:equatable/equatable.dart';

import '../../../core/bs/bs_date.dart';

enum RepeatRule { none, yearlyBs, yearlyAd, monthlyBs }

/// Days-before options offered in the editor.
const reminderOffsetChoices = [0, 1, 3, 7];

class Note extends Equatable {
  const Note({
    this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.repeat = RepeatRule.none,
    this.remind = true,
    this.reminderOffsets = const [0, 1],
    this.reminderMinutes = 8 * 60,
  });

  /// Null until the note is stored.
  final int? id;
  final String title;
  final String description;

  /// The original (first) date of the note.
  final BsDate date;
  final RepeatRule repeat;
  final bool remind;

  /// How many days before each occurrence to notify, e.g. `[0, 1]`.
  final List<int> reminderOffsets;

  /// Reminder time of day, minutes after midnight.
  final int reminderMinutes;

  Note copyWith({
    int? id,
    String? title,
    String? description,
    BsDate? date,
    RepeatRule? repeat,
    bool? remind,
    List<int>? reminderOffsets,
    int? reminderMinutes,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      repeat: repeat ?? this.repeat,
      remind: remind ?? this.remind,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }

  /// Occurrences in the inclusive range [from]..[to], in order.
  List<BsDate> occurrencesBetween(BsDate from, BsDate to) {
    final result = <BsDate>[];
    void addIfInRange(BsDate d) {
      if (!d.isBefore(from) && !d.isAfter(to) && !d.isBefore(date)) result.add(d);
    }

    switch (repeat) {
      case RepeatRule.none:
        addIfInRange(date);
      case RepeatRule.yearlyBs:
        for (var y = from.year; y <= to.year; y++) {
          if (!BsDate.isSupportedYear(y)) continue;
          addIfInRange(_clamped(y, date.month, date.day));
        }
      case RepeatRule.monthlyBs:
        for (var cursor = from.firstOfMonth; !cursor.isAfter(to); cursor = cursor.addMonths(1)) {
          addIfInRange(_clamped(cursor.year, cursor.month, date.day));
          if (cursor.year == BsDate.max.year && cursor.month == 12) break;
        }
      case RepeatRule.yearlyAd:
        final original = date.toAd();
        final fromAd = from.toAd();
        final toAd = to.toAd();
        for (var y = fromAd.year; y <= toAd.year; y++) {
          final ad = _clampedAd(y, original.month, original.day);
          if (BsDate.isSupportedAd(ad)) addIfInRange(BsDate.fromAd(ad));
        }
    }
    return result;
  }

  /// First occurrence on or after [from], searching up to two years ahead.
  BsDate? nextOccurrence(BsDate from) {
    final end = from.year + 2 <= BsDate.max.year ? BsDate(from.year + 2, 12, 1) : BsDate.max;
    final list = occurrencesBetween(from, end);
    return list.isEmpty ? null : list.first;
  }

  @override
  List<Object?> get props => [id, title, description, date, repeat, remind, reminderOffsets, reminderMinutes];
}

BsDate _clamped(int year, int month, int day) {
  final max = BsDate.daysInMonth(year, month);
  return BsDate(year, month, day > max ? max : day);
}

DateTime _clampedAd(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day > lastDay ? lastDay : day);
}
