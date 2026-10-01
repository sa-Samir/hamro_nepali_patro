import WidgetKit

/// Everything a widget shows for one local day.
struct DaySnapshot {
    let civilDay: Int
    let bs: BsDate
    let labels: Labels
    /// All stored events, sorted; may include days before today.
    let events: [PatroEvent]
    /// Sunrise tithi for today, if the app supplied one.
    let tithi: Int?
    let theme: WidgetTheme
    /// Photo-theme background, honouring the app's season override.
    let photoSeason: String

    var upcoming: [PatroEvent] { events.filter { $0.civilDay >= civilDay } }

    /// The next public holiday if any is known, otherwise the next event.
    var nextHighlight: PatroEvent? {
        upcoming.first { $0.kind == .holiday } ?? upcoming.first
    }

    func daysUntil(_ event: PatroEvent) -> Int { event.civilDay - civilDay }

    var weekday: Int { CivilDay.weekday(civilDay) }
    var monthStartDay: Int { civilDay - (bs.day - 1) }
    var monthEndDay: Int { monthStartDay + bs.daysInMonth - 1 }

    /// BS day numbers in the current month that are public holidays, including past days.
    var holidayDaysThisMonth: Set<Int> {
        Set(events
            .filter { $0.kind == .holiday && (monthStartDay...monthEndDay).contains($0.civilDay) }
            .map { $0.civilDay - monthStartDay + 1 })
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
    /// Nil when the date falls outside the BS table.
    let day: DaySnapshot?
}

struct DayProvider: TimelineProvider {
    private static let midnightsAhead = 3

    func placeholder(in context: Context) -> DayEntry {
        entry(at: Date(), store: SharedStore.load())
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        completion(entry(at: Date(), store: SharedStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        let store = SharedStore.load()
        let calendar = Calendar.current
        let now = Date()
        let midnight = calendar.startOfDay(for: now)
        let midnights = (1...Self.midnightsAhead).compactMap {
            calendar.date(byAdding: .day, value: $0, to: midnight)
        }
        let entries = ([now] + midnights).map { entry(at: $0, store: store) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(at date: Date, store: SharedStore) -> DayEntry {
        let civilDay = CivilDay.number(of: date)
        let snapshot = BsDate(civilDay: civilDay).map { bs in
            DaySnapshot(
                civilDay: civilDay,
                bs: bs,
                labels: store.labels,
                events: store.events,
                tithi: store.tithis[civilDay],
                theme: store.theme,
                photoSeason: SeasonPhoto.name(forMonth: bs.month, override: store.seasonOverride)
            )
        }
        return DayEntry(date: date, day: snapshot)
    }
}
