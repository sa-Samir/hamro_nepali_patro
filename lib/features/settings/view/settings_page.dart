import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bs/bs_date.dart';
import '../../../core/context_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../calendar/view/calendar_page.dart' show navClearance;
import '../../../data/remote/calendar_data_cubit.dart';
import '../../../data/repositories/holiday_repository.dart';
import '../../../services/backup_service.dart';
import '../../../services/native_bridge.dart';
import '../../../services/reminder_scheduler.dart';
import '../../notes/cubit/notes_cubit.dart';
import '../../notes/models/note.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/settings_cubit.dart';
import '../../calendar/models/season.dart';
import '../models/app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    final cubit = context.read<SettingsCubit>();
    final s = context.watch<SettingsCubit>().state;
    final holidayYears = context.read<HolidayRepository>().years;

    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, navClearance),
          children: [
            PageTitle(title: l10n.settingsTitle),
            const SizedBox(height: 16),
            const _HeroCard(),
            _Section(l10n.sectionGeneral, [
              _LabeledControl(
                icon: Icons.translate,
                label: l10n.language,
                control: PillToggle<AppLanguage>(
                  options: const [(AppLanguage.ne, 'नेपाली'), (AppLanguage.en, 'English')],
                  selected: s.language,
                  onChanged: cubit.setLanguage,
                ),
              ),
              _LabeledControl(
                icon: Icons.pin_outlined,
                label: l10n.numerals,
                control: PillToggle<NumeralStyle>(
                  options: [
                    (NumeralStyle.devanagari, l10n.numeralsNepali),
                    (NumeralStyle.western, l10n.numeralsEnglish),
                  ],
                  selected: s.numerals,
                  onChanged: (v) => cubit.update((s) => s.copyWith(numerals: v)),
                ),
              ),
              _LabeledControl(
                icon: Icons.palette_outlined,
                label: l10n.theme,
                control: PillToggle<ThemeMode>(
                  options: [
                    (ThemeMode.system, l10n.themeSystem),
                    (ThemeMode.light, l10n.themeLight),
                    (ThemeMode.dark, l10n.themeDark),
                  ],
                  selected: s.themeMode,
                  onChanged: (v) => cubit.update((s) => s.copyWith(themeMode: v)),
                ),
              ),
              SwitchListTile(
                secondary: const IconBubble(Icons.today_outlined),
                title: Text(l10n.showAdDates),
                value: s.showAdInCalendar,
                onChanged: (v) => cubit.update((s) => s.copyWith(showAdInCalendar: v)),
              ),
            ]),
            _Section(l10n.sectionReminders, [
              ListTile(
                leading: const IconBubble(Icons.schedule),
                title: Text(l10n.defaultReminderTime),
                trailing: Text(fmt.time(s.reminderMinutes), style: Theme.of(context).textTheme.titleMedium),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: s.reminderMinutes ~/ 60, minute: s.reminderMinutes % 60),
                  );
                  if (picked != null) {
                    cubit.update((s) => s.copyWith(reminderMinutes: picked.hour * 60 + picked.minute));
                  }
                },
              ),
            ]),
            if (Platform.isAndroid)
              _Section(l10n.sectionTodayNotification, [
                SwitchListTile(
                  secondary: const IconBubble(Icons.notifications_outlined),
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
                SwitchListTile(
                  secondary: const SizedBox(width: 40),
                  title: Text(l10n.includeAdDate),
                  value: s.todayNotificationShowAd,
                  onChanged: s.todayNotification
                      ? (v) => cubit.update((s) => s.copyWith(todayNotificationShowAd: v))
                      : null,
                ),
                SwitchListTile(
                  secondary: const SizedBox(width: 40),
                  title: Text(l10n.includeEvents),
                  value: s.todayNotificationShowEvents,
                  onChanged: s.todayNotification
                      ? (v) => cubit.update((s) => s.copyWith(todayNotificationShowEvents: v))
                      : null,
                ),
                ListTile(
                  enabled: s.todayNotification,
                  leading: const IconBubble(Icons.style_outlined),
                  title: Text(l10n.notificationStyle),
                  subtitle: Text(_styleLabel(l10n, s.todayNotificationStyle).$1),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickNotificationStyle(context, s.todayNotificationStyle),
                ),
              ]),
            _Section(l10n.sectionWidgets, [
              ListTile(
                leading: const IconBubble(Icons.palette_outlined),
                title: Text(l10n.widgetTheme),
                subtitle: Text(_widgetThemeLabel(l10n, s.widgetTheme).$1),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickWidgetTheme(context, s.widgetTheme),
              ),
              ListTile(
                leading: const IconBubble(Icons.landscape_outlined),
                title: Text(l10n.previewSeason),
                subtitle: Text(s.previewSeason == null ? l10n.previewSeasonAuto : seasonName(l10n, s.previewSeason!)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickPreviewSeason(context, s.previewSeason),
              ),
              if (Platform.isAndroid)
                for (final (kind, label, icon) in [
                  (WidgetKind.today, l10n.widgetToday, Icons.crop_square),
                  (WidgetKind.desk, l10n.widgetDesk, Icons.event_note_outlined),
                  (WidgetKind.agenda, l10n.widgetAgenda, Icons.view_agenda_outlined),
                  (WidgetKind.week, l10n.widgetWeek, Icons.view_week_outlined),
                  (WidgetKind.month, l10n.widgetMonth, Icons.calendar_view_month),
                ])
                  ListTile(
                    leading: IconBubble(icon),
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
              ListTile(
                leading: const IconBubble(Icons.info_outline),
                subtitle: Text(Platform.isIOS ? l10n.widgetsHintIos : l10n.widgetsHintAndroid),
              ),
            ]),
            _Section(l10n.sectionBackup, const [_ExportTile(), _ImportTile()]),
            _Section(l10n.sectionAbout, [
              ListTile(
                leading: const IconBubble(Icons.celebration_outlined),
                title: Text(l10n.holidayDataYears(holidayYears.map(fmt.number).join(', '))),
                subtitle: Text(l10n.holidayDisclaimer),
              ),
              const _CalendarDataTile(),
              const _PhotoCreditsTile(),
            ]),
          ],
        ),
      ),
    );
  }
}

