import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/astro/bs_calculator.dart';
import '../../../core/bs/bs_date.dart';
import '../../../core/context_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../calendar/view/calendar_page.dart';
import '../../calendar/widgets/bs_pickers.dart';
import '../cubit/converter_cubit.dart';

class ConverterPage extends StatelessWidget {
  const ConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: BlocBuilder<ConverterCubit, ConverterState>(
        builder: (context, state) {
          final cubit = context.read<ConverterCubit>();
          final isBs = state.direction == ConversionDirection.bsToAd;
          return SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, navClearance),
              children: [
                PageTitle(title: l10n.converterTitle),
                const SizedBox(height: 16),
                PillToggle<ConversionDirection>(
                  options: [(ConversionDirection.bsToAd, l10n.bsToAd), (ConversionDirection.adToBs, l10n.adToBs)],
                  selected: state.direction,
                  onChanged: cubit.setDirection,
                ),
                const SizedBox(height: 16),
                _InputCard(state: state),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _SwapButton(
                      tooltip: l10n.switchDirection,
                      onPressed: () =>
                          cubit.setDirection(isBs ? ConversionDirection.adToBs : ConversionDirection.bsToAd),
                    ),
                  ),
                ),
                _ResultCard(state: state),
                const SizedBox(height: 28),
                SectionHeader(title: l10n.daysBetweenTitle),
                const SizedBox(height: 10),
                _DaysBetweenCard(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Filled round button with a vertical swap arrow.
class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: p.highlight,
        foregroundColor: p.onHighlight,
        fixedSize: const Size.square(48),
      ),
      icon: const Icon(Icons.swap_vert),
    );
  }
}

Future<void> _pickDate(BuildContext context, ConverterState state, {required bool bs}) async {
  final cubit = context.read<ConverterCubit>();
  if (bs) {
    final picked = await showBsDatePicker(context, initial: state.date);
    if (picked != null) cubit.setBsDate(picked);
  } else {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date.toAd(),
      firstDate: BsDate.minAd,
      lastDate: BsDate.maxAd,
    );
    if (picked != null) cubit.setAdDate(picked);
  }
}

/// The date being converted, in the source calendar; tap to change it.
class _InputCard extends StatelessWidget {
  const _InputCard({required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final p = context.patro;
    final isBs = state.direction == ConversionDirection.bsToAd;
    final ad = state.date.toAd();
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      onTap: () => _pickDate(context, state, bs: isBs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isBs ? l10n.bsDateLabel : l10n.adDateLabel, style: TextStyle(color: p.muted, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  isBs ? fmt.bsDate(state.date) : fmt.adDateFull(ad),
                  style: serif(30, Theme.of(context).colorScheme.onSurface),
                ),
                Text(fmt.weekday(state.date.weekday), style: TextStyle(color: p.muted, fontSize: 13)),
              ],
            ),
          ),
          RoundIconButton(
            icon: Icons.edit_calendar_outlined,
            tooltip: l10n.changeDate,
            onPressed: () => _pickDate(context, state, bs: isBs),
          ),
        ],
      ),
    );
  }
}

/// The converted date on a deep maroon card, with tithi and quick actions.
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final p = context.patro;
    const ink = Color(0xFFF9F5F0);
    final accent = p.bright;
    final isBs = state.direction == ConversionDirection.bsToAd;
    final ad = state.date.toAd();
    final days = state.daysFromToday;
    final relative = switch (days) {
      0 => l10n.isToday,
      > 0 => fmt.digits(l10n.inDays(days)),
      _ => fmt.digits(l10n.daysAgo(-days)),
    };

    Widget chip(String text, {bool filled = false, IconData? icon}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? accent : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: filled ? 0 : 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 15, color: filled ? p.onBright : ink), const SizedBox(width: 6)],
          Text(
            text,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: filled ? p.onBright : ink),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.headerStart, p.headerEnd],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: RadialGradient(
            center: const Alignment(0.9, -1),
            radius: 1.2,
            colors: [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.convertedDate, style: TextStyle(color: ink.withValues(alpha: 0.7), fontSize: 13)),
            const SizedBox(height: 4),
            Semantics(
              liveRegion: true,
              child: Text(isBs ? fmt.adDateFull(ad) : fmt.bsDate(state.date), style: serif(34, ink)),
            ),
            Text(fmt.weekday(state.date.weekday), style: TextStyle(color: ink.withValues(alpha: 0.7), fontSize: 13)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                chip(fmt.tithi(const BsCalculator().tithiOn(ad)), filled: true, icon: Icons.brightness_3_outlined),
                chip(relative, icon: Icons.schedule),
                if (BsDate.isEstimatedYear(state.date.year)) chip(l10n.estimated, icon: Icons.info_outline),
              ],
            ),
            if (BsDate.isEstimatedYear(state.date.year)) ...[
              const SizedBox(height: 8),
              Text(
                l10n.estimatedExplain(fmt.number(state.date.year)),
                style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(text: '${fmt.bsDateWithWeekday(state.date)} = ${fmt.adDateLong(ad)}'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ink,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(Icons.ios_share, size: 18),
                    label: Text(l10n.share),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => openNoteEditor(context, state.date),
                    style: FilledButton.styleFrom(backgroundColor: ink, foregroundColor: p.deepInk),
                    icon: const Icon(Icons.notification_add_outlined, size: 18),
                    label: Text(l10n.remindShort, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Two BS dates and the gap between them, in days and in years/months/days.
class _DaysBetweenCard extends StatelessWidget {
  const _DaysBetweenCard({required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final p = context.patro;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cubit = context.read<ConverterCubit>();
    final breakdown = state.rangeBreakdown;

    Widget dateRow(String label, BsDate date, ValueChanged<BsDate> onPicked) => InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final picked = await showBsDatePicker(context, initial: date);
        if (picked != null) onPicked(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: p.highlight.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(fmt.number(date.day), style: serif(22, onSurface, height: 1)),
                  Text(
                    fmt.monthName(date.month),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(fontSize: 10, color: p.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: p.muted, fontSize: 12)),
                  Text(fmt.bsDate(date), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text(fmt.adDate(date.toAd()), style: TextStyle(color: p.muted, fontSize: 12.5)),
          ],
        ),
      ),
    );

    Widget stat(int value, String label) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: p.highlight.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(fmt.number(value), style: serif(26, onSurface, height: 1)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: p.muted, fontSize: 12)),
          ],
        ),
      ),
    );

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dateRow(l10n.fromDate, state.rangeStart, cubit.setRangeStart),
          Row(
            children: [
              Expanded(child: Divider(color: p.cardBorder)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RoundIconButton(icon: Icons.swap_vert, tooltip: l10n.swap, onPressed: cubit.swapRange, size: 40),
              ),
              Expanded(child: Divider(color: p.cardBorder)),
            ],
          ),
          dateRow(l10n.toDate, state.rangeEnd, cubit.setRangeEnd),
          const SizedBox(height: 14),
          Text(fmt.digits(l10n.totalDays(state.daysBetween.abs())), style: serif(40, onSurface, height: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              stat(breakdown.years, l10n.statYears),
              const SizedBox(width: 8),
              stat(breakdown.months, l10n.statMonths),
              const SizedBox(width: 8),
              stat(breakdown.days, l10n.statDays),
            ],
          ),
        ],
      ),
    );
  }
}
