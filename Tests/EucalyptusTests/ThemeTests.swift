import AppKit
import Testing
@testable import Eucalyptus

@MainActor
struct ThemeTests {
    private func hex(_ color: NSColor, dark: Bool) -> UInt32 {
        var rgb: (CGFloat, CGFloat, CGFloat) = (0, 0, 0)
        NSAppearance(named: dark ? .darkAqua : .aqua)!.performAsCurrentDrawingAppearance {
            let c = color.usingColorSpace(.sRGB)!
            rgb = (c.redComponent, c.greenComponent, c.blueComponent)
        }
        return UInt32(round(rgb.0 * 255)) << 16 | UInt32(round(rgb.1 * 255)) << 8 | UInt32(round(rgb.2 * 255))
    }

    @Test func accentDefaultsToKoalaTealAndFollowsConfigure() {
        #expect(hex(Theme.accent, dark: false) == 0x0E8F80)
        Theme.configure(accent: .init(fill: .init(0x112233, 0x445566), text: .init(0x111111, 0x222222), onFill: .init(0xFFFFFF, 0x000000)))
        #expect(hex(Theme.accent, dark: false) == 0x112233)
        #expect(hex(Theme.accent, dark: true) == 0x445566)
        #expect(hex(Theme.accentText, dark: true) == 0x222222)
        Theme.configure(accent: .koalaTeal)
        #expect(hex(Theme.accent, dark: true) == 0x2CC3AE)
    }

    @Test func pageFilterMatchesWordStarts() {
        let filter = PageFilter(query: "pin")
        #expect(filter.matches("Pin to Toolbar"))
        #expect(!filter.matches("typing"))
    }
}
