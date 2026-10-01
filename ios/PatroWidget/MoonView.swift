import SwiftUI

/// Moon phase for a tithi (1–30). The terminator is an ellipse whose
/// x-radius is r·|cos φ|, with φ = tithi · 12°.
struct MoonView: View {
    let tithi: Int

    private static let dark = Color(hex: 0x44403C)
    private static let lit = Color(hex: 0xF3E2B3)

    var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            let disc = CGRect(x: (size.width - side) / 2, y: (size.height - side) / 2, width: side, height: side)
            let phase = Double(tithi) * 12 * .pi / 180
            let waxing = tithi < 15
            let terminatorWidth = side * abs(cos(phase))
            let terminator = Path(ellipseIn: disc.insetBy(dx: (side - terminatorWidth) / 2, dy: 0))

            context.fill(Path(ellipseIn: disc), with: .color(Self.dark))

            var litHalf = context
            let halfWidth = disc.width / 2
            litHalf.clip(to: Path(CGRect(x: waxing ? disc.midX : disc.minX, y: disc.minY, width: halfWidth, height: disc.height)))
            litHalf.fill(Path(ellipseIn: disc), with: .color(Self.lit))

            // Crescent: the terminator eats into the lit half; gibbous: it extends the light.
            context.fill(terminator, with: .color(cos(phase) > 0 ? Self.dark : Self.lit))
        }
        .accessibilityHidden(true)
    }
}
