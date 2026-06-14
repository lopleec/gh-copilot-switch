import SwiftUI

struct ProfileEditorView: View {
    @Environment(AppSettingsStore.self) private var settings
    let title: String
    let onCancel: () -> Void
    let onSave: (ProfileDraft) -> Void

    @State private var draft: ProfileDraft
    @FocusState private var focusedField: FocusField?

    init(
        title: String,
        draft: ProfileDraft,
        onCancel: @escaping () -> Void,
        onSave: @escaping (ProfileDraft) -> Void
    ) {
        self.title = title
        self.onCancel = onCancel
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    private var localizer: AppLocalizer {
        settings.localizer
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.title2.weight(.semibold))

            Form {
                Section {
                    TextField(localizer.string(.editorProfileName), text: $draft.name)
                        .focused($focusedField, equals: .name)

                    Picker(localizer.string(.providerType), selection: $draft.providerType) {
                        ForEach(ProviderType.allCases) { providerType in
                            Text(providerType.displayName(using: localizer)).tag(providerType)
                        }
                    }
                } header: {
                    Text(localizer.string(.editorGeneralInfo))
                }

                Section {
                    TextField("COPILOT_PROVIDER_BASE_URL", text: $draft.baseURL)
                        .focused($focusedField, equals: .baseURL)

                    SecureField("COPILOT_PROVIDER_API_KEY", text: $draft.apiKey)
                        .focused($focusedField, equals: .apiKey)

                    TextField("COPILOT_MODEL", text: $draft.model)
                        .focused($focusedField, equals: .model)
                } header: {
                    Text(localizer.string(.editorEnvironmentSection))
                } footer: {
                    Text(localizer.string(.editorEnvironmentFooter))
                }
            }
            .formStyle(.grouped)

            if let validationError = draft.validationError {
                Label(localizer.string(validationError.titleKey), systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }

            HStack {
                Spacer()

                Button(localizer.string(.actionCancel), action: onCancel)
                Button(localizer.string(.saveProfile)) {
                    onSave(draft)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(draft.canSave == false)
            }
        }
        .padding(24)
        .frame(width: 520)
        .onAppear {
            focusedField = .name
        }
    }

    private enum FocusField: Hashable {
        case name
        case baseURL
        case apiKey
        case model
    }
}
