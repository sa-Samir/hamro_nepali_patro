import Foundation

/// A Bikram Sambat date. `month` is 1-based (1 = Baisakh).
struct BsDate: Equatable {
    let year: Int
    let month: Int
    let day: Int

    static func daysInMonth(year: Int, month: Int) -> Int {
        BsTable.monthLengths[year - BsData.firstYear][month - 1]
    }

    var daysInMonth: Int {
        Self.daysInMonth(year: year, month: month)
    }
}

extension BsDate {
    private static let epochDay = CivilDay.number(BsData.epochAd)!

    /// Walks the month-length table from the epoch; nil outside the covered years.
    init?(civilDay: Int) {
        var remaining = civilDay - Self.epochDay
        guard remaining >= 0 else { return nil }
        for (yearIndex, lengths) in BsTable.monthLengths.enumerated() {
            for (monthIndex, length) in lengths.enumerated() {
                if remaining < length {
                    self.init(year: BsData.firstYear + yearIndex, month: monthIndex + 1, day: remaining + 1)
                    return
                }
                remaining -= length
            }
        }
        return nil
    }

    /// The local calendar date of `date`, converted to BS.
    init?(_ date: Date, calendar: Calendar = .current) {
        self.init(civilDay: CivilDay.number(of: date, in: calendar))
    }
}

/// The bundled table with rows replaced by official corrections the app
/// downloaded (`bs_overrides` in the App Group). Invalid rows are ignored.
enum BsTable {
    private(set) static var monthLengths = BsData.monthLengths
    private static var appliedJson: String?

    static func applyOverrides(_ json: String?) {
        guard json != appliedJson else { return }
        var rows = BsData.monthLengths
        if let data = json?.data(using: .utf8),
           let overrides = try? JSONDecoder().decode([String: [Int]].self, from: data) {
            for (key, row) in overrides {
                guard let year = Int(key),
                      (BsData.firstYear...BsData.lastYear).contains(year),
                      row.count == 12,
                      row.allSatisfy({ (29...32).contains($0) }),
                      (365...366).contains(row.reduce(0, +))
                else { continue }
                rows[year - BsData.firstYear] = row
            }
        }
        monthLengths = rows
        appliedJson = json
    }
}
