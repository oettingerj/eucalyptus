import AppKit

/// Borderless SF Symbol button with the shared hover and pressed fills.
@MainActor
open class IconButton: NSButton {
    /// Fills for hover and press; a button on a hovered surface needs steps stronger than the surface.
    public var hoverFill = Theme.hoverFill { didSet { updateFill() } }
    public var pressedFill = Theme.pressedFill { didSet { updateFill() } }
    private var isHovered = false { didSet { updateFill() } }
    private var tracking: NSTrackingArea?

    public init(symbol: String, label: String, pointSize: CGFloat = 13, action: Selector?, target: AnyObject? = nil) {
        super.init(frame: NSRect(x: 0, y: 0, width: Theme.iconButtonSize, height: Theme.iconButtonSize))
        let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        image = NSImage(systemSymbolName: symbol, accessibilityDescription: label)?.withSymbolConfiguration(config)
        imagePosition = .imageOnly
        isBordered = false
        bezelStyle = .regularSquare
        contentTintColor = Theme.textSecondary
        toolTip = label
        setAccessibilityLabel(label)
        self.action = action
        self.target = target
        wantsLayer = true
        layer?.cornerRadius = Theme.controlRadius
        layer?.cornerCurve = .continuous
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }

    open override var intrinsicContentSize: NSSize { NSSize(width: Theme.iconButtonSize, height: Theme.iconButtonSize) }

    open override var isEnabled: Bool { didSet { contentTintColor = isEnabled ? Theme.textSecondary : Theme.neutral(5) } }

    open override var isHighlighted: Bool { didSet { updateFill() } }

    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let tracking { removeTrackingArea(tracking) }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self)
        addTrackingArea(area)
        tracking = area
    }

    open override func mouseEntered(with event: NSEvent) { isHovered = true }
    open override func mouseExited(with event: NSEvent) { isHovered = false }

    open override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        updateFill()
    }

    private func updateFill() {
        let fill: NSColor? = !isEnabled ? nil : isHighlighted ? pressedFill : isHovered ? hoverFill : nil
        layer?.backgroundColor = fill.map(resolved) ?? .clear
    }
}
