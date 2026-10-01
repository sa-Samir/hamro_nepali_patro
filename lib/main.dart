import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/database/app_database.dart';
import 'data/repositories/holiday_repository.dart';
import 'data/repositories/notes_repository.dart';
import 'data/remote/calendar_data_cubit.dart';
import 'data/remote/calendar_data_service.dart';
import 'data/repositories/settings_repository.dart';
import 'features/notes/cubit/notes_cubit.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'services/app_sync.dart';
import 'services/backup_service.dart';
import 'services/native_bridge.dart';
import 'services/reminder_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final settingsRepository = await SettingsRepository.create();
  final notesRepository = NotesRepository(AppDatabase());
  final holidays = await HolidayRepository.load();
  final calendarData = CalendarDataService(holidays: holidays);
  await calendarData.loadCached();
  final reminders = ReminderScheduler(FlutterLocalNotificationsPlugin());
  final native = NativeBridge();
  await Future.wait([reminders.init(), native.init()]);

  final settingsCubit = SettingsCubit(settingsRepository);
  final notesCubit = NotesCubit(notesRepository);
  final calendarDataCubit = CalendarDataCubit(calendarData)..refresh();
  final sync = AppSync(
    settings: settingsCubit,
    notes: notesCubit,
    calendarData: calendarDataCubit,
    holidays: holidays,
    reminders: reminders,
    native: native,
  )..start();

  runApp(
    PatroApp(
      settingsCubit: settingsCubit,
      notesCubit: notesCubit,
      calendarDataCubit: calendarDataCubit,
      holidays: holidays,
      reminders: reminders,
      native: native,
      backup: BackupService(),
      sync: sync,
    ),
  );
}
