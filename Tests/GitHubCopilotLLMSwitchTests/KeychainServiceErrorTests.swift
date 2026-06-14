import Security
import XCTest
@testable import GitHubCopilotLLMSwitch

final class KeychainServiceErrorTests: XCTestCase {
    func testInvalidDataUsesEnglishCopy() {
        let localizer = AppLocalizer(language: .english)

        XCTAssertEqual(
            KeychainServiceError.invalidData.userMessage(using: localizer),
            "The Keychain returned unreadable API key data."
        )
    }

    func testUnexpectedStatusUsesSelectedLanguageWrapper() {
        let english = AppLocalizer(language: .english)
        let chinese = AppLocalizer(language: .simplifiedChinese)
        let error = KeychainServiceError.unexpectedStatus(errSecParam)

        XCTAssertTrue(error.userMessage(using: english).hasPrefix("Keychain operation failed:"))
        XCTAssertTrue(error.userMessage(using: chinese).hasPrefix("钥匙串操作失败："))
    }
}
