import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/astro/bs_calculator.dart';
import '../../../core/bs/bs_date.dart';
import '../../../core/bs/date_formatter.dart';
import '../../../core/context_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/remote/calendar_data_cubit.dart';
import '../../../data/repositories/holiday_repository.dart';
import '../../notes/cubit/notes_cubit.dart';
import '../../notes/view/note_editor_page.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/models/app_settings.dart';
import '../cubit/calendar_cubit.dart';
import '../models/day_event.dart';
import '../models/season.dart';
import '../widgets/bs_pickers.dart';
import '../widgets/month_grid.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  /// Whether the header has scrolled under the status bar.
  final _scrolled = ValueNotifier(false);

  @override
  void dispose() {
    _scrolled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    context.watch<CalendarDataCubit>(); // month lengths / holidays may change
    final index = EventIndex(
      holidays: context.read<HolidayRepository>(),
      notes: context.watch<NotesCubit>().state.notes,
      language: settings.language,
    );
    final topInset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) => Stack(
          children: [
            NotificationListener<ScrollUpdateNotification>(
              onNotification: (n) {
                if (n.metrics.axis == Axis.vertical) _scrolled.value = n.metrics.pixels > 8;
                return false;
              },
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _Header(state: state, showTip: !settings.tipDismissed, topInset: topInset),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                        child: WeekdayHeader(fmt: context.fmt),
                      ),
                    ),
                    SliverToBoxAdapter(child: Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _MonthPager(state: state, index: index, showAd: settings.showAdInCalendar),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      sliver: SliverToBoxAdapter(
                        child: _DayAndMonthEvents(state: state, index: index),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Solid status bar once content scrolls under it, so the light
            // status icons never sit on the cream background.
            ValueListenableBuilder(
              valueListenable: _scrolled,
              builder: (context, scrolled, _) => IgnorePointer(
                child: AnimatedOpacity(
                  opacity: scrolled ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(height: topInset, color: context.patro.headerEnd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openNoteEditor(BuildContext context, BsDate date) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditorPage(initialDate: date)));

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.showTip, required this.topInset});

  final CalendarState state;
  final bool showTip;

  /// Status bar height; the photo extends underneath it.
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final patro = context.patro;
    final theme = Theme.of(context);
    final month = state.visibleMonth;
    final onHeader = patro.onHeader;
    final cubit = context.read<CalendarCubit>();
    // Subtitle in the other language, e.g. "Ashwin 2083" under "असोज".
    final isNe = fmt.language == AppLanguage.ne;
    final otherFmt = DateFormatter(
      language: isNe ? AppLanguage.en : AppLanguage.ne,
      numerals: isNe ? NumeralStyle.western : NumeralStyle.devanagari,
    );

    final season = context.select((SettingsCubit c) => c.state.previewSeason) ?? Season.ofMonth(month.month);

    return Stack(
      children: [
        Positioned.fill(child: _SeasonBackdrop(season: season)),
        Column(
          children: [
            SizedBox(height: topInset),
            if (showTip) const _TipBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.nepaliCalendar} · ${seasonName(l10n, season)}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: onHeader.withValues(alpha: 0.9)),
                            ),
                            Text(
                              fmt.monthName(month.month),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: onHeader,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '${otherFmt.monthName(month.month)} ${otherFmt.number(month.year)}',
                                  style: theme.textTheme.titleMedium?.copyWith(color: onHeader.withValues(alpha: 0.85)),
                                ),
                                if (BsDate.isEstimatedYear(month.year)) ...[
                                  const SizedBox(width: 10),
                                  _EstimatedChip(year: month.year),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: state.visibleMonth == state.today.firstOfMonth && state.selected == state.today
                            ? null
                            : cubit.goToToday,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: onHeader,
                          disabledForegroundColor: onHeader.withValues(alpha: 0.6),
                          backgroundColor: onHeader.withValues(alpha: 0.12),
                          side: BorderSide(color: onHeader.withValues(alpha: 0.35)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        child: Text(l10n.today),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _RoundButton(
                        icon: Icons.chevron_left,
                        tooltip: l10n.previousMonth,
                        onPressed: cubit.previousMonth,
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final picked = await showMonthPicker(context, month);
                            if (picked != null) cubit.showMonth(picked);
                          },
                          child: Semantics(
                            button: true,
                            label: l10n.goToMonth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        fmt.number(month.year),
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: onHeader,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down, color: onHeader.withValues(alpha: 0.8)),
                                    ],
                                  ),
                                  Text(
                                    fmt.adSpan(month),
                                    style: theme.textTheme.bodySmall?.copyWith(color: onHeader.withValues(alpha: 0.8)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      _RoundButton(icon: Icons.chevron_right, tooltip: l10n.nextMonth, onPressed: cubit.nextMonth),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The season's photo, darkened towards the brand maroon so white text stays
/// readable on any picture. Cross-fades when the season changes.
class _SeasonBackdrop extends StatelessWidget {
  const _SeasonBackdrop({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    final patro = context.patro;
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Image.asset(
            season.asset,
            key: ValueKey(season),
            fit: BoxFit.cover,
            alignment: season.focus,
            width: double.infinity,
            height: double.infinity,
            excludeFromSemantics: true,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.45),
                patro.headerStart.withValues(alpha: 0.5),
                patro.headerEnd.withValues(alpha: 0.9),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
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
    final onHeader = context.patro.onHeader;
    return Tooltip(
      message: l10n.estimatedExplain(context.fmt.number(year)),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: onHeader.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 13, color: onHeader.withValues(alpha: 0.85)),
            const SizedBox(width: 4),
            Text(l10n.estimated, style: TextStyle(color: onHeader.withValues(alpha: 0.85), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final onHeader = context.patro.onHeader;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 28,
      style: IconButton.styleFrom(
        backgroundColor: onHeader.withValues(alpha: 0.14),
        foregroundColor: onHeader,
        fixedSize: const Size(52, 52),
      ),
      icon: Icon(icon),
    );
  }
}

class _TipBanner extends StatelessWidget {
  const _TipBanner();

  @override
  Widget build(BuildContext context) {
    final patro = context.patro;
    return Container(
      width: double.infinity,
      color: patro.tipBackground,
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.tipNewFeature,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, height: 1.35),
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            color: Colors.white,
            onPressed: () => context.read<SettingsCubit>().update((s) => s.copyWith(tipDismissed: true)),
            icon: const Icon(Icons.close),
          ),
        ],
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

  double get _cellHeight => widget.showAd ? 60 : 50;

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
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: MonthGrid(
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
      ),
    );
  }
}

class _DayAndMonthEvents extends StatelessWidget {
  const _DayAndMonthEvents({required this.state, required this.index});

  final CalendarState state;
  final EventIndex index;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final theme = Theme.of(context);
    final holidays = context.read<HolidayRepository>();
    final month = state.visibleMonth;
    final monthEvents = index.between(month, BsDate(month.year, month.month, month.daysInThisMonth));
    final dayEvents = monthEvents.where((e) => e.date == state.selected).toList();
    final hasHolidayData = holidays.years.contains(month.year);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fmt.bsDateWithWeekday(state.selected),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            fmt.adDateLong(state.selected.toAd()),
                            style: theme.textTheme.bodyMedium?.copyWith(color: context.patro.muted),
                          ),
                          Text(
                            fmt.tithi(const BsCalculator().tithiOn(state.selected.toAd())),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.patro.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.addReminderOnDate,
                      color: context.patro.muted,
                      onPressed: () => openNoteEditor(context, state.selected),
                      icon: const Icon(Icons.notification_add_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (dayEvents.isEmpty)
                  Text(l10n.nothingOnThisDay, style: theme.textTheme.bodyMedium?.copyWith(color: context.patro.muted))
                else
                  for (final e in dayEvents) _EventTile(event: e, showDate: false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(l10n.thisMonth, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        if (!hasHolidayData)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              l10n.holidayDataMissing(fmt.number(month.year)),
              style: theme.textTheme.bodySmall?.copyWith(color: context.patro.muted),
            ),
          ),
        for (final e in monthEvents) _EventTile(event: e, showDate: true),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.showDate});

  final DayEvent event;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final fmt = context.fmt;
    final patro = context.patro;
    final scheme = Theme.of(context).colorScheme;
    final color = switch (event.kind) {
      DayEventKind.holiday => patro.holiday,
      DayEventKind.festival => patro.muted,
      DayEventKind.note => patro.accent,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (event.note != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditorPage(note: event.note)));
        } else {
          context.read<CalendarCubit>().select(event.date);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            if (showDate) ...[
              SizedBox(
                width: 36,
                child: Text(
                  fmt.number(event.date.day),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    event.kind == DayEventKind.holiday
                        ? '${fmt.weekday(event.date.weekday)} · ${context.l10n.publicHoliday}'
                        : fmt.weekday(event.date.weekday),
                    style: TextStyle(fontSize: 12.5, color: patro.muted),
                  ),
                ],
              ),
            ),
            if (event.kind == DayEventKind.note)
              Icon(Icons.notifications_active_outlined, size: 18, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
