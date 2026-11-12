import AppKit
import SwiftUI

// Text colors for SwiftUI pages (Settings, History, bucket pages), from the neutral ramp.
@MainActor public let settingsPrimary = Color(nsColor: Theme.textPrimary)
@MainActor public let settingsSecondary = Color(nsColor: Theme.textSecondary)
@MainActor public let settingsTertiary = Color(nsColor: Theme.textTertiary)
@MainActor public let settingsFail = Color(nsColor: Theme.fail)

/// A one-pixel separator from the neutral ramp.
public struct SettingsRule: View {
    @Environment(\.pixelLength) private var pixel
    public init() {}
    public var body: some View { Rectangle().fill(Color(nsColor: Theme.hairline)).frame(height: pixel) }
}

/// The filled primary action: the accent's deep variant behind `onAccent` text.
public struct SettingsPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color(nsColor: Theme.onAccent))
            .padding(.horizontal, 12).frame(height: 24)
            .background(RoundedRectangle(cornerRadius: Theme.controlRadius).fill(Color(nsColor: Theme.accentText)))
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.5)
            .contentShape(RoundedRectangle(cornerRadius: Theme.controlRadius))
    }
}

@MainActor
extension Toggle {
    /// A small switch without its label (the row names it). On reads in a neutral tint; the accent stays on focus and primary actions.
    public func settingsSwitch() -> some View {
        labelsHidden().toggleStyle(.switch).controlSize(.small).tint(Color(nsColor: Theme.switchTint))
    }
}
