import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/astro/bs_calculator.dart';
import '../../../core/bs/bs_date.dart';
import '../../../core/bs/date_formatter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/holiday_repository.dart';
import '../../calendar/models/day_event.dart';
import '../../calendar/models/season.dart';
import '../../notes/cubit/notes_cubit.dart';
import '../models/app_settings.dart';

/// Today's facts the previews show, from the same sources as the real
/// notification and widgets.
class _Today {
  _Today(BuildContext context, AppSettings settings) : fmt = DateFormatter.of(settings), date = BsDate.today() {
    tithi = fmt.tithi(const BsCalculator().tithiOn(date.toAd()));
    final events = EventIndex(
      holidays: context.read<HolidayRepository>(),
      notes: context.read<NotesCubit>().state.notes,
      language: settings.language,
    ).between(date, date.addDays(60));
    next = events.isEmpty ? null : events.first;
  }

  final DateFormatter fmt;
  final BsDate date;
  late final String tithi;
  late final DayEvent? next;

  String get weekday => fmt.weekday(date.weekday);
  String get monthYear => fmt.bsMonthYear(date.year, date.month);
  String get day => fmt.number(date.day);
  String get adDate => fmt.adDate(date.toAd());
  String? get nextLine =>
      next == null ? null : '${fmt.monthName(next!.date.month)} ${fmt.number(next!.date.day)}: ${next!.title}';
}

/// Rounded frame that every preview sits in, with a small caption.
class PreviewFrame extends StatelessWidget {
  const PreviewFrame({super.key, required this.label, required this.child, this.background});

  final String label;
  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: background ?? p.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: p.muted, fontSize: 11, letterSpacing: 0.4)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// How dates read with the chosen language and digits.
class LanguagePreview extends StatelessWidget {
  const LanguagePreview({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final t = _Today(context, settings);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.fmt.bsDate(t.date), style: serif(30, onSurface)),
        const SizedBox(height: 2),
        Text('${t.weekday} · ${t.fmt.adDateFull(t.date.toAd())}', style: TextStyle(color: context.patro.muted)),
        const SizedBox(height: 8),
        Text(
          t.tithi,
          style: TextStyle(color: context.patro.accent, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// A week of calendar tiles in the current theme, with or without AD dates.
class LookPreview extends StatelessWidget {
  const LookPreview({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final t = _Today(context, settings);
    final sunday = t.date.addDays(-t.date.weekday);
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: () {
              final d = sunday.addDays(i);
              final isToday = d == t.date;
              final color = isToday ? p.onHighlight : (i == 6 ? p.accent : onSurface);
              return Container(
                margin: const EdgeInsets.all(2),
                height: settings.showAdInCalendar ? 52 : 42,
                decoration: BoxDecoration(
                  color: isToday ? p.highlight : p.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.cardBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.fmt.number(d.day),
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: color),
                    ),
                    if (settings.showAdInCalendar)
                      Text(
                        t.fmt.number(d.toAd().day),
                        style: TextStyle(fontSize: 10, color: isToday ? p.onHighlight.withValues(alpha: 0.7) : p.muted),
                      ),
                  ],
                ),
              );
            }(),
          ),
      ],
    );
  }
}

/// A sample reminder notification at the chosen default time.
class ReminderPreview extends StatelessWidget {
  const ReminderPreview({super.key, required this.settings, required this.title});

