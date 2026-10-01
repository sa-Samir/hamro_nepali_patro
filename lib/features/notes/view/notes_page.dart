import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bs/bs_date.dart';
import '../../../core/context_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../calendar/cubit/calendar_cubit.dart';
import '../cubit/notes_cubit.dart';
import '../models/note.dart';
import 'note_editor_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditorPage(initialDate: today))),
        icon: const Icon(Icons.add),
        label: Text(l10n.newNote),
      ),
      body: !state.loaded
          ? const Center(child: CircularProgressIndicator())
          : state.notes.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              children: [
                if (upcoming.isNotEmpty) _SectionTitle(l10n.upcoming),
                for (final (note, next) in upcoming) _NoteTile(note: note, next: next, today: today),
                if (past.isNotEmpty) _SectionTitle(l10n.past),
                for (final note in past) _NoteTile(note: note, next: null, today: today),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: context.patro.muted),
    ),
  );
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.next, required this.today});

  final Note note;

  /// Next occurrence, or null if the note is in the past.
  final BsDate? next;
  final BsDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final scheme = Theme.of(context).colorScheme;
    final patro = context.patro;
    final date = next ?? note.date;
    final days = today.daysUntil(date);
    final relative = switch (days) {
      0 => l10n.today,
      > 0 => fmt.digits(l10n.inDays(days)),
      _ => fmt.digits(l10n.daysAgo(-days)),
    };
    final isPast = next == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(note.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(20)),
          child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
        ),
        onDismissed: (_) {
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
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditorPage(note: note))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isPast ? scheme.surfaceContainerHigh : scheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fmt.number(date.day),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isPast ? patro.muted : scheme.onPrimary,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          fmt.monthName(date.month),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(fontSize: 11, color: isPast ? patro.muted : scheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text('${fmt.bsDate(date)} · $relative', style: TextStyle(color: patro.muted, fontSize: 13)),
                        if (note.description.isNotEmpty)
                          Text(
                            note.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: patro.muted, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  if (note.repeat != RepeatRule.none) Icon(Icons.repeat, size: 18, color: patro.muted),
                  if (note.remind) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.notifications_active_outlined, size: 18, color: patro.accent),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: scheme.secondaryContainer,
              child: Icon(Icons.event_note_outlined, size: 40, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.emptyNotes,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.patro.muted),
            ),
          ],
        ),
      ),
    );
  }
}
