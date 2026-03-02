import AppKit
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate, PopoverActions {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var popoverVC: PopoverViewController!
    private var refreshTimer: Timer?
    private let api = UsageAPI()

    private var lastUsage: UsageResponse?
    private var lastError: String?
    private var lastPlanInfo: PlanInfo?
    private var lastProfile: ProfileResponse?
    private var cachedVersion: String?
    private var cachedLoginMethod: String?

    private let settings = Settings.shared
    private let settingsWindowController = SettingsWindowController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusBarTitle(text: "C:--  W:--")

        // Setup popover
        popoverVC = PopoverViewController()
        popoverVC.delegate = self

        popover = NSPopover()
        popover.contentViewController = popoverVC
        popover.behavior = .transient
        popover.animates = true

        // Button click to toggle popover
        if let button = statusItem.button {
            button.action = #selector(statusBarClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Observe settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange),
            name: Settings.didChangeNotification,
            object: nil
        )

        // Load static info once
        cachedVersion = ClaudeCodeInfo.getVersion()
        cachedLoginMethod = ClaudeCodeInfo.getLoginMethod()

        refresh()
        startAutoRefresh()
    }

    // MARK: - Status Bar Click

    @objc private func statusBarClicked() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            refresh()
            updatePopover()
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    // MARK: - Settings Change

    @objc private func settingsDidChange() {
        updateStatusBarText()
        updatePopover()
        restartAutoRefresh()
    }

    // MARK: - Popover Update

    private func updatePopover() {
        popoverVC.update(with: PopoverData(
            usage: lastUsage,
            planInfo: lastPlanInfo,
            profile: lastProfile,
            error: lastError,
            version: cachedVersion,
            loginMethod: cachedLoginMethod
        ))
    }

    // MARK: - PopoverActions

    func popoverDidRequestRefresh() {
        refresh()
    }

    func popoverDidRequestQuit() {
        NSApplication.shared.terminate(nil)
    }

    func popoverDidRequestSettings() {
        popover.performClose(nil)
        settingsWindowController.updateInfo(
            profile: lastProfile,
            planInfo: lastPlanInfo,
            version: cachedVersion,
            loginMethod: cachedLoginMethod
        )
        settingsWindowController.showWindow()
    }

    // MARK: - Menu Bar Title

    private func colorForUtilization(_ pct: Double) -> NSColor {
        if pct >= 95 {
            return NSColor.systemRed
        } else if pct >= 80 {
            return NSColor.systemOrange
        }
        return NSColor.systemGreen
    }

    private func updateStatusBarTitle(text: String, fiveHour: Double? = nil) {
        guard let button = statusItem.button else { return }

        button.image = nil

        let attributed = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: attributed.length)

        var color = NSColor.labelColor
        if let pct = fiveHour {
            color = colorForUtilization(pct)
        }

        attributed.addAttribute(.foregroundColor, value: color, range: fullRange)
        attributed.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular), range: fullRange)
        button.attributedTitle = attributed
    }

    private func updateStatusBarText() {
        guard let usage = lastUsage else { return }
        let fiveHour = usage.fiveHour.utilization
        let weekly = usage.sevenDay.utilization

        let text: String
        switch settings.statusBarFormat {
        case .fiveHourOnly:
            text = String(format: "C:%.0f%%", fiveHour)
        case .fiveHourAndWeekly:
            text = String(format: "C:%.0f%%  W:%.0f%%", fiveHour, weekly)
        case .weeklyOnly:
            text = String(format: "W:%.0f%%", weekly)
        case .percentOnly:
            text = String(format: "%.0f%%", fiveHour)
        }
        updateStatusBarTitle(text: text, fiveHour: fiveHour)
    }

    // MARK: - Data Fetching

    private func refresh() {
        // Load plan info
        lastPlanInfo = KeychainHelper.getPlanInfo()

        // Update popover immediately with cached data
        updatePopover()

        // Fetch API data asynchronously
        Task {
            do {
                let token = try KeychainHelper.getOAuthToken()

                // Fetch usage and profile in parallel
                async let usageTask = api.fetchUsage(token: token)
                async let profileTask = api.fetchProfile(token: token)

                let usage = try await usageTask
                let profile = try? await profileTask

                await MainActor.run {
                    self.lastUsage = usage
                    self.lastProfile = profile
                    self.lastError = nil
                    self.updateStatusBarText()
                    self.updatePopover()
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.updateStatusBarTitle(text: "⚠")
                    self.updatePopover()
                }
            }
        }
    }

    // MARK: - Auto Refresh

    private func startAutoRefresh() {
        let interval = settings.refreshInterval.seconds
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    private func restartAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        startAutoRefresh()
    }
}
