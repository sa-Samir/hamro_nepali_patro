import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../core/astro/bs_calculator.dart';
import '../core/bs/bs_date.dart';
import '../features/calendar/models/day_event.dart';
import '../features/settings/models/app_settings.dart';

enum WidgetKind { today, desk, agenda, week, month }

/// Talks to the native widgets and Android's ongoing notification.
/// See docs/NATIVE_CONTRACT.md for the keys and methods.
class NativeBridge {
  static const appGroupId = 'group.com.nepali.patro';
  static const _channel = MethodChannel('com.nepali.patro/native');

  Future<void> init() async {
    if (Platform.isIOS) await HomeWidget.setAppGroupId(appGroupId);
  }

  /// Publishes settings and upcoming events, then asks native code to redraw
  /// widgets and the ongoing notification.
  Future<void> sync({required AppSettings settings, required EventIndex events}) async {
    final today = BsDate.today();
    // From the start of the month so the month widget can colour past holidays.
    final upcoming = events.between(today.firstOfMonth, today.addDays(120));
    final payload = jsonEncode([
      for (final e in upcoming)
        {
          'ad': _isoDate(e.date.toAd()),
          'title': e.title,
          'kind': switch (e.kind) {
            DayEventKind.holiday => 'holiday',
            DayEventKind.festival => 'event',
            DayEventKind.note => 'note',
          },
        },
    ]);
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>('lang', settings.language.name),
        HomeWidget.saveWidgetData<String>('numerals', settings.numerals == NumeralStyle.devanagari ? 'ne' : 'en'),
        HomeWidget.saveWidgetData<String>('events', payload),
        HomeWidget.saveWidgetData<String>('tithis', _tithis(today)),
        HomeWidget.saveWidgetData<String>(
          'bs_overrides',
          jsonEncode(BsDate.overrides.map((year, row) => MapEntry('$year', row))),
        ),
        HomeWidget.saveWidgetData<bool>('pn_enabled', settings.todayNotification),
        HomeWidget.saveWidgetData<bool>('pn_show_ad', settings.todayNotificationShowAd),
        HomeWidget.saveWidgetData<bool>('pn_show_events', settings.todayNotificationShowEvents),
        HomeWidget.saveWidgetData<String>('pn_style', settings.todayNotificationStyle.name),
        HomeWidget.saveWidgetData<String>('widget_theme', settings.widgetTheme.name),
        HomeWidget.saveWidgetData<String>('season_override', settings.previewSeason?.name ?? ''),
      ]);
      await _channel.invokeMethod<void>('refreshAll');
    } on MissingPluginException {
      // Tests and unsupported platforms.
    } on PlatformException catch (e) {
      debugPrint('Native refresh failed: $e');
    }
  }

  /// Asks the Android launcher to pin a widget. Returns false where that
  /// isn't supported (always on iOS).
  Future<bool> requestPinWidget(WidgetKind kind) async {
    try {
      return await _channel.invokeMethod<bool>('requestPinWidget', {'kind': kind.name}) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Sunrise tithi (1–30) by AD date, yesterday → +120 days, for the
  /// notification; native code has no astronomy of its own.
  static String _tithis(BsDate today) {
    const calculator = BsCalculator();
    final start = today.toAd().subtract(const Duration(days: 1));
    return jsonEncode({
      for (var i = 0; i <= 121; i++)
        _isoDate(start.add(Duration(days: i))): calculator.tithiOn(start.add(Duration(days: i))).number,
    });
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
