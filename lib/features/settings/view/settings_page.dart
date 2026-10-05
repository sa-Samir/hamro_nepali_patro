import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bs/bs_date.dart';
import '../../../core/context_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../../data/remote/calendar_data_cubit.dart';
import '../../../data/repositories/holiday_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/backup_service.dart';
import '../../../services/native_bridge.dart';
import '../../../services/reminder_scheduler.dart';
import '../../calendar/models/season.dart';
import '../../calendar/view/calendar_page.dart' show navClearance;
import '../../notes/cubit/notes_cubit.dart';
import '../../notes/models/note.dart';
import '../cubit/settings_cubit.dart';
import '../models/app_settings.dart';
import 'settings_previews.dart';

/// Settings as a grid of category tiles. Each tile shows its current value
/// and opens a sheet with a live preview above the controls, so a change
/// is visible before leaving the sheet.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final s = context.watch<SettingsCubit>().state;
    final reminders = context.watch<NotesCubit>().state.notes.length;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final tiles = <_TileSpec>[
      _TileSpec(
        icon: Icons.translate,
        title: l10n.language,
        value:
            '${s.language == AppLanguage.ne ? 'नेपाली' : 'English'} · '
            '${s.numerals == NumeralStyle.devanagari ? '१२३' : '123'}',
        sheet: _languageSheet,
      ),
      _TileSpec(icon: Icons.contrast, title: l10n.tileLook, value: _themeLabel(l10n, s.themeMode), sheet: _lookSheet),
      _TileSpec(
        icon: Icons.alarm,
        title: l10n.sectionReminders,
        value: fmt.time(s.reminderMinutes),
        sheet: _remindersSheet,
      ),
      if (Platform.isAndroid)
        _TileSpec(
          icon: Icons.notifications_none,
          title: l10n.tileNotification,
          value: s.todayNotification ? _styleLabel(l10n, s.todayNotificationStyle).$1 : l10n.stateOff,
          active: s.todayNotification,
          sheet: _notificationSheet,
        ),
      _TileSpec(
        icon: Icons.widgets_outlined,
        title: l10n.sectionWidgets,
        value: _widgetThemeLabel(l10n, s.widgetTheme).$1,
        sheet: _widgetsSheet,
      ),
      _TileSpec(
        icon: Icons.cloud_sync_outlined,
        title: l10n.sectionBackup,
        value: fmt.digits(l10n.reminderCountLabel(reminders)),
        sheet: _backupSheet,
      ),
      _TileSpec(icon: Icons.info_outline, title: l10n.sectionAbout, value: l10n.privacyNote, sheet: _aboutSheet),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              sliver: SliverToBoxAdapter(
                child: PageTitle(eyebrow: l10n.settingsSubtitle, title: l10n.settingsTitle),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, navClearance),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [for (final t in tiles) _SettingsTile(spec: t)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _SheetBuilder = List<Widget> Function(BuildContext context, AppSettings s);

class _TileSpec {
  const _TileSpec({
    required this.icon,
    required this.title,
    required this.value,
    required this.sheet,
    this.active = true,
  });

  final IconData icon;
  final String title;
  final String value;
  final _SheetBuilder sheet;

  /// Dims the value (e.g. a feature that's switched off).
  final bool active;
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.spec});

  final _TileSpec spec;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _openSheet(context, spec.title, spec.sheet),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(spec.icon, size: 44),
              const Spacer(),
              Icon(Icons.north_east, size: 18, color: p.muted),
            ],
          ),
          const Spacer(),
          Text(spec.title, style: serif(24, onSurface)),
          const SizedBox(height: 2),
          Text(
            spec.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: spec.active ? p.muted : p.muted.withValues(alpha: 0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Opens a category sheet that rebuilds as settings change.
Future<void> _openSheet(BuildContext context, String title, _SheetBuilder builder) {
  // The sheet paints its own background inside the builder: a colour passed
  // to showModalBottomSheet is fixed when it opens and would stay light after
  // switching to dark mode from the Look sheet.
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, s) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        // The background lives inside the draggable area so it is exactly as
        // tall as the sheet.
        builder: (context, controller) => _SheetBackground(
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              Text(title, style: serif(34, Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 16),
              ...builder(context, s),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SheetBackground extends StatelessWidget {
  const _SheetBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
      color: context.patro.backgroundBottom,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 36,
          height: 4,
          decoration: BoxDecoration(color: context.patro.muted, borderRadius: BorderRadius.circular(2)),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

/// Small muted label above a group of controls inside a sheet.
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(
      text,
      style: TextStyle(color: context.patro.muted, fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );
}

/// Choice chips that wrap onto several lines.
Widget _chips<T>(BuildContext context, List<(T, String)> options, T selected, ValueChanged<T> onSelected) {
  final p = context.patro;
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final (value, label) in options)
        ChoiceChip(
          label: Text(label),
          selected: value == selected,
          showCheckmark: false,
          labelStyle: TextStyle(
            color: value == selected ? p.onHighlight : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) => onSelected(value),
        ),
    ],
  );
}

/// Glass card holding switch / list rows.
Widget _rows(BuildContext context, List<Widget> children) {
  final p = context.patro;
  return GlassCard(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: p.cardBorder),
          children[i],
        ],
      ],
    ),
  );
}

