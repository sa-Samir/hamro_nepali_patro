import SwiftUI
import WidgetKit

struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TodayWidget", provider: DayProvider()) { entry in
            if let day = entry.day {
                TodayWidgetView(day: day)
            } else {
                UnsupportedDateView()
            }
        }
        .configurationDisplayName("Today")
        .description("Today's Bikram Sambat date.")
        .patroSystemWidget([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

private struct TodayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let day: DaySnapshot

    private var labels: Labels { day.labels }
    private var theme: WidgetTheme { day.theme }

    var body: some View {
        switch family {
        case .accessoryCircular:
            circular.accessoryWidget()
        case .accessoryRectangular:
            rectangular.accessoryWidget()
        case .accessoryInline:
            Text("\(labels.full(day.bs)), \(labels.weekdayShort(day.weekday))")
                .accessoryWidget()
        default:
            small.patroWidget(theme: theme, season: day.photoSeason)
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(labels.monthYear(day.bs))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.number)
                Spacer(minLength: 4)
                if let tithi = day.tithi {
                    MoonView(tithi: tithi).frame(width: 16, height: 16)
                }
            }
            Text(labels.number(day.bs.day))
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(theme.number)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 0)
            Text(labels.weekdayFull(day.weekday))
                .font(.system(size: 13))
                .foregroundStyle(theme.text)
            TithiLabel(day: day)
            Text(labels.adDate(day.civilDay))
                .font(.system(size: 11))
                .foregroundStyle(theme.muted)
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(WidgetLayout.padding)
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text(labels.number(day.bs.day))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(labels.month(day.bs.month))
                    .font(.system(size: 9, weight: .semibold))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(4)
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(labels.full(day.bs))
                .font(.headline)
                .widgetAccentable()
            Text("\(labels.weekdayFull(day.weekday)) · \(labels.adShort(day.civilDay))")
            if let tithi = day.tithi {
                Text(labels.tithi(tithi))
                    .foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
