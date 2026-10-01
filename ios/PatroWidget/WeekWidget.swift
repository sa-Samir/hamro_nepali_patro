import SwiftUI
import WidgetKit

struct WeekWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WeekWidget", provider: DayProvider()) { entry in
            if let day = entry.day {
                WeekWidgetView(day: day)
            } else {
                UnsupportedDateView()
            }
        }
        .configurationDisplayName("This week")
        .description("Today and this week at a glance")
        .patroSystemWidget([.systemMedium])
    }
}

private struct WeekWidgetView: View {
    let day: DaySnapshot

    private var labels: Labels { day.labels }
    private var theme: WidgetTheme { day.theme }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(labels.number(day.bs.day))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(theme.number)
                Text("\(labels.monthYear(day.bs)) · \(labels.weekdayFull(day.weekday))")
                    .font(.system(size: 13))
                    .foregroundStyle(theme.text)
            }
            subtitle
            Spacer(minLength: 0)
            weekRow
            Spacer(minLength: 0)
            if let next = day.upcoming.first {
                EventLine(event: next, detail: labels.countdownIn(day.daysUntil(next)))
            }
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(WidgetLayout.padding)
        .patroWidget(theme: theme, season: day.photoSeason)
    }

    private var subtitle: some View {
        HStack(spacing: 0) {
            TithiLabel(day: day)
            Text(day.tithi == nil ? labels.adShort(day.civilDay) : " · \(labels.adShort(day.civilDay))")
                .font(.system(size: 11))
                .foregroundStyle(theme.muted)
        }
    }

    private var weekRow: some View {
        let holidays = Set(day.events.filter { $0.kind == .holiday }.map(\.civilDay))
        let sunday = day.civilDay - day.weekday
        return HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { weekday in
                let civilDay = sunday + weekday
                VStack(spacing: 2) {
                    Text(labels.weekdayShort(weekday))
                        .font(.system(size: 11))
                        .foregroundStyle(weekday == 6 ? theme.gold : theme.muted)
                    DayNumber(
                        text: BsDate(civilDay: civilDay).map { labels.number($0.day) } ?? "",
                        color: theme.dayColor(weekday: weekday, isHoliday: holidays.contains(civilDay)),
                        isToday: civilDay == day.civilDay,
                        size: 14
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
