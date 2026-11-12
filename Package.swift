// swift-tools-version: 6.0
import PackageDescription

/// Eucalyptus: the design system and app plumbing Koala and Dingo share. Tokens, fonts, controls,
/// page chrome, menu shortcuts, and small AppKit helpers. Nothing here knows about a browser or mail.
let package = Package(
    name: "Eucalyptus",
    platforms: [.macOS("26.0")],
    products: [
        .library(name: "Eucalyptus", targets: ["Eucalyptus"]),
    ],
    targets: [
        .target(name: "Eucalyptus", resources: [.copy("Fonts")]),
        .testTarget(name: "EucalyptusTests", dependencies: ["Eucalyptus"]),
    ]
)
