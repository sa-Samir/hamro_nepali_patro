import Foundation

enum Lang: String {
    case ne, en
}

/// Localized names and digits, per the `lang` and `numerals` settings.
struct Labels {
    let lang: Lang
    let numerals: Lang

    private static let months: [Lang: [String]] = [
        .ne: ["बैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज", "कात्तिक", "मंसिर", "पुस", "माघ", "फागुन", "चैत"],
        .en: ["Baisakh", "Jestha", "Asar", "Shrawan", "Bhadra", "Ashwin", "Kartik", "Mangsir", "Poush", "Magh", "Falgun", "Chaitra"],
    ]
    private static let weekdaysShort: [Lang: [String]] = [
        .ne: ["आइत", "सोम", "मंगल", "बुध", "बिहि", "शुक्र", "शनि"],
        .en: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
    ]
    private static let weekdaysFull: [Lang: [String]] = [
        .ne: ["आइतबार", "सोमबार", "मंगलबार", "बुधबार", "बिहीबार", "शुक्रबार", "शनिबार"],
        .en: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
    ]
    private static let tithiNames: [Lang: [String]] = [
        .ne: ["प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पञ्चमी", "षष्ठी", "सप्तमी",
              "अष्टमी", "नवमी", "दशमी", "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी"],
        .en: ["Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami", "Shashthi", "Saptami",
              "Ashtami", "Navami", "Dashami", "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi"],
    ]
    /// Two BS months per season, starting with Chaitra.
    private static let seasons: [Lang: [String]] = [
        .ne: ["बसन्त ऋतु", "ग्रीष्म ऋतु", "वर्षा ऋतु", "शरद ऋतु", "हेमन्त ऋतु", "शिशिर ऋतु"],
        .en: ["Spring", "Summer", "Monsoon", "Autumn", "Early winter", "Winter"],
    ]
    private static let devanagariZero: UInt32 = 0x0966

    func month(_ month: Int) -> String { Self.months[lang]![month - 1] }
    func weekdayShort(_ weekday: Int) -> String { Self.weekdaysShort[lang]![weekday] }
    func weekdayFull(_ weekday: Int) -> String { Self.weekdaysFull[lang]![weekday] }

    /// Tithi 1–30: 1–14 shukla, 15 purnima, 16–29 krishna, 30 aunsi.
    func tithi(_ tithi: Int) -> String {
        switch tithi {
        case 15: return lang == .ne ? "पूर्णिमा" : "Purnima"
        case 30: return lang == .ne ? "औंसी" : "Aunsi"
        default:
            let paksha = tithi < 15 ? (lang == .ne ? "शुक्ल" : "Shukla") : (lang == .ne ? "कृष्ण" : "Krishna")
            return "\(paksha) \(Self.tithiNames[lang]![(tithi - 1) % 15])"
        }
    }

    func season(_ month: Int) -> String { Self.seasons[lang]![(month % 12) / 2] }

    var today: String { lang == .ne ? "आज" : "Today" }
    var noEvents: String { lang == .ne ? "आगामी कार्यक्रम छैन" : "Nothing coming up" }
    var unsupported: String { lang == .ne ? "पात्रो अपडेट गर्नुहोस्" : "Update Patro" }

    /// "आज" / "भोलि" / "३ दिन".
    func countdown(_ days: Int) -> String {
        relative(days) ?? (lang == .ne ? "\(number(days)) दिन" : "\(number(days)) days")
    }

    /// "आज" / "भोलि" / "३ दिनमा".
    func countdownIn(_ days: Int) -> String {
        relative(days) ?? (lang == .ne ? "\(number(days)) दिनमा" : "in \(number(days)) days")
    }

    private func relative(_ days: Int) -> String? {
        switch days {
        case 0: return today
        case 1: return lang == .ne ? "भोलि" : "Tomorrow"
        default: return nil
        }
    }

    func number(_ value: Int) -> String {
        digits(String(value))
    }

    /// Rewrites every Western or Devanagari digit in `text` to the preferred numerals.
    func digits(_ text: String) -> String {
        let zero = numerals == .ne ? Self.devanagariZero : 0x30
        let scalars = text.unicodeScalars.map { scalar -> Unicode.Scalar in
            let value = scalar.value
            let digit: UInt32
            switch value {
            case 0x30...0x39: digit = value - 0x30
            case Self.devanagariZero...(Self.devanagariZero + 9): digit = value - Self.devanagariZero
            default: return scalar
            }
            return Unicode.Scalar(zero + digit)!
        }
        return String(String.UnicodeScalarView(scalars))
    }

    func monthYear(_ date: BsDate) -> String {
        "\(month(date.month)) \(number(date.year))"
    }

    func dayMonth(_ date: BsDate) -> String {
        "\(number(date.day)) \(month(date.month))"
    }

    /// e.g. "असोज २५".
    func monthDay(_ date: BsDate) -> String {
        "\(month(date.month)) \(number(date.day))"
    }

    func full(_ date: BsDate) -> String {
        "\(dayMonth(date)) \(number(date.year))"
    }

    /// e.g. "30 Sep 2026".
    func adDate(_ civilDay: Int) -> String {
        format(civilDay, template: "dMMMy")
    }

    /// e.g. "Oct 1".
    func adShort(_ civilDay: Int) -> String {
        format(civilDay, template: "MMMd")
    }

    /// The AD months spanned by a BS month, e.g. "Sep/Oct 2026".
    func adMonthSpan(from first: Int, to last: Int) -> String {
        let start = format(first, template: "MMM")
        let end = format(last, template: "MMM")
        let year = format(last, template: "y")
        return start == end ? "\(end) \(year)" : "\(start)/\(end) \(year)"
    }

    private func format(_ civilDay: Int, template: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: lang == .ne ? "ne_NP" : "en_US")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.setLocalizedDateFormatFromTemplate(template)
        return digits(formatter.string(from: CivilDay.utcDate(civilDay)))
    }
}
