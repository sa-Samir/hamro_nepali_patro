# Patro — नेपाली पात्रो

A Bikram Sambat calendar for Android and iOS that works without any account. Everything stays on the phone.

- BS month calendar with AD dates, tithi, public holidays and festivals (2083 BS bundled), and a header photo for each of the six ritus
- Dates from 1970 to 2200 BS. Years without a published calendar are calculated astronomically and labelled अनुमानित / Estimated
- Optional downloaded calendar updates (official month lengths and holidays) with no account; see [docs/CALENDAR_DATA.md](docs/CALENDAR_DATA.md)
- Nepali / English interface, with Nepali or Western digits chosen separately
- BS ↔ AD converter, plus a days-between / age calculator
- Reminders for important dates: one-off, yearly on the BS date, yearly on the AD date, or monthly. Notify on the day and/or 1, 3 or 7 days before, at a chosen time
- Android: ongoing "today" notification that updates every midnight (optional)
- Home-screen widgets on both platforms (Today, Today & upcoming, Month), plus Lock Screen widgets on iOS
- Export and import reminders as a JSON backup file

## Project layout

```
lib/
  core/bs/          BS date engine (bs_date.dart), generated table (bs_data.dart), formatting
  core/theme/       colours and ThemeData
  data/             drift database, repositories (notes, settings, holidays)
  features/         calendar, converter, notes, settings — each with cubit/ and view/
  services/         reminder scheduling, native bridge (widgets/notification), backup, sync
  l10n/             app_en.arb / app_ne.arb
assets/holidays/    <BS year>.json holiday data
android/…/kotlin/com/nepali/patro/   widgets, ongoing notification, midnight refresh
ios/PatroWidget/    WidgetKit extension
tool/               BS month-length table + generator
docs/NATIVE_CONTRACT.md   how Flutter and the native code share data
```

State management is BLoC (`flutter_bloc`): `SettingsCubit`, `NotesCubit`, `CalendarCubit`, `ConverterCubit` and a per-screen `NoteEditorCubit`. `AppSync` watches settings and notes and reschedules reminders and refreshes widgets whenever they change.

## Development

```bash
flutter pub get
dart run build_runner build   # drift database code
flutter test
flutter run
```

Localisation code is generated from `lib/l10n/*.arb` on `flutter pub get` / `flutter run`.

### Updating BS month lengths

Month lengths come from a table, `tool/bs_month_lengths.json`. Years after the table's last row are calculated by `BsCalculator`, which uses the Surya Siddhanta Sankranti and Nepal's day rules and matches about 99% of the published table. Edit the JSON, then run:

```bash
dart run tool/gen_bs_data.dart
```

This regenerates the Dart, Kotlin and Swift copies so the app and the widgets always agree. `dart run tool/astro_experiment.dart` re-measures the calculation against the table. Between releases, corrections can be shipped as downloaded data instead (docs/CALENDAR_DATA.md).

Season photos are from Wikimedia Commons under CC BY / CC BY-SA. Credits are in `assets/seasons/credits.json` and shown in Settings → About.

### Adding holidays for a new year

Add `assets/holidays/<year>.json` in the same format as `2083.json` (`month`/`day` are BS; `holiday: true` means a nationwide public holiday). The app picks up every file in that folder.

### iOS setup

The widget extension shares data with the app through the App Group `group.com.nepali.patro`. Before building for a real device, open `ios/Runner.xcworkspace` (or `.xcodeproj`), choose your Team for both the **Runner** and **PatroWidget** targets, and add the App Groups capability with that group ID to both. The simulator doesn't need this.

The minimum iOS version is 15. Widgets need iOS 16 or later.
