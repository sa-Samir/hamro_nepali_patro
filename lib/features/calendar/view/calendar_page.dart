import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/astro/bs_calculator.dart';
import '../../../core/bs/bs_date.dart';
import '../../../core/context_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../../data/remote/calendar_data_cubit.dart';
import '../../../data/repositories/holiday_repository.dart';
import '../../home/home_shell.dart';
import '../../notes/cubit/notes_cubit.dart';
import '../../notes/view/note_editor_page.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../cubit/calendar_cubit.dart';
import '../models/day_event.dart';
import '../models/season.dart';
import '../widgets/bs_pickers.dart';
import '../widgets/month_grid.dart';

/// Space left at the bottom for the floating navigation bar.
const navClearance = 112.0;

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    context.watch<CalendarDataCubit>(); // month lengths / holidays may change
    final index = EventIndex(
      holidays: context.read<HolidayRepository>(),
      notes: context.watch<NotesCubit>().state.notes,
      language: settings.language,
    );
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final season = settings.previewSeason ?? Season.ofMonth(state.visibleMonth.month);
          return SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, navClearance),
              children: [
                _GreetingRow(state: state, season: season),
                const SizedBox(height: 18),
                _MonthHeading(state: state),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                  child: Column(
                    children: [
                      WeekdayHeader(fmt: context.fmt),
                      const SizedBox(height: 6),
                      _MonthPager(state: state, index: index, showAd: settings.showAdInCalendar),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _DayHeroCard(date: state.selected, events: index.on(state.selected), season: season),
                const SizedBox(height: 16),
                const _QuickActions(),
                const SizedBox(height: 24),
                _UpcomingSection(state: state, index: index),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> openNoteEditor(BuildContext context, BsDate date) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditorPage(initialDate: date)));

/// "नमस्ते / नेपाली पात्रो · शरद ऋतु" with a season-photo avatar and header actions.
/// Today's date is left to the grid and the day card so it appears only once.
class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.state, required this.season});

  final CalendarState state;
  final Season season;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.patro;
    final cubit = context.read<CalendarCubit>();
    return Row(
      children: [
        CircleAvatar(radius: 22, backgroundImage: AssetImage(season.asset)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.greeting, style: TextStyle(color: p.muted, fontSize: 13)),
              Text(
                '${l10n.nepaliCalendar} · ${seasonName(l10n, season)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        RoundIconButton(icon: Icons.today_outlined, tooltip: l10n.today, onPressed: cubit.goToToday),
        const SizedBox(width: 8),
        RoundIconButton(
          icon: Icons.calendar_view_month_outlined,
          tooltip: l10n.goToMonth,
          onPressed: () async {
            final picked = await showMonthPicker(context, state.visibleMonth);
            if (picked != null) cubit.showMonth(picked);
          },
        ),
      ],
    );
  }
}

/// Large serif month + year and AD span, with month arrows.
class _MonthHeading extends StatelessWidget {
  const _MonthHeading({required this.state});

  final CalendarState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final p = context.patro;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cubit = context.read<CalendarCubit>();
    final month = state.visibleMonth;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${fmt.monthName(month.month)} '),
                    TextSpan(
                      text: fmt.number(month.year),
                      style: TextStyle(fontStyle: FontStyle.italic, color: p.muted),
                    ),
                  ],
                ),
                style: serif(46, onSurface, height: 1.05),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    fmt.adSpan(month),
                    style: TextStyle(color: p.muted, fontSize: 13),
                  ),
                  if (BsDate.isEstimatedYear(month.year)) _EstimatedChip(year: month.year),
                ],
              ),
            ],
          ),
        ),
        RoundIconButton(icon: Icons.chevron_left, tooltip: l10n.previousMonth, onPressed: cubit.previousMonth),
        const SizedBox(width: 8),
        RoundIconButton(icon: Icons.chevron_right, tooltip: l10n.nextMonth, onPressed: cubit.nextMonth),
      ],
    );
  }
}

