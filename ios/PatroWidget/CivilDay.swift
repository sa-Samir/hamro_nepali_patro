import Foundation

/// A Gregorian calendar day counted from 1970-01-01. Pure integers keep day
/// arithmetic exact across time zones and DST changes.
enum CivilDay {
    private static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    static func number(_ components: DateComponents) -> Int? {
        guard let date = utc.date(from: components) else { return nil }
        return Int((date.timeIntervalSince1970 / 86_400).rounded(.down))
    }

    /// The local date of `date` in `calendar` (the device's by default).
    static func number(of date: Date, in calendar: Calendar = .current) -> Int {
        number(calendar.dateComponents([.year, .month, .day], from: date))!
    }

    /// Parses `yyyy-MM-dd`.
    static func number(iso: String) -> Int? {
        let parts = iso.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return number(DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    /// 0 = Sunday … 6 = Saturday (1970-01-01 was a Thursday).
    static func weekday(_ day: Int) -> Int {
        ((day + 4) % 7 + 7) % 7
    }

    /// Midnight UTC of `day`; format it with a UTC formatter.
    static func utcDate(_ day: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(day) * 86_400)
    }

    static func dayOfMonth(_ day: Int) -> Int {
        utc.component(.day, from: utcDate(day))
    }
}
