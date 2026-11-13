> **Moved:** this project now lives in [oettingerj/outback](https://github.com/oettingerj/outback/tree/main/eucalyptus). This repo is archived.

# Eucalyptus

The shared ground under Koala and Dingo: one design system and the AppKit plumbing both apps use.

- `Theme`: the neutral ramp, surfaces, text, state colors, type, geometry, and motion. Each app sets its accent once at launch with `Theme.configure(accent:)`.
- `MonoFont`: 0xProto (SIL OFL 1.1), registered for the process and embeddable in pages.
- Controls and chrome: `IconButton`, `PageSearchField`, `PageColumn`, `PageFilter`, `PreviewFactGrid`, `SettingsRule`, `PrimaryButtonStyle`, popovers and dropdown panels.
- Plumbing: `MenuShortcut` and `MenuShortcuts` (rebindable menu shortcuts), `ObservationLoop`, `AppSupport`, `Perf`, `closureMenuItem`, `Pasteboard`, `FaviconContrast`, small scrollers.

Apps depend on it by path (`../eucalyptus`).

```sh
swift build && swift test
```
