import Foundation

struct ProfilesSnapshot: Codable {
    var profiles: [ProviderProfile]
    var activeProfileID: ProviderProfile.ID?
    var activeManagedFilePath: String?

    static let empty = ProfilesSnapshot(profiles: [], activeProfileID: nil, activeManagedFilePath: nil)
}

final class ProfilesRepository {
    private let fileURL: URL

    init(fileURL: URL = AppPaths.profilesFileURL) {
        self.fileURL = fileURL
    }

    func load() throws -> ProfilesSnapshot {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return .empty
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ProfilesSnapshot.self, from: data)
    }

    func save(_ snapshot: ProfilesSnapshot) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(snapshot)
        try data.write(to: fileURL, options: .atomic)
    }
}
