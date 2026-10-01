import 'package:flutter/material.dart';

import '../../../core/bs/bs_date.dart';
import '../../../core/bs/date_formatter.dart';
import '../../../core/context_ext.dart';
import 'month_grid.dart';

/// Year stepper plus a 3×4 grid of months. Calls [onPicked] with the first
/// day of the chosen month.
class MonthYearSelector extends StatefulWidget {
  const MonthYearSelector({super.key, required this.initial, required this.fmt, required this.onPicked});

  final BsDate initial;
  final DateFormatter fmt;
  final ValueChanged<BsDate> onPicked;

  @override
  State<MonthYearSelector> createState() => _MonthYearSelectorState();
}

class _MonthYearSelectorState extends State<MonthYearSelector> {
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final fmt = widget.fmt;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: l10n.year,
              onPressed: _year > BsDate.min.year ? () => setState(() => _year--) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            SizedBox(
              width: 96,
              child: Text(
                fmt.number(_year),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: l10n.year,
              onPressed: _year < BsDate.max.year ? () => setState(() => _year++) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (var m = 1; m <= 12; m++)
              () {
                final isCurrent = _year == widget.initial.year && m == widget.initial.month;
                return isCurrent
                    ? FilledButton(
                        onPressed: () => widget.onPicked(BsDate(_year, m, 1)),
                        style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(fmt.monthName(m)),
                      )
                    : OutlinedButton(
                        onPressed: () => widget.onPicked(BsDate(_year, m, 1)),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: scheme.outlineVariant),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(fmt.monthName(m)),
                      );
              }(),
          ],
        ),
      ],
    );
  }
}

Future<BsDate?> showMonthPicker(BuildContext context, BsDate initial) {
  return showModalBottomSheet<BsDate>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: MonthYearSelector(
          initial: initial,
          fmt: sheetContext.fmt,
          onPicked: (d) => Navigator.pop(sheetContext, d),
        ),
      ),
    ),
  );
}

/// Dialog for picking a single BS date.
Future<BsDate?> showBsDatePicker(BuildContext context, {required BsDate initial}) {
  return showDialog<BsDate>(
    context: context,
    builder: (_) => _BsDatePickerDialog(initial: initial),
  );
}

class _BsDatePickerDialog extends StatefulWidget {
  const _BsDatePickerDialog({required this.initial});

  final BsDate initial;

  @override
  State<_BsDatePickerDialog> createState() => _BsDatePickerDialogState();
}

class _BsDatePickerDialogState extends State<_BsDatePickerDialog> {
  late BsDate _month = widget.initial.firstOfMonth;
  late BsDate _selected = widget.initial;
  var _choosingMonth = false;

  @override
  Widget build(BuildContext context) {
    final fmt = context.fmt;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final today = BsDate.today();
    final canGoBack = _month.isAfter(BsDate.min);
    final canGoForward = _month.year < BsDate.max.year || _month.month < 12;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  fmt.bsDateWithWeekday(_selected),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(fmt.adDateLong(_selected.toAd()), style: theme.textTheme.bodyMedium),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _choosingMonth = !_choosingMonth),
                  icon: Icon(_choosingMonth ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                  label: Text(fmt.bsMonthYear(_month.year, _month.month)),
                ),
                const Spacer(),
                if (!_choosingMonth) ...[
                  IconButton(
                    tooltip: l10n.previousMonth,
                    onPressed: canGoBack ? () => setState(() => _month = _month.addMonths(-1)) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    tooltip: l10n.nextMonth,
                    onPressed: canGoForward ? () => setState(() => _month = _month.addMonths(1)) : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ],
            ),
            if (_choosingMonth)
              Padding(
                padding: const EdgeInsets.all(8),
                child: MonthYearSelector(
                  initial: _month,
                  fmt: fmt,
                  onPicked: (m) => setState(() {
                    _month = m;
                    _choosingMonth = false;
                  }),
                ),
              )
            else ...[
              WeekdayHeader(fmt: fmt),
              const SizedBox(height: 4),
              MonthGrid(
                month: _month,
                today: today,
                selected: _selected,
                fmt: fmt,
                cellHeight: 48,
                showAd: false,
                onSelect: (d) => setState(() => _selected = d),
              ),
            ],
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _selected = today;
                    _month = today.firstOfMonth;
                    _choosingMonth = false;
                  }),
                  child: Text(l10n.today),
                ),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                FilledButton(onPressed: () => Navigator.pop(context, _selected), child: Text(l10n.ok)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
