import SwiftUI

struct ProfileDetailView: View {
    @Environment(AppSettingsStore.self) private var settings
    let profile: ProviderProfile
    let isActive: Bool
    let hasAPIKey: Bool
    let shellPreview: String
    let managedFilePath: String
    let shellSyntaxDisplayName: String
    let onEdit: () -> Void
    let onApply: () -> Void
    let onDelete: () -> Void

    private var localizer: AppLocalizer {
        settings.localizer
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                configurationSection
                shellSection
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.name)
                        .font(.largeTitle.weight(.semibold))

                    Text(localizer.string(.profileDetailDescriptionFormat, profile.providerType.displayName(using: localizer)))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isActive {
                    Label(localizer.string(.profileActive), systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                } else {
                    Text(localizer.string(.profileInactive))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Button(localizer.string(.editProfile), action: onEdit)
                Button(isActive ? localizer.string(.deactivateCurrentProfile) : localizer.string(.applyToCopilot), action: onApply)
                    .keyboardShortcut(.defaultAction)
                Button(localizer.string(.deleteProfile), role: .destructive, action: onDelete)
            }
        }
    }

    private var configurationSection: some View {
        GroupBox(localizer.string(.configSectionTitle)) {
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent(localizer.string(.providerType), value: profile.providerType.displayName(using: localizer))
                LabeledContent(localizer.string(.baseURL), value: profile.baseURL)
                LabeledContent(localizer.string(.model), value: profile.model)
                LabeledContent(localizer.string(.apiKey)) {
                    Text(hasAPIKey ? localizer.string(.savedToKeychain) : localizer.string(.notSet))
                }

                if let lastAppliedAt = profile.lastAppliedAt {
                    LabeledContent(localizer.string(.lastApplied)) {
                        Text(lastAppliedAt, format: .dateTime.year().month().day().hour().minute())
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
        }
    }

    private var shellSection: some View {
        GroupBox(localizer.string(.managedBlockSectionTitle)) {
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent(localizer.string(.managedTargetFile), value: managedFilePath)
                LabeledContent(localizer.string(.managedShellSyntax), value: shellSyntaxDisplayName)

                Text(localizer.string(.managedBlockDescription))
                    .foregroundStyle(.secondary)

                Text(shellPreview)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(localizer.string(.managedBlockHint))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