(String, String) _styleLabel(AppLocalizations l10n, TodayNotificationStyle style) => switch (style) {
  TodayNotificationStyle.number => (l10n.notificationStyleNumber, l10n.notificationStyleNumberHint),
  TodayNotificationStyle.page => (l10n.notificationStylePage, l10n.notificationStylePageHint),
  TodayNotificationStyle.moon => (l10n.notificationStyleMoon, l10n.notificationStyleMoonHint),
  TodayNotificationStyle.week => (l10n.notificationStyleWeek, l10n.notificationStyleWeekHint),
  TodayNotificationStyle.countdown => (l10n.notificationStyleCountdown, l10n.notificationStyleCountdownHint),
  TodayNotificationStyle.plain => (l10n.notificationStylePlain, l10n.notificationStylePlainHint),
};

/// The notification updates as soon as a style is picked, so people can
/// pull down the shade to compare.
Future<void> _pickNotificationStyle(BuildContext context, TodayNotificationStyle current) async {
  final l10n = context.l10n;
  final picked = await showModalBottomSheet<TodayNotificationStyle>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: RadioGroup<TodayNotificationStyle>(
        groupValue: current,
        onChanged: (v) => Navigator.pop(sheetContext, v),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final style in TodayNotificationStyle.values)
                RadioListTile<TodayNotificationStyle>(
                  value: style,
                  title: Text(_styleLabel(l10n, style).$1),
                  subtitle: Text(_styleLabel(l10n, style).$2),
                ),
            ],
          ),
        ),
      ),
    ),
  );
  if (picked != null && context.mounted) {
    await context.read<SettingsCubit>().update((s) => s.copyWith(todayNotificationStyle: picked));
  }
}

(String, String) _widgetThemeLabel(AppLocalizations l10n, WidgetTheme theme) => switch (theme) {
  WidgetTheme.photo => (l10n.widgetThemePhoto, l10n.widgetThemePhotoHint),
  WidgetTheme.maroon => (l10n.widgetThemeMaroon, l10n.widgetThemeMaroonHint),
  WidgetTheme.marigold => (l10n.widgetThemeMarigold, l10n.widgetThemeMarigoldHint),
  WidgetTheme.cream => (l10n.widgetThemeCream, l10n.widgetThemeCreamHint),
};

