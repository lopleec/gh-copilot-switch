import Foundation
import Security

enum KeychainServiceError: LocalizedError {
    case unexpectedStatus(OSStatus)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .unexpectedStatus(let status):
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "未知错误"
            return "钥匙串操作失败：\(message) (\(status))"
        case .invalidData:
            return "钥匙串返回了无法识别的 API Key 数据。"
        }
    }
}

final class KeychainService {
    private let service: String

    init(service: String = AppConstants.keychainService) {
        self.service = service
    }

    func saveAPIKey(_ apiKey: String?, for profileID: UUID) throws {
        guard let apiKey, apiKey.isEmpty == false else {
            try deleteAPIKey(for: profileID)
            return
        }

        let query = baseQuery(for: profileID)
        let encodedValue = Data(apiKey.utf8)
        let lookupStatus = SecItemCopyMatching(query as CFDictionary, nil)

        switch lookupStatus {
        case errSecSuccess:
            let updateAttributes = [kSecValueData as String: encodedValue]
            let updateStatus = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainServiceError.unexpectedStatus(updateStatus)
            }
        case errSecItemNotFound:
            var insertAttributes = query
            insertAttributes[kSecValueData as String] = encodedValue
            let addStatus = SecItemAdd(insertAttributes as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainServiceError.unexpectedStatus(addStatus)
            }
        default:
            throw KeychainServiceError.unexpectedStatus(lookupStatus)
        }
    }

    func loadAPIKey(for profileID: UUID) throws -> String? {
        var query = baseQuery(for: profileID)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let value = String(data: data, encoding: .utf8) else {
                throw KeychainServiceError.invalidData
            }
            return value
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainServiceError.unexpectedStatus(status)
        }
    }

    func deleteAPIKey(for profileID: UUID) throws {
        let status = SecItemDelete(baseQuery(for: profileID) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainServiceError.unexpectedStatus(status)
        }
    }

    private func baseQuery(for profileID: UUID) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: profileID.uuidString,
        ]
    }
}
