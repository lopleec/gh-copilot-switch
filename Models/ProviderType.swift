import Foundation

enum ProviderType: String, Codable, CaseIterable, Identifiable {
    case openAI = "openai"
    case azure = "azure"
    case anthropic = "anthropic"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .openAI:
            return "sparkles.rectangle.stack"
        case .azure:
            return "cloud"
        case .anthropic:
            return "bubble.left.and.text.bubble.right"
        }
    }

    var requiresExplicitTypeExport: Bool {
        self != .openAI
    }

    var titleKey: AppCopy {
        switch self {
        case .openAI:
            return .providerOpenAICompatible
        case .azure:
            return .providerAzureOpenAI
        case .anthropic:
            return .providerAnthropic
        }
    }

    func displayName(using localizer: AppLocalizer) -> String {
        localizer.string(titleKey)
    }
}
