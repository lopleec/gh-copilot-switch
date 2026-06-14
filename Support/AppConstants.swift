import Foundation

enum AppConstants {
    static let appName = "GitHubCopilotLLMSwitch"
    static let displayName = "GitHub Copilot LLM Switch"
    static let bundleIdentifier = "com.luccazh.GitHubCopilotLLMSwitch"
    static let keychainService = "\(bundleIdentifier).profiles"
    static let managedBlockStart = "# >>> GitHubCopilotLLMSwitch >>>"
    static let managedBlockEnd = "# <<< GitHubCopilotLLMSwitch <<<"
}
