# Calendar data: bundled, calculated and downloaded

Where each date in the app comes from, in priority order:

1. **Downloaded data** (`data/patro-data.json`, published to a static URL). Official month lengths and holiday lists that came out after the app was built.
2. **Bundled table** (`tool/bs_month_lengths.json`). Years up to `verifiedThrough` (2083) are checked against published calendars. 2084–2100 are projections.
3. **Calculated years.** The generator fills 2101–2200 using `BsCalculator` (Surya Siddhanta Sankranti with Nepal's day rules). The calculation reproduces about 99% of published month starts from 1970 to 2083, and all of 2084–2100 (see `tool/astro_experiment.dart`).

Years after the verified year show an **अनुमानित / Estimated** label. Tithi is always calculated (sunrise in Kathmandu). It matches every day in `test/fixtures/tithi_reference.json` where the published sources agree.

## The download

The app does a plain anonymous `GET` of `PATRO_DATA_URL` at most every 12 hours. It sends `If-None-Match`, so an unchanged file costs one tiny request, and nothing personal is ever sent. It keeps the last valid copy for offline use. A file that fails validation, or has a lower `revision` than the one in use, is ignored.

Set the URL at build time:

```bash
flutter build apk --dart-define=PATRO_DATA_URL=https://<you>.github.io/patro-data/patro-data.json
```

If no URL is set, the app never goes online and only uses bundled and calculated data.

Any static host works: GitHub Pages, Cloudflare R2/Pages, Firebase Hosting. It must serve HTTPS. ETag support is optional.

## File format

```json
{
  "format": "patro-data",
  "schema": 1,
  "revision": 2,
  "publishedAt": "2027-03-20",
  "verifiedThrough": 2084,
  "monthLengths": { "2084": [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31] },
  "holidays": {
    "2084": { "events": [ { "month": 1, "day": 1, "en": "Nepali New Year", "ne": "नयाँ वर्ष", "holiday": true } ] }
  }
}
```

- `revision`: increase it on every publish. Phones only move forward.
- `monthLengths`: whole-year rows that replace the bundled table. Each row must have 12 months of 29–32 days and total 365 or 366 days.
- `holidays`: whole years that replace the bundled `assets/holidays/<year>.json`, in the same event format.
- `verifiedThrough`: raises the "estimated" boundary.
- `schema`: only bump it for incompatible format changes. Older apps then ignore the file.

## Publishing a yearly update

1. When the Nepal Panchanga Nirnayak Samiti publishes the next year, add its month lengths. When the Home Ministry publishes the holiday list, add the holidays too.
2. Run `dart run tool/validate_calendar_data.dart`. It flags month lengths that differ from the calculation, which is worth double-checking but can be legitimate.
3. Bump `revision` and `verifiedThrough`, then upload.
4. At the next app release, fold the data into `tool/bs_month_lengths.json` and `assets/holidays/` so new installs have it offline. Then run `dart run tool/gen_bs_data.dart`.

The widgets get the same month-length corrections through the `bs_overrides` key (see `NATIVE_CONTRACT.md`).
