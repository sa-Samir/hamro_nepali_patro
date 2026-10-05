# Flutter ↔ native contract

The Flutter app owns all user data (notes, settings, holidays). Native code
(Android widgets + ongoing notification, iOS WidgetKit extension) **computes
today's BS date itself** from the generated table (`BsData.kt` /
`BsData.swift`) so it stays correct at midnight without the Flutter engine
running. Everything else it needs is read from shared key/value storage that
Flutter writes through the `home_widget` package.

## BS date table

Single source of truth: `tool/bs_month_lengths.json`. Regenerate with
`dart run tool/gen_bs_data.dart`, which writes:

- `lib/core/bs/bs_data.dart`
- `android/app/src/main/kotlin/com/nepali/patro/bs/BsData.kt`
- `ios/PatroWidget/BsData.swift`

Epoch: 1 Baisakh 1970 BS = 1913-04-13 AD. Covered years: 1970–2200 BS (2101+ calculated by the generator; see CALENDAR_DATA.md).
Conversion = count days from the epoch and walk the month-length table.
Day-of-week comes from the AD date. Use the device's local date.

## Shared storage

| Platform | Store |
|---|---|
| Android | `SharedPreferences` named `HomeWidgetPreferences` (what `home_widget` uses) |
| iOS | `UserDefaults(suiteName: "group.com.nepali.patro")` (App Group) |

Keys (written by Flutter, read by native):

| Key | Type | Meaning |
|---|---|---|
| `lang` | String `"ne"` / `"en"` | UI language for labels (month/weekday names, captions) |
| `numerals` | String `"ne"` / `"en"` | Digits used for numbers: Devanagari (०-९) or Western |
| `events` | String (JSON) | Upcoming items, see below |
| `widget_theme` | String | `maroon` (deep wine + gold), `photo` (season photo + dark wash), `marigold` or `cream` (cream + maroon; follows dark mode). Missing → `maroon`. |
| `season_override` | String | Settings → Preview season: a season name (`basanta`, `grishma`, `barsha`, `sharad`, `hemanta`, `shishir`) whose photo replaces the current one; empty = follow the BS month. |
| `tithis` | String (JSON) | Sunrise tithi by AD date, yesterday → today + 120 days: `{"2026-10-01": 20}`. 1–15 shukla (15 = purnima), 16–30 krishna (30 = aunsi). Missing dates mean "don't show a tithi". |
| `bs_overrides` | String (JSON) | Official month-length corrections downloaded by the app, e.g. `{"2084": [31, 32, …]}`. Native converters replace those rows of the generated table and ignore invalid rows. |
| `pn_enabled` | Bool | Android only: show the ongoing "today" notification |
| `pn_show_ad` | Bool | Android only: include the AD date in the notification |
| `pn_show_events` | Bool | Android only: include today's / next event in the notification |

`events` JSON: array sorted by date, covering the first day of the current BS
month → today + 120 days, titles already localized to `lang`:

```json
[{"ad": "2026-10-11", "title": "घटस्थापना", "kind": "holiday"},
 {"ad": "2026-10-12", "title": "Aama's birthday", "kind": "note"}]
```

`kind` is one of `holiday` (public holiday), `event` (festival/observance, not
a day off), `note` (user reminder). The month widget uses every entry that
falls in the displayed BS month (so earlier holidays this month stay marked);
the agenda widget and the Android notification must ignore entries dated
before the current local date so stale data is harmless.

On Android, `home_widget` stores Booleans as SharedPreferences booleans and
Strings as strings.

## Method channel

Name: `com.nepali.patro/native`

| Method | Args | Android | iOS |
|---|---|---|---|
| `refreshAll` | none | Post/cancel ongoing notification per `pn_*`, update every widget, (re)schedule the next midnight refresh alarm | `WidgetCenter.shared.reloadAllTimelines()` |
| `requestPinWidget` | `{"kind": "today"\|"desk"\|"agenda"\|"week"\|"month"}` | `AppWidgetManager.requestPinAppWidget` if supported; returns bool | returns `false` |

## Widgets

| Kind | Android provider class | iOS kind | Content |
|---|---|---|---|
| today | `com.nepali.patro.widget.TodayWidgetProvider` | `TodayWidget` | Small: BS month + year, big day, moon phase, weekday, tithi, AD date |
| desk | `com.nepali.patro.widget.DeskWidgetProvider` | `DeskWidget` | Small: tear-off page (maroon strip with month + year), big day, weekday, tithi |
| agenda | `com.nepali.patro.widget.AgendaWidgetProvider` | `AgendaWidget` | Medium "Upcoming": today on the left, next 3 events with countdowns on the right |
| week | `com.nepali.patro.widget.WeekWidgetProvider` | `WeekWidget` | Medium: today, Sun–Sat strip with today marked, next event countdown |
| month | `com.nepali.patro.widget.MonthWidgetProvider` | `MonthWidget` | Large: month grid, today + tithi panel, season, next holiday/event |

Tapping any widget opens the app.

## Names

Months (ne): बैशाख, जेठ, असार, साउन, भदौ, असोज, कात्तिक, मंसिर, पुस, माघ, फागुन, चैत
Months (en): Baisakh, Jestha, Asar, Shrawan, Bhadra, Ashwin, Kartik, Mangsir, Poush, Magh, Falgun, Chaitra
Weekdays short (ne, Sun→Sat): आइत, सोम, मंगल, बुध, बिहि, शुक्र, शनि
Weekdays full (ne): आइतबार, सोमबार, मंगलबार, बुधबार, बिहीबार, शुक्रबार, शनिबार
Weekdays short (en): Sun, Mon, Tue, Wed, Thu, Fri, Sat

## Palette

| Token | Hex |
|---|---|
| primary (maroon) | `#7A1F1F` (gradient to `#5C1616`) |
| accent (gold) | `#C08A2E` |
| surface (cream) | `#FBF5EC` |
| on-surface | `#2B1A14` |
| muted | `#8A6A5A` |
| holiday text | `#B3261E` |