List<Widget> _languageSheet(BuildContext context, AppSettings s) {
  final l10n = context.l10n;
  final cubit = context.read<SettingsCubit>();
  return [
    PreviewFrame(
      label: l10n.previewLabel,
      child: LanguagePreview(settings: s),
    ),
    _Label(l10n.language),
    PillToggle<AppLanguage>(
      options: const [(AppLanguage.ne, 'नेपाली'), (AppLanguage.en, 'English')],
      selected: s.language,
      onChanged: cubit.setLanguage,
    ),
    _Label(l10n.numerals),
    PillToggle<NumeralStyle>(
      options: [(NumeralStyle.devanagari, l10n.numeralsNepali), (NumeralStyle.western, l10n.numeralsEnglish)],
      selected: s.numerals,
      onChanged: (v) => cubit.update((s) => s.copyWith(numerals: v)),
    ),
  ];
}

String _themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
  ThemeMode.system => l10n.themeSystem,
  ThemeMode.light => l10n.themeLight,
  ThemeMode.dark => l10n.themeDark,
};

List<Widget> _lookSheet(BuildContext context, AppSettings s) {
  final l10n = context.l10n;
  final cubit = context.read<SettingsCubit>();
  return [
    PreviewFrame(
      label: l10n.previewLabel,
      child: LookPreview(settings: s),
    ),
    _Label(l10n.theme),
    PillToggle<ThemeMode>(
      options: [for (final m in ThemeMode.values) (m, _themeLabel(l10n, m))],
      selected: s.themeMode,
      onChanged: (v) => cubit.update((s) => s.copyWith(themeMode: v)),
    ),
    const SizedBox(height: 16),
    _rows(context, [
      SwitchListTile(
        title: Text(l10n.showAdDates),
        value: s.showAdInCalendar,
        onChanged: (v) => cubit.update((s) => s.copyWith(showAdInCalendar: v)),
      ),
    ]),
  ];
}

List<Widget> _remindersSheet(BuildContext context, AppSettings s) {
  final l10n = context.l10n;
  final fmt = context.fmt;
  final cubit = context.read<SettingsCubit>();
  return [
    PreviewFrame(
      label: l10n.previewLabel,
      child: ReminderPreview(settings: s, title: l10n.sampleReminder),
    ),
    _Label(l10n.defaultReminderTime),
    SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: const Icon(Icons.schedule),
        label: Text(fmt.time(s.reminderMinutes), style: const TextStyle(fontSize: 18)),
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: s.reminderMinutes ~/ 60, minute: s.reminderMinutes % 60),
          );
          if (picked != null) cubit.update((s) => s.copyWith(reminderMinutes: picked.hour * 60 + picked.minute));
        },
      ),
    ),
  ];
}

