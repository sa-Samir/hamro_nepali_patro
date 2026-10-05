import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'data/remote/calendar_data_cubit.dart';
import 'data/repositories/holiday_repository.dart';
import 'features/calendar/cubit/calendar_cubit.dart';
import 'features/converter/cubit/converter_cubit.dart';
import 'features/home/home_shell.dart';
import 'features/notes/cubit/notes_cubit.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/models/app_settings.dart';
import 'l10n/app_localizations.dart';
import 'services/app_sync.dart';
import 'services/backup_service.dart';
import 'services/native_bridge.dart';
import 'services/reminder_scheduler.dart';

class PatroApp extends StatelessWidget {
  const PatroApp({
    super.key,
    required this.settingsCubit,
    required this.notesCubit,
    required this.calendarDataCubit,
    required this.holidays,
    required this.reminders,
    required this.native,
    required this.backup,
    required this.sync,
  });

  final SettingsCubit settingsCubit;
  final NotesCubit notesCubit;
  final CalendarDataCubit calendarDataCubit;
  final HolidayRepository holidays;
  final ReminderScheduler reminders;
  final NativeBridge native;
  final BackupService backup;
  final AppSync sync;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: holidays),
        RepositoryProvider.value(value: reminders),
        RepositoryProvider.value(value: native),
        RepositoryProvider.value(value: backup),
        RepositoryProvider.value(value: sync),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: settingsCubit),
          BlocProvider.value(value: notesCubit),
          BlocProvider.value(value: calendarDataCubit),
          BlocProvider(create: (_) => CalendarCubit()),
          BlocProvider(create: (_) => ConverterCubit()),
        ],
        child: BlocBuilder<SettingsCubit, AppSettings>(
          buildWhen: (a, b) => a.language != b.language || a.themeMode != b.themeMode || a.palette != b.palette,
          builder: (context, settings) => MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(settings.palette),
            darkTheme: AppTheme.dark(settings.palette),
            themeMode: settings.themeMode,
            locale: settings.language.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeShell(),
          ),
        ),
      ),
    );
  }
}
