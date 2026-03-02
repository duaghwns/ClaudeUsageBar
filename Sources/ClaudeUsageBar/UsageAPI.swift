import Foundation

struct UsageBucket: Codable {
    let utilization: Double
    let resetsAt: String?

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}

struct UsageResponse: Codable {
    let fiveHour: UsageBucket
    let sevenDay: UsageBucket
    let sevenDayOpus: UsageBucket?
    let sevenDaySonnet: UsageBucket?

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDayOpus = "seven_day_opus"
        case sevenDaySonnet = "seven_day_sonnet"
    }
}

enum UsageAPIError: Error, LocalizedError {
    case invalidResponse(Int)
    case networkError(Error)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let code):
            return "API 오류: HTTP \(code)"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError(let error):
            return "응답 파싱 오류: \(error.localizedDescription)"
        }
    }
}

// MARK: - Profile Models

struct ProfileAccount: Codable {
    let fullName: String?
    let displayName: String?
    let email: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case displayName = "display_name"
        case email
    }
}

struct ProfileOrganization: Codable {
    let name: String?
    let organizationType: String?
    let rateLimitTier: String?
    let subscriptionStatus: String?

    enum CodingKeys: String, CodingKey {
        case name
        case organizationType = "organization_type"
        case rateLimitTier = "rate_limit_tier"
        case subscriptionStatus = "subscription_status"
    }
}

struct ProfileResponse: Codable {
    let account: ProfileAccount?
    let organization: ProfileOrganization?
}

actor UsageAPI {
    private let session = URLSession.shared

    func fetchProfile(token: String) async throws -> ProfileResponse {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/api/oauth/profile")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.timeoutInterval = 15

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw UsageAPIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw UsageAPIError.invalidResponse(code)
        }

        do {
            return try JSONDecoder().decode(ProfileResponse.self, from: data)
        } catch {
            throw UsageAPIError.decodingError(error)
        }
    }

    func fetchUsage(token: String) async throws -> UsageResponse {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/api/oauth/usage")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.timeoutInterval = 15

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw UsageAPIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsageAPIError.invalidResponse(0)
        }

        guard httpResponse.statusCode == 200 else {
            throw UsageAPIError.invalidResponse(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(UsageResponse.self, from: data)
        } catch {
            throw UsageAPIError.decodingError(error)
        }
    }

    // MARK: - Legacy Reset Time Formatting

    static func formatResetTime(_ isoString: String?) -> String? {
        guard let isoString = isoString else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var resetDate = formatter.date(from: isoString)
        if resetDate == nil {
            formatter.formatOptions = [.withInternetDateTime]
            resetDate = formatter.date(from: isoString)
        }
        guard let date = resetDate else { return nil }

        let now = Date()
        let interval = date.timeIntervalSince(now)
        guard interval > 0 else { return "곧 리셋" }

        let totalMinutes = Int(interval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        let days = hours / 24
        let remainingHours = hours % 24

        if days > 0 {
            if remainingHours > 0 {
                return "\(days)일 \(remainingHours)시간 후 리셋"
            }
            return "\(days)일 후 리셋"
        } else if hours > 0 {
            if minutes > 0 {
                return "\(hours)시간 \(minutes)분 후 리셋"
            }
            return "\(hours)시간 후 리셋"
        } else {
            return "\(minutes)분 후 리셋"
        }
    }
}
