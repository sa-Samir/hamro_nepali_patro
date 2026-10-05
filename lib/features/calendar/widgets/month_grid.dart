import 'package:flutter/material.dart';

import '../../../core/bs/bs_date.dart';
import '../../../core/bs/date_formatter.dart';
import '../../../core/theme/app_theme.dart';
import '../models/day_event.dart';

/// Rows needed to show [month] in a Sunday-first grid.
int weeksInMonth(BsDate month) {
  final first = month.firstOfMonth;
  return ((first.weekday + first.daysInThisMonth) / 7).ceil();
}

/// Sunday-first grid of one BS month.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.today,
    required this.selected,
    required this.fmt,
    required this.onSelect,
    this.onLongPress,
    this.eventsOf,
    this.showAd = true,
    this.cellHeight = 64,
  });

  final BsDate month;
  final BsDate today;
  final BsDate? selected;
  final DateFormatter fmt;
  final ValueChanged<BsDate> onSelect;
  final ValueChanged<BsDate>? onLongPress;

  /// Events for a day; used for holiday colouring and markers.
  final List<DayEvent> Function(BsDate date)? eventsOf;
  final bool showAd;
  final double cellHeight;

  @override
  Widget build(BuildContext context) {
    final first = month.firstOfMonth;
    final leading = first.weekday;
    final days = first.daysInThisMonth;
    final rows = weeksInMonth(first);
    return Column(
      children: [
        for (var row = 0; row < rows; row++)
          SizedBox(
            height: cellHeight,
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: () {
                      final day = row * 7 + col - leading + 1;
                      if (day < 1 || day > days) return const SizedBox.shrink();
                      final date = BsDate(first.year, first.month, day);
                      return _DayCell(
                        date: date,
                        isToday: date == today,
                        isSelected: date == selected,
                        isSaturday: col == 6,
                        events: eventsOf?.call(date) ?? const [],
                        fmt: fmt,
                        showAd: showAd,
                        onTap: () => onSelect(date),
                        onLongPress: onLongPress == null ? null : () => onLongPress!(date),
                      );
                    }(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isSaturday,
    required this.events,
    required this.fmt,
    required this.showAd,
    required this.onTap,
    this.onLongPress,
  });

  final BsDate date;
  final bool isToday;
  final bool isSelected;
  final bool isSaturday;
  final List<DayEvent> events;
  final DateFormatter fmt;
  final bool showAd;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final patro = context.patro;
    final isHoliday = events.any((e) => e.kind == DayEventKind.holiday);
    final hasNote = events.any((e) => e.kind == DayEventKind.note);
    final hasFestival = events.any((e) => e.kind == DayEventKind.festival);

    final Color dayColor;
    if (isToday) {
      dayColor = patro.onHighlight;
    } else if (isHoliday) {
      dayColor = patro.holiday;
    } else if (isSaturday) {
      dayColor = patro.accent;
    } else {
      dayColor = scheme.onSurface;
    }
    final adColor = isToday ? patro.onHighlight.withValues(alpha: 0.7) : patro.muted;
    final ad = date.toAd();

    final semantics = [
      fmt.bsDateWithWeekday(date),
      if (showAd) fmt.adDate(ad),
      for (final e in events) e.title,
    ].join(', ');

    // Every day is a small rounded tile; today is filled, the selection outlined.
    return Semantics(
      button: true,
      selected: isSelected,
      label: semantics,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: isToday ? patro.highlight : patro.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isSelected && !isToday ? patro.highlight : patro.cardBorder,
              width: isSelected && !isToday ? 1.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fmt.number(date.day),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: dayColor, height: 1.1),
                ),
                if (showAd) Text(fmt.number(ad.day), style: TextStyle(fontSize: 10.5, color: adColor, height: 1.3)),
                const SizedBox(height: 2),
                SizedBox(
                  height: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasFestival && !isHoliday) _Dot(color: isToday ? patro.onHighlight : patro.muted),
                      if (hasNote) _Dot(color: isToday ? patro.onHighlight : patro.highlight),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 5,
    height: 5,
    margin: const EdgeInsets.symmetric(horizontal: 1.5),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Sunday → Saturday header row.
class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({super.key, required this.fmt});

  final DateFormatter fmt;

  @override
  Widget build(BuildContext context) {
    final patro = context.patro;
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Text(
                  fmt.weekdayShort(i),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: i == 6 ? patro.accent : patro.muted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
