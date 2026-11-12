import Foundation

/// The app's Application Support folder, named for the bundle, so Release and Debug builds
/// ("Koala" and "Koala Dev") keep their data apart.
public enum AppSupport {
    public static var folderName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ProcessInfo.processInfo.processName
    }

    /// The folder, or a subfolder of it, created if needed.
    public static func directory(_ subfolder: String? = nil) throws -> URL {
        var directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                                    appropriateFor: nil, create: true)
            .appendingPathComponent(folderName, isDirectory: true)
        if let subfolder { directory.appendPathComponent(subfolder, isDirectory: true) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
