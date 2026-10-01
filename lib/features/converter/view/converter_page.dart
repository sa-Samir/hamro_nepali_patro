import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/astro/bs_calculator.dart';
import '../../../core/bs/bs_date.dart';
import '../../../core/context_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../calendar/view/calendar_page.dart';
import '../../calendar/widgets/bs_pickers.dart';
import '../cubit/converter_cubit.dart';

class ConverterPage extends StatelessWidget {
  const ConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.converterTitle)),
      body: BlocBuilder<ConverterCubit, ConverterState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            SegmentedButton<ConversionDirection>(
              segments: [
                ButtonSegment(value: ConversionDirection.bsToAd, label: Text(l10n.bsToAd)),
                ButtonSegment(value: ConversionDirection.adToBs, label: Text(l10n.adToBs)),
              ],
              selected: {state.direction},
              showSelectedIcon: false,
              onSelectionChanged: (s) => context.read<ConverterCubit>().setDirection(s.first),
            ),
            const SizedBox(height: 16),
            _InputCard(state: state),
            const SizedBox(height: 12),
            _ResultCard(state: state),
            const SizedBox(height: 28),
            _DaysBetweenCard(state: state),
          ],
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final cubit = context.read<ConverterCubit>();
    final isBs = state.direction == ConversionDirection.bsToAd;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.edit_calendar_outlined),
        title: Text(isBs ? l10n.bsDateLabel : l10n.adDateLabel, style: TextStyle(color: context.patro.muted)),
        subtitle: Text(
          isBs ? fmt.bsDateWithWeekday(state.date) : fmt.adDateLong(state.date.toAd()),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          if (isBs) {
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
        },
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final patro = context.patro;
    final theme = Theme.of(context);
    final isBs = state.direction == ConversionDirection.bsToAd;
    final ad = state.date.toAd();
    final days = state.daysFromToday;
    final relative = switch (days) {
      0 => l10n.isToday,
      > 0 => fmt.digits(l10n.inDays(days)),
      _ => fmt.digits(l10n.daysAgo(-days)),
    };
    final primary = isBs ? fmt.adDateLong(ad) : fmt.bsDate(state.date);
    final secondary = isBs ? fmt.bsDateWithWeekday(state.date) : fmt.weekday(state.date.weekday);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [patro.headerStart, patro.headerEnd]),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.convertedDate, style: TextStyle(color: patro.onHeader.withValues(alpha: 0.8))),
          const SizedBox(height: 6),
          Semantics(
            liveRegion: true,
            child: Text(
              primary,
              style: theme.textTheme.headlineSmall?.copyWith(color: patro.onHeader, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Text(secondary, style: TextStyle(color: patro.onHeader.withValues(alpha: 0.85))),
          Text(
            fmt.tithi(const BsCalculator().tithiOn(ad)),
            style: TextStyle(color: patro.onHeader.withValues(alpha: 0.85)),
          ),
          if (BsDate.isEstimatedYear(state.date.year))
            Text(
              '${l10n.estimated} · ${l10n.estimatedExplain(fmt.number(state.date.year))}',
              style: TextStyle(color: patro.onHeader.withValues(alpha: 0.7), fontSize: 12),
            ),
          const SizedBox(height: 4),
          Text(
            relative,
            style: TextStyle(color: patro.accent, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: patro.onHeader),
                onPressed: () => SharePlus.instance.share(
                  ShareParams(text: '${fmt.bsDateWithWeekday(state.date)} = ${fmt.adDateLong(ad)}'),
                ),
                icon: const Icon(Icons.share_outlined, size: 20),
                label: Text(l10n.share),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: patro.onHeader),
                onPressed: () => openNoteEditor(context, state.date),
                icon: const Icon(Icons.notifications_none, size: 20),
                label: Text(l10n.addReminderOnDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DaysBetweenCard extends StatelessWidget {
  const _DaysBetweenCard({required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final theme = Theme.of(context);
    final cubit = context.read<ConverterCubit>();
    final breakdown = state.rangeBreakdown;

    Widget dateTile(String label, BsDate date, ValueChanged<BsDate> onPicked) => ListTile(
      title: Text(label, style: TextStyle(color: context.patro.muted)),
      subtitle: Text(fmt.bsDate(date), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      trailing: Text(fmt.adDate(date.toAd()), style: TextStyle(color: context.patro.muted)),
      onTap: () async {
        final picked = await showBsDatePicker(context, initial: date);
        if (picked != null) onPicked(picked);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(l10n.daysBetweenTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              dateTile(l10n.fromDate, state.rangeStart, cubit.setRangeStart),
              Row(
                children: [
                  const Expanded(child: Divider(indent: 16)),
                  IconButton(tooltip: l10n.swap, onPressed: cubit.swapRange, icon: const Icon(Icons.swap_vert)),
                  const Expanded(child: Divider(endIndent: 16)),
                ],
              ),
              dateTile(l10n.toDate, state.rangeEnd, cubit.setRangeEnd),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fmt.digits(l10n.totalDays(state.daysBetween.abs())),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      fmt.digits(l10n.yearsMonthsDays(breakdown.years, breakdown.months, breakdown.days)),
                      style: TextStyle(color: context.patro.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
