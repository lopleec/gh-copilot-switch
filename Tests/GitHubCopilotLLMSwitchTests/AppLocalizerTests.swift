import XCTest
@testable import GitHubCopilotLLMSwitch

final class AppLocalizerTests: XCTestCase {
    func testEnglishLocalizationReturnsEnglishCopy() {
        let localizer = AppLocalizer(language: .english)

        XCTAssertEqual(localizer.string(.toolbarSettings), "Settings")
        XCTAssertEqual(localizer.string(.profileListEmptyTitle), "No profiles available")
    }

    func testChineseLocalizationFormatsInterpolatedMessage() {
        let localizer = AppLocalizer(language: .simplifiedChinese)

        XCTAssertEqual(
            localizer.string(.statusAppliedProfileFormat, "Claude Sonnet", "~/.bash_profile"),
            "已将 Claude Sonnet 写入 ~/.bash_profile。重新打开终端后 Copilot CLI 会使用这个模型。"
        )
    }
}