/// Placed widgets redraw as soon as a theme is picked.
Future<void> _pickWidgetTheme(BuildContext context, WidgetTheme current) async {
  final l10n = context.l10n;
  final picked = await showModalBottomSheet<WidgetTheme>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: RadioGroup<WidgetTheme>(
        groupValue: current,
        onChanged: (v) => Navigator.pop(sheetContext, v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final theme in WidgetTheme.values)
              RadioListTile<WidgetTheme>(
                value: theme,
                title: Text(_widgetThemeLabel(l10n, theme).$1),
                subtitle: Text(_widgetThemeLabel(l10n, theme).$2),
              ),
          ],
        ),
      ),
    ),
  );
  if (picked != null && context.mounted) {
    await context.read<SettingsCubit>().update((s) => s.copyWith(widgetTheme: picked));
  }
}

/// Lets people check every season photo (app header and widgets) without
/// waiting for the calendar to get there.
Future<void> _pickPreviewSeason(BuildContext context, Season? current) async {
  final l10n = context.l10n;
  // A sheet can't return "null = automatic", so wrap the choice.
  final picked = await showModalBottomSheet<({Season? season})>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: RadioGroup<Season?>(
        groupValue: current,
        onChanged: (v) => Navigator.pop(sheetContext, (season: v)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Season?>(
                value: null,
                title: Text(l10n.previewSeasonAuto),
                subtitle: Text(l10n.previewSeasonAutoHint),
              ),
              for (final season in Season.values)
                RadioListTile<Season?>(value: season, title: Text(seasonName(l10n, season))),
            ],
          ),
        ),
      ),
    ),
  );
  if (picked != null && context.mounted) {
    await context.read<SettingsCubit>().update((s) => s.copyWith(previewSeason: () => picked.season));
  }
}

/// Attribution required by the season photos' Creative Commons licences.
class _PhotoCreditsTile extends StatelessWidget {
  const _PhotoCreditsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const IconBubble(Icons.photo_library_outlined),
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
      leading: const IconBubble(Icons.date_range_outlined),
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
      leading: const IconBubble(Icons.upload_file_outlined),
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
      leading: const IconBubble(Icons.download_outlined),
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

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 26, 4, 10),
          child: Text(title, style: serif(24, Theme.of(context).colorScheme.onSurface)),
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Theme(
            data: Theme.of(context).copyWith(
              listTileTheme: ListTileThemeData(
                iconColor: p.muted,
                subtitleTextStyle: TextStyle(color: p.muted, fontSize: 13),
                titleTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: 72, endIndent: 16, color: p.cardBorder),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A label above a full-width control such as a pill toggle.
class _LabeledControl extends StatelessWidget {
  const _LabeledControl({required this.icon, required this.label, required this.control});

  final IconData icon;
  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconBubble(icon),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        control,
      ],
    ),
  );
}

/// The app on its season photo, with the privacy promise and a couple of
/// at-a-glance numbers.
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    const ink = Color(0xFFF9F5F0);
    final settings = context.watch<SettingsCubit>().state;
    final season = settings.previewSeason ?? Season.ofMonth(BsDate.today().month);
    final reminders = context.watch<NotesCubit>().state.notes.length;
    final holidayYears = context.read<HolidayRepository>().years;

    Widget stat(String value, String label) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: serif(24, ink, height: 1)),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink.withValues(alpha: 0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );

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
                  colors: [Colors.black.withValues(alpha: 0.35), context.patro.headerEnd.withValues(alpha: 0.95)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(color: Color(0xFFBAD45F), shape: BoxShape.circle),
                      child: const Icon(Icons.lock_outline, color: Color(0xFF0C1008), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.appTitle, style: serif(30, ink))),
                  ],
                ),
                const SizedBox(height: 10),
                Text(l10n.privacyNote, style: TextStyle(color: ink.withValues(alpha: 0.85), height: 1.35)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    stat(fmt.number(reminders), l10n.notesTitle),
                    const SizedBox(width: 8),
                    stat(holidayYears.map(fmt.number).join(', '), l10n.statHolidayData),
                    const SizedBox(width: 8),
                    stat(fmt.number(BsDate.verifiedThroughYear), l10n.statVerifiedThrough),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