/// Marks years whose dates are calculated rather than published.
class _EstimatedChip extends StatelessWidget {
  const _EstimatedChip({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.patro;
    return Tooltip(
      message: l10n.estimatedExplain(context.fmt.number(year)),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: p.card,
          border: Border.all(color: p.cardBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 13, color: p.muted),
            const SizedBox(width: 4),
            Text(l10n.estimated, style: TextStyle(color: p.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MonthPager extends StatefulWidget {
  const _MonthPager({required this.state, required this.index, required this.showAd});

  final CalendarState state;
  final EventIndex index;
  final bool showAd;

  @override
  State<_MonthPager> createState() => _MonthPagerState();
}

class _MonthPagerState extends State<_MonthPager> {
  late final PageController _controller = PageController(initialPage: monthIndexOf(widget.state.visibleMonth));

  var _animating = false;

  double get _cellHeight => widget.showAd ? 54 : 46;

  @override
  void didUpdateWidget(covariant _MonthPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = monthIndexOf(widget.state.visibleMonth);
    if (!_controller.hasClients) return;
    final current = _controller.page?.round() ?? target;
    if (current == target) return;
    if ((current - target).abs() > 2) {
      _controller.jumpToPage(target);
    } else {
      // Pages passed during the animation must not change the selection.
      _animating = true;
      _controller
          .animateToPage(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic)
          .whenComplete(() => _animating = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = context.fmt;
    final cubit = context.read<CalendarCubit>();
    final rows = weeksInMonth(widget.state.visibleMonth);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: rows * _cellHeight,
      child: PageView.builder(
        controller: _controller,
        itemCount: monthCount,
        onPageChanged: (i) {
          if (!_animating) cubit.showMonth(monthAtIndex(i));
        },
        itemBuilder: (context, i) => MonthGrid(
          month: monthAtIndex(i),
          today: widget.state.today,
          selected: widget.state.selected,
          fmt: fmt,
          showAd: widget.showAd,
          cellHeight: _cellHeight,
          eventsOf: widget.index.on,
          onSelect: cubit.select,
          onLongPress: (d) {
            cubit.select(d);
            openNoteEditor(context, d);
          },
        ),
      ),
    );
  }
}

/// The selected day on the season photo: date, tithi, its events and a
/// single "add reminder" pill.
class _DayHeroCard extends StatelessWidget {
  const _DayHeroCard({required this.date, required this.events, required this.season});

  final BsDate date;
  final List<DayEvent> events;
  final Season season;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final p = context.patro;
    const onPhoto = Color(0xFFF9F5F0);
    final tithi = fmt.tithi(const BsCalculator().tithiOn(date.toAd()));
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(season.asset, fit: BoxFit.cover, alignment: season.focus, excludeFromSemantics: true),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.25), p.headerEnd.withValues(alpha: 0.92)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fmt.bsDate(date), style: serif(32, onPhoto)),
                const SizedBox(height: 2),
                Text(
                  '${fmt.weekday(date.weekday)} · ${fmt.adDateFull(date.toAd())}',
                  style: TextStyle(color: onPhoto.withValues(alpha: 0.8), fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PhotoChip(icon: Icons.brightness_3_outlined, label: tithi, highlighted: true),
                    for (final e in events)
                      _PhotoChip(
                        icon: switch (e.kind) {
                          DayEventKind.holiday => Icons.celebration_outlined,
                          DayEventKind.festival => Icons.temple_hindu_outlined,
                          DayEventKind.note => Icons.notifications_active_outlined,
                        },
                        label: e.title,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => openNoteEditor(context, date),
                    style: FilledButton.styleFrom(backgroundColor: onPhoto, foregroundColor: const Color(0xFF0C1008)),
                    icon: const Icon(Icons.notification_add_outlined, size: 20),
                    label: Text(l10n.remindMe),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoChip extends StatelessWidget {
  const _PhotoChip({required this.icon, required this.label, this.highlighted = false});

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    // Lime reads well on the dark photo wash in both light and dark mode.
    const lime = Color(0xFFBAD45F);
    final fill = highlighted ? lime : Colors.white.withValues(alpha: 0.16);
    final ink = highlighted ? const Color(0xFF0C1008) : const Color(0xFFF9F5F0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: highlighted ? 0 : 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: ink),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three square tiles for the most common jumps.
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.patro;
    final actions = [
      (Icons.swap_horiz, l10n.quickConvert, HomeTab.converter),
      (Icons.notifications_none, l10n.quickReminders, HomeTab.reminders),
      (Icons.widgets_outlined, l10n.quickWidgets, HomeTab.settings),
    ];
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              onTap: () => HomeShell.show(context, actions[i].$3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: p.highlight.withValues(alpha: 0.18), shape: BoxShape.circle),
                    child: Icon(actions[i].$1, size: 20, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    actions[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Next holidays, festivals and reminders from today; when another month is
/// on screen, that month's events instead.
class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({required this.state, required this.index});

  final CalendarState state;
  final EventIndex index;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final month = state.visibleMonth;
    final browsingOtherMonth = !month.isSameMonth(state.today);
    final events = browsingOtherMonth
        ? index.between(month, BsDate(month.year, month.month, month.daysInThisMonth))
        : index.between(state.today, state.today.addDays(45)).take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: browsingOtherMonth ? fmt.bsMonthYear(month.year, month.month) : l10n.upcomingCount,
          count: events.isEmpty ? null : fmt.number(events.length),
        ),
        const SizedBox(height: 8),
        if (events.isEmpty)
          Text(l10n.nothingUpcoming, style: TextStyle(color: context.patro.muted))
        else
          for (final e in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EventCard(event: e, today: state.today),
            ),
      ],
    );
  }
}

/// A holiday, festival or reminder: date tile, title, when, countdown pill.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.today});

  final DayEvent event;
  final BsDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final p = context.patro;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final days = today.daysUntil(event.date);
    final isHoliday = event.kind == DayEventKind.holiday;
    final soon = days >= 0 && days <= 7;
    final when = switch (days) {
      0 => l10n.today,
      > 0 => fmt.digits(l10n.inDays(days)),
      _ => fmt.digits(l10n.daysAgo(-days)),
    };
    return GlassCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        if (event.note != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditorPage(note: event.note)));
        } else {
          context.read<CalendarCubit>().select(event.date);
        }
      },
      child: Row(
        children: [
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              color: isHoliday ? p.holiday.withValues(alpha: 0.16) : p.highlight.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(fmt.number(event.date.day), style: serif(24, isHoliday ? p.holiday : onSurface, height: 1)),
                Text(
                  fmt.monthName(event.date.month),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(fontSize: 10.5, color: p.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 14, color: p.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${fmt.weekday(event.date.weekday)} · ${fmt.adDate(event.date.toAd())}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, color: p.muted),
                      ),
                    ),
                  ],
                ),
                if (isHoliday) ...[
                  const SizedBox(height: 2),
                  Text(l10n.publicHoliday, style: TextStyle(fontSize: 12, color: p.holiday)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: soon ? p.highlight : p.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.cardBorder),
            ),
            child: Text(
              when,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: soon ? p.onHighlight : onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
