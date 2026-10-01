import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../calendar/models/season.dart';

enum AppLanguage {
  ne,
  en;

  Locale get locale => Locale(name);
}

enum NumeralStyle { devanagari, western }

/// Layout of Android's ongoing "today" notification.
enum TodayNotificationStyle { number, page, moon, week, countdown, plain }

/// Look of the home-screen widgets.
enum WidgetTheme { photo, maroon, marigold, cream }

class AppSettings extends Equatable {
  const AppSettings({
    this.language = AppLanguage.ne,
    this.numerals = NumeralStyle.devanagari,
    this.themeMode = ThemeMode.system,
    this.showAdInCalendar = true,
    this.reminderMinutes = 8 * 60,
    this.todayNotification = false,
    this.todayNotificationShowAd = true,
    this.todayNotificationShowEvents = true,
    this.todayNotificationStyle = TodayNotificationStyle.number,
    this.widgetTheme = WidgetTheme.photo,
    this.previewSeason,
    this.tipDismissed = false,
  });

  final AppLanguage language;
  final NumeralStyle numerals;
  final ThemeMode themeMode;
  final bool showAdInCalendar;

  /// Default reminder time for new notes, in minutes after midnight.
  final int reminderMinutes;

  /// Android's ongoing notification that shows today's date.
  final bool todayNotification;
  final bool todayNotificationShowAd;
  final bool todayNotificationShowEvents;
  final TodayNotificationStyle todayNotificationStyle;
  final WidgetTheme widgetTheme;

  /// Shows this season's photo instead of the current one (null = follow the calendar).
  final Season? previewSeason;

  final bool tipDismissed;

  AppSettings copyWith({
    AppLanguage? language,
    NumeralStyle? numerals,
    ThemeMode? themeMode,
    bool? showAdInCalendar,
    int? reminderMinutes,
    bool? todayNotification,
    bool? todayNotificationShowAd,
    bool? todayNotificationShowEvents,
    TodayNotificationStyle? todayNotificationStyle,
    WidgetTheme? widgetTheme,
    Season? Function()? previewSeason,
    bool? tipDismissed,
  }) {
    return AppSettings(
      language: language ?? this.language,
      numerals: numerals ?? this.numerals,
      themeMode: themeMode ?? this.themeMode,
      showAdInCalendar: showAdInCalendar ?? this.showAdInCalendar,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      todayNotification: todayNotification ?? this.todayNotification,
      todayNotificationShowAd: todayNotificationShowAd ?? this.todayNotificationShowAd,
      todayNotificationShowEvents: todayNotificationShowEvents ?? this.todayNotificationShowEvents,
      todayNotificationStyle: todayNotificationStyle ?? this.todayNotificationStyle,
      widgetTheme: widgetTheme ?? this.widgetTheme,
      previewSeason: previewSeason != null ? previewSeason() : this.previewSeason,
      tipDismissed: tipDismissed ?? this.tipDismissed,
    );
  }

  @override
  List<Object?> get props => [
    language,
    numerals,
    themeMode,
    showAdInCalendar,
    reminderMinutes,
    todayNotification,
    todayNotificationShowAd,
    todayNotificationShowEvents,
    todayNotificationStyle,
    widgetTheme,
    previewSeason,
    tipDismissed,
  ];
}
