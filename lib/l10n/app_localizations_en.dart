// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Patro';

  @override
  String get nepaliCalendar => 'Nepali Calendar';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navConverter => 'Converter';

  @override
  String get navNotes => 'Reminders';

  @override
  String get navSettings => 'Settings';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get tipNewFeature =>
      'New: save your important dates. Tap a date, then the bell to get reminded before it comes.';

  @override
  String get add => 'Add';

  @override
  String get nothingOnThisDay => 'Nothing on this day';

  @override
  String get thisMonth => 'This month';

  @override
  String get publicHoliday => 'Public holiday';

  @override
  String holidayDataMissing(String year) {
    return 'Holiday data isn\'t available for $year yet.';
  }

  @override
  String get goToMonth => 'Go to month';

  @override
  String get year => 'Year';

  @override
  String get month => 'Month';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get share => 'Share';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get converterTitle => 'Date converter';

  @override
  String get bsToAd => 'BS → AD';

  @override
  String get adToBs => 'AD → BS';

  @override
  String get bsDateLabel => 'Date in BS';

  @override
  String get adDateLabel => 'Date in AD';

  @override
  String get convertedDate => 'Converted date';

  @override
  String get tapToChange => 'Tap to change';

  @override
  String get isToday => 'That\'s today';

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'Tomorrow',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'Yesterday',
    );
    return '$_temp0';
  }

  @override
  String get daysBetweenTitle => 'Days between dates';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get swap => 'Swap';

  @override
  String totalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String yearsMonthsDays(int years, int months, int days) {
    return '$years y, $months m, $days d';
  }

  @override
  String get addReminderOnDate => 'Add reminder';

  @override
  String get notesTitle => 'Reminders';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get emptyNotes => 'No reminders yet. Tap + to save an important date.';

  @override
  String get noteDeleted => 'Reminder deleted';

  @override
  String get newNote => 'New reminder';

  @override
  String get editNote => 'Edit reminder';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleHint => 'e.g. Aama\'s birthday';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get descriptionLabel => 'Notes (optional)';

  @override
  String get dateLabel => 'Date';

  @override
  String get repeatLabel => 'Repeat';

  @override
  String get repeatNone => 'Doesn\'t repeat';

  @override
  String get repeatYearlyBs => 'Every year (same BS date)';

  @override
  String get repeatYearlyAd => 'Every year (same AD date)';

  @override
  String get repeatMonthlyBs => 'Every month (same BS day)';

  @override
  String get notifyMe => 'Notify me';

  @override
  String get notifyWhen => 'When';

  @override
  String get onTheDay => 'On the day';

  @override
  String daysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get weekBefore => '1 week before';

  @override
  String get reminderTime => 'Time';

  @override
  String get deleteNoteConfirm => 'Delete this reminder?';

  @override
  String get notificationsDenied =>
      'Notifications are off for Patro. Turn them on in system settings to get reminders.';

  @override
  String reminderToday(String date) {
    return 'Today · $date';
  }

  @override
  String reminderInDays(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days · $date',
      one: 'Tomorrow · $date',
    );
    return '$_temp0';
  }

  @override
  String get reminderChannelName => 'Reminders';

  @override
  String get reminderChannelDescription => 'Reminders for your saved dates';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionGeneral => 'General';

  @override
  String get language => 'Language';

  @override
  String get numerals => 'Digits';

  @override
  String get numeralsNepali => 'Nepali १२३';

  @override
  String get numeralsEnglish => 'English 123';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get showAdDates => 'Show AD dates in the calendar';

  @override
  String get sectionReminders => 'Reminders';

  @override
  String get defaultReminderTime => 'Default reminder time';

  @override
  String get sectionTodayNotification => 'Today in the notification bar';

  @override
  String get todayNotification => 'Show today\'s date';

  @override
  String get todayNotificationSubtitle =>
      'A silent notification that updates every midnight';

  @override
  String get includeAdDate => 'Include AD date';

  @override
  String get includeEvents => 'Include holidays and reminders';

  @override
  String get sectionWidgets => 'Widgets';

  @override
  String get widgetToday => 'Today';

  @override
  String get widgetAgenda => 'Upcoming';

  @override
  String get widgetMonth => 'Month';

  @override
  String get widgetsHintIos =>
      'Touch and hold your Home Screen or Lock Screen, tap Edit, then Add Widget and search for Patro.';

  @override
  String get widgetsHintAndroid =>
      'Tap Add, or long-press your home screen and choose Widgets → Patro.';

  @override
  String get widgetPinUnsupported =>
      'Your launcher can\'t add widgets from apps. Long-press the home screen and choose Widgets.';

  @override
  String get sectionBackup => 'Backup';

  @override
  String get exportNotes => 'Export reminders';

  @override
  String get exportSubtitle => 'Save a backup file to restore on another phone';

  @override
  String get importNotes => 'Import reminders';

  @override
  String get importSubtitle => 'Add reminders from a backup file';

  @override
  String exportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count reminders',
      one: 'Exported 1 reminder',
    );
    return '$_temp0';
  }

  @override
  String importConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count reminders from this backup?',
      one: 'Add 1 reminder from this backup?',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count reminders',
      one: 'Imported 1 reminder',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'That file isn\'t a valid Patro backup.';

  @override
  String get nothingToExport => 'There are no reminders to export yet.';

  @override
  String get sectionAbout => 'About';

  @override
  String holidayDataYears(String years) {
    return 'Holiday data: $years BS';
  }

  @override
  String get privacyNote =>
      'No account needed. Everything stays on this phone.';

  @override
  String get holidayDisclaimer =>
      'Holiday dates follow the government calendar and may change if the government announces changes.';

  @override
  String get estimated => 'Estimated';

  @override
  String estimatedExplain(String year) {
    return 'The official calendar for $year isn\'t published yet. These dates are calculated astronomically and may move by a day.';
  }

  @override
  String get calendarData => 'Calendar data';

  @override
  String calendarDataVerified(String year) {
    return 'Published calendar through $year BS; later years are calculated';
  }

  @override
  String calendarDataRevision(String revision) {
    return 'Downloaded update $revision in use';
  }

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get calendarDataUpdated => 'Calendar data updated';

  @override
  String get calendarDataUpToDate => 'Calendar data is up to date';

  @override
  String get seasonBasanta => 'Spring';

  @override
  String get seasonGrishma => 'Summer';

  @override
  String get seasonBarsha => 'Monsoon';

  @override
  String get seasonSharad => 'Autumn';

  @override
  String get seasonHemanta => 'Early winter';

  @override
  String get seasonShishir => 'Winter';

  @override
  String get photoCredits => 'Photo credits';

  @override
  String get photoCreditsSubtitle => 'Season photos from Wikimedia Commons';

  @override
  String get notificationStyle => 'Style';

  @override
  String get notificationStyleNumber => 'Big number';

  @override
  String get notificationStylePage => 'Desk page';

  @override
  String get notificationStyleNumberHint => 'Today\'s day as a large number';

  @override
  String get notificationStylePageHint => 'A small tear-off calendar page';

  @override
  String get notificationStyleMoon => 'Moon and tithi';

  @override
  String get notificationStyleMoonHint =>
      'Moon phase, tithi and the next aunsi or purnima';

  @override
  String get notificationStyleWeek => 'This week';

  @override
  String get notificationStyleWeekHint =>
      'Sunday to Saturday with today marked';

  @override
  String get notificationStyleCountdown => 'Next festival';

  @override
  String get notificationStyleCountdownHint =>
      'Days left until the next holiday or reminder';

  @override
  String get notificationStylePlain => 'Plain text';

  @override
  String get notificationStylePlainHint => 'A standard Android notification';

  @override
  String get widgetDesk => 'Desk page';

  @override
  String get widgetWeek => 'This week';

  @override
  String get widgetTheme => 'Widget theme';

  @override
  String get widgetThemePhoto => 'Season photo';

  @override
  String get widgetThemePhotoHint =>
      'The app\'s season photo, changes every two months';

  @override
  String get widgetThemeMaroon => 'Rich maroon';

  @override
  String get widgetThemeMaroonHint => 'Deep maroon with marigold accents';

  @override
  String get widgetThemeMarigold => 'Marigold';

  @override
  String get widgetThemeMarigoldHint => 'Warm marigold with maroon';

  @override
  String get widgetThemeCream => 'Sage';

  @override
  String get widgetThemeCreamHint => 'Light, follows dark mode';

  @override
  String get previewSeason => 'Preview season';

  @override
  String get previewSeasonAuto => 'Automatic';

  @override
  String get previewSeasonAutoHint => 'Follows the calendar';

  @override
  String get greeting => 'Namaste';

  @override
  String todayIs(String date) {
    return 'Today, $date';
  }

  @override
  String get upcomingCount => 'Upcoming';

  @override
  String get quickConvert => 'Convert date';

  @override
  String get quickReminders => 'Reminders';

  @override
  String get quickWidgets => 'Widgets';

  @override
  String get remindMe => 'Add reminder';

  @override
  String get history => 'History';

  @override
  String get edit => 'Edit';

  @override
  String get nothingUpcoming => 'Nothing in the next few weeks';

  @override
  String get statYears => 'Years';

  @override
  String get statMonths => 'Months';

  @override
  String get statDays => 'Days';

  @override
  String get switchDirection => 'Switch direction';

  @override
  String get changeDate => 'Change date';

  @override
  String get statHolidayData => 'Holiday data';

  @override
  String get statVerifiedThrough => 'Verified to';

  @override
  String get remindShort => 'Remind me';

  @override
  String get tileLook => 'Look';

  @override
  String get tileNotification => 'Notification';

  @override
  String get stateOn => 'On';

  @override
  String get stateOff => 'Off';

  @override
  String get previewLabel => 'Preview';

  @override
  String get sampleReminder => 'Aama\'s birthday';

  @override
  String reminderCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reminders',
      one: '1 reminder',
      zero: 'No reminders',
    );
    return '$_temp0';
  }

  @override
  String get addToHomeScreen => 'Add to home screen';

  @override
  String get settingsSubtitle => 'Tap a tile to change it';

  @override
  String get widgetThemeForest => 'Forest';

  @override
  String get widgetThemeForestHint => 'Deep green with lime, like the app';

  @override
  String get palette => 'Palette';

  @override
  String get paletteForest => 'Forest';

  @override
  String get paletteHimalaya => 'Himalayan night';

  @override
  String get paletteTerracotta => 'Terracotta';

  @override
  String get paletteRhododendron => 'Rhododendron';

  @override
  String get paletteLake => 'Lake';

  @override
  String get paletteMaroon => 'Maroon';
}
