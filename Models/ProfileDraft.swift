import Foundation

enum ProfileDraftValidationError {
    case missingName
    case invalidBaseURL
    case missingModel

    var titleKey: AppCopy {
        switch self {
        case .missingName:
            return .validationMissingName
        case .invalidBaseURL:
            return .validationInvalidBaseURL
        case .missingModel:
            return .validationMissingModel
        }
    }
}

struct ProfileDraft: Equatable {
    let id: UUID
    var name: String
    var providerType: ProviderType
    var baseURL: String
    var apiKey: String
    var model: String

    init(
        id: UUID = UUID(),
        name: String = "",
        providerType: ProviderType = .openAI,
        baseURL: String = "https://api.example.com/v1",
        apiKey: String = "",
        model: String = ""
    ) {
        self.id = id
        self.name = name
        self.providerType = providerType
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.model = model
    }

    init(profile: ProviderProfile, apiKey: String?) {
        self.init(
            id: profile.id,
            name: profile.name,
            providerType: profile.providerType,
            baseURL: profile.baseURL,
            apiKey: apiKey ?? "",
            model: profile.model
        )
    }

    var normalizedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedBaseURL: String {
        baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedModel: String {
        model.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedAPIKey: String? {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var validationError: ProfileDraftValidationError? {
        if normalizedName.isEmpty {
            return .missingName
        }

        guard let components = URLComponents(string: normalizedBaseURL),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              components.host?.isEmpty == false else {
            return .invalidBaseURL
        }

        if normalizedModel.isEmpty {
            return .missingModel
        }

        return nil
    }

    var canSave: Bool {
        validationError == nil
    }

    func makeProfile(persistingFrom existing: ProviderProfile?) -> ProviderProfile {
        ProviderProfile(
            id: existing?.id ?? id,
            name: normalizedName,
            providerType: providerType,
            baseURL: normalizedBaseURL,
            model: normalizedModel,
            createdAt: existing?.createdAt ?? Date(),
            updatedAt: Date(),
            lastAppliedAt: existing?.lastAppliedAt
        )
    }
}
