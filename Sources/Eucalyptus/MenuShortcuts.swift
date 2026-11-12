import AppKit

/// The user's shortcut overrides for menu commands. Every command an app builds through its menu
/// helper registers here with its built-in shortcut; the menu bar stays the single source of truth
/// for what each key does, and Settings and the command bar read it back from there.
@MainActor
public enum MenuShortcuts {
    /// One rebindable command, as Settings lists it.
    public struct Command: Identifiable, Equatable {
        public let id: String
        /// The title the command was built with, before any Show/Hide toggling.
        public let title: String
        /// The menu bar menu it lives in, such as "File".
        public let menu: String
        public let defaultShortcut: MenuShortcut
        public let shortcut: MenuShortcut

        public var isCustomized: Bool { shortcut != defaultShortcut }
    }

    /// The app's own menus that fill in only when opened (History, Bookmarks). Listing them lets
    /// Settings and conflict checks see their commands; AppKit's own delegates are never driven by hand.
    public static var isPopulatableMenu: (NSMenuDelegate) -> Bool = { _ in false }

    private static var defaults: [String: (title: String, shortcut: MenuShortcut)] = [:]
    private static let defaultsKey = "MenuShortcuts"

    /// Overrides by `id(for:)`, kept in user defaults. `.none` means removed.
    public static var overrides: [String: MenuShortcut] {
        get {
            guard let data = UserDefaults.standard.data(forKey: defaultsKey),
                  let shortcuts = try? JSONDecoder().decode([String: MenuShortcut].self, from: data) else { return [:] }
            return shortcuts
        }
        set { UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: defaultsKey) }
    }

    /// The selector, plus the tag for commands that share one (Show Tab 1–9, sections).
    public static func id(for item: NSMenuItem) -> String? {
        guard let action = item.action else { return nil }
        let selector = NSStringFromSelector(action)
        return item.tag == 0 ? selector : "\(selector)#\(item.tag)"
    }

    public static func shortcut(of item: NSMenuItem) -> MenuShortcut {
        MenuShortcut(key: item.keyEquivalent, modifiers: item.keyEquivalentModifierMask)
    }

    /// Records the item's built-in shortcut the first time its command is seen, then gives it the user's.
    public static func register(_ item: NSMenuItem) {
        guard let id = id(for: item) else { return }
        if defaults[id] == nil { defaults[id] = (item.title, shortcut(of: item)) }
        apply(current(for: id), to: item)
    }

    /// The shortcut a command has now: the user's override, else its built-in one.
    public static func current(for id: String) -> MenuShortcut {
        overrides[id] ?? defaults[id]?.shortcut ?? .none
    }

    /// Sets a command's shortcut; nil goes back to its built-in one.
    public static func set(_ shortcut: MenuShortcut?, for id: String) {
        var changed = overrides
        changed[id] = shortcut == defaults[id]?.shortcut ? nil : shortcut
        overrides = changed
        applyAll()
    }

    public static func resetAll() {
        overrides = [:]
        applyAll()
    }

    /// Gives every registered menu item its current shortcut. Hidden alternates are never registered.
    private static func applyAll() {
        walk { item, _ in
            if let id = id(for: item), defaults[id] != nil, !item.isHidden { apply(current(for: id), to: item) }
        }
    }

    private static func apply(_ shortcut: MenuShortcut, to item: NSMenuItem) {
        item.keyEquivalent = shortcut.key
        item.keyEquivalentModifierMask = shortcut.isNone ? [] : shortcut.modifierFlags
    }

    /// Every registered command in menu bar order.
    public static func commands() -> [Command] {
        var seen: Set<String> = []
        var commands: [Command] = []
        walk(populating: true) { item, menu in
            guard !item.isHidden, let id = id(for: item), let base = defaults[id], seen.insert(id).inserted else { return }
            commands.append(Command(id: id, title: base.title, menu: menu, defaultShortcut: base.shortcut, shortcut: current(for: id)))
        }
        return commands
    }

    /// The title of the menu item that already answers to `shortcut`, other than command `id`.
    public static func owner(of shortcut: MenuShortcut, excluding id: String) -> String? {
        guard !shortcut.isNone else { return nil }
        var owner: String?
        walk(populating: true) { item, _ in
            guard owner == nil, Self.id(for: item) != id, Self.shortcut(of: item) == shortcut else { return }
            owner = Self.id(for: item).flatMap { defaults[$0]?.title } ?? item.title
        }
        return owner
    }

    /// A command's shortcut for hint text, such as "⌥⌘J"; nil when it has none.
    public static func text(for action: Selector) -> String? {
        let shortcut = current(for: NSStringFromSelector(action))
        return shortcut.isNone ? nil : shortcut.display
    }

    /// `title (⌘D)`, or the bare title when the command has no shortcut.
    public static func label(_ title: String, for action: Selector) -> String {
        text(for: action).map { "\(title) (\($0))" } ?? title
    }

    /// Visits every item under the menu bar with the name of its top-level menu. `populating`
    /// builds the app's delegate menus first, since they fill in only when opened.
    private static func walk(populating: Bool = false, _ visit: (NSMenuItem, String) -> Void) {
        guard let main = NSApp.mainMenu else { return }
        func descend(_ menu: NSMenu, top: String) {
            if populating, let delegate = menu.delegate, isPopulatableMenu(delegate) {
                delegate.menuNeedsUpdate?(menu)
            }
            for item in menu.items where !item.isSeparatorItem {
                if let submenu = item.submenu {
                    // Services lists other apps' commands, not this app's.
                    guard submenu !== NSApp.servicesMenu else { continue }
                    descend(submenu, top: menu === main ? submenu.title : top)
                } else if menu !== main {
                    visit(item, top)
                }
            }
        }
        descend(main, top: "")
    }
}
