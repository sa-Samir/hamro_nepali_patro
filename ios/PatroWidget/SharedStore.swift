import Foundation

struct PatroEvent {
    enum Kind: String {
        case holiday, event, note
    }

    let civilDay: Int
    let title: String
    let kind: Kind
}

/// Settings and events written by the Flutter app into the App Group.
struct SharedStore {
    static let appGroup = "group.com.nepali.patro"

    let labels: Labels
    /// Sorted by date; may still include past entries.
    let events: [PatroEvent]
    /// Sunrise tithi (1–30) keyed by civil day.
    let tithis: [Int: Int]
    let theme: WidgetTheme
    /// Season photo chosen in the app; validated by `SeasonPhoto.name`.
    let seasonOverride: String?

    static func load() -> SharedStore {
        let defaults = UserDefaults(suiteName: appGroup)
        BsTable.applyOverrides(defaults?.string(forKey: "bs_overrides"))
        let lang = defaults?.string(forKey: "lang").flatMap(Lang.init) ?? .ne
        let numerals = defaults?.string(forKey: "numerals").flatMap(Lang.init) ?? lang
        return SharedStore(
            labels: Labels(lang: lang, numerals: numerals),
            events: decodeEvents(defaults?.string(forKey: "events")),
            tithis: decodeTithis(defaults?.string(forKey: "tithis")),
            theme: WidgetTheme.named(defaults?.string(forKey: "widget_theme")),
            seasonOverride: defaults?.string(forKey: "season_override")
        )
    }

    private struct RawEvent: Decodable {
        let ad: String
        let title: String
        let kind: String
    }

    private static func decodeEvents(_ json: String?) -> [PatroEvent] {
        guard let data = json?.data(using: .utf8),
              let raw = try? JSONDecoder().decode([RawEvent].self, from: data)
        else { return [] }
        return raw
            .compactMap { event in
                CivilDay.number(iso: event.ad).map {
                    PatroEvent(civilDay: $0, title: event.title, kind: PatroEvent.Kind(rawValue: event.kind) ?? .event)
                }
            }
            .sorted { $0.civilDay < $1.civilDay }
    }

    private static func decodeTithis(_ json: String?) -> [Int: Int] {
        guard let data = json?.data(using: .utf8),
              let raw = try? JSONDecoder().decode([String: Int].self, from: data)
        else { return [:] }
        var tithis: [Int: Int] = [:]
        for (iso, tithi) in raw where (1...30).contains(tithi) {
            if let day = CivilDay.number(iso: iso) { tithis[day] = tithi }
        }
        return tithis
    }
}
