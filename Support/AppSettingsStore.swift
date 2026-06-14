import Foundation
import Observation

struct ManagedShellConfiguration: Equatable {
    var filePath: String
    var syntax: ShellConfigurationSyntax

    init(
        filePath: String = AppPaths.defaultManagedShellFilePath,
        syntax: ShellConfigurationSyntax = .posix
    ) {
        self.filePath = AppPaths.normalizedManagedShellFilePath(filePath)
        self.syntax = syntax
    }

    var displayPath: String {
        AppPaths.normalizedManagedShellFilePath(filePath)
    }

    var fileURL: URL {
        AppPaths.resolveManagedShellFileURL(filePath)
    }
}

@MainActor
@Observable
final class AppSettingsStore {
    private let userDefaults: UserDefaults

    var preferredLanguage: AppLanguage {
        didSet {
            userDefaults.set(preferredLanguage.rawValue, forKey: AppPreferenceKeys.preferredLanguage)
        }
    }

    var statusBannerDuration: StatusBannerDuration {
        didSet {
            userDefaults.set(statusBannerDuration.rawValue, forKey: AppPreferenceKeys.statusBannerDuration)
        }
    }

    var managedShellFilePath: String {
        didSet {
            let normalizedPath = AppPaths.normalizedManagedShellFilePath(managedShellFilePath)
            guard managedShellFilePath != normalizedPath else {
                userDefaults.set(managedShellFilePath, forKey: AppPreferenceKeys.managedShellFilePath)
                return
            }

            managedShellFilePath = normalizedPath
        }
    }

    var managedShellSyntax: ShellConfigurationSyntax {
        didSet {
            userDefaults.set(managedShellSyntax.rawValue, forKey: AppPreferenceKeys.managedShellSyntax)
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        preferredLanguage = AppLanguage(
            rawValue: userDefaults.string(forKey: AppPreferenceKeys.preferredLanguage)
                ?? AppLanguage.system.rawValue
        ) ?? .system
        statusBannerDuration = StatusBannerDuration(
            rawValue: userDefaults.string(forKey: AppPreferenceKeys.statusBannerDuration)
                ?? StatusBannerDuration.brief.rawValue
        ) ?? .brief
        managedShellFilePath = AppPaths.normalizedManagedShellFilePath(
            userDefaults.string(forKey: AppPreferenceKeys.managedShellFilePath)
        )
        managedShellSyntax = ShellConfigurationSyntax(
            rawValue: userDefaults.string(forKey: AppPreferenceKeys.managedShellSyntax)
                ?? ShellConfigurationSyntax.posix.rawValue
        ) ?? .posix
    }

    var localizer: AppLocalizer {
        AppLocalizer(language: preferredLanguage)
    }

    var locale: Locale {
        localizer.locale
    }

    var managedShellConfiguration: ManagedShellConfiguration {
        ManagedShellConfiguration(
            filePath: managedShellFilePath,
            syntax: managedShellSyntax
        )
    }
}
