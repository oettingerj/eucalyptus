import AppKit
import SwiftUI

/// The search field native pages share. Esc clears it.
public struct PageSearchField: View {
    public let prompt: String
    @Binding public var text: String
    public var focused: FocusState<Bool>.Binding
    /// Arrow keys, Return, and Esc once the field is empty, for pages whose list the field drives.
    public var onKey: ((KeyPress) -> KeyPress.Result)?

    public init(prompt: String, text: Binding<String>, focused: FocusState<Bool>.Binding,
                onKey: ((KeyPress) -> KeyPress.Result)? = nil) {
        self.prompt = prompt
        _text = text
        self.focused = focused
        self.onKey = onKey
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").font(.system(size: 13, weight: .medium)).foregroundStyle(settingsTertiary)
                .accessibilityHidden(true)
            TextField(prompt, text: $text)
                .textFieldStyle(.plain).font(.system(size: 13))
                .tint(Color(nsColor: Theme.accent))
                .focused(focused)
                .accessibilityLabel(prompt)
                .onKeyPress(keys: [.escape]) { press in
                    guard !text.isEmpty else { return onKey?(press) ?? .ignored }
                    text = ""
                    return .handled
                }
                .onKeyPress(keys: [.upArrow, .downArrow, .return]) { press in onKey?(press) ?? .ignored }
            if text.isEmpty {
                Text("⌘F").font(.system(size: 11).monospacedDigit()).foregroundStyle(settingsTertiary).accessibilityHidden(true)
            } else {
                Text("esc").font(.system(size: 11)).foregroundStyle(settingsTertiary).accessibilityHidden(true)
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 12)).foregroundStyle(settingsTertiary)
                }
                .buttonStyle(.plain).help("Clear search (Esc)").accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 10).frame(height: 32)
        .background(RoundedRectangle(cornerRadius: Theme.controlRadius)
            .fill(Color(nsColor: focused.wrappedValue ? Theme.neutral(0) : Theme.fieldFill)))
        .overlay {
            if focused.wrappedValue {
                RoundedRectangle(cornerRadius: Theme.controlRadius).strokeBorder(Color(nsColor: Theme.accent), lineWidth: 1.5)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { focused.wrappedValue = true }
    }
}

/// A page column up to `width` with 20pt gutters, centered.
public struct PageColumn<Content: View>: View {
    public var width: CGFloat = 760
    @ViewBuilder public var content: Content
    @State private var pageWidth: CGFloat = 0

    public init(width: CGFloat = 760, @ViewBuilder content: () -> Content) {
        self.width = width
        self.content = content()
    }

    public var body: some View {
        let column = max(0, min(width, pageWidth - 40))
        VStack(alignment: .leading, spacing: 0) { content }
            .frame(width: column, alignment: .leading)
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: CGFloat.self, of: \.size.width) { pageWidth = $0 }
    }
}

/// A native page's search query. Like a command bar, every query word must start a word in the row's text,
/// so "pin" finds Pin to Toolbar but not "typing".
public struct PageFilter: Sendable {
    public var query = ""

    public init(query: String = "") { self.query = query }

    public var words: [String] { Self.words(in: query) }
    public var isActive: Bool { !words.isEmpty }

    private static func words(in text: String) -> [String] {
        text.lowercased().split { !$0.isLetter && !$0.isNumber && $0 != "%" }.map(String.init)
    }

    public func matches(_ text: String) -> Bool {
        let haystack = Self.words(in: text)
        return words.allSatisfy { word in haystack.contains { $0.hasPrefix(word) } }
    }

    /// Sets the matched word starts in semibold at the text's own size, so a filtered row shows why it matched.
    @MainActor
    public func highlight(_ text: String, size: CGFloat, mono: Bool = false) -> AttributedString {
        var result = AttributedString(text)
        for word in words {
            var searchStart = text.startIndex
            while let range = text.range(of: word, options: .caseInsensitive, range: searchStart..<text.endIndex) {
                let startsWord = range.lowerBound == text.startIndex || !text[text.index(before: range.lowerBound)].isLetter
                    && !text[text.index(before: range.lowerBound)].isNumber
                if startsWord, let marked = Range(range, in: result) {
                    result[marked].font = mono ? .mono(size: size, weight: .semibold) : .system(size: size, weight: .semibold)
                }
                searchStart = range.upperBound
            }
        }
        return result
    }
}
