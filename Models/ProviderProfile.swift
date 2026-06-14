import Foundation

struct ProviderProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var providerType: ProviderType
    var baseURL: String
    var model: String
    var createdAt: Date
    var updatedAt: Date
    var lastAppliedAt: Date?

    var subtitle: String {
        model
    }
}
