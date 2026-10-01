import SwiftUI
import WidgetKit

struct DeskWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DeskWidget", provider: DayProvider()) { entry in
            if let day = entry.day {
                DeskWidgetView(day: day)
            } else {
                UnsupportedDateView()
            }
        }
        .configurationDisplayName("Desk page")
        .description("Today on a tear-off calendar page")
        .patroSystemWidget([.systemSmall])
    }
}

private struct DeskWidgetView: View {
    let day: DaySnapshot

    private var labels: Labels { day.labels }
    private var theme: WidgetTheme { day.theme }

    var body: some View {
        VStack(spacing: 0) {
            Text(labels.monthYear(day.bs))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.stripText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(theme.stripFill)
            Spacer(minLength: 0)
            Text(labels.number(day.bs.day))
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(theme.number)
                .minimumScaleFactor(0.6)
            Text(labels.weekdayFull(day.weekday))
                .font(.system(size: 12))
                .foregroundStyle(theme.text)
            TithiLabel(day: day)
            Spacer(minLength: 0)
        }
        .lineLimit(1)
        .padding(.bottom, 10)
        .patroWidget(theme: theme, season: day.photoSeason)
    }
}
