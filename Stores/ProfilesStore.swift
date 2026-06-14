import Foundation
import Observation

@MainActor
@Observable
final class ProfilesStore {
    private let repository: ProfilesRepository
    private let settings: AppSettingsStore
    private let keychainService: KeychainService
    private let shellEnvironmentService: ShellEnvironmentService

    private(set) var profiles: [ProviderProfile] = []
    var selectedProfileID: ProviderProfile.ID?
    private(set) var activeProfileID: ProviderProfile.ID?
    private(set) var activeManagedFilePath: String?
    var editorRequest: EditorRequest?
    var status: StatusMessage?

    private var localizer: AppLocalizer {
        settings.localizer
    }

    init(
        settings: AppSettingsStore,
        repository: ProfilesRepository = ProfilesRepository(),
        keychainService: KeychainService = KeychainService(),
        shellEnvironmentService: ShellEnvironmentService = ShellEnvironmentService()
    ) {
        self.settings = settings
        self.repository = repository
        self.keychainService = keychainService
        self.shellEnvironmentService = shellEnvironmentService
        loadSnapshot()
    }

    var selectedProfile: ProviderProfile? {
        guard let selectedProfileID else { return nil }
        return profile(withID: selectedProfileID)
    }

    var selectedProfileIsActive: Bool {
        selectedProfileID == activeProfileID
    }

    func startCreatingProfile() {
        editorRequest = EditorRequest(
            mode: .create,
            draft: ProfileDraft(name: localizer.string(.defaultProfileName))
        )
    }

    func startEditingSelectedProfile() {
        guard let selectedProfile else { return }

        do {
            let apiKey = try keychainService.loadAPIKey(for: selectedProfile.id)
            editorRequest = EditorRequest(
                mode: .edit(selectedProfile.id),
                draft: ProfileDraft(profile: selectedProfile, apiKey: apiKey)
            )
        } catch {
            status = .error(localizer.string(.statusReadAPIKeyFailedFormat, userFacingMessage(for: error)))
        }
    }

    func dismissEditor() {
        editorRequest = nil
    }

    func commitEditor(_ draft: ProfileDraft, mode: EditorRequest.Mode) {
        guard draft.canSave else { return }

        do {
            switch mode {
            case .create:
                let profile = draft.makeProfile(persistingFrom: nil)
                profiles.insert(profile, at: 0)
                try keychainService.saveAPIKey(draft.normalizedAPIKey, for: profile.id)
                selectedProfileID = profile.id
                try persist()
                status = .success(localizer.string(.statusProfileAdded))

            case .edit(let profileID):
                guard let existingProfile = profile(withID: profileID),
                      let index = profiles.firstIndex(where: { $0.id == profileID }) else {
                    status = .error(localizer.string(.statusEditMissingProfile))
                    return
                }

                var updatedProfile = draft.makeProfile(persistingFrom: existingProfile)
                try keychainService.saveAPIKey(draft.normalizedAPIKey, for: updatedProfile.id)

                if activeProfileID == updatedProfile.id {
                    let configuration = settings.managedShellConfiguration
                    let currentManagedFilePath = configuration.displayPath

                    if let activeManagedFilePath,
                       activeManagedFilePath != currentManagedFilePath {
                        try shellEnvironmentService.clearManagedBlock(
                            configuration: ManagedShellConfiguration(
                                filePath: activeManagedFilePath,
                                syntax: configuration.syntax
                            )
                        )
                    }

                    updatedProfile.lastAppliedAt = Date()
                    try shellEnvironmentService.apply(
                        profile: updatedProfile,
                        apiKey: draft.normalizedAPIKey,
                        configuration: configuration
                    )
                    activeManagedFilePath = currentManagedFilePath
                    status = .success(localizer.string(.statusProfileSavedAndSyncedFormat, currentManagedFilePath))
                } else {
                    status = .success(localizer.string(.statusProfileSaved))
                }

                profiles[index] = updatedProfile
                selectedProfileID = updatedProfile.id
                try persist()
            }

            editorRequest = nil
        } catch {
            status = .error(localizer.string(.statusSaveFailedFormat, userFacingMessage(for: error)))
        }
    }

    func setProfileActive(_ profileID: ProviderProfile.ID, isActive: Bool) {
        if isActive {
            applyProfile(profileID)
        } else if activeProfileID == profileID {
            clearActiveProfile()
        }
    }

    func applySelectedProfile() {
        guard let selectedProfileID else { return }
        applyProfile(selectedProfileID)
    }

