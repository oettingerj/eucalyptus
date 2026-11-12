import CoreText
import Foundation
import Testing
@testable import Eucalyptus

@Suite struct MonoFontTests {
    @Test func registersBothFacesFromTheBundle() {
        MonoFont.register()
        for name in [MonoFont.regular, MonoFont.bold] {
            #expect(CTFontCopyPostScriptName(CTFontCreateWithName(name as CFString, 12, nil)) as String == name)
        }
    }

    @Test func embedsTheRegularFace() {
        #expect(MonoFont.cssFontFace.contains("data:font/woff2;base64,"))
    }
}
