import AppKit
import SwiftUI

/// The shared design tokens. One 11-step neutral ramp is the only tonal scale; every surface,
/// hairline, and text color is a step on it. Chroma is reserved for the app's accent and for state.
/// Each app names its accent once at launch with `configure(accent:)`, before any view is made.
@MainActor
public enum Theme {
    // MARK: Neutral ramp (step 0 is the lightest surface in light mode, the deepest in dark)

    private static let lightRamp: [UInt32] = [
        0xFFFFFF, 0xFAFAFA, 0xF4F4F5, 0xEBEBED, 0xDEDEE1, 0xC8C8CD,
        0xA0A0A8, 0x6C6C75, 0x4E4E56, 0x2E2E33, 0x18181B,
    ]
    private static let darkRamp: [UInt32] = [
        0x111113, 0x18181B, 0x1E1E21, 0x26262A, 0x303035, 0x3E3E44,
        0x5A5A62, 0x8A8A93, 0xA6A6AE, 0xD4D4D8, 0xF4F4F5,
    ]

    public static func neutral(_ step: Int) -> NSColor {
        dynamic(light: lightRamp[step], dark: darkRamp[step], name: "neutral\(step)")
    }

    // MARK: Surfaces

    /// Ground behind the window's top strip.
    public static let stripGround = dynamic(light: lightRamp[3], dark: darkRamp[0], name: "stripGround")
    /// Toolbar, pages, and the selected tab, which share one surface.
    public static let chromeSurface = dynamic(light: lightRamp[1], dark: darkRamp[2], name: "chromeSurface")
    /// Hover fill for tabs, rows, and toolbar buttons.
    public static let hoverFill = dynamic(light: lightRamp[4], dark: darkRamp[3], name: "hoverFill")
    /// Pressed fill.
    public static let pressedFill = dynamic(light: lightRamp[5], dark: darkRamp[4], name: "pressedFill")
    /// Text field well.
    public static let fieldFill = dynamic(light: lightRamp[3], dark: darkRamp[1], name: "fieldFill")
    /// One-pixel separators.
    public static let hairline = dynamic(light: lightRamp[4], dark: darkRamp[4], name: "hairline")

    // MARK: Text

    public static let textPrimary = neutral(10)
    public static let textSecondary = neutral(8)
    public static let textTertiary = neutral(7)

    // MARK: Accent

    /// An app's accent: its fill, the darker variant used for text and filled buttons, and the
    /// text that sits on that fill. Each is a light and dark appearance pair.
    public struct Accent: Sendable {
        public struct Pair: Sendable {
            public let light: UInt32
            public let dark: UInt32
            public init(_ light: UInt32, _ dark: UInt32) {
                self.light = light
                self.dark = dark
            }
        }

        public let fill: Pair
        public let text: Pair
        public let onFill: Pair

        public init(fill: Pair, text: Pair, onFill: Pair) {
            self.fill = fill
            self.text = text
            self.onFill = onFill
        }

        /// Koala's teal.
        public static let koalaTeal = Accent(fill: Pair(0x0E8F80, 0x2CC3AE), text: Pair(0x0B7A6D, 0x2CC3AE),
                                             onFill: Pair(0xFFFFFF, 0x0B1F1C))
    }

    /// Sets the app's accent. Call once at launch, before any view reads a color.
    public static func configure(accent: Accent) {
        self.accent = dynamic(light: accent.fill.light, dark: accent.fill.dark, name: "accent")
        accentText = dynamic(light: accent.text.light, dark: accent.text.dark, name: "accentText")
        onAccent = dynamic(light: accent.onFill.light, dark: accent.onFill.dark, name: "onAccent")
    }

    /// Focus, selection, and primary actions only.
    public private(set) static var accent = dynamic(light: Accent.koalaTeal.fill.light, dark: Accent.koalaTeal.fill.dark, name: "accent")
    public private(set) static var accentText = dynamic(light: Accent.koalaTeal.text.light, dark: Accent.koalaTeal.text.dark, name: "accentText")
    /// Text on a filled primary button, whose fill is `accentText`.
    public private(set) static var onAccent = dynamic(light: Accent.koalaTeal.onFill.light, dark: Accent.koalaTeal.onFill.dark, name: "onAccent")

    // MARK: Controls and state

    /// Native selected segments use white labels in both appearances.
    public static let controlSelectionTint = dynamic(light: 0x4E4E56, dark: 0x3E3E44, name: "controlSelectionTint")
    /// A switch's on track: ramp step 8 light, step 7 dark, so on stays above 3:1 against chrome surface.
    public static let switchTint = dynamic(light: lightRamp[8], dark: darkRamp[7], name: "switchTint")
    public static let pass = dynamic(light: 0x248A57, dark: 0x3DD68C, name: "pass")
    public static let pending = dynamic(light: 0xB07A0A, dark: 0xF5A524, name: "pending")
    public static let fail = dynamic(light: 0xD1343A, dark: 0xF2555A, name: "fail")
    public static let merged = dynamic(light: 0x8E4EC6, dark: 0xB57FE8, name: "merged")

    // MARK: Type

    public static let tabTitle = NSFont.systemFont(ofSize: 12, weight: .regular)
    public static let tabTitleSelected = NSFont.systemFont(ofSize: 12, weight: .medium)
    public static let field = NSFont.systemFont(ofSize: 13, weight: .regular)
    public static let fieldMono = mono(ofSize: 12)

    /// 0xProto, the monospace face. It ships Regular and Bold only: semibold and heavier set Bold.
    public nonisolated static func mono(ofSize size: CGFloat, weight: NSFont.Weight = .regular) -> NSFont {
        NSFont(name: weight.rawValue >= NSFont.Weight.semibold.rawValue ? MonoFont.bold : MonoFont.regular, size: size)
            ?? .monospacedSystemFont(ofSize: size, weight: weight)
    }

    // MARK: Geometry (4pt grid)

    public static let stripHeight: CGFloat = 40      // matches the native compact titlebar
    public static let toolbarHeight: CGFloat = 36
    public static let tabHeight: CGFloat = 28
    public static let tabMaxWidth: CGFloat = 200
    public static let tabMinWidth: CGFloat = 120
    public static let tabSpacing: CGFloat = 4
    public static let trafficLightInset: CGFloat = 80
    public static let controlRadius: CGFloat = 6
    public static let panelRadius: CGFloat = 10
    public static let iconButtonSize: CGFloat = 28

    // MARK: Motion

    public static let hoverDuration: TimeInterval = 0.08
    public static let panelDuration: TimeInterval = 0.12

    public static var reduceMotion: Bool { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }

    // MARK: Helpers

    private nonisolated static func dynamic(light: UInt32, dark: UInt32, name: String) -> NSColor {
        NSColor(name: NSColor.Name(name)) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastAqua])
                .map { $0 == .darkAqua || $0 == .accessibilityHighContrastDarkAqua } ?? false
            return NSColor(hex: isDark ? dark : light)
        }
    }
}

extension NSColor {
    public convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: alpha)
    }
}

extension NSView {
    /// Resolves a dynamic color against this view's appearance, for use in CALayer properties.
    @MainActor
    public func resolved(_ color: NSColor) -> CGColor {
        var cg = color.cgColor
        effectiveAppearance.performAsCurrentDrawingAppearance { cg = color.cgColor }
        return cg
    }
}

extension Font {
    /// SwiftUI's handle on `Theme.mono`.
    public static func mono(size: CGFloat, weight: NSFont.Weight = .regular) -> Font {
        Font(Theme.mono(ofSize: size, weight: weight))
    }
}
