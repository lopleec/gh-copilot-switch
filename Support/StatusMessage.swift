import SwiftUI

struct StatusMessage: Identifiable, Equatable {
    enum Level: Equatable {
        case success
        case error
        case info

        var iconName: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .error:
                return "xmark.octagon.fill"
            case .info:
                return "info.circle.fill"
            }
        }

        var tint: Color {
            switch self {
            case .success:
                return .green
            case .error:
                return .red
            case .info:
                return .accentColor
            }
        }
    }

    let id = UUID()
    let level: Level
    let text: String

    static func success(_ text: String) -> StatusMessage {
        StatusMessage(level: .success, text: text)
    }

    static func error(_ text: String) -> StatusMessage {
        StatusMessage(level: .error, text: text)
    }

    static func info(_ text: String) -> StatusMessage {
        StatusMessage(level: .info, text: text)
    }
}
