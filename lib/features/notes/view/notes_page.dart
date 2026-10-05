import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bs/bs_date.dart';
import '../../../core/context_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../../l10n/app_localizations.dart';
import '../../calendar/cubit/calendar_cubit.dart';
import '../../calendar/view/calendar_page.dart' show navClearance;
import '../cubit/notes_cubit.dart';
import '../models/note.dart';
import 'note_editor_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final state = context.watch<NotesCubit>().state;
    final today = context.select((CalendarCubit c) => c.state.today);

    final upcoming = <(Note, BsDate)>[];
    final past = <Note>[];
    for (final note in state.notes) {
      final next = note.nextOccurrence(today);
      next == null ? past.add(note) : upcoming.add((note, next));
    }
    upcoming.sort((a, b) => a.$2.compareTo(b.$2));
    past.sort((a, b) => b.date.compareTo(a.date));
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, navClearance),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.todayIs('${fmt.monthName(today.month)} ${fmt.number(today.day)}'),
                        style: TextStyle(color: context.patro.muted, fontSize: 13),
                      ),
                      Text(l10n.notesTitle, style: serif(40, Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ),
                RoundIconButton(
                  icon: Icons.add,
                  tooltip: l10n.newNote,
                  onPressed: () => _openEditor(context, initialDate: today),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _WeekStrip(today: today, notes: state.notes),
            const SizedBox(height: 24),
            if (!state.loaded)
              const Center(child: CircularProgressIndicator())
            else if (state.notes.isEmpty)
              _EmptyState(onCreate: () => _openEditor(context, initialDate: today))
            else ...[
              if (upcoming.isNotEmpty) ...[
                SectionHeader(title: l10n.upcomingCount, count: fmt.number(upcoming.length)),
                const SizedBox(height: 10),
                _FeaturedReminder(note: upcoming.first.$1, next: upcoming.first.$2, today: today),
                for (final (note, next) in upcoming.skip(1))
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _ReminderCard(note: note, next: next, today: today),
                  ),
              ],
              if (past.isNotEmpty) ...[
                const SizedBox(height: 28),
                SectionHeader(title: l10n.history),
                const SizedBox(height: 10),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      for (var i = 0; i < past.length; i++) ...[
                        if (i > 0) Divider(height: 1, color: context.patro.cardBorder),
                        _HistoryRow(note: past[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _openEditor(BuildContext context, {Note? note, BsDate? initialDate}) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => NoteEditorPage(note: note, initialDate: initialDate),
  ),
);

void _deleteWithUndo(BuildContext context, Note note) {
  final l10n = context.l10n;
  final cubit = context.read<NotesCubit>();
  cubit.delete(note);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.noteDeleted),
        action: SnackBarAction(label: l10n.undo, onPressed: () => cubit.restore(note)),
      ),
    );
}

String _repeatLabel(AppLocalizations l10n, RepeatRule rule) => switch (rule) {
  RepeatRule.none => l10n.repeatNone,
  RepeatRule.yearlyBs => l10n.repeatYearlyBs,
  RepeatRule.yearlyAd => l10n.repeatYearlyAd,
  RepeatRule.monthlyBs => l10n.repeatMonthlyBs,
};

/// This week, Sunday to Saturday, with today in a pill and dots on days
/// that have a reminder.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.today, required this.notes});

  final BsDate today;
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    final fmt = context.fmt;
    final p = context.patro;
    final sunday = today.addDays(-today.weekday);
    final saturday = sunday.addDays(6);
    final withReminders = {for (final n in notes) ...n.occurrencesBetween(sunday, saturday)};
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: () {
              final day = sunday.addDays(i);
              final isToday = day == today;
              final ink = isToday ? p.onHighlight : (i == 6 ? p.accent : Theme.of(context).colorScheme.onSurface);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isToday ? p.highlight : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Text(
                      fmt.weekdayShort(i),
                      maxLines: 1,
                      style: TextStyle(fontSize: 11, color: isToday ? p.onHighlight : p.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt.number(day.day),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ink),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: withReminders.contains(day)
                            ? (isToday ? p.onHighlight : p.highlight)
                            : Colors.transparent,
                      ),
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

/// Date tile used as the "avatar" of a reminder.
class _DateTile extends StatelessWidget {
  const _DateTile({required this.date, this.size = 52, this.dimmed = false});

  final BsDate date;
  final double size;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final fmt = context.fmt;
    final p = context.patro;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: size,
      height: size + 4,
      decoration: BoxDecoration(
        color: dimmed ? p.card : p.highlight.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(fmt.number(date.day), style: serif(size * 0.46, dimmed ? p.muted : onSurface, height: 1)),
          Text(
            fmt.monthName(date.month),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(fontSize: 10.5, color: p.muted),
          ),
        ],
      ),
    );
  }
}

