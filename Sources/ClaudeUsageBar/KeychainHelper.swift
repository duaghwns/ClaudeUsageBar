import Foundation
import Security

enum KeychainError: Error, LocalizedError {
    case itemNotFound
    case unexpectedData
    case tokenExpired
    case osError(OSStatus)

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return L10n.tr("error.keychainNotFound")
        case .unexpectedData:
            return L10n.tr("error.unexpectedData")
        case .tokenExpired:
            return L10n.tr("error.tokenExpired")
        case .osError(let status):
            return String(format: L10n.tr("error.keychainOS"), status)
        }
    }
}

struct PlanInfo {
    let subscriptionType: String?
    let rateLimitTier: String?

    var displayName: String {
        guard let tier = rateLimitTier else {
            return subscriptionType ?? "Unknown"
        }
        // Parse tier like "default_claude_max_5x" → "Max 5x"
        let parts = tier.lowercased().split(separator: "_")
        if let maxIndex = parts.firstIndex(of: "max") {
            let suffix = parts.dropFirst(maxIndex.advanced(by: 1))
            if suffix.isEmpty {
                return "Max"
            }
            return "Max \(suffix.joined(separator: " "))"
        }
        if tier.lowercased().contains("pro") {
            return "Pro"
        }
        return subscriptionType?.capitalized ?? tier
    }

    static func formatTier(_ tier: String) -> String {
        let parts = tier.lowercased().split(separator: "_")
        if let maxIndex = parts.firstIndex(of: "max") {
            let suffix = parts.dropFirst(maxIndex.advanced(by: 1))
            if suffix.isEmpty { return "Max" }
            return "Max \(suffix.joined(separator: " "))"
        }
        if tier.lowercased().contains("pro") { return "Pro" }
        return tier.isEmpty ? "Free" : tier
    }
}

struct KeychainHelper {
    // MARK: - Private Helpers

    private static func readKeychainData() throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Claude Code-credentials",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.osError(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.unexpectedData
        }

        return data
    }

    private static func parseOAuthData(from data: Data) throws -> [String: Any] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let oauthData = json["claudeAiOauth"] as? [String: Any]
        else {
            throw KeychainError.unexpectedData
        }
        return oauthData
    }

    // MARK: - Public API

    static func getOAuthToken() throws -> String {
        let data = try readKeychainData()
        let oauthData = try parseOAuthData(from: data)

        guard let token = oauthData["accessToken"] as? String else {
            throw KeychainError.unexpectedData
        }

        // Check if token is expired
        if let expiresAt = oauthData["expiresAt"] as? Double {
            let expirationDate = Date(timeIntervalSince1970: expiresAt / 1000)
            if expirationDate < Date() {
                throw KeychainError.tokenExpired
            }
        }

        return token
    }

    static func getPlanInfo() -> PlanInfo? {
        guard let data = try? readKeychainData(),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let oauthData = json["claudeAiOauth"] as? [String: Any]
        else {
            return nil
        }

        let subscriptionType = oauthData["subscriptionType"] as? String
        let rateLimitTier = oauthData["rateLimitTier"] as? String

        guard subscriptionType != nil || rateLimitTier != nil else {
            return nil
        }

        return PlanInfo(subscriptionType: subscriptionType, rateLimitTier: rateLimitTier)
    }

    static func getLoginMethod() -> String? {
        guard let data = try? readKeychainData(),
              let oauthData = try? parseOAuthData(from: data)
        else { return nil }

        let sub = oauthData["subscriptionType"] as? String ?? ""
        let tier = oauthData["rateLimitTier"] as? String ?? ""

        // e.g. subscriptionType="max", rateLimitTier="default_claude_max_5x" → "Claude Max Account"
        if tier.lowercased().contains("max") || sub.lowercased() == "max" {
            return "Claude Max Account"
        } else if sub.lowercased() == "pro" || tier.lowercased().contains("pro") {
            return "Claude Pro Account"
        } else if !sub.isEmpty {
            return "Claude \(sub.capitalized) Account"
        }
        return nil
    }
}

struct ClaudeCodeInfo {
    static func getVersion() -> String? {
        let candidates = [
            NSHomeDirectory() + "/.local/bin/claude",
            "/usr/local/bin/claude",
            "/opt/homebrew/bin/claude",
        ]

        guard let claudePath = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
            return nil
        }

        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: claudePath)
        process.arguments = ["--version"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !output.isEmpty
        else { return nil }

        // "2.1.63 (Claude Code)" → "2.1.63"
        return output.components(separatedBy: " ").first
    }

    static func getLoginMethod() -> String? {
        return KeychainHelper.getLoginMethod()
    }
}
