import SwiftUI

struct ContentView: View {
    @Environment(AppSettingsStore.self) private var settings
    @Bindable var store: ProfilesStore
    @State private var isDeleteConfirmationPresented = false
    @State private var statusDismissTask: Task<Void, Never>?

    private var localizer: AppLocalizer {
        settings.localizer
    }

    private var bannerDuration: StatusBannerDuration {
        settings.statusBannerDuration
    }

    private var managedShellFilePath: String {
        settings.managedShellConfiguration.displayPath
    }

    private var managedShellSyntax: ShellConfigurationSyntax {
        settings.managedShellSyntax
    }

    var body: some View {
        NavigationSplitView {
            ProfileListView(
                profiles: store.profiles,
                selection: $store.selectedProfileID,
                activeProfileID: store.activeProfileID,
                onToggle: store.setProfileActive(_:isActive:)
            )
            .navigationSplitViewColumnWidth(min: 250, ideal: 280)
        } detail: {
            if let selectedProfile = store.selectedProfile {
                ProfileDetailView(
                    profile: selectedProfile,
                    isActive: store.selectedProfileIsActive,
                    hasAPIKey: store.hasAPIKey(for: selectedProfile.id),
                    shellPreview: store.maskedShellPreview(for: selectedProfile.id),
                    managedFilePath: managedShellFilePath,
                    shellSyntaxDisplayName: localizer.string(managedShellSyntax.titleKey),
                    onEdit: store.startEditingSelectedProfile,
                    onApply: store.selectedProfileIsActive ? store.clearActiveProfile : store.applySelectedProfile,
                    onDelete: { isDeleteConfirmationPresented = true }
                )
            } else {
                ContentUnavailableView(
                    localizer.string(.emptySelectionTitle),
                    systemImage: "switch.2",
                    description: Text(localizer.string(.emptySelectionDescription))
                )
            }
        }
        .navigationTitle(localizer.string(.appDisplayName))
        .toolbar {
            ToolbarItemGroup {
                Button {
                    store.startCreatingProfile()
                } label: {
                    Label(localizer.string(.toolbarNewProfile), systemImage: "plus")
                }

                Button {
                    store.startEditingSelectedProfile()
                } label: {
                    Label(localizer.string(.toolbarEditProfile), systemImage: "square.and.pencil")
                }
                .disabled(store.selectedProfile == nil)

                Button(role: .destructive) {
                    isDeleteConfirmationPresented = true
                } label: {
                    Label(localizer.string(.toolbarDeleteProfile), systemImage: "trash")
                }
                .disabled(store.selectedProfile == nil)

                SettingsLink {
                    Label(localizer.string(.toolbarSettings), systemImage: "gearshape")
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.selectedProfileIsActive ? store.clearActiveProfile() : store.applySelectedProfile()
                } label: {
                    Label(
                        store.selectedProfileIsActive
                            ? localizer.string(.toolbarDeactivateCurrentProfile)
                            : localizer.string(.toolbarApplyToCopilot),
                        systemImage: store.selectedProfileIsActive ? "power" : "checkmark.circle"
                    )
                }
                .disabled(store.selectedProfile == nil)
            }
        }
        .sheet(item: editorRequestBinding) { request in
            ProfileEditorView(
                title: localizer.string(request.titleKey),
                draft: request.draft,
                onCancel: store.dismissEditor,
                onSave: { draft in
                    store.commitEditor(draft, mode: request.mode)
                }
            )
        }
        .alert(
            localizer.string(.alertDeleteTitle),
            isPresented: $isDeleteConfirmationPresented,
            presenting: store.selectedProfile
        ) { profile in
            Button(localizer.string(.alertDeleteAction), role: .destructive) {
                store.deleteSelectedProfile()
            }

            Button(localizer.string(.actionCancel), role: .cancel) {}
        } message: { profile in
            Text(localizer.string(.alertDeleteMessageFormat, profile.name))
        }
        .overlay(alignment: .topTrailing) {
            if let status = store.status {
                StatusBannerView(status: status, onDismiss: store.dismissStatus)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.18), value: store.status?.id)
        .onAppear {
            scheduleStatusDismiss()
        }
        .onChange(of: store.status?.id) { _, _ in
            scheduleStatusDismiss()
        }
        .onChange(of: settings.statusBannerDuration) { _, _ in
            scheduleStatusDismiss()
        }
        .onDisappear {
            statusDismissTask?.cancel()
        }
    }

    private var editorRequestBinding: Binding<EditorRequest?> {
        Binding(
            get: { store.editorRequest },
            set: { newValue in
                if newValue == nil {
                    store.dismissEditor()
                }
            }
        )
    }

    private func scheduleStatusDismiss() {
        statusDismissTask?.cancel()

        guard store.status != nil else { return }

        statusDismissTask = Task {
            try? await Task.sleep(for: .seconds(bannerDuration.seconds))

            guard Task.isCancelled == false else { return }

            await MainActor.run {
                withAnimation(.snappy(duration: 0.18)) {
                    store.dismissStatus()
                }
            }
        }
    }
}
