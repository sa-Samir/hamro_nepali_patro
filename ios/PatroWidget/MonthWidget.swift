import SwiftUI
import WidgetKit

struct MonthWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MonthWidget", provider: DayProvider()) { entry in
            if let day = entry.day {
                MonthWidgetView(day: day)
            } else {
                UnsupportedDateView()
            }
        }
        .configurationDisplayName("Month")
        .description("The current Bikram Sambat month.")
        .patroSystemWidget([.systemLarge])
    }
}

private struct MonthWidgetView: View {
    let day: DaySnapshot

    private var labels: Labels { day.labels }
    /// The photo theme only covers the header band; the grid uses sage.
    private var headerTheme: WidgetTheme { day.theme }
    private var theme: WidgetTheme { day.theme.kind == .photo ? .sage : day.theme }

    /// BS day numbers laid out Sun–Sat, padded with nils to whole weeks.
    private var weeks: [[Int?]] {
        let leading = CivilDay.weekday(day.monthStartDay)
        var cells: [Int?] = Array(repeating: nil, count: leading) + (1...day.bs.daysInMonth).map { $0 }
        cells += Array(repeating: nil, count: (7 - cells.count % 7) % 7)
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
    }

    var body: some View {
        let holidays = day.holidayDaysThisMonth
        VStack(spacing: 6) {
            header
            VStack(spacing: 6) {
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { weekday in
                        Text(String(labels.weekdayShort(weekday).prefix(1)))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(initialColor(weekday))
                            .frame(maxWidth: .infinity)
                    }
                }
                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { weekday in
                            cell(week[weekday], weekday: weekday, holidays: holidays)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                footer
            }
            .padding([.horizontal, .bottom], WidgetLayout.padding)
        }
        .patroWidget(theme: theme, season: day.photoSeason)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(labels.monthYear(day.bs))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(headerTheme.number)
                Text("\(labels.adMonthSpan(from: day.monthStartDay, to: day.monthEndDay)) · \(labels.season(day.bs.month))")
                    .font(.system(size: 11))
                    .foregroundStyle(headerTheme.muted)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(labels.today) \(labels.number(day.bs.day)) · \(labels.weekdayFull(day.weekday))")
                    .font(.system(size: 12))
                    .foregroundStyle(headerTheme.text)
                TithiLabel(day: day, color: headerTheme.gold)
            }
        }
        .lineLimit(1)
        .padding([.horizontal, .top], WidgetLayout.padding)
        .padding(.bottom, headerTheme.kind == .photo ? 12 : 0)
        .background {
            if headerTheme.kind == .photo {
                ThemeBackground(theme: headerTheme, season: day.photoSeason)
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        if let next = day.nextHighlight {
            Rectangle()
                .fill(theme.hairline)
                .frame(height: 1)
            let date = BsDate(civilDay: next.civilDay).map(labels.monthDay) ?? labels.adShort(next.civilDay)
            EventLine(event: next, detail: "\(date) · \(labels.countdownIn(day.daysUntil(next)))", spread: true)
        }
    }

    private func initialColor(_ weekday: Int) -> Color {
        switch weekday {
        case 0: return theme.sundayHeader
        case 6: return theme.gold
        default: return theme.muted
        }
    }

    private func cell(_ bsDay: Int?, weekday: Int, holidays: Set<Int>) -> some View {
        Group {
            if let bsDay {
                DayNumber(
                    text: labels.number(bsDay),
                    color: theme.dayColor(weekday: weekday, isHoliday: holidays.contains(bsDay)),
                    isToday: bsDay == day.bs.day,
                    size: 13
                )
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
