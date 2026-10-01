import SwiftUI
import WidgetKit

struct AgendaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AgendaWidget", provider: DayProvider()) { entry in
            if let day = entry.day {
                AgendaWidgetView(day: day)
            } else {
                UnsupportedDateView()
            }
        }
        .configurationDisplayName("Upcoming")
        .description("Today's date and the next upcoming events.")
        .patroSystemWidget([.systemMedium])
    }
}

private struct AgendaWidgetView: View {
    let day: DaySnapshot

    private var labels: Labels { day.labels }
    private var theme: WidgetTheme { day.theme }

    private static let panelFill = Color(hex: 0x7A1F1F)
    private static let panelAccent = Color(hex: 0xF6D58E)

    var body: some View {
        Group {
            if theme.kind == .marigold {
                // Marigold puts today on a solid maroon panel running to the edges.
                HStack(spacing: 0) {
                    todayColumn(accent: Self.panelAccent, number: .white, text: .white)
                        .padding(WidgetLayout.padding)
                        .frame(maxHeight: .infinity)
                        .background(Self.panelFill)
                    eventList.padding(WidgetLayout.padding)
                }
            } else {
                HStack(spacing: 12) {
                    todayColumn(accent: theme.number, number: theme.number, text: theme.text)
                    Rectangle()
                        .fill(theme.hairline)
                        .frame(width: 1)
                    eventList
                }
                .padding(WidgetLayout.padding)
            }
        }
        .patroWidget(theme: theme, season: day.photoSeason)
    }

    /// `accent` colours month + year (and the tithi on the marigold panel).
    private func todayColumn(accent: Color, number: Color, text: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(labels.monthYear(day.bs))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(accent)
            Text(labels.number(day.bs.day))
                .font(.system(size: 50, weight: .bold))
                .foregroundStyle(number)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 0)
            Text(labels.weekdayFull(day.weekday))
                .font(.system(size: 12))
                .foregroundStyle(text)
            TithiLabel(day: day, color: theme.kind == .marigold ? accent : nil)
        }
        .lineLimit(1)
        .frame(width: 96, alignment: .leading)
        .frame(maxHeight: .infinity)
    }

    private var eventList: some View {
        let events = day.upcoming.prefix(3)
        return VStack(alignment: .leading, spacing: 10) {
            if events.isEmpty {
                Spacer(minLength: 0)
                Text(labels.noEvents)
                    .font(.system(size: 13))
                    .foregroundStyle(theme.muted)
            } else {
                ForEach(Array(events.enumerated()), id: \.offset) { _, event in
                    row(event)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func row(_ event: PatroEvent) -> some View {
        let isHoliday = event.kind == .holiday
        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(event.title)
                .font(.system(size: 13, weight: isHoliday ? .medium : .regular))
                .foregroundStyle(isHoliday ? theme.holiday : theme.text)
            Spacer(minLength: 4)
            Text(labels.countdown(day.daysUntil(event)))
                .font(.system(size: 11))
                .foregroundStyle(isHoliday ? theme.holiday : theme.muted)
                .layoutPriority(1)
        }
        .lineLimit(1)
    }
}
