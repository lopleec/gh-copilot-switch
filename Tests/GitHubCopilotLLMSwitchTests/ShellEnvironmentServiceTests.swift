import XCTest
@testable import GitHubCopilotLLMSwitch

final class ShellEnvironmentServiceTests: XCTestCase {
    func testApplyAppendsManagedBlockToExistingFile() throws {
        let fileURL = try makeTemporaryFile()
        try #"export PATH="$HOME/.local/bin:$PATH""#
            .write(to: fileURL, atomically: true, encoding: .utf8)

        let service = ShellEnvironmentService()
        try service.apply(
            profile: sampleProfile(),
            apiKey: "test-api-key",
            configuration: makeConfiguration(fileURL: fileURL)
        )

        let contents = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertTrue(contents.contains(#"export PATH="$HOME/.local/bin:$PATH""#))
        XCTAssertTrue(contents.contains(AppConstants.managedBlockStart))
        XCTAssertTrue(contents.contains(#"export COPILOT_PROVIDER_BASE_URL="https://api.example.com/v1""#))
        XCTAssertTrue(contents.contains(#"export COPILOT_PROVIDER_API_KEY="test-api-key""#))
        XCTAssertTrue(contents.contains(#"export COPILOT_MODEL="gpt-4o""#))
        XCTAssertTrue(contents.hasSuffix("\n"))
    }

    func testApplyReplacesPreviousManagedBlockAndKeepsOtherContent() throws {
        let fileURL = try makeTemporaryFile()
        let originalContents = """
        export PATH="$HOME/.local/bin:$PATH"

        \(AppConstants.managedBlockStart)
        export COPILOT_PROVIDER_BASE_URL="https://old.example.com/v1"
        export COPILOT_PROVIDER_API_KEY="old-key"
        export COPILOT_MODEL="old-model"
        \(AppConstants.managedBlockEnd)
        """
        try originalContents.write(to: fileURL, atomically: true, encoding: .utf8)

        let service = ShellEnvironmentService()
        try service.apply(
            profile: sampleProfile(
                providerType: .azure,
                baseURL: "https://azure.example.com/openai/deployments/demo",
                model: "demo"
            ),
            apiKey: "new-key",
            configuration: makeConfiguration(fileURL: fileURL)
        )

        let contents = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertTrue(contents.contains(#"export PATH="$HOME/.local/bin:$PATH""#))
        XCTAssertFalse(contents.contains("old.example.com"))
        XCTAssertFalse(contents.contains("old-model"))
        XCTAssertEqual(countOccurrences(of: AppConstants.managedBlockStart, in: contents), 1)
        XCTAssertTrue(contents.contains(#"export COPILOT_PROVIDER_TYPE="azure""#))
        XCTAssertTrue(contents.contains(#"export COPILOT_MODEL="demo""#))
    }

    func testClearManagedBlockPreservesUserContent() throws {
        let fileURL = try makeTemporaryFile()
        let originalContents = """
        export PATH="$HOME/.local/bin:$PATH"

        \(AppConstants.managedBlockStart)
        export COPILOT_PROVIDER_BASE_URL="https://api.example.com/v1"
        export COPILOT_PROVIDER_API_KEY="temporary-key"
        export COPILOT_MODEL="gpt-4o"
        \(AppConstants.managedBlockEnd)
        """
        try originalContents.write(to: fileURL, atomically: true, encoding: .utf8)

        let service = ShellEnvironmentService()
        try service.clearManagedBlock(configuration: makeConfiguration(fileURL: fileURL))

        let contents = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertTrue(contents.contains(#"export PATH="$HOME/.local/bin:$PATH""#))
        XCTAssertFalse(contents.contains(AppConstants.managedBlockStart))
        XCTAssertFalse(contents.contains("COPILOT_PROVIDER_BASE_URL"))
    }

    func testFishSyntaxUsesSetCommands() throws {
        let fileURL = try makeTemporaryFile()
        let service = ShellEnvironmentService()

        try service.apply(
            profile: sampleProfile(providerType: .anthropic, model: "claude-sonnet-4"),
            apiKey: "fish-test-key",
            configuration: makeConfiguration(fileURL: fileURL, syntax: .fish)
        )

        let contents = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertTrue(contents.contains(#"set -gx COPILOT_PROVIDER_BASE_URL "https://api.example.com/v1""#))
        XCTAssertTrue(contents.contains(#"set -gx COPILOT_PROVIDER_TYPE "anthropic""#))
        XCTAssertTrue(contents.contains(#"set -gx COPILOT_PROVIDER_API_KEY "fish-test-key""#))
        XCTAssertTrue(contents.contains(#"set -gx COPILOT_MODEL "claude-sonnet-4""#))
        XCTAssertFalse(contents.contains("export COPILOT_MODEL"))
    }

    func testApplyPreservesLeadingWhitespaceAndNewlinesOutsideManagedBlock() throws {
        let fileURL = try makeTemporaryFile()
        let originalContents = """


        # Existing shell setup
        export PATH="$HOME/.local/bin:$PATH"
        """
        try originalContents.write(to: fileURL, atomically: true, encoding: .utf8)

        let service = ShellEnvironmentService()
        try service.apply(
            profile: sampleProfile(),
            apiKey: "test-api-key",
            configuration: makeConfiguration(fileURL: fileURL)
        )

        let contents = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertTrue(
            contents.hasPrefix(
                "\n\n# Existing shell setup\nexport PATH=\"$HOME/.local/bin:$PATH\"\n\n"
            )
        )
        XCTAssertTrue(contents.contains(AppConstants.managedBlockStart))
    }

    func testPosixSyntaxEscapesExclamationMarks() throws {
        let fileURL = try makeTemporaryFile()
        let service = ShellEnvironmentService()

        try service.apply(
            profile: sampleProfile(model: "gpt!4o"),
            apiKey: "bang!key",
            configuration: makeConfiguration(fileURL: fileURL)
        )

        let contents = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertTrue(contents.contains(#"export COPILOT_PROVIDER_API_KEY="bang\!key""#))
        XCTAssertTrue(contents.contains(#"export COPILOT_MODEL="gpt\!4o""#))
    }

    private func makeTemporaryFile() throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        return directoryURL.appendingPathComponent(".zshrc", isDirectory: false)
    }

    private func makeConfiguration(
        fileURL: URL,
        syntax: ShellConfigurationSyntax = .posix
    ) -> ManagedShellConfiguration {
        ManagedShellConfiguration(filePath: fileURL.path, syntax: syntax)
    }

    private func sampleProfile(
        providerType: ProviderType = .openAI,
        baseURL: String = "https://api.example.com/v1",
        model: String = "gpt-4o"
    ) -> ProviderProfile {
        ProviderProfile(
            id: UUID(),
            name: "Remote OpenAI",
            providerType: providerType,
            baseURL: baseURL,
            model: model,
            createdAt: Date(),
            updatedAt: Date(),
            lastAppliedAt: nil
        )
    }

    private func countOccurrences(of needle: String, in haystack: String) -> Int {
        haystack.components(separatedBy: needle).count - 1
    }
}
