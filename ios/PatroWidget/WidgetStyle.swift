import SwiftUI
import WidgetKit

enum WidgetLayout {
    /// System widgets disable content margins (some themes paint edge to edge) and pad themselves.
    static let padding: CGFloat = 16
}

extension View {
    /// Themed card, theme environment and the tap-to-open URL shared by every home-screen widget.
    func patroWidget(theme: WidgetTheme, season: String) -> some View {
        modifier(PatroWidgetModifier(background: ThemeBackground(theme: theme, season: season)))
            .environment(\.widgetTheme, theme)
    }

    /// Lock-screen widgets are tinted by the system, so they get no theme.
    func accessoryWidget() -> some View {
        modifier(PatroWidgetModifier(background: Color.clear))
    }
}

extension WidgetConfiguration {
    func patroSystemWidget(_ families: [WidgetFamily]) -> some WidgetConfiguration {
        supportedFamilies(families).contentMarginsDisabled()
    }
}

private struct PatroWidgetModifier<Background: View>: ViewModifier {
    let background: Background

    func body(content: Content) -> some View {
        styled(content).widgetURL(URL(string: "patro://today"))
    }

    @ViewBuilder
    private func styled(_ content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(for: .widget) { background }
        } else {
            content.background(background)
        }
    }
}

/// Today's tithi in the theme's gold; empty when the app supplied none.
struct TithiLabel: View {
    @Environment(\.widgetTheme) private var theme
    let day: DaySnapshot
    var color: Color?

    var body: some View {
        if let tithi = day.tithi {
            Text(day.labels.tithi(tithi))
                .font(.system(size: 11))
                .foregroundStyle(color ?? theme.gold)
                .lineLimit(1)
        }
    }
}

/// A BS day number in a calendar grid; today gets the theme's highlight.
struct DayNumber: View {
    @Environment(\.widgetTheme) private var theme
    let text: String
    let color: Color
    let isToday: Bool
    let size: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: isToday ? .bold : .medium))
            .foregroundStyle(isToday ? theme.todayText : color)
            .frame(minWidth: size * 2, minHeight: size * 1.7)
            .background {
                if isToday {
                    RoundedRectangle(cornerRadius: 6, style: .continuous).fill(theme.todayFill)
                }
            }
    }
}

/// "● title  detail" for the next event; `spread` pushes the detail to the trailing edge.
struct EventLine: View {
    @Environment(\.widgetTheme) private var theme
    let event: PatroEvent
    let detail: String
    var spread = false

    var body: some View {
        let accent = event.kind == .holiday ? theme.holiday : theme.muted
        HStack(spacing: 4) {
            Text("●").foregroundStyle(accent)
            Text(event.title)
                .foregroundStyle(theme.text)
                .layoutPriority(1)
            if spread { Spacer(minLength: 4) }
            Text(detail)
                .foregroundStyle(accent)
            if !spread { Spacer(minLength: 0) }
        }
        .font(.system(size: 11))
        .lineLimit(1)
    }
}

/// Shown only if the device date is beyond the bundled BS table.
struct UnsupportedDateView: View {
    var body: some View {
        let store = SharedStore.load()
        Text(store.labels.unsupported)
            .font(.caption)
            .foregroundStyle(store.theme.text)
            .multilineTextAlignment(.center)
            .padding(WidgetLayout.padding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .patroWidget(theme: store.theme, season: SeasonPhoto.name(forMonth: 1, override: store.seasonOverride))
    }
}
