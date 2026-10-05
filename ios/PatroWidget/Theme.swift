import SwiftUI
import UIKit

/// The widget look chosen in the app's settings (`widget_theme`).
/// Shared with the Android widgets and the app's notification designs.
struct WidgetTheme {
    enum Kind: String {
        case forest, photo, maroon, marigold
        /// Keeps the settings key of the earlier cream theme.
        case sage = "cream"
    }

    let kind: Kind
    /// Card colours top to bottom (one for a solid card); the photo theme draws the season photo instead.
    let background: [Color]
    let text: Color
    let muted: Color
    /// Big day number and month + year.
    let number: Color
    /// Tithi and Saturdays.
    let gold: Color
    let holiday: Color
    let sundayHeader: Color
    let hairline: Color
    let todayFill: Color
    let todayText: Color
    let stripFill: Color
    let stripText: Color

    static func named(_ name: String?) -> WidgetTheme {
        switch name.flatMap(Kind.init) {
        case .sage: return .sage
        case .photo: return .photo
        case .maroon: return .maroon
        case .marigold: return .marigold
        case .forest, nil: return .forest
        }
    }

    func dayColor(weekday: Int, isHoliday: Bool) -> Color {
        if isHoliday { return holiday }
        return weekday == 6 ? gold : text
    }

    static let forest = WidgetTheme(
        kind: .forest,
        background: [Color(hex: 0x26331F), Color(hex: 0x0C1008)],
        text: Color(hex: 0xF9F5F0),
        muted: Color(hex: 0xA9ABA6),
        number: Color(hex: 0xBAD45F),
        gold: Color(hex: 0xD9C98A),
        holiday: Color(hex: 0xF2937D),
        sundayHeader: Color(hex: 0xF9F5F0),
        hairline: .white.opacity(0.15),
        todayFill: Color(hex: 0xBAD45F),
        todayText: Color(hex: 0x0C1008),
        stripFill: Color(hex: 0xBAD45F),
        stripText: Color(hex: 0x0C1008)
    )

    /// Follows the system light/dark appearance.
    static let sage = WidgetTheme(
        kind: .sage,
        background: [Color(light: 0xF7F4EE, dark: 0x141C11)],
        text: Color(light: 0x141A11, dark: 0xF9F5F0),
        muted: Color(light: 0x5E665C, dark: 0xA9ABA6),
        number: Color(light: 0x2E4A24, dark: 0xBAD45F),
        gold: Color(light: 0x8A6D1F, dark: 0xD9C98A),
        holiday: Color(light: 0xC4472F, dark: 0xF2937D),
        sundayHeader: Color(light: 0x2E4A24, dark: 0xBAD45F),
        hairline: Color(light: UIColor(hex: 0xDCE3D5), dark: UIColor.white.withAlphaComponent(0.15)),
        todayFill: Color(light: 0x2E4A24, dark: 0xBAD45F),
        todayText: Color(light: 0xF9F5F0, dark: 0x0C1008),
        stripFill: Color(light: 0x2E4A24, dark: 0xBAD45F),
        stripText: Color(light: 0xF9F5F0, dark: 0x0C1008)
    )

    static let maroon = WidgetTheme(
        kind: .maroon,
        background: [Color(hex: 0x6E1B1B)],
        text: .white,
        muted: Color(hex: 0xE8C9C0),
        number: .white,
        gold: Color(hex: 0xF2C66D),
        holiday: Color(hex: 0xFFB4A9),
        sundayHeader: Color(hex: 0xFFD8CF),
        hairline: .white.opacity(0.25),
        todayFill: Color(hex: 0xF2C66D),
        todayText: Color(hex: 0x3A1A0E),
        stripFill: Color(hex: 0xF2C66D),
        stripText: Color(hex: 0x6E1B1B)
    )

    static let marigold = WidgetTheme(
        kind: .marigold,
        background: [Color(hex: 0xF6D58E)],
        text: Color(hex: 0x3A1A0E),
        muted: Color(hex: 0x6B4A2E),
        number: Color(hex: 0x7A1F1F),
        gold: Color(hex: 0x8A3B12),
        holiday: Color(hex: 0xA3201A),
        sundayHeader: Color(hex: 0x7A1F1F),
        hairline: Color(hex: 0x7A1F1F).opacity(0.2),
        todayFill: Color(hex: 0x7A1F1F),
        todayText: .white,
        stripFill: Color(hex: 0x7A1F1F),
        stripText: .white
    )

    static let photo = WidgetTheme(
        kind: .photo,
        background: [Color(hex: 0x3A0E0E)],
        text: .white,
        muted: Color(hex: 0xEADBD2),
        number: .white,
        gold: Color(hex: 0xF2C66D),
        holiday: Color(hex: 0xFFB4A9),
        sundayHeader: .white,
        hairline: .white.opacity(0.33),
        todayFill: Color(hex: 0xF2C66D),
        todayText: Color(hex: 0x3A1A0E),
        stripFill: Color(hex: 0x6E1B1B).opacity(0.7),
        stripText: .white
    )
}

private struct WidgetThemeKey: EnvironmentKey {
    static let defaultValue = WidgetTheme.forest
}

extension EnvironmentValues {
    var widgetTheme: WidgetTheme {
        get { self[WidgetThemeKey.self] }
        set { self[WidgetThemeKey.self] = newValue }
    }
}

/// The theme's card: its colours, or the season photo under a scrim.
struct ThemeBackground: View {
    let theme: WidgetTheme
    /// Season photo name, see `SeasonPhoto.name`.
    let season: String

    private static let scrim = LinearGradient(
        stops: [
            .init(color: Color(red: 26 / 255, green: 6 / 255, blue: 6 / 255, opacity: 0.55), location: 0),
            .init(color: Color(red: 58 / 255, green: 14 / 255, blue: 14 / 255, opacity: 0.55), location: 0.45),
            .init(color: Color(red: 58 / 255, green: 14 / 255, blue: 14 / 255, opacity: 0.85), location: 1),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        if theme.kind == .photo, let photo = SeasonPhoto.image(named: season) {
            // Centre-crop: the clear base takes the offered size and the photo fills it.
            Color.clear
                .overlay {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .overlay(Self.scrim)
        } else {
            LinearGradient(colors: theme.background, startPoint: .top, endPoint: .bottom)
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }

    init(light: UInt32, dark: UInt32) {
        self.init(light: UIColor(hex: light), dark: UIColor(hex: dark))
    }

    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { $0.userInterfaceStyle == .dark ? dark : light })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
