import AppKit
import Foundation

// Current app version — bump this on each release
let kAppVersion = "1.0.1"
private let kGitHubRepo = "duaghwns/ClaudeUsageBar"

class SettingsWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let settings = Settings.shared
    private var tabView: NSTabView?
    private var updateStatusLabel: NSTextField?

    // Info tab data
    private var profile: ProfileResponse?
    private var planInfo: PlanInfo?
    private var version: String?
    private var loginMethod: String?

    func updateInfo(profile: ProfileResponse?, planInfo: PlanInfo?, version: String?, loginMethod: String?) {
        self.profile = profile
        self.planInfo = planInfo
        self.version = version
        self.loginMethod = loginMethod
        // Refresh info tab if window is visible
        if let tabView = tabView, let infoItem = tabView.tabViewItems.first {
            infoItem.view?.subviews.forEach { $0.removeFromSuperview() }
            if let view = infoItem.view {
                buildInfoContent(in: view)
            }
        }
    }

    func showWindow() {
        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        w.title = L10n.tr("settings.windowTitle")
        w.center()
        w.delegate = self
        w.isReleasedWhenClosed = false
        w.backgroundColor = .white

        let contentView = NSView(frame: w.contentView!.bounds)
        contentView.autoresizingMask = [.width, .height]
        w.contentView = contentView

        buildTabView(in: contentView)

        window = w
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
        tabView = nil
        updateStatusLabel = nil
    }

    // MARK: - Tab View Construction

    private func buildTabView(in container: NSView) {
        let tv = NSTabView(frame: container.bounds)
        tv.autoresizingMask = [.width, .height]
        tv.tabViewType = .topTabsBezelBorder

        let infoTab = NSTabViewItem(identifier: "info")
        infoTab.label = L10n.tr("settings.tab.info")
        let infoView = NSView()
        infoView.autoresizingMask = [.width, .height]
        infoTab.view = infoView
        tv.addTabViewItem(infoTab)

        let displayTab = NSTabViewItem(identifier: "display")
        displayTab.label = L10n.tr("settings.tab.display")
        let displayView = NSView()
        displayView.autoresizingMask = [.width, .height]
        displayTab.view = displayView
        tv.addTabViewItem(displayTab)

        let generalTab = NSTabViewItem(identifier: "general")
        generalTab.label = L10n.tr("settings.tab.general")
        let generalView = NSView()
        generalView.autoresizingMask = [.width, .height]
        generalTab.view = generalView
        tv.addTabViewItem(generalTab)

        container.addSubview(tv)
        tabView = tv

        buildInfoContent(in: infoView)
        buildDisplayContent(in: displayView)
        buildGeneralContent(in: generalView)

        tv.selectTabViewItem(at: 0)
    }

    // MARK: - Info Tab

    private func buildInfoContent(in container: NSView) {
        let width = container.bounds.width > 0 ? container.bounds.width : 330
        var y: CGFloat = 350

        // Name
        let nameValue = profile?.account?.displayName ?? profile?.account?.fullName ?? L10n.tr("settings.info.noData")
        y = addInfoRow(L10n.tr("settings.info.name"), value: nameValue, in: container, y: y, width: width)

        // Email
        let emailValue = profile?.account?.email ?? L10n.tr("settings.info.noData")
        y = addInfoRow(L10n.tr("settings.info.email"), value: emailValue, in: container, y: y, width: width)

        // Organization
        let orgValue = profile?.organization?.name ?? L10n.tr("settings.info.noData")
        y = addInfoRow(L10n.tr("settings.info.org"), value: orgValue, in: container, y: y, width: width)

        // Plan
        let planDisplay: String
        if let org = profile?.organization {
            planDisplay = PlanInfo.formatTier(org.rateLimitTier ?? org.organizationType ?? "")
        } else if let plan = planInfo {
            planDisplay = plan.displayName
        } else {
            planDisplay = L10n.tr("settings.info.noData")
        }
        y = addInfoRow(L10n.tr("settings.info.plan"), value: planDisplay, in: container, y: y, width: width)

        // Default model with version
        let modelDisplay = defaultModelFromTier(
            tier: profile?.organization?.rateLimitTier ?? profile?.organization?.organizationType,
            subscriptionType: planInfo?.subscriptionType
        )
        y = addInfoRow(L10n.tr("settings.info.model"), value: modelDisplay, in: container, y: y, width: width)

        // Login method
        y = addInfoRow(L10n.tr("settings.info.login"), value: loginMethod ?? L10n.tr("settings.info.noData"), in: container, y: y, width: width)

        // Version
        y = addInfoRow(L10n.tr("settings.info.version"), value: version != nil ? "v\(version!)" : L10n.tr("settings.info.noData"), in: container, y: y, width: width)

        // Timezone
        y = addInfoRow(L10n.tr("settings.info.timezone"), value: TimeZone.current.identifier, in: container, y: y, width: width)

        // Region
        let locale = Locale.current
        let regionCode = locale.region?.identifier ?? locale.language.region?.identifier ?? "-"
        let regionName = Locale.current.localizedString(forRegionCode: regionCode) ?? regionCode
        y = addInfoRow(L10n.tr("settings.info.region"), value: "\(regionName) (\(regionCode))", in: container, y: y, width: width)

        y -= 12

        // App version + Update check button
        let appVersionLabel = NSTextField(labelWithString: "ClaudeUsageBar v\(kAppVersion)")
        appVersionLabel.font = NSFont.systemFont(ofSize: 11)
        appVersionLabel.textColor = .secondaryLabelColor
        appVersionLabel.frame = NSRect(x: 20, y: y - 20, width: 160, height: 16)
        container.addSubview(appVersionLabel)

        let updateBtn = NSButton(title: L10n.tr("settings.info.checkUpdate"), target: self, action: #selector(checkForUpdate))
        updateBtn.bezelStyle = .rounded
        updateBtn.controlSize = .small
        updateBtn.font = NSFont.systemFont(ofSize: 11)
        updateBtn.sizeToFit()
        updateBtn.frame = NSRect(x: width - updateBtn.frame.width - 20, y: y - 22, width: updateBtn.frame.width, height: 22)
        container.addSubview(updateBtn)

        y -= 28

        let statusLabel = NSTextField(labelWithString: "")
        statusLabel.font = NSFont.systemFont(ofSize: 11)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.frame = NSRect(x: 20, y: y - 16, width: width - 40, height: 16)
        container.addSubview(statusLabel)
        updateStatusLabel = statusLabel
    }

    // MARK: - Display Tab

    private func buildDisplayContent(in container: NSView) {
        let width = container.bounds.width > 0 ? container.bounds.width : 330
        var y: CGFloat = 310

        y = addSectionHeader(L10n.tr("settings.display"), in: container, y: y, width: width)

        y = addCheckbox(
            L10n.tr("settings.display.fiveHour"),
            checked: settings.showFiveHour,
            action: #selector(toggleFiveHour(_:)),
            in: container, y: y, width: width
        )
        y = addCheckbox(
            L10n.tr("settings.display.sevenDay"),
            checked: settings.showSevenDay,
            action: #selector(toggleSevenDay(_:)),
            in: container, y: y, width: width
        )
        y = addCheckbox(
            L10n.tr("settings.display.opus"),
            checked: settings.showOpus,
            action: #selector(toggleOpus(_:)),
            in: container, y: y, width: width
        )
        y = addCheckbox(
            L10n.tr("settings.display.sonnet"),
            checked: settings.showSonnet,
            action: #selector(toggleSonnet(_:)),
            in: container, y: y, width: width
        )

        y = addCheckbox(
            L10n.tr("settings.display.coloredStatusBar"),
            checked: settings.useColoredStatusBar,
            action: #selector(toggleColoredStatusBar(_:)),
            in: container, y: y, width: width
        )

        y -= 8

        y = addSectionHeader(L10n.tr("settings.statusBar"), in: container, y: y, width: width)

        let formatOptions: [(StatusBarFormat, String)] = [
            (.fiveHourAndWeekly, L10n.tr("settings.statusBar.fiveHourAndWeekly")),
            (.fiveHourOnly, L10n.tr("settings.statusBar.fiveHourOnly")),
            (.weeklyOnly, L10n.tr("settings.statusBar.weeklyOnly")),
            (.percentOnly, L10n.tr("settings.statusBar.percentOnly")),
        ]
        for (fmt, title) in formatOptions {
            y = addRadioButton(
                title,
                selected: settings.statusBarFormat == fmt,
                tag: StatusBarFormat.allCases.firstIndex(of: fmt)!,
                action: #selector(statusBarFormatChanged(_:)),
                in: container, y: y, width: width
            )
        }
    }

    // MARK: - General Tab

    private func buildGeneralContent(in container: NSView) {
        let width = container.bounds.width > 0 ? container.bounds.width : 330
        var y: CGFloat = 310

        y = addSectionHeader(L10n.tr("settings.refreshInterval"), in: container, y: y, width: width)

        let refreshOptions: [(RefreshInterval, String)] = [
            (.oneMinute, L10n.tr("settings.refreshInterval.1")),
            (.threeMinutes, L10n.tr("settings.refreshInterval.3")),
            (.fiveMinutes, L10n.tr("settings.refreshInterval.5")),
            (.tenMinutes, L10n.tr("settings.refreshInterval.10")),
        ]
        for (interval, title) in refreshOptions {
            y = addRadioButton(
                title,
                selected: settings.refreshInterval == interval,
                tag: 200 + RefreshInterval.allCases.firstIndex(of: interval)!,
                action: #selector(refreshIntervalChanged(_:)),
                in: container, y: y, width: width
            )
        }

        y -= 8

        y = addSectionHeader(L10n.tr("settings.language"), in: container, y: y, width: width)

        y = addRadioButton(
            L10n.tr("settings.language.ko"),
            selected: settings.language == .ko,
            tag: 100,
            action: #selector(languageChanged(_:)),
            in: container, y: y, width: width
        )
        y = addRadioButton(
            L10n.tr("settings.language.en"),
            selected: settings.language == .en,
            tag: 101,
            action: #selector(languageChanged(_:)),
            in: container, y: y, width: width
        )

        y -= 8

        y = addSectionHeader(L10n.tr("settings.general"), in: container, y: y, width: width)

        y = addCheckbox(
            L10n.tr("settings.launchAtLogin"),
            checked: LaunchAtLogin.isEnabled,
            action: #selector(toggleLaunchAtLogin(_:)),
            in: container, y: y, width: width
        )
    }

    // MARK: - UI Helpers

    private func addSectionHeader(_ text: String, in container: NSView, y: CGFloat, width: CGFloat) -> CGFloat {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.boldSystemFont(ofSize: 13)
        label.frame = NSRect(x: 20, y: y - 24, width: width - 40, height: 20)
        container.addSubview(label)
        return y - 30
    }

    private func addCheckbox(_ title: String, checked: Bool, action: Selector, in container: NSView, y: CGFloat, width: CGFloat) -> CGFloat {
        let btn = NSButton(checkboxWithTitle: title, target: self, action: action)
        btn.state = checked ? .on : .off
        btn.frame = NSRect(x: 36, y: y - 22, width: width - 56, height: 18)
        container.addSubview(btn)
        return y - 26
    }

    private func addRadioButton(_ title: String, selected: Bool, tag: Int, action: Selector, in container: NSView, y: CGFloat, width: CGFloat) -> CGFloat {
        let btn = NSButton(radioButtonWithTitle: title, target: self, action: action)
        btn.state = selected ? .on : .off
        btn.tag = tag
        btn.frame = NSRect(x: 36, y: y - 22, width: width - 56, height: 18)
        container.addSubview(btn)
        return y - 26
    }

    private func addInfoRow(_ label: String, value: String, in container: NSView, y: CGFloat, width: CGFloat) -> CGFloat {
        let labelField = NSTextField(labelWithString: label)
        labelField.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        labelField.textColor = .secondaryLabelColor
        labelField.frame = NSRect(x: 20, y: y - 20, width: 80, height: 16)
        container.addSubview(labelField)

        let valueField = NSTextField(labelWithString: value)
        valueField.font = NSFont.systemFont(ofSize: 12)
        valueField.frame = NSRect(x: 104, y: y - 20, width: width - 124, height: 16)
        valueField.lineBreakMode = .byTruncatingTail
        container.addSubview(valueField)

        return y - 24
    }

    private func defaultModelFromTier(tier: String?, subscriptionType: String?) -> String {
        let t = (tier ?? "").lowercased()
        let s = (subscriptionType ?? "").lowercased()
        if t.contains("max") || s == "max" {
            return "Claude Opus 4.6 (Default)"
        } else if t.contains("pro") || s == "pro" {
            return "Claude Sonnet 4.6 (Default)"
        } else if !t.isEmpty || !s.isEmpty {
            return "Claude Sonnet 4.6"
        }
        return L10n.tr("settings.info.noData")
    }

    // MARK: - Rebuild All Tabs

    private func rebuildAllTabs() {
        guard let tv = tabView else { return }

        window?.title = L10n.tr("settings.windowTitle")

        for item in tv.tabViewItems {
            switch item.identifier as? String {
            case "info":
                item.label = L10n.tr("settings.tab.info")
                item.view?.subviews.forEach { $0.removeFromSuperview() }
                if let view = item.view { buildInfoContent(in: view) }
            case "display":
                item.label = L10n.tr("settings.tab.display")
                item.view?.subviews.forEach { $0.removeFromSuperview() }
                if let view = item.view { buildDisplayContent(in: view) }
            case "general":
                item.label = L10n.tr("settings.tab.general")
                item.view?.subviews.forEach { $0.removeFromSuperview() }
                if let view = item.view { buildGeneralContent(in: view) }
            default:
                break
            }
        }
    }

    // MARK: - Update Check

    @objc private func checkForUpdate() {
        updateStatusLabel?.stringValue = L10n.tr("settings.update.checking")

        Task {
            do {
                let (latestVersion, downloadURL) = try await fetchLatestRelease()
                await MainActor.run {
                    if compareVersions(current: kAppVersion, latest: latestVersion) < 0 {
                        // New version available
                        updateStatusLabel?.stringValue = String(format: L10n.tr("settings.update.available"), latestVersion)

                        let alert = NSAlert()
                        alert.messageText = L10n.tr("settings.update.newVersion")
                        alert.informativeText = String(format: L10n.tr("settings.update.newVersionDetail"), latestVersion, kAppVersion)
                        alert.addButton(withTitle: L10n.tr("settings.update.download"))
                        alert.addButton(withTitle: L10n.tr("settings.update.later"))
                        alert.alertStyle = .informational

                        if alert.runModal() == .alertFirstButtonReturn {
                            if let url = downloadURL {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    } else {
                        updateStatusLabel?.stringValue = L10n.tr("settings.update.upToDate")
                    }
                }
            } catch {
                await MainActor.run {
                    updateStatusLabel?.stringValue = L10n.tr("settings.update.error")
                }
            }
        }
    }

    private func fetchLatestRelease() async throws -> (String, URL?) {
        let url = URL(string: "https://api.github.com/repos/\(kGitHubRepo)/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            // No releases yet — check tags as fallback
            return try await fetchLatestTag()
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let tagName = (json?["tag_name"] as? String ?? "").replacingOccurrences(of: "v", with: "")

        // Try to find a .zip or .dmg asset, otherwise use the html_url
        var downloadURL: URL? = nil
        if let assets = json?["assets"] as? [[String: Any]] {
            for asset in assets {
                if let name = asset["name"] as? String,
                   let dlStr = asset["browser_download_url"] as? String,
                   (name.hasSuffix(".zip") || name.hasSuffix(".dmg")) {
                    downloadURL = URL(string: dlStr)
                    break
                }
            }
        }
        if downloadURL == nil, let htmlURL = json?["html_url"] as? String {
            downloadURL = URL(string: htmlURL)
        }

        return (tagName, downloadURL)
    }

    private func fetchLatestTag() async throws -> (String, URL?) {
        let url = URL(string: "https://api.github.com/repos/\(kGitHubRepo)/tags?per_page=1")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let tags = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let first = tags.first,
              let tagName = first["name"] as? String else {
            return (kAppVersion, nil) // No tags at all, treat as up-to-date
        }

        let version = tagName.replacingOccurrences(of: "v", with: "")
        let releasePage = URL(string: "https://github.com/\(kGitHubRepo)/releases")
        return (version, releasePage)
    }

    /// Returns -1 if current < latest, 0 if equal, 1 if current > latest
    private func compareVersions(current: String, latest: String) -> Int {
        let c = current.split(separator: ".").compactMap { Int($0) }
        let l = latest.split(separator: ".").compactMap { Int($0) }
        let count = max(c.count, l.count)
        for i in 0..<count {
            let cv = i < c.count ? c[i] : 0
            let lv = i < l.count ? l[i] : 0
            if cv < lv { return -1 }
            if cv > lv { return 1 }
        }
        return 0
    }

    // MARK: - Actions

    @objc private func toggleFiveHour(_ sender: NSButton) {
        settings.showFiveHour = sender.state == .on
    }

    @objc private func toggleSevenDay(_ sender: NSButton) {
        settings.showSevenDay = sender.state == .on
    }

    @objc private func toggleOpus(_ sender: NSButton) {
        settings.showOpus = sender.state == .on
    }

    @objc private func toggleSonnet(_ sender: NSButton) {
        settings.showSonnet = sender.state == .on
    }

    @objc private func toggleColoredStatusBar(_ sender: NSButton) {
        settings.useColoredStatusBar = sender.state == .on
    }

    @objc private func statusBarFormatChanged(_ sender: NSButton) {
        let allCases = StatusBarFormat.allCases
        guard sender.tag >= 0, sender.tag < allCases.count else { return }
        settings.statusBarFormat = allCases[sender.tag]
        refreshRadioGroup(in: sender.superview, selected: sender, tagRange: 0..<allCases.count)
    }

    @objc private func languageChanged(_ sender: NSButton) {
        switch sender.tag {
        case 100: settings.language = .ko
        case 101: settings.language = .en
        default: break
        }
        refreshRadioGroup(in: sender.superview, selected: sender, tagRange: 100..<102)
        rebuildAllTabs()
    }

    @objc private func refreshIntervalChanged(_ sender: NSButton) {
        let idx = sender.tag - 200
        let allCases = RefreshInterval.allCases
        guard idx >= 0, idx < allCases.count else { return }
        settings.refreshInterval = allCases[idx]
        refreshRadioGroup(in: sender.superview, selected: sender, tagRange: 200..<(200 + allCases.count))
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSButton) {
        LaunchAtLogin.isEnabled = sender.state == .on
    }

    private func refreshRadioGroup(in view: NSView?, selected: NSButton, tagRange: Range<Int>) {
        guard let view = view else { return }
        for subview in view.subviews {
            if let btn = subview as? NSButton,
               btn !== selected,
               tagRange.contains(btn.tag),
               btn.bezelStyle == selected.bezelStyle
            {
                btn.state = .off
            }
        }
    }
}

// MARK: - Launch at Login (LaunchAgent)

struct LaunchAtLogin {
    private static let label = "com.claudeusagebar.launcher"

    private static var plistPath: String {
        let home = NSHomeDirectory()
        return "\(home)/Library/LaunchAgents/\(label).plist"
    }

    private static var executablePath: String {
        return ProcessInfo.processInfo.arguments[0]
    }

    static var isEnabled: Bool {
        get {
            return FileManager.default.fileExists(atPath: plistPath)
        }
        set {
            if newValue {
                install()
            } else {
                uninstall()
            }
        }
    }

    private static func install() {
        let plist: [String: Any] = [
            "Label": label,
            "ProgramArguments": [executablePath],
            "RunAtLoad": true,
            "KeepAlive": false,
        ]

        let dir = (plistPath as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

        if let data = try? PropertyListSerialization.data(
            fromPropertyList: plist, format: .xml, options: 0
        ) {
            FileManager.default.createFile(atPath: plistPath, contents: data)
        }
    }

    private static func uninstall() {
        try? FileManager.default.removeItem(atPath: plistPath)
    }
}
