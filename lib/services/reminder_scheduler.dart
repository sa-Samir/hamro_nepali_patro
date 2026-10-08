import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/bs/bs_date.dart';
import '../core/bs/date_formatter.dart';
import '../features/notes/models/note.dart';
import '../features/settings/models/app_settings.dart';
import '../l10n/app_localizations.dart';

/// A reminder notification to be delivered at [at].
@immutable
class PlannedReminder {
  const PlannedReminder({required this.at, required this.note, required this.occurrence, required this.daysBefore});

  final DateTime at;
  final Note note;
  final BsDate occurrence;
  final int daysBefore;
}

/// Works out upcoming reminder times. iOS keeps at most 64 pending local
/// notifications, so only the soonest [limit] are scheduled; the list is
/// rebuilt every time the app starts or a note changes.
List<PlannedReminder> planReminders(List<Note> notes, DateTime now, {int limit = 60, int horizonDays = 400}) {
  final today = BsDate.fromAd(now);
  final end = BsDate.fromAd(now.add(Duration(days: horizonDays)));
  final planned = <PlannedReminder>[];
  for (final note in notes.where((n) => n.remind && n.reminderOffsets.isNotEmpty)) {
    for (final occurrence in note.occurrencesBetween(today, end)) {
      final day = occurrence.toAd();
      for (final offset in note.reminderOffsets) {
        final at = DateTime(day.year, day.month, day.day - offset).add(Duration(minutes: note.reminderMinutes));
        if (at.isAfter(now)) {
          planned.add(PlannedReminder(at: at, note: note, occurrence: occurrence, daysBefore: offset));
        }
      }
    }
  }
  planned.sort((a, b) => a.at.compareTo(b.at));
  return planned.take(limit).toList();
}

class ReminderScheduler {
  ReminderScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  static const _channelId = 'reminders';

  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Kathmandu'));
    }
    // A broken notification setup must never stop the app from starting.
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic_stat_patro'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
  }

  /// Asks for notification permission. Returns whether it was granted.
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, sound: true, badge: false) ?? false;
  }

  /// Replaces every pending reminder with a fresh plan for [notes].
  Future<void> reschedule(List<Note> notes, AppSettings settings) async {
    // Cancel only what this plugin scheduled; cancelAll() would also clear the
    // native ongoing "today" notification on Android.
    for (final pending in await _plugin.pendingNotificationRequests()) {
      await _plugin.cancel(id: pending.id);
    }

    final plan = planReminders(notes, DateTime.now());
    if (plan.isEmpty) return;

    final l10n = lookupAppLocalizations(settings.language.locale);
    final fmt = DateFormatter.of(settings);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.reminderChannelName,
        channelDescription: l10n.reminderChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_stat_patro',
      ),
      iOS: const DarwinNotificationDetails(),
    );
    final mode = await _androidScheduleMode();

    for (var i = 0; i < plan.length; i++) {
      final r = plan[i];
      final date = fmt.bsDate(r.occurrence);
      final body = r.daysBefore == 0 ? l10n.reminderToday(date) : fmt.digits(l10n.reminderInDays(r.daysBefore, date));
      await _plugin.zonedSchedule(
        id: 1000 + i,
        title: r.note.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        notificationDetails: details,
        androidScheduleMode: mode,
        payload: '${r.note.id}',
      );
    }
  }

  Future<AndroidScheduleMode> _androidScheduleMode() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final exact = await android?.canScheduleExactNotifications() ?? false;
    return exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
  }
}
