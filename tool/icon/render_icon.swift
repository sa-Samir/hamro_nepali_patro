// Renders the Patro app icon: a calendar page with a Himalayan peak and sun,
// in the app's maroon and gold.
// Usage: swift tool/icon/render_icon.swift <out-dir>
// Writes icon.png (full, 1024), foreground.png (adaptive foreground,
// transparent, content in the safe zone) and monochrome.png (themed icons).
import AppKit

// Maroon palette, matching the app: maroon with gold.
let maroon = NSColor(red: 0x7A / 255, green: 0x1F / 255, blue: 0x1F / 255, alpha: 1)
let maroonDark = NSColor(red: 0x5C / 255, green: 0x16 / 255, blue: 0x16 / 255, alpha: 1)
let maroonLight = NSColor(red: 0x9A / 255, green: 0x2E / 255, blue: 0x2A / 255, alpha: 1)
let gold = NSColor(red: 0xD9 / 255, green: 0x9E / 255, blue: 0x3A / 255, alpha: 1)
let cream = NSColor(red: 0xFB / 255, green: 0xF5 / 255, blue: 0xEC / 255, alpha: 1)
let snow = NSColor.white

enum Mode { case full, foreground, monochrome }

func poly(_ pts: [(CGFloat, CGFloat)]) -> NSBezierPath {
    let p = NSBezierPath()
    p.move(to: NSPoint(x: pts[0].0, y: pts[0].1))
    for pt in pts.dropFirst() { p.line(to: NSPoint(x: pt.0, y: pt.1)) }
    p.close()
    return p
}

func render(_ mode: Mode, size: Int = 1024) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.scaleBy(x: CGFloat(size) / 1024, y: CGFloat(size) / 1024)

    if mode == .full {
        NSGradient(starting: maroonLight, ending: maroonDark)!
            .draw(in: NSRect(x: 0, y: 0, width: 1024, height: 1024), angle: -90)
    }
    // Adaptive layers are inset 16% by flutter_launcher_icons, which puts the
    // artwork inside Android's 66% safe zone, so they need no extra scaling.
    let ink: (NSColor) -> NSColor = { mode == .monochrome ? .white : $0 }

    // Page
    let page = NSRect(x: 222, y: 180, width: 580, height: 600)
    let pagePath = NSBezierPath(roundedRect: page, xRadius: 72, yRadius: 72)
    if mode == .monochrome {
        // Outline only, so the themed icon reads as a calendar.
        ink(cream).setStroke(); pagePath.lineWidth = 34; pagePath.stroke()
    } else {
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
        shadow.shadowBlurRadius = 30
        shadow.shadowOffset = NSSize(width: 0, height: -12)
        shadow.set()
        cream.setFill(); pagePath.fill()
        NSGraphicsContext.restoreGraphicsState()
    }

    NSGraphicsContext.saveGraphicsState()
    pagePath.addClip()
    // Header strip
    if mode != .monochrome {
        gold.setFill(); NSRect(x: page.minX, y: 640, width: page.width, height: 140).fill()
    } else {
        ink(gold).setFill(); NSRect(x: page.minX, y: 640, width: page.width, height: 22).fill()
    }
    // Sun
    ink(gold).setFill()
    NSBezierPath(ovalIn: NSRect(x: 600, y: 470, width: 104, height: 104)).fill()
    // Distant range
    (mode == .monochrome ? NSColor.white.withAlphaComponent(0.55) : maroon.withAlphaComponent(0.35)).setFill()
    poly([(222, 300), (330, 430), (400, 380), (470, 450), (560, 360), (680, 470), (802, 360), (802, 180), (222, 180)]).fill()
    // Main peak with a fishtail (Machhapuchhre) summit
    ink(maroon).setFill()
    poly([(222, 250), (360, 400), (420, 360), (515, 560), (548, 520), (572, 548), (700, 330),
          (760, 360), (802, 320), (802, 180), (222, 180)]).fill()
    // Snow
    if mode != .monochrome {
        snow.setFill()
        poly([(468, 462), (515, 560), (548, 520), (572, 548), (618, 472), (590, 486), (560, 462), (530, 492), (500, 456)]).fill()
    }
    NSGraphicsContext.restoreGraphicsState()

    // Binding rings over the top edge
    for x in [372.0, 652.0] {
        let ring = NSBezierPath(roundedRect: NSRect(x: x - 24, y: 720, width: 48, height: 128), xRadius: 24, yRadius: 24)
        ink(mode == .monochrome ? .white : cream).setFill(); ring.fill()
        if mode != .monochrome {
            maroonDark.withAlphaComponent(0.35).setStroke(); ring.lineWidth = 6; ring.stroke()
        }
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let out = CommandLine.arguments[1]
for (name, mode) in [("icon", Mode.full), ("foreground", .foreground), ("monochrome", .monochrome)] {
    try! render(mode).representation(using: .png, properties: [:])!
        .write(to: URL(fileURLWithPath: "\(out)/\(name).png"))
}
print("ok")