  final AppSettings settings;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = _Today(context, settings);
    return _NotificationShell(
      trailing: t.fmt.time(settings.reminderMinutes),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          Text(t.fmt.bsDate(t.date.addDays(1)), style: TextStyle(color: context.patro.muted, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Android-style notification card.
class _NotificationShell extends StatelessWidget {
  const _NotificationShell({required this.child, this.trailing, this.icon});

  final Widget child;
  final String? trailing;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = context.patro;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon ??
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(color: p.highlight, borderRadius: BorderRadius.circular(5)),
                  ),
              const SizedBox(width: 8),
              Text('Patro', style: TextStyle(color: p.muted, fontSize: 12)),
              const Spacer(),
              if (trailing != null) Text(trailing!, style: TextStyle(color: p.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// The ongoing "today" notification in the chosen style.
class NotificationPreview extends StatelessWidget {
  const NotificationPreview({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final t = _Today(context, settings);
    final ad = settings.todayNotificationShowAd ? t.adDate : null;
    final event = settings.todayNotificationShowEvents ? t.nextLine : null;
    final sub = [t.tithi, ?ad].join(' · ');
    TextStyle muted([double size = 13]) => TextStyle(color: p.muted, fontSize: size);
    const maroon = Color(0xFF7A1F1F);

    final Widget body = switch (settings.todayNotificationStyle) {
      TodayNotificationStyle.number => Row(
        children: [
          Text(t.day, style: serif(40, p.highlight, weight: FontWeight.w600, height: 1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t.monthYear} · ${t.weekday}', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(sub, style: muted()),
              ],
            ),
          ),
        ],
      ),
      TodayNotificationStyle.page => Row(
        children: [
          Container(
            width: 46,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: const Color(0xFFFBF5EC), borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Container(
                  height: 15,
                  width: double.infinity,
                  color: maroon,
                  alignment: Alignment.center,
                  child: Text(
                    t.fmt.monthName(t.date.month),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      t.day,
                      style: const TextStyle(color: maroon, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.weekday, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(sub, style: muted()),
              ],
            ),
          ),
        ],
      ),
      TodayNotificationStyle.moon => Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF44403C),
            child: const Icon(Icons.brightness_3, color: Color(0xFFF3E2B3), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.tithi, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${t.weekday} · ${t.fmt.bsDate(t.date)}', style: muted()),
              ],
            ),
          ),
        ],
      ),
      TodayNotificationStyle.week => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${t.fmt.bsDate(t.date)}, ${t.weekday}', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(sub, style: muted()),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: () {
                    final d = t.date.addDays(i - t.date.weekday);
                    final today = d == t.date;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: today ? p.highlight : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        t.fmt.number(d.day),
                        style: TextStyle(fontSize: 13, color: today ? p.onHighlight : (i == 6 ? p.accent : onSurface)),
                      ),
                    );
                  }(),
                ),
            ],
          ),
        ],
      ),
      TodayNotificationStyle.countdown => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.next == null
                ? '${t.fmt.bsDate(t.date)} · ${t.weekday}'
                : '${t.next!.title} · ${t.fmt.number(t.date.daysUntil(t.next!.date))}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text('${t.fmt.bsDate(t.date)} · $sub', style: muted()),
        ],
      ),
      TodayNotificationStyle.plain => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${t.fmt.bsDate(t.date)} · ${t.weekday}', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text([t.tithi, ?event ?? ad].join(' · '), style: muted()),
        ],
      ),
    };

    return Opacity(
      opacity: settings.todayNotification ? 1 : 0.45,
      child: _NotificationShell(
        icon: Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.highlight, borderRadius: BorderRadius.circular(5)),
          child: Text(
            BsDate.today().day.toString(),
            style: TextStyle(color: p.onHighlight, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            body,
            if (event != null && settings.todayNotificationStyle != TodayNotificationStyle.plain) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(width: 3, height: 14, color: p.holiday),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(event, maxLines: 1, overflow: TextOverflow.ellipsis, style: muted(12.5)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Colours of the home-screen widget themes (kept in step with
/// android/.../widget/WidgetTheme.kt and ios/PatroWidget/Theme.swift).
({Color bg, Color text, Color muted, Color number, Color gold}) _widgetPalette(WidgetTheme theme) => switch (theme) {
  WidgetTheme.cream => (
    bg: const Color(0xFFFBF5EC),
    text: const Color(0xFF2B1A14),
    muted: const Color(0xFF7A6558),
    number: const Color(0xFF7A1F1F),
    gold: const Color(0xFFA8711A),
  ),
  WidgetTheme.photo => (
    bg: const Color(0xFF3A1712),
    text: Colors.white,
    muted: const Color(0xFFEADBD2),
    number: Colors.white,
    gold: const Color(0xFFF2C66D),
  ),
  WidgetTheme.maroon => (
    bg: const Color(0xFF6E1B1B),
    text: Colors.white,
    muted: const Color(0xFFE8C9C0),
    number: Colors.white,
    gold: const Color(0xFFF2C66D),
  ),
  WidgetTheme.marigold => (
    bg: const Color(0xFFF6D58E),
    text: const Color(0xFF3A1A0E),
    muted: const Color(0xFF6B4A2E),
    number: const Color(0xFF7A1F1F),
    gold: const Color(0xFF8A3B12),
  ),
};

/// The small Today widget and the Upcoming widget in the chosen theme.
class WidgetPreview extends StatelessWidget {
  const WidgetPreview({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final t = _Today(context, settings);
    final c = _widgetPalette(settings.widgetTheme);
    final season = settings.previewSeason ?? Season.ofMonth(t.date.month);

    Widget card({required double width, required Widget child}) => SizedBox(
      width: width,
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: c.bg),
            if (settings.widgetTheme == WidgetTheme.photo) ...[
              Image.asset(season.asset, fit: BoxFit.cover, alignment: season.focus),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0x8C1A0606), const Color(0x8C3A0E0E), const Color(0xD93A0E0E)],
                  ),
                ),
              ),
            ],
            Padding(padding: const EdgeInsets.all(12), child: child),
          ],
        ),
      ),
    );

    final small = card(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.monthYear,
            style: TextStyle(color: c.number, fontSize: 11, fontWeight: FontWeight.w700),
          ),
          Text(
            t.day,
            style: TextStyle(color: c.number, fontSize: 40, fontWeight: FontWeight.w700, height: 1.1),
          ),
          const Spacer(),
          Text(t.weekday, style: TextStyle(color: c.text, fontSize: 12)),
          Text(
            t.tithi,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: c.gold, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediumWidth = constraints.maxWidth - 140 - 10;
        return Row(
          children: [
            small,
            const SizedBox(width: 10),
            if (mediumWidth > 120)
              card(
                width: mediumWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (t.next == null)
                      Text('—', style: TextStyle(color: c.muted))
                    else ...[
                      Text(
                        t.next!.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.fmt.number(t.date.daysUntil(t.next!.date)),
                        style: TextStyle(color: c.number, fontSize: 30, fontWeight: FontWeight.w700),
                      ),
                      Text(t.fmt.bsDate(t.next!.date), style: TextStyle(color: c.muted, fontSize: 11)),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
