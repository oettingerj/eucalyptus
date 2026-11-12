import AppKit
import ObjectiveC

extension NSScroller {
    /// Makes every native scroller small: SwiftUI scroll views, text views, and lists alike, with no
    /// per-view setup. AppKit has no app-wide scroller size and SwiftUI exposes none, so this exchanges
    /// `init(frame:)` for a version that sets `controlSize` to `.small`. Overlay knobs get thinner and
    /// legacy scrollers narrow from 17pt to 13pt. Web views draw their own scrollbars.
    /// Call once, before any window is made.
    @MainActor
    public static func makeAllSmall() {
        guard let original = class_getInstanceMethod(NSScroller.self, #selector(NSScroller.init(frame:))),
              let small = class_getInstanceMethod(NSScroller.self, #selector(NSScroller.eucalyptus_smallInit(frame:)))
        else { return }
        method_exchangeImplementations(original, small)
    }

    /// After the exchange this name runs AppKit's original `init(frame:)`.
    @objc private func eucalyptus_smallInit(frame: NSRect) -> NSScroller {
        let scroller = eucalyptus_smallInit(frame: frame)
        scroller.controlSize = .small
        return scroller
    }
}
