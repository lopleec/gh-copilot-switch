import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct GitHubCopilotLLMSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var settings: AppSettingsStore
    @State private var store: ProfilesStore

    init() {
        let settings = AppSettingsStore()
        _settings = State(initialValue: settings)
        _store = State(initialValue: ProfilesStore(settings: settings))
    }

    var body: some Scene {
        WindowGroup(settings.localizer.string(.appDisplayName), id: "main") {
            ContentView(store: store)
                .environment(settings)
                .environment(\.locale, settings.locale)
        }
        .defaultSize(width: 980, height: 640)
        .commands {
            CommandMenu(settings.localizer.string(.menuProfiles)) {
                Button(settings.localizer.string(.menuNewProfile)) {
                    store.startCreatingProfile()
                }
                .keyboardShortcut("n")

                Button(settings.localizer.string(.menuEditSelectedProfile)) {
                    store.startEditingSelectedProfile()
                }
                .disabled(store.selectedProfile == nil)

                Divider()

                Button(
                    store.selectedProfileIsActive
                    ? settings.localizer.string(.menuDeactivateCurrentProfile)
                    : settings.localizer.string(.menuApplySelectedProfile)
                ) {
                    store.selectedProfileIsActive ? store.clearActiveProfile() : store.applySelectedProfile()
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(store.selectedProfile == nil)
            }
        }

        Settings {
            SettingsView()
                .environment(settings)
                .environment(\.locale, settings.locale)
        }
    }
}
