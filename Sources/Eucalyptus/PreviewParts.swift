import SwiftUI

/// One label and value in a preview pane's facts grid.
public struct PreviewFact: Identifiable {
    public let label: String
    public let value: Text
    public var help: String?
    /// What VoiceOver reads for the value when its symbols and layout don't speak for themselves.
    public var accessibilityLabel: String?
    public var id: String { label }

    public init(label: String, value: Text, help: String? = nil, accessibilityLabel: String? = nil) {
        self.label = label
        self.value = value
        self.help = help
        self.accessibilityLabel = accessibilityLabel
    }
}

/// The facts grid shared by preview and detail panes: 11pt tertiary
/// labels, 12pt primary values, aligned on their first baselines.
public struct PreviewFactGrid: View {
    public let facts: [PreviewFact]
    public var lineLimit = 2

    public init(facts: [PreviewFact], lineLimit: Int = 2) {
        self.facts = facts
        self.lineLimit = lineLimit
    }

    public var body: some View {
        Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 12, verticalSpacing: 7) {
            ForEach(facts) { fact in
                GridRow {
                    Text(fact.label)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(nsColor: Theme.textTertiary))
                        .gridColumnAlignment(.leading)
                    fact.value
                        .font(.system(size: 12))
                        .foregroundStyle(Color(nsColor: Theme.textPrimary))
                        .lineLimit(lineLimit)
                        .fixedSize(horizontal: false, vertical: true)
                        .help(fact.help ?? "")
                }
                .accessibilityElement(children: .combine)
                .modifier(SpokenValue(text: fact.accessibilityLabel.map { "\(fact.label), \($0)" }))
            }
        }
    }
}

/// Replaces the combined label only when a fact gives its own words.
private struct SpokenValue: ViewModifier {
    let text: String?
    func body(content: Content) -> some View {
        if let text { content.accessibilityLabel(text) } else { content }
    }
}