    func clearActiveProfile() {
        do {
            if let activeManagedFilePath {
                try shellEnvironmentService.clearManagedBlock(
                    configuration: ManagedShellConfiguration(
                        filePath: activeManagedFilePath,
                        syntax: settings.managedShellSyntax
                    )
                )
            }
            activeProfileID = nil
            let removedPath = activeManagedFilePath ?? settings.managedShellConfiguration.displayPath
            activeManagedFilePath = nil
            try persist()
            status = .info(localizer.string(.statusManagedConfigRemovedFormat, removedPath))
        } catch {
            status = .error(localizer.string(.statusDeactivateFailedFormat, userFacingMessage(for: error)))
        }
    }

    func deleteSelectedProfile() {
        guard let selectedProfileID else { return }
        deleteProfile(selectedProfileID)
    }

    func hasAPIKey(for profileID: ProviderProfile.ID) -> Bool {
        (try? keychainService.loadAPIKey(for: profileID))?.isEmpty == false
    }

    func maskedShellPreview(for profileID: ProviderProfile.ID) -> String {
        guard let profile = profile(withID: profileID) else { return "" }
        let apiKey = try? keychainService.loadAPIKey(for: profileID)
        return shellEnvironmentService.maskedPreview(
            for: profile,
            apiKey: apiKey ?? nil,
            configuration: settings.managedShellConfiguration
        )
    }

    func dismissStatus() {
        status = nil
    }

    private func applyProfile(_ profileID: ProviderProfile.ID) {
        guard let index = profiles.firstIndex(where: { $0.id == profileID }) else {
            status = .error(localizer.string(.statusApplyMissingProfile))
            return
        }

        do {
            let apiKey = try keychainService.loadAPIKey(for: profileID)
            let configuration = settings.managedShellConfiguration
            let currentManagedFilePath = configuration.displayPath

            if let activeManagedFilePath,
               activeManagedFilePath != currentManagedFilePath {
                try shellEnvironmentService.clearManagedBlock(
                    configuration: ManagedShellConfiguration(
                        filePath: activeManagedFilePath,
                        syntax: configuration.syntax
                    )
                )
            }

            profiles[index].lastAppliedAt = Date()
            try shellEnvironmentService.apply(
                profile: profiles[index],
                apiKey: apiKey,
                configuration: configuration
            )
            activeProfileID = profileID
            activeManagedFilePath = currentManagedFilePath
            try persist()
            status = .success(localizer.string(.statusAppliedProfileFormat, profiles[index].name, currentManagedFilePath))
        } catch {
            status = .error(localizer.string(.statusApplyFailedFormat, userFacingMessage(for: error)))
        }
    }

    private func deleteProfile(_ profileID: ProviderProfile.ID) {
        do {
            if activeProfileID == profileID {
                if let activeManagedFilePath {
                    try shellEnvironmentService.clearManagedBlock(
                        configuration: ManagedShellConfiguration(
                            filePath: activeManagedFilePath,
                            syntax: settings.managedShellSyntax
                        )
                    )
                }
                activeProfileID = nil
                activeManagedFilePath = nil
            }

            profiles.removeAll { $0.id == profileID }
            try keychainService.deleteAPIKey(for: profileID)

            if selectedProfileID == profileID {
                selectedProfileID = profiles.first?.id
            }

            try persist()
            status = .info(localizer.string(.statusProfileDeleted))
        } catch {
            status = .error(localizer.string(.statusDeleteFailedFormat, userFacingMessage(for: error)))
        }
    }

    private func loadSnapshot() {
        do {
            let snapshot = try repository.load()
            profiles = snapshot.profiles
            activeProfileID = snapshot.activeProfileID
            activeManagedFilePath = snapshot.activeManagedFilePath

            if let activeProfileID, profile(withID: activeProfileID) == nil {
                self.activeProfileID = nil
                activeManagedFilePath = nil
            }

            selectedProfileID = profiles.first?.id
        } catch {
            status = .error(localizer.string(.statusLoadFailedFormat, userFacingMessage(for: error)))
        }
    }

    private func userFacingMessage(for error: Error) -> String {
        if let keychainError = error as? KeychainServiceError {
            return keychainError.userMessage(using: localizer)
        }

        return error.localizedDescription
    }

    private func profile(withID profileID: ProviderProfile.ID) -> ProviderProfile? {
        profiles.first { $0.id == profileID }
    }

    private func persist() throws {
        try repository.save(
            ProfilesSnapshot(
                profiles: profiles,
                activeProfileID: activeProfileID,
                activeManagedFilePath: activeManagedFilePath
            )
        )
    }
}
