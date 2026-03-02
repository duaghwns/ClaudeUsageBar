import Foundation

struct DailyActivity: Codable {
    let date: String
    let messageCount: Int
    let sessionCount: Int
    let toolCallCount: Int
}

struct DailyModelTokens: Codable {
    let date: String
    let tokensByModel: [String: Int]
}

struct StatsData: Codable {
    let dailyActivity: [DailyActivity]?
    let dailyModelTokens: [DailyModelTokens]?
}

struct TodayStats {
    let messageCount: Int
    let sessionCount: Int
    let toolCallCount: Int
    let totalTokens: Int
    let date: String // "yyyy-MM-dd" of the data
    let isToday: Bool
}

struct StatsCache {
    static func loadTodayStats() -> TodayStats? {
        let path = NSString(string: "~/.claude/stats-cache.json").expandingTildeInPath
        guard let data = FileManager.default.contents(atPath: path) else {
            return nil
        }

        guard let stats = try? JSONDecoder().decode(StatsData.self, from: data) else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        // Try today first
        let todayActivity = stats.dailyActivity?.first { $0.date == today }
        let todayTokens = stats.dailyModelTokens?.first { $0.date == today }

        if todayActivity != nil || todayTokens != nil {
            let totalTokens = todayTokens?.tokensByModel.values.reduce(0, +) ?? 0
            return TodayStats(
                messageCount: todayActivity?.messageCount ?? 0,
                sessionCount: todayActivity?.sessionCount ?? 0,
                toolCallCount: todayActivity?.toolCallCount ?? 0,
                totalTokens: totalTokens,
                date: today,
                isToday: true
            )
        }

        // Fallback: use most recent date
        let sortedActivity = stats.dailyActivity?.sorted { $0.date > $1.date }
        guard let latest = sortedActivity?.first else {
            return nil
        }

        let latestTokens = stats.dailyModelTokens?.first { $0.date == latest.date }
        let totalTokens = latestTokens?.tokensByModel.values.reduce(0, +) ?? 0

        return TodayStats(
            messageCount: latest.messageCount,
            sessionCount: latest.sessionCount,
            toolCallCount: latest.toolCallCount,
            totalTokens: totalTokens,
            date: latest.date,
            isToday: false
        )
    }
}
