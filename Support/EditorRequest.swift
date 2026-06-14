import Foundation

struct EditorRequest: Identifiable {
    enum Mode {
        case create
        case edit(ProviderProfile.ID)
    }

    let id = UUID()
    let mode: Mode
    let draft: ProfileDraft

    var titleKey: AppCopy {
        switch mode {
        case .create:
            return .editorCreateTitle
        case .edit:
            return .editorEditTitle
        }
    }
}
