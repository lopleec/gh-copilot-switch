import SwiftUI

struct ProfileRowView: View {
    @Environment(AppSettingsStore.self) private var settings
    let profile: ProviderProfile
    let isActive: Bool
    let onToggle: (Bool) -> Void

    private var localizer: AppLocalizer {
        settings.localizer
    }

    private var toggleHelpText: String {
        isActive
            ? localizer.string(.toggleDeactivateHelp)
            : localizer.string(.toggleActivateHelp)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: profile.providerType.iconName)
                .foregroundStyle(.secondary)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .lineLimit(1)

                Text(profile.subtitle.isEmpty ? localizer.string(.modelUnset) : profile.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            Toggle(
                isOn: Binding(
                    get: { isActive },
                    set: { newValue in
                        onToggle(newValue)
                    }
                )
            ) {
                EmptyView()
            }
            .labelsHidden()
            .toggleStyle(.switch)
            .help(toggleHelpText)
            .accessibilityLabel(profile.name)
            .accessibilityHint(toggleHelpText)
        }
    }
}