List<Widget> _notificationSheet(BuildContext context, AppSettings s) {
  final l10n = context.l10n;
  final cubit = context.read<SettingsCubit>();
  return [
    PreviewFrame(
      label: l10n.previewLabel,
      child: NotificationPreview(settings: s),
    ),
    const SizedBox(height: 16),
    _rows(context, [
      SwitchListTile(
        title: Text(l10n.todayNotification),
        subtitle: Text(l10n.todayNotificationSubtitle),
        value: s.todayNotification,
        onChanged: (v) async {
          if (v) {
            final messenger = ScaffoldMessenger.of(context);
            final granted = await context.read<ReminderScheduler>().requestPermission();
            if (!granted) {
              messenger.showSnackBar(SnackBar(content: Text(l10n.notificationsDenied)));
              return;
            }
          }
          cubit.update((s) => s.copyWith(todayNotification: v));
        },
      ),
    ]),
    _Label(l10n.notificationStyle),
    _chips<TodayNotificationStyle>(
      context,
      [for (final st in TodayNotificationStyle.values) (st, _styleLabel(l10n, st).$1)],
      s.todayNotificationStyle,
      (v) => cubit.update((s) => s.copyWith(todayNotificationStyle: v)),
    ),
    const SizedBox(height: 16),
    _rows(context, [
      SwitchListTile(
        title: Text(l10n.includeAdDate),
        value: s.todayNotificationShowAd,
        onChanged: (v) => cubit.update((s) => s.copyWith(todayNotificationShowAd: v)),
      ),
      SwitchListTile(
        title: Text(l10n.includeEvents),
        value: s.todayNotificationShowEvents,
        onChanged: (v) => cubit.update((s) => s.copyWith(todayNotificationShowEvents: v)),
      ),
    ]),
  ];
}

List<Widget> _widgetsSheet(BuildContext context, AppSettings s) {
  final l10n = context.l10n;
  final cubit = context.read<SettingsCubit>();
  return [
    PreviewFrame(
      label: l10n.previewLabel,
      child: WidgetPreview(settings: s),
    ),
    _Label(l10n.widgetTheme),
    _chips<WidgetTheme>(
      context,
      [for (final t in WidgetTheme.values) (t, _widgetThemeLabel(l10n, t).$1)],
      s.widgetTheme,
      (v) => cubit.update((s) => s.copyWith(widgetTheme: v)),
    ),
    _Label(l10n.previewSeason),
    _chips<Season?>(
      context,
      [(null, l10n.previewSeasonAuto), for (final season in Season.values) (season, seasonName(l10n, season))],
      s.previewSeason,
      (v) => cubit.update((s) => s.copyWith(previewSeason: () => v)),
    ),
    _Label(l10n.addToHomeScreen),
    if (Platform.isAndroid)
      _rows(context, [
        for (final (kind, label, icon) in [
          (WidgetKind.today, l10n.widgetToday, Icons.crop_square),
          (WidgetKind.desk, l10n.widgetDesk, Icons.event_note_outlined),
          (WidgetKind.agenda, l10n.widgetAgenda, Icons.view_agenda_outlined),
          (WidgetKind.week, l10n.widgetWeek, Icons.view_week_outlined),
          (WidgetKind.month, l10n.widgetMonth, Icons.calendar_view_month),
        ])
          ListTile(
            leading: IconBubble(icon, size: 36),
            title: Text(label),
            trailing: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: context.patro.highlight.withValues(alpha: 0.16),
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final ok = await context.read<NativeBridge>().requestPinWidget(kind);
                if (!ok) messenger.showSnackBar(SnackBar(content: Text(l10n.widgetPinUnsupported)));
              },
              child: Text(l10n.add),
            ),
          ),
      ]),
    Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      child: Text(
        Platform.isIOS ? l10n.widgetsHintIos : l10n.widgetsHintAndroid,
        style: TextStyle(color: context.patro.muted, fontSize: 13),
      ),
    ),
  ];
}

List<Widget> _backupSheet(BuildContext context, AppSettings s) => [
  _rows(context, const [_ExportTile(), _ImportTile()]),
];

List<Widget> _aboutSheet(BuildContext context, AppSettings s) {
  final l10n = context.l10n;
  final fmt = context.fmt;
  final holidayYears = context.read<HolidayRepository>().years;
  return [
    _rows(context, [
      ListTile(leading: const IconBubble(Icons.lock_outline, size: 36), title: Text(l10n.privacyNote)),
      ListTile(
        leading: const IconBubble(Icons.celebration_outlined, size: 36),
        title: Text(l10n.holidayDataYears(holidayYears.map(fmt.number).join(', '))),
        subtitle: Text(l10n.holidayDisclaimer),
      ),
      const _CalendarDataTile(),
      const _PhotoCreditsTile(),
    ]),
  ];
}

