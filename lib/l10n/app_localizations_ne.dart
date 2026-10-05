// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'पात्रो';

  @override
  String get nepaliCalendar => 'नेपाली पात्रो';

  @override
  String get navCalendar => 'पात्रो';

  @override
  String get navConverter => 'रूपान्तरण';

  @override
  String get navNotes => 'सम्झना';

  @override
  String get navSettings => 'सेटिङ';

  @override
  String get today => 'आज';

  @override
  String get tomorrow => 'भोलि';

  @override
  String get tipNewFeature =>
      'नयाँ सुविधा: अब तपाईं आफ्ना महत्वपूर्ण मितिहरू सुरक्षित राख्न सक्नुहुन्छ। मिति थिचेर घण्टी चिन्हबाट सम्झना थप्नुहोस्!';

  @override
  String get add => 'थप्नुस्';

  @override
  String get nothingOnThisDay => 'यो दिन केही छैन';

  @override
  String get thisMonth => 'यो महिना';

  @override
  String get publicHoliday => 'सार्वजनिक बिदा';

  @override
  String holidayDataMissing(String year) {
    return '$year को बिदा विवरण अहिले उपलब्ध छैन।';
  }

  @override
  String get goToMonth => 'महिनामा जानुहोस्';

  @override
  String get year => 'वर्ष';

  @override
  String get month => 'महिना';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get ok => 'ठिक छ';

  @override
  String get save => 'सुरक्षित गर्नुहोस्';

  @override
  String get delete => 'मेटाउनुहोस्';

  @override
  String get undo => 'पूर्ववत्';

  @override
  String get share => 'सेयर';

  @override
  String get previousMonth => 'अघिल्लो महिना';

  @override
  String get nextMonth => 'अर्को महिना';

  @override
  String get converterTitle => 'मिति रूपान्तरण';

  @override
  String get bsToAd => 'बि.सं. → ई.सं.';

  @override
  String get adToBs => 'ई.सं. → बि.सं.';

  @override
  String get bsDateLabel => 'बि.सं. मिति';

  @override
  String get adDateLabel => 'ई.सं. मिति';

  @override
  String get convertedDate => 'रूपान्तरित मिति';

  @override
  String get tapToChange => 'परिवर्तन गर्न थिच्नुहोस्';

  @override
  String get isToday => 'आज नै हो';

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिनपछि',
      one: 'भोलि',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन अघि',
      one: 'हिजो',
    );
    return '$_temp0';
  }

  @override
  String get daysBetweenTitle => 'दुई मितिबीचको अन्तर';

  @override
  String get fromDate => 'देखि';

  @override
  String get toDate => 'सम्म';

  @override
  String get swap => 'साटासाट';

  @override
  String totalDays(int count) {
    return '$count दिन';
  }

  @override
  String yearsMonthsDays(int years, int months, int days) {
    return '$years वर्ष, $months महिना, $days दिन';
  }

  @override
  String get addReminderOnDate => 'सम्झना थप्नुस्';

  @override
  String get notesTitle => 'सम्झनाहरू';

  @override
  String get upcoming => 'आगामी';

  @override
  String get past => 'बितेका';

  @override
  String get emptyNotes =>
      'अहिलेसम्म कुनै सम्झना छैन। महत्वपूर्ण मिति सुरक्षित गर्न + थिच्नुहोस्।';

  @override
  String get noteDeleted => 'सम्झना मेटाइयो';

  @override
  String get newNote => 'नयाँ सम्झना';

  @override
  String get editNote => 'सम्झना सम्पादन';

  @override
  String get titleLabel => 'शीर्षक';

  @override
  String get titleHint => 'जस्तै: आमाको जन्मदिन';

  @override
  String get titleRequired => 'शीर्षक लेख्नुहोस्';

  @override
  String get descriptionLabel => 'विवरण (ऐच्छिक)';

  @override
  String get dateLabel => 'मिति';

  @override
  String get repeatLabel => 'दोहोर्याउने';

  @override
  String get repeatNone => 'दोहोरिँदैन';

  @override
  String get repeatYearlyBs => 'हरेक वर्ष (उही बि.सं. मिति)';

  @override
  String get repeatYearlyAd => 'हरेक वर्ष (उही ई.सं. मिति)';

  @override
  String get repeatMonthlyBs => 'हरेक महिना (उही बि.सं. गते)';

  @override
  String get notifyMe => 'सूचना दिनुहोस्';

  @override
  String get notifyWhen => 'कहिले';

  @override
  String get onTheDay => 'सोही दिन';

  @override
  String daysBefore(int count) {
    return '$count दिन अघि';
  }

  @override
  String get weekBefore => '१ हप्ता अघि';

  @override
  String get reminderTime => 'समय';

  @override
  String get deleteNoteConfirm => 'यो सम्झना मेटाउने हो?';

  @override
  String get notificationsDenied =>
      'पात्रोका लागि सूचना बन्द छ। सम्झना पाउन सिस्टम सेटिङमा सूचना खोल्नुहोस्।';

  @override
  String reminderToday(String date) {
    return 'आज · $date';
  }

  @override
  String reminderInDays(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिनपछि · $date',
      one: 'भोलि · $date',
    );
    return '$_temp0';
  }

  @override
  String get reminderChannelName => 'सम्झनाहरू';

  @override
  String get reminderChannelDescription =>
      'तपाईंले सुरक्षित गरेका मितिहरूको सम्झना';

  @override
  String get settingsTitle => 'सेटिङ';

  @override
  String get sectionGeneral => 'सामान्य';

  @override
  String get language => 'भाषा';

  @override
  String get numerals => 'अंक';

  @override
  String get numeralsNepali => 'नेपाली १२३';

  @override
  String get numeralsEnglish => 'अंग्रेजी 123';

  @override
  String get theme => 'थिम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'उज्यालो';

  @override
  String get themeDark => 'अँध्यारो';

  @override
  String get showAdDates => 'पात्रोमा ई.सं. मिति देखाउनुहोस्';

  @override
  String get sectionReminders => 'सम्झना';

  @override
  String get defaultReminderTime => 'सम्झनाको पूर्वनिर्धारित समय';

  @override
  String get sectionTodayNotification => 'सूचना पट्टीमा आजको मिति';

  @override
  String get todayNotification => 'आजको मिति देखाउनुहोस्';

  @override
  String get todayNotificationSubtitle =>
      'हरेक मध्यरातमा आफैं अद्यावधिक हुने शान्त सूचना';

  @override
  String get includeAdDate => 'ई.सं. मिति पनि देखाउनुहोस्';

  @override
  String get includeEvents => 'बिदा र सम्झना पनि देखाउनुहोस्';

  @override
  String get sectionWidgets => 'विजेट';

  @override
  String get widgetToday => 'आज';

  @override
  String get widgetAgenda => 'आगामी';

  @override
  String get widgetMonth => 'महिना';

  @override
  String get widgetsHintIos =>
      'होम स्क्रिन वा लक स्क्रिनमा केही बेर थिच्नुहोस्, Edit → Add Widget मा गएर Patro खोज्नुहोस्।';

  @override
  String get widgetsHintAndroid =>
      'थप्नुस् थिच्नुहोस्, वा होम स्क्रिनमा केही बेर थिचेर Widgets → Patro छान्नुहोस्।';

  @override
  String get widgetPinUnsupported =>
      'तपाईंको लन्चरले एपबाट विजेट थप्न दिँदैन। होम स्क्रिनमा केही बेर थिचेर Widgets छान्नुहोस्।';

  @override
  String get sectionBackup => 'ब्याकअप';

  @override
  String get exportNotes => 'सम्झनाहरू निर्यात गर्नुहोस्';

  @override
  String get exportSubtitle =>
      'अर्को फोनमा फर्काउन ब्याकअप फाइल सुरक्षित गर्नुहोस्';

  @override
  String get importNotes => 'सम्झनाहरू आयात गर्नुहोस्';

  @override
  String get importSubtitle => 'ब्याकअप फाइलबाट सम्झनाहरू थप्नुहोस्';

  @override
  String exportDone(int count) {
    return '$count वटा सम्झना निर्यात भयो';
  }

  @override
  String importConfirm(int count) {
    return 'यो ब्याकअपबाट $count वटा सम्झना थप्ने हो?';
  }

  @override
  String importDone(int count) {
    return '$count वटा सम्झना आयात भयो';
  }

  @override
  String get importFailed => 'यो फाइल मान्य पात्रो ब्याकअप होइन।';

  @override
  String get nothingToExport => 'निर्यात गर्न कुनै सम्झना छैन।';

  @override
  String get sectionAbout => 'बारेमा';

  @override
  String holidayDataYears(String years) {
    return 'बिदा विवरण: बि.सं. $years';
  }

  @override
  String get privacyNote => 'खाता चाहिँदैन। सबै कुरा यही फोनमा रहन्छ।';

  @override
  String get holidayDisclaimer =>
      'बिदाका मितिहरू सरकारी पात्रो अनुसार छन्, सरकारले परिवर्तन गरेमा फरक पर्न सक्छ।';

  @override
  String get estimated => 'अनुमानित';

  @override
  String estimatedExplain(String year) {
    return '$year को आधिकारिक पात्रो प्रकाशित भइसकेको छैन। यी मितिहरू खगोलीय गणनाबाट निकालिएका हुन्, एक दिन फरक पर्न सक्छ।';
  }

  @override
  String get calendarData => 'पात्रो विवरण';

  @override
  String calendarDataVerified(String year) {
    return 'बि.सं. $year सम्म प्रकाशित पात्रो अनुसार; त्यसपछिका वर्ष गणना गरिएका';
  }

  @override
  String calendarDataRevision(String revision) {
    return 'डाउनलोड गरिएको अद्यावधिक $revision प्रयोगमा';
  }

  @override
  String get checkForUpdates => 'अद्यावधिक जाँच्नुहोस्';

  @override
  String get calendarDataUpdated => 'पात्रो विवरण अद्यावधिक भयो';

  @override
  String get calendarDataUpToDate => 'पात्रो विवरण अद्यावधिक छ';

  @override
  String get seasonBasanta => 'बसन्त ऋतु';

  @override
  String get seasonGrishma => 'ग्रीष्म ऋतु';

  @override
  String get seasonBarsha => 'वर्षा ऋतु';

  @override
  String get seasonSharad => 'शरद ऋतु';

  @override
  String get seasonHemanta => 'हेमन्त ऋतु';

  @override
  String get seasonShishir => 'शिशिर ऋतु';

  @override
  String get photoCredits => 'तस्बिर श्रेय';

  @override
  String get photoCreditsSubtitle => 'विकिमिडिया कमन्सबाट लिइएका ऋतु तस्बिरहरू';

  @override
  String get notificationStyle => 'शैली';

  @override
  String get notificationStyleNumber => 'ठूलो अंक';

  @override
  String get notificationStylePage => 'डेस्क पात्रो';

  @override
  String get notificationStyleNumberHint => 'आजको गते ठूलो अंकमा';

  @override
  String get notificationStylePageHint => 'सानो च्यातिने पात्रोको पाना';

  @override
  String get notificationStyleMoon => 'चन्द्रमा र तिथि';

  @override
  String get notificationStyleMoonHint =>
      'चन्द्रमाको कला, तिथि र आगामी औंसी/पूर्णिमा';

  @override
  String get notificationStyleWeek => 'यो हप्ता';

  @override
  String get notificationStyleWeekHint => 'आइतदेखि शनिसम्म, आज चिन्ह लगाइएको';

  @override
  String get notificationStyleCountdown => 'आगामी पर्व';

  @override
  String get notificationStyleCountdownHint =>
      'अर्को बिदा वा सम्झनासम्म बाँकी दिन';

  @override
  String get notificationStylePlain => 'साधारण';

  @override
  String get notificationStylePlainHint => 'एन्ड्रोइडको सामान्य सूचना';

  @override
  String get widgetDesk => 'डेस्क पात्रो';

  @override
  String get widgetWeek => 'यो हप्ता';

  @override
  String get widgetTheme => 'विजेट थिम';

  @override
  String get widgetThemePhoto => 'ऋतुको तस्बिर';

  @override
  String get widgetThemePhotoHint =>
      'एपकै ऋतु तस्बिर, हरेक दुई महिनामा फेरिन्छ';

  @override
  String get widgetThemeMaroon => 'गाढा मरुन';

  @override
  String get widgetThemeMaroonHint => 'सयपत्री रङसहित गाढा मरुन';

  @override
  String get widgetThemeMarigold => 'सयपत्री';

  @override
  String get widgetThemeMarigoldHint => 'मरुनसहित न्यानो सयपत्री रङ';

  @override
  String get widgetThemeCream => 'क्रिम';

  @override
  String get widgetThemeCreamHint => 'हल्का र सादा, डार्क मोड अनुसार फेरिन्छ';

  @override
  String get previewSeason => 'ऋतु पूर्वावलोकन';

  @override
  String get previewSeasonAuto => 'स्वचालित';

  @override
  String get previewSeasonAutoHint => 'पात्रो अनुसार';

  @override
  String get greeting => 'नमस्ते';

  @override
  String todayIs(String date) {
    return 'आज, $date';
  }

  @override
  String get upcomingCount => 'आगामी';

  @override
  String get quickConvert => 'मिति बदल्नुहोस्';

  @override
  String get quickReminders => 'सम्झनाहरू';

  @override
  String get quickWidgets => 'विजेट';

  @override
  String get remindMe => 'सम्झना थप्नुस्';

  @override
  String get history => 'इतिहास';

  @override
  String get edit => 'सम्पादन';

  @override
  String get nothingUpcoming => 'आउँदा केही हप्तामा केही छैन';

  @override
  String get statYears => 'वर्ष';

  @override
  String get statMonths => 'महिना';

  @override
  String get statDays => 'दिन';

  @override
  String get switchDirection => 'दिशा बदल्नुहोस्';

  @override
  String get changeDate => 'मिति बदल्नुहोस्';

  @override
  String get statHolidayData => 'बिदा विवरण';

  @override
  String get statVerifiedThrough => 'प्रमाणित';

  @override
  String get remindShort => 'सम्झाउनुस्';

  @override
  String get tileLook => 'रूप';

  @override
  String get tileNotification => 'सूचना';

  @override
  String get stateOn => 'सक्रिय';

  @override
  String get stateOff => 'बन्द';

  @override
  String get previewLabel => 'पूर्वावलोकन';

  @override
  String get sampleReminder => 'आमाको जन्मदिन';

  @override
  String reminderCountLabel(int count) {
    return '$count वटा सम्झना';
  }

  @override
  String get addToHomeScreen => 'होम स्क्रिनमा थप्नुहोस्';

  @override
  String get settingsSubtitle => 'परिवर्तन गर्न टाइल थिच्नुहोस्';
}
