import SwiftUI

struct ProfileListView: View {
    @Environment(AppSettingsStore.self) private var settings
    let profiles: [ProviderProfile]
    @Binding var selection: ProviderProfile.ID?
    let activeProfileID: ProviderProfile.ID?
    let onToggle: (ProviderProfile.ID, Bool) -> Void

    private var localizer: AppLocalizer {
        settings.localizer
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(profiles) { profile in
                ProfileRowView(
                    profile: profile,
                    isActive: activeProfileID == profile.id,
                    onToggle: { isActive in
                        onToggle(profile.id, isActive)
                    }
                )
                .tag(profile.id)
            }
        }
        .listStyle(.sidebar)
        .overlay {
            if profiles.isEmpty {
                ContentUnavailableView(
                    localizer.string(.profileListEmptyTitle),
                    systemImage: "square.stack.badge.plus",
                    description: Text(localizer.string(.profileListEmptyDescription))
                )
            }
        }
    }
}
