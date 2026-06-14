import Foundation

enum AppPreferenceKeys {
    static let preferredLanguage = "preferredLanguage"
    static let statusBannerDuration = "statusBannerDuration"
    static let managedShellFilePath = "managedShellFilePath"
    static let managedShellSyntax = "managedShellSyntax"
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case simplifiedChinese = "zh-Hans"
    case english = "en"

    var id: String { rawValue }

    var resolvedLanguage: AppLanguage {
        guard self == .system else { return self }

        let preferredIdentifier = Locale.preferredLanguages.first?.lowercased() ?? "en"
        return preferredIdentifier.hasPrefix("zh") ? .simplifiedChinese : .english
    }

    var locale: Locale {
        Locale(identifier: resolvedLanguage.rawValue)
    }

    var titleKey: AppCopy {
        switch self {
        case .system:
            return .settingsLanguageSystem
        case .simplifiedChinese:
            return .settingsLanguageChinese
        case .english:
            return .settingsLanguageEnglish
        }
    }
}

enum StatusBannerDuration: String, CaseIterable, Identifiable {
    case brief
    case standard
    case long

    var id: String { rawValue }

    var seconds: Double {
        switch self {
        case .brief:
            return 1.15
        case .standard:
            return 1.8
        case .long:
            return 2.8
        }
    }

    var titleKey: AppCopy {
        switch self {
        case .brief:
            return .durationBrief
        case .standard:
            return .durationStandard
        case .long:
            return .durationLong
        }
    }
}

enum ShellConfigurationSyntax: String, CaseIterable, Identifiable {
    case posix
    case fish

    var id: String { rawValue }

    var titleKey: AppCopy {
        switch self {
        case .posix:
            return .settingsShellSyntaxPosix
        case .fish:
            return .settingsShellSyntaxFish
        }
    }
}
