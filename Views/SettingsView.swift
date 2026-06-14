import SwiftUI

struct SettingsView: View {
    @Environment(AppSettingsStore.self) private var settings
    @State private var isEditingManagedShellFilePath = false
    @State private var managedShellFilePathDraft = ""

    private var localizer: AppLocalizer {
        settings.localizer
    }

    var body: some View {
        @Bindable var settings = settings

        TabView {
            Form {
                Section {
                    Picker(localizer.string(.settingsLanguage), selection: $settings.preferredLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(localizer.string(language.titleKey))
                                .tag(language)
                        }
                    }

                    Picker(localizer.string(.settingsNotificationDuration), selection: $settings.statusBannerDuration) {
                        ForEach(StatusBannerDuration.allCases) { duration in
                            Text(localizer.string(duration.titleKey))
                                .tag(duration)
                        }
                    }
                } header: {
                    Text(localizer.string(.settingsAppearanceSection))
                }

                Section {
                    if isEditingManagedShellFilePath {
                        VStack(alignment: .leading, spacing: 10) {
                            TextField(localizer.string(.settingsTargetFilePath), text: $managedShellFilePathDraft)
                                .textFieldStyle(.roundedBorder)

                            HStack {
                                Button(localizer.string(.settingsSaveTargetFile)) {
                                    settings.managedShellFilePath = managedShellFilePathDraft
                                    isEditingManagedShellFilePath = false
                                }

                                Button(localizer.string(.actionCancel)) {
                                    managedShellFilePathDraft = settings.managedShellConfiguration.displayPath
                                    isEditingManagedShellFilePath = false
                                }
                            }
                        }
                    } else {
                        LabeledContent(
                            localizer.string(.settingsTargetFilePath),
                            value: settings.managedShellConfiguration.displayPath
                        )

                        Button(localizer.string(.settingsEditTargetFile)) {
                            managedShellFilePathDraft = settings.managedShellConfiguration.displayPath
                            isEditingManagedShellFilePath = true
                        }
                    }

                    Picker(localizer.string(.settingsShellSyntax), selection: $settings.managedShellSyntax) {
                        ForEach(ShellConfigurationSyntax.allCases) { syntax in
                            Text(localizer.string(syntax.titleKey))
                                .tag(syntax)
                        }
                    }

                    LabeledContent(
                        localizer.string(.settingsManagedFile),
                        value: settings.managedShellConfiguration.displayPath
                    )

                    Text(localizer.string(.settingsTargetFileHint))
                        .foregroundStyle(.secondary)

                    Text(localizer.string(.settingsManagedBehavior))
                        .foregroundStyle(.secondary)
                } header: {
                    Text(localizer.string(.settingsIntegrationSection))
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label(localizer.string(.settingsGeneralTab), systemImage: "gearshape")
            }
        }
        .frame(width: 500, height: 320)
        .scenePadding()
        .onAppear {
            managedShellFilePathDraft = settings.managedShellConfiguration.displayPath
        }
    }
}
