import Foundation

struct L10n {
    private static let strings: [AppLanguage: [String: String]] = [
        .ko: [
            // Header
            "header.title": "── Claude Usage ──",

            // Plan
            "plan.label": "Plan: %@",

            // Usage (menu format)
            "usage.fiveHour": "5시간 사용률: %.1f%%",
            "usage.sevenDay": "주간 사용률:   %.1f%%",
            "usage.opus": "Opus 사용률:   %.1f%%",
            "usage.loading": "로딩 중...",

            // Usage (popover labels)
            "usage.label.fiveHour": "Current Session (5hr)",
            "usage.label.sevenDay": "Week",
            "usage.label.opus": "Opus",
            "usage.label.sonnet": "Sonnet",

            // Reset time (menu: suffix style)
            "usage.resetSoon": "곧 리셋",
            "usage.resetMinutes": "%d분 후 리셋",
            "usage.resetHoursMin": "%d시간 %d분 후 리셋",
            "usage.resetHours": "%d시간 후 리셋",
            "usage.resetDaysHours": "%d일 %d시간 후 리셋",
            "usage.resetDays": "%d일 후 리셋",

            // Reset time (popover: prefix style)
            "usage.resetPrefixMinutes": "리셋: %d분 후",
            "usage.resetPrefixHoursMin": "리셋: %d시간 %d분 후",
            "usage.resetPrefixHours": "리셋: %d시간 후",
            "usage.resetPrefixDaysHours": "리셋: %d일 %d시간 후",
            "usage.resetPrefixDays": "리셋: %d일 후",

            // Stats (menu format)
            "stats.messages": "오늘 메시지: %@개",
            "stats.tokens": "오늘 토큰:   %@",
            "stats.sessions": "오늘 세션:   %d회",
            "stats.tools": "오늘 도구:   %@회",
            "stats.none": "로컬 통계 없음",

            // Stats (popover labels)
            "stats.label.messages": "메시지",
            "stats.label.tokens": "토큰",
            "stats.label.sessions": "세션",
            "stats.label.tools": "도구 호출",
            "stats.label.date": "(%@ 기준)",

            // Actions
            "action.refresh": "↻ 새로고침",
            "action.autoRefresh": "⚙ 자동 새로고침: 5분",
            "action.autoRefreshShort.1": "1분마다 업데이트",
            "action.autoRefreshShort.3": "3분마다 업데이트",
            "action.autoRefreshShort.5": "5분마다 업데이트",
            "action.autoRefreshShort.10": "10분마다 업데이트",
            "action.quit": "종료",

            // Refresh interval
            "settings.refreshInterval": "새로고침 주기",
            "settings.refreshInterval.1": "1분",
            "settings.refreshInterval.3": "3분",
            "settings.refreshInterval.5": "5분",
            "settings.refreshInterval.10": "10분",

            // Settings
            "settings.title": "⚙ 설정",
            "settings.windowTitle": "설정",
            "settings.general": "일반",
            "settings.launchAtLogin": "부팅 시 실행",
            "settings.display": "표시 항목",
            "settings.display.fiveHour": "5시간 사용률",
            "settings.display.sevenDay": "주간 사용률",
            "settings.display.opus": "Opus 사용률",
            "settings.display.sonnet": "Sonnet 사용률",
            "settings.display.stats": "로컬 통계",
            "settings.statusBar": "상태바 표시",
            "settings.statusBar.fiveHourAndWeekly": "5시간 + 주간",
            "settings.statusBar.fiveHourOnly": "5시간만",
            "settings.statusBar.weeklyOnly": "주간만",
            "settings.statusBar.percentOnly": "숫자만",
            "settings.language": "언어",
            "settings.language.ko": "한국어",
            "settings.language.en": "English",

            // Errors
            "error.keychainNotFound": "Keychain에서 Claude Code 인증 정보를 찾을 수 없습니다",
            "error.unexpectedData": "Keychain 데이터 형식이 올바르지 않습니다",
            "error.tokenExpired": "OAuth 토큰이 만료되었습니다. Claude Code에서 다시 로그인하세요",
            "error.keychainOS": "Keychain 오류: %d",
            "error.apiHTTP": "API 오류: HTTP %d",
            "error.network": "네트워크 오류: %@",
            "error.decode": "응답 파싱 오류: %@",
        ],
        .en: [
            // Header
            "header.title": "── Claude Usage ──",

            // Plan
            "plan.label": "Plan: %@",

            // Usage (menu format)
            "usage.fiveHour": "5h Usage:    %.1f%%",
            "usage.sevenDay": "Weekly Usage: %.1f%%",
            "usage.opus": "Opus Usage:   %.1f%%",
            "usage.loading": "Loading...",

            // Usage (popover labels)
            "usage.label.fiveHour": "Current Session (5hr)",
            "usage.label.sevenDay": "Week",
            "usage.label.opus": "Opus",
            "usage.label.sonnet": "Sonnet",

            // Reset time (menu)
            "usage.resetSoon": "Resets soon",
            "usage.resetMinutes": "Resets in %dm",
            "usage.resetHoursMin": "Resets in %dh %dm",
            "usage.resetHours": "Resets in %dh",
            "usage.resetDaysHours": "Resets in %dd %dh",
            "usage.resetDays": "Resets in %dd",

            // Reset time (popover)
            "usage.resetPrefixMinutes": "Resets in: %dm",
            "usage.resetPrefixHoursMin": "Resets in: %dh %dm",
            "usage.resetPrefixHours": "Resets in: %dh",
            "usage.resetPrefixDaysHours": "Resets in: %dd %dh",
            "usage.resetPrefixDays": "Resets in: %dd",

            // Stats (menu format)
            "stats.messages": "Messages today: %@",
            "stats.tokens": "Tokens today:   %@",
            "stats.sessions": "Sessions today: %d",
            "stats.tools": "Tool calls today: %@",
            "stats.none": "No local stats",

            // Stats (popover labels)
            "stats.label.messages": "Messages",
            "stats.label.tokens": "Tokens",
            "stats.label.sessions": "Sessions",
            "stats.label.tools": "Tool Calls",
            "stats.label.date": "(as of %@)",

            // Actions
            "action.refresh": "↻ Refresh",
            "action.autoRefresh": "⚙ Auto-refresh: 5min",
            "action.autoRefreshShort.1": "Updates every 1min",
            "action.autoRefreshShort.3": "Updates every 3min",
            "action.autoRefreshShort.5": "Updates every 5min",
            "action.autoRefreshShort.10": "Updates every 10min",
            "action.quit": "Quit",

            // Refresh interval
            "settings.refreshInterval": "Refresh Interval",
            "settings.refreshInterval.1": "1 min",
            "settings.refreshInterval.3": "3 min",
            "settings.refreshInterval.5": "5 min",
            "settings.refreshInterval.10": "10 min",

            // Settings
            "settings.title": "⚙ Settings",
            "settings.windowTitle": "Settings",
            "settings.general": "General",
            "settings.launchAtLogin": "Launch at Login",
            "settings.display": "Display Items",
            "settings.display.fiveHour": "5-Hour Usage",
            "settings.display.sevenDay": "Weekly Usage",
            "settings.display.opus": "Opus Usage",
            "settings.display.sonnet": "Sonnet Usage",
            "settings.display.stats": "Local Stats",
            "settings.statusBar": "Status Bar",
            "settings.statusBar.fiveHourAndWeekly": "5h + Weekly",
            "settings.statusBar.fiveHourOnly": "5h Only",
            "settings.statusBar.weeklyOnly": "Weekly Only",
            "settings.statusBar.percentOnly": "Number Only",
            "settings.language": "Language",
            "settings.language.ko": "한국어",
            "settings.language.en": "English",

            // Errors
            "error.keychainNotFound": "Claude Code credentials not found in Keychain",
            "error.unexpectedData": "Unexpected Keychain data format",
            "error.tokenExpired": "OAuth token expired. Please log in again in Claude Code",
            "error.keychainOS": "Keychain error: %d",
            "error.apiHTTP": "API error: HTTP %d",
            "error.network": "Network error: %@",
            "error.decode": "Response parsing error: %@",
        ],
    ]

    static func tr(_ key: String) -> String {
        let lang = Settings.shared.language
        if let value = strings[lang]?[key] {
            return value
        }
        if let value = strings[.ko]?[key] {
            return value
        }
        return key
    }
}
