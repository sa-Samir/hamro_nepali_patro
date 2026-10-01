import ImageIO
import UIKit

/// The app's season header photos, bundled at ≤ 800 px wide.
enum SeasonPhoto {
    /// In season order starting with Chaitra + Baisakh (see `Labels.season`).
    private static let names = ["basanta", "grishma", "barsha", "sharad", "hemanta", "shishir"]
    /// Widget extensions have a tight memory budget, so decode a bounded thumbnail.
    private static let maxPixelSize = 800

    /// The user's `season_override` when it names a season, else the season of BS `month`.
    static func name(forMonth month: Int, override: String?) -> String {
        if let override, names.contains(override) { return override }
        return names[(month % 12) / 2]
    }

    static func image(named name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil)
        else { return nil }
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ] as CFDictionary
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options).map(UIImage.init(cgImage:))
    }
}
