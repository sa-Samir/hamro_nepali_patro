import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/calendar/models/season.dart';
import '../../features/settings/models/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const _language = 'language';
  static const _numerals = 'numerals';
  static const _themeMode = 'themeMode';
  static const _showAd = 'showAdInCalendar';
  static const _reminderMinutes = 'reminderMinutes';
  static const _todayNotification = 'todayNotification';
  static const _todayShowAd = 'todayNotificationShowAd';
  static const _todayShowEvents = 'todayNotificationShowEvents';
  static const _todayStyle = 'todayNotificationStyle';
  static const _widgetTheme = 'widgetTheme';
  static const _previewSeason = 'previewSeason';
  static const _tipDismissed = 'tipDismissed';

  static Future<SettingsRepository> create() async => SettingsRepository(
    await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions()),
  );

  AppSettings load() {
    const d = AppSettings();
    return AppSettings(
      language: AppLanguage.values.asNameMap()[_prefs.getString(_language)] ?? d.language,
      numerals: NumeralStyle.values.asNameMap()[_prefs.getString(_numerals)] ?? d.numerals,
      themeMode: ThemeMode.values.asNameMap()[_prefs.getString(_themeMode)] ?? d.themeMode,
      showAdInCalendar: _prefs.getBool(_showAd) ?? d.showAdInCalendar,
      reminderMinutes: _prefs.getInt(_reminderMinutes) ?? d.reminderMinutes,
      todayNotification: _prefs.getBool(_todayNotification) ?? d.todayNotification,
      todayNotificationShowAd: _prefs.getBool(_todayShowAd) ?? d.todayNotificationShowAd,
      todayNotificationShowEvents: _prefs.getBool(_todayShowEvents) ?? d.todayNotificationShowEvents,
      todayNotificationStyle:
          TodayNotificationStyle.values.asNameMap()[_prefs.getString(_todayStyle)] ?? d.todayNotificationStyle,
      widgetTheme: WidgetTheme.values.asNameMap()[_prefs.getString(_widgetTheme)] ?? d.widgetTheme,
      previewSeason: Season.values.asNameMap()[_prefs.getString(_previewSeason)],
      tipDismissed: _prefs.getBool(_tipDismissed) ?? d.tipDismissed,
    );
  }

  Future<void> save(AppSettings s) async {
    await Future.wait([
      _prefs.setString(_language, s.language.name),
      _prefs.setString(_numerals, s.numerals.name),
      _prefs.setString(_themeMode, s.themeMode.name),
      _prefs.setBool(_showAd, s.showAdInCalendar),
      _prefs.setInt(_reminderMinutes, s.reminderMinutes),
      _prefs.setBool(_todayNotification, s.todayNotification),
      _prefs.setBool(_todayShowAd, s.todayNotificationShowAd),
      _prefs.setBool(_todayShowEvents, s.todayNotificationShowEvents),
      _prefs.setString(_todayStyle, s.todayNotificationStyle.name),
      _prefs.setString(_widgetTheme, s.widgetTheme.name),
      _prefs.setString(_previewSeason, s.previewSeason?.name ?? ''),
      _prefs.setBool(_tipDismissed, s.tipDismissed),
    ]);
  }
}
