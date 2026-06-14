import XCTest
@testable import GitHubCopilotLLMSwitch

@MainActor
final class AppSettingsStoreTests: XCTestCase {
    func testManagedShellFilePathNormalizesBeforePersisting() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)

        settings.managedShellFilePath = ".bash_profile"

        XCTAssertEqual(settings.managedShellFilePath, "~/.bash_profile")
        XCTAssertEqual(settings.managedShellConfiguration.displayPath, "~/.bash_profile")
        XCTAssertEqual(defaults.string(forKey: AppPreferenceKeys.managedShellFilePath), "~/.bash_profile")
    }

    func testChangingLanguageUpdatesLocalizer() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)

        settings.preferredLanguage = .english

        XCTAssertEqual(settings.localizer.string(.toolbarSettings), "Settings")
        XCTAssertEqual(defaults.string(forKey: AppPreferenceKeys.preferredLanguage), AppLanguage.english.rawValue)
    }

    private func makeUserDefaults() -> UserDefaults {
        let suiteName = "GitHubCopilotLLMSwitchTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
