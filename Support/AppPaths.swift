import Foundation

enum AppPaths {
    static let defaultManagedShellFilePath = "~/.zshrc"

    static var applicationSupportDirectory: URL {
        let baseDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support", isDirectory: true)

        return baseDirectory.appendingPathComponent(AppConstants.appName, isDirectory: true)
    }

    static var profilesFileURL: URL {
        applicationSupportDirectory.appendingPathComponent("profiles.json", isDirectory: false)
    }

    static func normalizedManagedShellFilePath(_ rawValue: String?) -> String {
        let trimmed = (rawValue ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.isEmpty == false else {
            return defaultManagedShellFilePath
        }

        if trimmed.hasPrefix("~") || trimmed.hasPrefix("/") {
            return trimmed
        }

        return trimmed.hasPrefix(".") ? "~/" + trimmed : "~/" + trimmed
    }

    static func resolveManagedShellFileURL(_ rawValue: String?) -> URL {
        let normalizedPath = normalizedManagedShellFilePath(rawValue)
        let expandedPath = (normalizedPath as NSString).expandingTildeInPath

        if expandedPath.hasPrefix("/") {
            return URL(fileURLWithPath: expandedPath, isDirectory: false)
        }

        return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(expandedPath, isDirectory: false)
    }
}
