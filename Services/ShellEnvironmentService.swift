import Foundation

final class ShellEnvironmentService {
    func apply(
        profile: ProviderProfile,
        apiKey: String?,
        configuration: ManagedShellConfiguration
    ) throws {
        let fileURL = configuration.fileURL
        let currentContents = try loadContents(from: fileURL)
        let block = managedBlock(
            for: profile,
            apiKey: apiKey,
            syntax: configuration.syntax,
            maskSensitiveValues: false
        )
        let updatedContents = replacingManagedBlock(in: currentContents, with: block)
        try write(updatedContents, to: fileURL)
    }

    func clearManagedBlock(configuration: ManagedShellConfiguration) throws {
        let fileURL = configuration.fileURL
        let currentContents = try loadContents(from: fileURL)
        let updatedContents = replacingManagedBlock(in: currentContents, with: nil)
        try write(updatedContents, to: fileURL)
    }

    func maskedPreview(
        for profile: ProviderProfile,
        apiKey: String?,
        configuration: ManagedShellConfiguration
    ) -> String {
        managedBlock(
            for: profile,
            apiKey: apiKey,
            syntax: configuration.syntax,
            maskSensitiveValues: true
        )
    }

    private func loadContents(from fileURL: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return ""
        }

        return try String(contentsOf: fileURL, encoding: .utf8)
    }

    private func write(_ contents: String, to fileURL: URL) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private func managedBlock(
        for profile: ProviderProfile,
        apiKey: String?,
        syntax: ShellConfigurationSyntax,
        maskSensitiveValues: Bool
    ) -> String {
        let baseURLValue = renderAssignment(
            variable: "COPILOT_PROVIDER_BASE_URL",
            value: profile.baseURL,
            syntax: syntax
        )
        var lines = [AppConstants.managedBlockStart, baseURLValue]

        if profile.providerType.requiresExplicitTypeExport {
            lines.append(
                renderAssignment(
                    variable: "COPILOT_PROVIDER_TYPE",
                    value: profile.providerType.rawValue,
                    syntax: syntax
                )
            )
        }

        if let apiKey, apiKey.isEmpty == false {
            let value = maskSensitiveValues ? maskedValue(for: apiKey) : apiKey
            lines.append(
                renderAssignment(
                    variable: "COPILOT_PROVIDER_API_KEY",
                    value: value,
                    syntax: syntax
                )
            )
        }

        lines.append(
            renderAssignment(
                variable: "COPILOT_MODEL",
                value: profile.model,
                syntax: syntax
            )
        )
        lines.append(AppConstants.managedBlockEnd)

        return lines.joined(separator: "\n")
    }

    private func replacingManagedBlock(in contents: String, with replacement: String?) -> String {
        var strippedContents = contents

        while let startRange = strippedContents.range(of: AppConstants.managedBlockStart) {
            let endRange = strippedContents.range(
                of: AppConstants.managedBlockEnd,
                range: startRange.upperBound..<strippedContents.endIndex
            )

            let removalUpperBound: String.Index
            if let endRange {
                if endRange.upperBound < strippedContents.endIndex,
                   strippedContents[endRange.upperBound] == "\n" {
                    removalUpperBound = strippedContents.index(after: endRange.upperBound)
                } else {
                    removalUpperBound = endRange.upperBound
                }
            } else {
                removalUpperBound = strippedContents.endIndex
            }

            strippedContents.removeSubrange(startRange.lowerBound..<removalUpperBound)
        }

        let normalizedBase = strippedContents.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let replacement else {
            return normalizedBase.isEmpty ? "" : normalizedBase + "\n"
        }

        if normalizedBase.isEmpty {
            return replacement + "\n"
        }

        return normalizedBase + "\n\n" + replacement + "\n"
    }

    private func renderAssignment(
        variable: String,
        value: String,
        syntax: ShellConfigurationSyntax
    ) -> String {
        switch syntax {
        case .posix:
            return #"export \#(variable)="\#(shellEscaped(value))""#
        case .fish:
            return #"set -gx \#(variable) "\#(shellEscaped(value))""#
        }
    }

    private func shellEscaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "$", with: "\\$")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "\n", with: "")
    }

    private func maskedValue(for value: String) -> String {
        String(repeating: "*", count: min(max(value.count, 4), 12))
    }
}