(String, String) _styleLabel(AppLocalizations l10n, TodayNotificationStyle style) => switch (style) {
  TodayNotificationStyle.number => (l10n.notificationStyleNumber, l10n.notificationStyleNumberHint),
  TodayNotificationStyle.page => (l10n.notificationStylePage, l10n.notificationStylePageHint),
  TodayNotificationStyle.moon => (l10n.notificationStyleMoon, l10n.notificationStyleMoonHint),
  TodayNotificationStyle.week => (l10n.notificationStyleWeek, l10n.notificationStyleWeekHint),
  TodayNotificationStyle.countdown => (l10n.notificationStyleCountdown, l10n.notificationStyleCountdownHint),
  TodayNotificationStyle.plain => (l10n.notificationStylePlain, l10n.notificationStylePlainHint),
};

(String, String) _widgetThemeLabel(AppLocalizations l10n, WidgetTheme theme) => switch (theme) {
  WidgetTheme.forest => (l10n.widgetThemeForest, l10n.widgetThemeForestHint),
  WidgetTheme.photo => (l10n.widgetThemePhoto, l10n.widgetThemePhotoHint),
  WidgetTheme.maroon => (l10n.widgetThemeMaroon, l10n.widgetThemeMaroonHint),
  WidgetTheme.marigold => (l10n.widgetThemeMarigold, l10n.widgetThemeMarigoldHint),
  WidgetTheme.cream => (l10n.widgetThemeCream, l10n.widgetThemeCreamHint),
};

/// Attribution required by the season photos' Creative Commons licences.
class _PhotoCreditsTile extends StatelessWidget {
  const _PhotoCreditsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const IconBubble(Icons.photo_library_outlined, size: 36),
      title: Text(l10n.photoCredits),
      subtitle: Text(l10n.photoCreditsSubtitle),
      onTap: () async {
        final credits = (jsonDecode(await rootBundle.loadString('assets/seasons/credits.json')) as List)
            .cast<Map<String, dynamic>>();
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.photoCredits),
            content: SingleChildScrollView(
              child: SelectableText(
                [
                  for (final c in credits) '“${c['title']}” — ${c['artist']}\n${c['license']} · ${c['source']}',
                ].join('\n\n'),
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.ok))],
          ),
        );
      },
    );
  }
}

class _CalendarDataTile extends StatelessWidget {
  const _CalendarDataTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final data = context.watch<CalendarDataCubit>();
    final revision = data.state;
    return ListTile(
      leading: const IconBubble(Icons.date_range_outlined, size: 36),
      title: Text(l10n.calendarData),
      subtitle: Text(
        [
          l10n.calendarDataVerified(fmt.number(BsDate.verifiedThroughYear)),
          if (revision > 0) l10n.calendarDataRevision(fmt.number(revision)),
        ].join('\n'),
      ),
      trailing: data.canUpdate
          ? IconButton(
              tooltip: l10n.checkForUpdates,
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final updated = await data.refresh(force: true);
                messenger.showSnackBar(
                  SnackBar(content: Text(updated ? l10n.calendarDataUpdated : l10n.calendarDataUpToDate)),
                );
              },
            )
          : null,
    );
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const IconBubble(Icons.upload_file_outlined, size: 36),
      title: Text(l10n.exportNotes),
      subtitle: Text(l10n.exportSubtitle),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final fmt = context.fmt;
        final notes = context.read<NotesCubit>().state.notes;
        if (notes.isEmpty) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.nothingToExport)));
          return;
        }
        final saved = await context.read<BackupService>().export(notes);
        if (saved) messenger.showSnackBar(SnackBar(content: Text(fmt.digits(l10n.exportDone(notes.length)))));
      },
    );
  }
}

class _ImportTile extends StatelessWidget {
  const _ImportTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const IconBubble(Icons.download_outlined, size: 36),
      title: Text(l10n.importNotes),
      subtitle: Text(l10n.importSubtitle),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final fmt = context.fmt;
        final notesCubit = context.read<NotesCubit>();
        final List<Note>? imported;
        try {
          imported = await context.read<BackupService>().pickAndRead();
        } on FormatException {
          messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed)));
          return;
        }
        if (imported == null || !context.mounted) return;
        final notes = imported;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            content: Text(fmt.digits(l10n.importConfirm(notes.length))),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.cancel)),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.ok)),
            ],
          ),
        );
        if (confirmed != true) return;
        await notesCubit.importAll(notes);
        messenger.showSnackBar(SnackBar(content: Text(fmt.digits(l10n.importDone(notes.length)))));
      },
    );
  }
}