/// The next reminder, with its details and Delete / Edit pills.
class _FeaturedReminder extends StatelessWidget {
  const _FeaturedReminder({required this.note, required this.next, required this.today});

  final Note note;
  final BsDate next;
  final BsDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final p = context.patro;
    final days = today.daysUntil(next);
    final offsets = note.reminderOffsets
        .map(
          (d) => switch (d) {
            0 => l10n.onTheDay,
            7 => l10n.weekBefore,
            _ => fmt.digits(l10n.daysBefore(d)),
          },
        )
        .join(', ');
    Widget detail(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: p.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: p.muted, fontSize: 13)),
          ),
        ],
      ),
    );
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DateTile(date: next, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.title, style: serif(24, Theme.of(context).colorScheme.onSurface)),
                    Text(
                      days == 0 ? l10n.today : fmt.digits(l10n.inDays(days)),
                      style: TextStyle(color: p.highlight, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          detail(Icons.event_outlined, '${fmt.bsDateWithWeekday(next)} · ${fmt.adDate(next.toAd())}'),
          if (note.repeat != RepeatRule.none) detail(Icons.repeat, _repeatLabel(l10n, note.repeat)),
          if (note.remind && offsets.isNotEmpty)
            detail(Icons.notifications_active_outlined, '$offsets · ${fmt.time(note.reminderMinutes)}'),
          if (note.description.isNotEmpty) detail(Icons.notes, note.description),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GhostPillButton(label: l10n.delete, onPressed: () => _deleteWithUndo(context, note)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => _openEditor(context, note: note),
                  child: Text(l10n.edit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.note, required this.next, required this.today});

  final Note note;
  final BsDate next;
  final BsDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final p = context.patro;
    final days = today.daysUntil(next);
    final soon = days <= 7;
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: p.holiday.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(24)),
        child: Icon(Icons.delete_outline, color: p.holiday),
      ),
      onDismissed: (_) => _deleteWithUndo(context, note),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        onTap: () => _openEditor(context, note: note),
        child: Row(
          children: [
            _DateTile(date: next),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (note.repeat != RepeatRule.none) ...[
                        Icon(Icons.repeat, size: 14, color: p.muted),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          '${fmt.weekday(next.weekday)} · ${fmt.adDate(next.toAd())}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, color: p.muted),
                        ),
                      ),
                    ],
                  ),
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
                days == 0 ? l10n.today : fmt.digits(l10n.inDays(days)),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: soon ? p.onHighlight : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A past one-off reminder: title on the left, date on the right.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final fmt = context.fmt;
    final p = context.patro;
    return InkWell(
      onTap: () => _openEditor(context, note: note),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _DateTile(date: note.date, size: 40, dimmed: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(fmt.bsDate(note.date), style: TextStyle(fontSize: 12, color: p.muted)),
                Text(fmt.adDate(note.date.toAd()), style: TextStyle(fontSize: 11, color: p.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: p.highlight.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(Icons.event_note_outlined, size: 34, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.emptyNotes,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onCreate, child: Text(context.l10n.newNote)),
          ),
        ],
      ),
    );
  }
}
