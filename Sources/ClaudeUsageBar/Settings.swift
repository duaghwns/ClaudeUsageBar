import Foundation

enum AppLanguage: String, CaseIterable {
    case ko
    case en
}

enum StatusBarFormat: String, CaseIterable {
    case fiveHourOnly
    case fiveHourAndWeekly
    case weeklyOnly
    case percentOnly
}

enum RefreshInterval: Int, CaseIterable {
    case oneMinute = 60
    case threeMinutes = 180
    case fiveMinutes = 300
    case tenMinutes = 600

    var seconds: TimeInterval { TimeInterval(rawValue) }
}

final class Settings {
    static let shared = Settings()

    static let didChangeNotification = Notification.Name("SettingsDidChange")

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let language = "app_language"
        static let showFiveHour = "show_five_hour"
        static let showSevenDay = "show_seven_day"
        static let showOpus = "show_opus"
        static let showSonnet = "show_sonnet"
        static let statusBarFormat = "status_bar_format"
        static let refreshInterval = "refresh_interval"
        static let useColoredStatusBar = "use_colored_status_bar"
    }

    private init() {
        defaults.register(defaults: [
            Keys.language: AppLanguage.ko.rawValue,
            Keys.showFiveHour: true,
            Keys.showSevenDay: true,
            Keys.showOpus: true,
            Keys.showSonnet: true,
            Keys.statusBarFormat: StatusBarFormat.fiveHourAndWeekly.rawValue,
            Keys.refreshInterval: RefreshInterval.fiveMinutes.rawValue,
            Keys.useColoredStatusBar: true,
        ])
    }

    var language: AppLanguage {
        get { AppLanguage(rawValue: defaults.string(forKey: Keys.language) ?? "ko") ?? .ko }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.language)
            notifyChange()
        }
    }

    var showFiveHour: Bool {
        get { defaults.bool(forKey: Keys.showFiveHour) }
        set { defaults.set(newValue, forKey: Keys.showFiveHour); notifyChange() }
    }

    var showSevenDay: Bool {
        get { defaults.bool(forKey: Keys.showSevenDay) }
        set { defaults.set(newValue, forKey: Keys.showSevenDay); notifyChange() }
    }

    var showOpus: Bool {
        get { defaults.bool(forKey: Keys.showOpus) }
        set { defaults.set(newValue, forKey: Keys.showOpus); notifyChange() }
    }

    var showSonnet: Bool {
        get { defaults.bool(forKey: Keys.showSonnet) }
        set { defaults.set(newValue, forKey: Keys.showSonnet); notifyChange() }
    }

    var statusBarFormat: StatusBarFormat {
        get { StatusBarFormat(rawValue: defaults.string(forKey: Keys.statusBarFormat) ?? "") ?? .fiveHourAndWeekly }
        set { defaults.set(newValue.rawValue, forKey: Keys.statusBarFormat); notifyChange() }
    }

    var useColoredStatusBar: Bool {
        get { defaults.bool(forKey: Keys.useColoredStatusBar) }
        set { defaults.set(newValue, forKey: Keys.useColoredStatusBar); notifyChange() }
    }

    var refreshInterval: RefreshInterval {
        get { RefreshInterval(rawValue: defaults.integer(forKey: Keys.refreshInterval)) ?? .fiveMinutes }
        set { defaults.set(newValue.rawValue, forKey: Keys.refreshInterval); notifyChange() }
    }

    private func notifyChange() {
        NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil)
    }
}
