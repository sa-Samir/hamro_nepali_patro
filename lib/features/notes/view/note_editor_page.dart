import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bs/bs_date.dart';
import '../../../core/context_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../../services/reminder_scheduler.dart';
import '../../calendar/widgets/bs_pickers.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../cubit/note_editor_cubit.dart';
import '../cubit/notes_cubit.dart';
import '../models/note.dart';

class NoteEditorPage extends StatelessWidget {
  const NoteEditorPage({super.key, this.note, this.initialDate});

  final Note? note;
  final BsDate? initialDate;

  @override
  Widget build(BuildContext context) {
    final notes = context.read<NotesCubit>();
    return BlocProvider(
      create: (_) => NoteEditorCubit(
        note: note,
        date: initialDate,
        defaultReminderMinutes: context.read<SettingsCubit>().state.reminderMinutes,
        save: notes.save,
        delete: notes.delete,
      ),
      child: const _NoteEditorView(),
    );
  }
}

class _NoteEditorView extends StatelessWidget {
  const _NoteEditorView();

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<NoteEditorCubit>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final reminders = context.read<ReminderScheduler>();
    final saved = await cubit.save();
    if (!saved) return;
    if (cubit.state.draft.remind) {
      final granted = await reminders.requestPermission();
      if (!granted) messenger.showSnackBar(SnackBar(content: Text(l10n.notificationsDenied)));
    }
    navigator.pop();
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<NoteEditorCubit>();
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteNoteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirmed != true) return;
    await cubit.delete();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final theme = Theme.of(context);
    final cubit = context.read<NoteEditorCubit>();
    final state = context.watch<NoteEditorCubit>().state;
    final note = state.draft;

    // Same gradient background as the tab pages, so the top of the screen
    // doesn't change colour when the editor opens.
    return PatroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(state.isNew ? l10n.newNote : l10n.editNote),
          actions: [
            if (!state.isNew)
              IconButton(
                tooltip: l10n.delete,
                onPressed: () => _delete(context),
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              initialValue: note.title,
              autofocus: state.isNew,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.titleLabel,
                hintText: l10n.titleHint,
                errorText: state.showErrors && state.titleMissing ? l10n.titleRequired : null,
              ),
              onChanged: cubit.setTitle,
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(fmt.bsDateWithWeekday(note.date)),
                  subtitle: Text(fmt.adDateLong(note.date.toAd())),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final picked = await showBsDatePicker(context, initial: note.date);
                    if (picked != null) cubit.setDate(picked);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: Text(l10n.repeatLabel),
                  subtitle: Text(_repeatLabel(context, note.repeat)),
                  onTap: () async {
                    final picked = await showModalBottomSheet<RepeatRule>(
                      context: context,
                      showDragHandle: true,
                      builder: (sheetContext) => SafeArea(
                        child: RadioGroup<RepeatRule>(
                          groupValue: note.repeat,
                          onChanged: (v) => Navigator.pop(sheetContext, v),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final rule in RepeatRule.values)
                                RadioListTile<RepeatRule>(value: rule, title: Text(_repeatLabel(context, rule))),
                            ],
                          ),
                        ),
                      ),
                    );
                    if (picked != null) cubit.setRepeat(picked);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: Text(l10n.notifyMe),
                  value: note.remind,
                  onChanged: cubit.setRemind,
                ),
                if (note.remind) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final days in reminderOffsetChoices)
                          FilterChip(
                            label: Text(fmt.digits(_offsetLabel(context, days))),
                            selected: note.reminderOffsets.contains(days),
                            onSelected: (_) => cubit.toggleOffset(days),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(l10n.reminderTime),
                    trailing: Text(fmt.time(note.reminderMinutes), style: theme.textTheme.titleMedium),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: note.reminderMinutes ~/ 60, minute: note.reminderMinutes % 60),
                      );
                      if (picked != null) cubit.setReminderMinutes(picked.hour * 60 + picked.minute);
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: note.description,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.descriptionLabel, alignLabelWithHint: true),
              onChanged: cubit.setDescription,
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(
              onPressed: state.status == EditorStatus.saving ? null : () => _save(context),
              child: Text(l10n.save),
            ),
          ),
        ),
      ),
    );
  }
}

String _repeatLabel(BuildContext context, RepeatRule rule) {
  final l10n = context.l10n;
  return switch (rule) {
    RepeatRule.none => l10n.repeatNone,
    RepeatRule.yearlyBs => l10n.repeatYearlyBs,
    RepeatRule.yearlyAd => l10n.repeatYearlyAd,
    RepeatRule.monthlyBs => l10n.repeatMonthlyBs,
  };
}

String _offsetLabel(BuildContext context, int days) {
  final l10n = context.l10n;
  return switch (days) {
    0 => l10n.onTheDay,
    7 => l10n.weekBefore,
    _ => l10n.daysBefore(days),
  };
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Theme(
      data: Theme.of(context).copyWith(listTileTheme: ListTileThemeData(iconColor: context.patro.muted)),
      child: Column(children: children),
    ),
  );
}
