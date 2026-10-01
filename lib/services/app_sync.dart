import 'dart:async';

import '../data/remote/calendar_data_cubit.dart';
import '../data/repositories/holiday_repository.dart';
import '../features/calendar/models/day_event.dart';
import '../features/notes/cubit/notes_cubit.dart';
import '../features/settings/cubit/settings_cubit.dart';
import 'native_bridge.dart';
import 'reminder_scheduler.dart';

/// Keeps reminders, widgets and the ongoing notification in step with notes
/// and settings. Changes are debounced so a burst of edits costs one sync.
class AppSync {
  AppSync({
    required this.settings,
    required this.notes,
    required this.calendarData,
    required this.holidays,
    required this.reminders,
    required this.native,
  });

  final SettingsCubit settings;
  final NotesCubit notes;
  final CalendarDataCubit calendarData;
  final HolidayRepository holidays;
  final ReminderScheduler reminders;
  final NativeBridge native;

  final _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _debounce;

  void start() {
    _subscriptions
      ..add(settings.stream.listen((_) => _schedule()))
      ..add(notes.stream.listen((_) => _schedule()))
      ..add(calendarData.stream.listen((_) => _schedule()));
    _schedule();
  }

  /// Call when the app returns to the foreground; the date may have changed
  /// and newer calendar data may be available.
  void refresh() {
    calendarData.refresh();
    _schedule();
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _run);
  }

  Future<void> _run() async {
    if (!notes.state.loaded) return;
    final s = settings.state;
    final index = EventIndex(holidays: holidays, notes: notes.state.notes, language: s.language);
    await Future.wait([reminders.reschedule(notes.state.notes, s), native.sync(settings: s, events: index)]);
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    for (final s in _subscriptions) {
      await s.cancel();
    }
  }
}
