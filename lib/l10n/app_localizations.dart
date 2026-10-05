import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Patro'**
  String get appTitle;

  /// No description provided for @nepaliCalendar.
  ///
  /// In en, this message translates to:
  /// **'Nepali Calendar'**
  String get nepaliCalendar;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navConverter.
  ///
  /// In en, this message translates to:
  /// **'Converter'**
  String get navConverter;

  /// No description provided for @navNotes.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get navNotes;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @tipNewFeature.
  ///
  /// In en, this message translates to:
  /// **'New: save your important dates. Tap a date, then the bell to get reminded before it comes.'**
  String get tipNewFeature;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @nothingOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this day'**
  String get nothingOnThisDay;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @publicHoliday.
  ///
  /// In en, this message translates to:
  /// **'Public holiday'**
  String get publicHoliday;

  /// No description provided for @holidayDataMissing.
  ///
  /// In en, this message translates to:
  /// **'Holiday data isn\'t available for {year} yet.'**
  String holidayDataMissing(String year);

  /// No description provided for @goToMonth.
  ///
  /// In en, this message translates to:
  /// **'Go to month'**
  String get goToMonth;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @converterTitle.
  ///
  /// In en, this message translates to:
  /// **'Date converter'**
  String get converterTitle;

  /// No description provided for @bsToAd.
  ///
  /// In en, this message translates to:
  /// **'BS → AD'**
  String get bsToAd;

  /// No description provided for @adToBs.
  ///
  /// In en, this message translates to:
  /// **'AD → BS'**
  String get adToBs;

  /// No description provided for @bsDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date in BS'**
  String get bsDateLabel;

  /// No description provided for @adDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date in AD'**
  String get adDateLabel;

  /// No description provided for @convertedDate.
  ///
  /// In en, this message translates to:
  /// **'Converted date'**
  String get convertedDate;

  /// No description provided for @tapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get tapToChange;

  /// No description provided for @isToday.
  ///
  /// In en, this message translates to:
  /// **'That\'s today'**
  String get isToday;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tomorrow} other{In {count} days}}'**
  String inDays(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Yesterday} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @daysBetweenTitle.
  ///
  /// In en, this message translates to:
  /// **'Days between dates'**
  String get daysBetweenTitle;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String totalDays(int count);

  /// No description provided for @yearsMonthsDays.
  ///
  /// In en, this message translates to:
  /// **'{years} y, {months} m, {days} d'**
  String yearsMonthsDays(int years, int months, int days);

  /// No description provided for @addReminderOnDate.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminderOnDate;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notesTitle;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @emptyNotes.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet. Tap + to save an important date.'**
  String get emptyNotes;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get noteDeleted;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editNote;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Aama\'s birthday'**
  String get titleHint;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get descriptionLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @repeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatLabel;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t repeat'**
  String get repeatNone;

  /// No description provided for @repeatYearlyBs.
  ///
  /// In en, this message translates to:
  /// **'Every year (same BS date)'**
  String get repeatYearlyBs;

  /// No description provided for @repeatYearlyAd.
  ///
  /// In en, this message translates to:
  /// **'Every year (same AD date)'**
  String get repeatYearlyAd;

  /// No description provided for @repeatMonthlyBs.
  ///
  /// In en, this message translates to:
  /// **'Every month (same BS day)'**
  String get repeatMonthlyBs;

  /// No description provided for @notifyMe.
  ///
  /// In en, this message translates to:
  /// **'Notify me'**
  String get notifyMe;

  /// No description provided for @notifyWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get notifyWhen;

  /// No description provided for @onTheDay.
  ///
  /// In en, this message translates to:
  /// **'On the day'**
  String get onTheDay;

  /// No description provided for @daysBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day before} other{{count} days before}}'**
  String daysBefore(int count);

  /// No description provided for @weekBefore.
  ///
  /// In en, this message translates to:
  /// **'1 week before'**
  String get weekBefore;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTime;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this reminder?'**
  String get deleteNoteConfirm;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Patro. Turn them on in system settings to get reminders.'**
  String get notificationsDenied;

  /// No description provided for @reminderToday.
  ///
  /// In en, this message translates to:
  /// **'Today · {date}'**
  String reminderToday(String date);

  /// No description provided for @reminderInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tomorrow · {date}} other{In {count} days · {date}}}'**
  String reminderInDays(int count, String date);

  /// No description provided for @reminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders for your saved dates'**
  String get reminderChannelDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @numerals.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get numerals;

  /// No description provided for @numeralsNepali.
  ///
  /// In en, this message translates to:
  /// **'Nepali १२३'**
  String get numeralsNepali;

  /// No description provided for @numeralsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English 123'**
  String get numeralsEnglish;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @showAdDates.
  ///
  /// In en, this message translates to:
  /// **'Show AD dates in the calendar'**
  String get showAdDates;

  /// No description provided for @sectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get sectionReminders;

  /// No description provided for @defaultReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Default reminder time'**
  String get defaultReminderTime;

  /// No description provided for @sectionTodayNotification.
  ///
  /// In en, this message translates to:
  /// **'Today in the notification bar'**
  String get sectionTodayNotification;

  /// No description provided for @todayNotification.
  ///
  /// In en, this message translates to:
  /// **'Show today\'s date'**
  String get todayNotification;

  /// No description provided for @todayNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A silent notification that updates every midnight'**
  String get todayNotificationSubtitle;

  /// No description provided for @includeAdDate.
  ///
  /// In en, this message translates to:
  /// **'Include AD date'**
  String get includeAdDate;

  /// No description provided for @includeEvents.
  ///
  /// In en, this message translates to:
  /// **'Include holidays and reminders'**
  String get includeEvents;

  /// No description provided for @sectionWidgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get sectionWidgets;

  /// No description provided for @widgetToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get widgetToday;

  /// No description provided for @widgetAgenda.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get widgetAgenda;

  /// No description provided for @widgetMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get widgetMonth;

  /// No description provided for @widgetsHintIos.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold your Home Screen or Lock Screen, tap Edit, then Add Widget and search for Patro.'**
  String get widgetsHintIos;

  /// No description provided for @widgetsHintAndroid.
  ///
  /// In en, this message translates to:
  /// **'Tap Add, or long-press your home screen and choose Widgets → Patro.'**
  String get widgetsHintAndroid;

  /// No description provided for @widgetPinUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Your launcher can\'t add widgets from apps. Long-press the home screen and choose Widgets.'**
  String get widgetPinUnsupported;

  /// No description provided for @sectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get sectionBackup;

  /// No description provided for @exportNotes.
  ///
  /// In en, this message translates to:
  /// **'Export reminders'**
  String get exportNotes;

  /// No description provided for @exportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a backup file to restore on another phone'**
  String get exportSubtitle;

  /// No description provided for @importNotes.
  ///
  /// In en, this message translates to:
  /// **'Import reminders'**
  String get importNotes;

  /// No description provided for @importSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add reminders from a backup file'**
  String get importSubtitle;

  /// No description provided for @exportDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 reminder} other{Exported {count} reminders}}'**
  String exportDone(int count);

  /// No description provided for @importConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 reminder from this backup?} other{Add {count} reminders from this backup?}}'**
  String importConfirm(int count);

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 reminder} other{Imported {count} reminders}}'**
  String importDone(int count);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t a valid Patro backup.'**
  String get importFailed;

  /// No description provided for @nothingToExport.
  ///
  /// In en, this message translates to:
  /// **'There are no reminders to export yet.'**
  String get nothingToExport;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @holidayDataYears.
  ///
  /// In en, this message translates to:
  /// **'Holiday data: {years} BS'**
  String holidayDataYears(String years);

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'No account needed. Everything stays on this phone.'**
  String get privacyNote;

  /// No description provided for @holidayDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Holiday dates follow the government calendar and may change if the government announces changes.'**
  String get holidayDisclaimer;

  /// No description provided for @estimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get estimated;

  /// No description provided for @estimatedExplain.
  ///
  /// In en, this message translates to:
  /// **'The official calendar for {year} isn\'t published yet. These dates are calculated astronomically and may move by a day.'**
  String estimatedExplain(String year);

  /// No description provided for @calendarData.
  ///
  /// In en, this message translates to:
  /// **'Calendar data'**
  String get calendarData;

  /// No description provided for @calendarDataVerified.
  ///
  /// In en, this message translates to:
  /// **'Published calendar through {year} BS; later years are calculated'**
  String calendarDataVerified(String year);

  /// No description provided for @calendarDataRevision.
  ///
  /// In en, this message translates to:
  /// **'Downloaded update {revision} in use'**
  String calendarDataRevision(String revision);

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @calendarDataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Calendar data updated'**
  String get calendarDataUpdated;

  /// No description provided for @calendarDataUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Calendar data is up to date'**
  String get calendarDataUpToDate;

  /// No description provided for @seasonBasanta.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get seasonBasanta;

  /// No description provided for @seasonGrishma.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonGrishma;

  /// No description provided for @seasonBarsha.
  ///
  /// In en, this message translates to:
  /// **'Monsoon'**
  String get seasonBarsha;

  /// No description provided for @seasonSharad.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get seasonSharad;

  /// No description provided for @seasonHemanta.
  ///
  /// In en, this message translates to:
  /// **'Early winter'**
  String get seasonHemanta;

  /// No description provided for @seasonShishir.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get seasonShishir;

  /// No description provided for @photoCredits.
  ///
  /// In en, this message translates to:
  /// **'Photo credits'**
  String get photoCredits;

  /// No description provided for @photoCreditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Season photos from Wikimedia Commons'**
  String get photoCreditsSubtitle;

  /// No description provided for @notificationStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get notificationStyle;

  /// No description provided for @notificationStyleNumber.
  ///
  /// In en, this message translates to:
  /// **'Big number'**
  String get notificationStyleNumber;

  /// No description provided for @notificationStylePage.
  ///
  /// In en, this message translates to:
  /// **'Desk page'**
  String get notificationStylePage;

  /// No description provided for @notificationStyleNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Today\'s day as a large number'**
  String get notificationStyleNumberHint;

  /// No description provided for @notificationStylePageHint.
  ///
  /// In en, this message translates to:
  /// **'A small tear-off calendar page'**
  String get notificationStylePageHint;

  /// No description provided for @notificationStyleMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon and tithi'**
  String get notificationStyleMoon;

  /// No description provided for @notificationStyleMoonHint.
  ///
  /// In en, this message translates to:
  /// **'Moon phase, tithi and the next aunsi or purnima'**
  String get notificationStyleMoonHint;

  /// No description provided for @notificationStyleWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get notificationStyleWeek;

  /// No description provided for @notificationStyleWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Sunday to Saturday with today marked'**
  String get notificationStyleWeekHint;

  /// No description provided for @notificationStyleCountdown.
  ///
  /// In en, this message translates to:
  /// **'Next festival'**
  String get notificationStyleCountdown;

  /// No description provided for @notificationStyleCountdownHint.
  ///
  /// In en, this message translates to:
  /// **'Days left until the next holiday or reminder'**
  String get notificationStyleCountdownHint;

  /// No description provided for @notificationStylePlain.
  ///
  /// In en, this message translates to:
  /// **'Plain text'**
  String get notificationStylePlain;

  /// No description provided for @notificationStylePlainHint.
  ///
  /// In en, this message translates to:
  /// **'A standard Android notification'**
  String get notificationStylePlainHint;

  /// No description provided for @widgetDesk.
  ///
  /// In en, this message translates to:
  /// **'Desk page'**
  String get widgetDesk;

  /// No description provided for @widgetWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get widgetWeek;

  /// No description provided for @widgetTheme.
  ///
  /// In en, this message translates to:
  /// **'Widget theme'**
  String get widgetTheme;

  /// No description provided for @widgetThemePhoto.
  ///
  /// In en, this message translates to:
  /// **'Season photo'**
  String get widgetThemePhoto;

  /// No description provided for @widgetThemePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'The app\'s season photo, changes every two months'**
  String get widgetThemePhotoHint;

  /// No description provided for @widgetThemeMaroon.
  ///
  /// In en, this message translates to:
  /// **'Rich maroon'**
  String get widgetThemeMaroon;

  /// No description provided for @widgetThemeMaroonHint.
  ///
  /// In en, this message translates to:
  /// **'Deep maroon with marigold accents'**
  String get widgetThemeMaroonHint;

  /// No description provided for @widgetThemeMarigold.
  ///
  /// In en, this message translates to:
  /// **'Marigold'**
  String get widgetThemeMarigold;

  /// No description provided for @widgetThemeMarigoldHint.
  ///
  /// In en, this message translates to:
  /// **'Warm marigold with maroon'**
  String get widgetThemeMarigoldHint;

  /// No description provided for @widgetThemeCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get widgetThemeCream;

  /// No description provided for @widgetThemeCreamHint.
  ///
  /// In en, this message translates to:
  /// **'Light and quiet, follows dark mode'**
  String get widgetThemeCreamHint;

  /// No description provided for @previewSeason.
  ///
  /// In en, this message translates to:
  /// **'Preview season'**
  String get previewSeason;

  /// No description provided for @previewSeasonAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get previewSeasonAuto;

  /// No description provided for @previewSeasonAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Follows the calendar'**
  String get previewSeasonAutoHint;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste'**
  String get greeting;

  /// No description provided for @todayIs.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String todayIs(String date);

  /// No description provided for @upcomingCount.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingCount;

  /// No description provided for @quickConvert.
  ///
  /// In en, this message translates to:
  /// **'Convert date'**
  String get quickConvert;

  /// No description provided for @quickReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get quickReminders;

  /// No description provided for @quickWidgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get quickWidgets;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get remindMe;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @nothingUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the next few weeks'**
  String get nothingUpcoming;

  /// No description provided for @statYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get statYears;

  /// No description provided for @statMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get statMonths;

  /// No description provided for @statDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get statDays;

  /// No description provided for @switchDirection.
  ///
  /// In en, this message translates to:
  /// **'Switch direction'**
  String get switchDirection;

  /// No description provided for @changeDate.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get changeDate;

  /// No description provided for @statHolidayData.
  ///
  /// In en, this message translates to:
  /// **'Holiday data'**
  String get statHolidayData;

  /// No description provided for @statVerifiedThrough.
  ///
  /// In en, this message translates to:
  /// **'Verified to'**
  String get statVerifiedThrough;

  /// No description provided for @remindShort.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
