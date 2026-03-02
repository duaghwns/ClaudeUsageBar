import AppKit
import Foundation

class SettingsWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let settings = Settings.shared

    func showWindow() {
        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 520),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        w.title = L10n.tr("settings.windowTitle")
        w.center()
        w.delegate = self
        w.isReleasedWhenClosed = false

        let contentView = NSView(frame: w.contentView!.bounds)
        contentView.autoresizingMask = [.width, .height]
        w.contentView = contentView

        buildUI(in: contentView)

        window = w
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
    }

    // MARK: - UI Construction

    private func buildUI(in container: NSView) {
        let width = container.bounds.width
        var y: CGFloat = container.bounds.height - 10

        // === Display Items Section ===
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

        y -= 8

        // === Status Bar Format Section ===
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

        y -= 8

        // === Refresh Interval Section ===
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

        // === Language Section ===
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

        // === General Section ===
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

    @objc private func statusBarFormatChanged(_ sender: NSButton) {
        let allCases = StatusBarFormat.allCases
        guard sender.tag >= 0, sender.tag < allCases.count else { return }
        settings.statusBarFormat = allCases[sender.tag]
        // Deselect other radio buttons in same group
        refreshRadioGroup(in: sender.superview, selected: sender, tagRange: 0..<allCases.count)
    }

    @objc private func languageChanged(_ sender: NSButton) {
        switch sender.tag {
        case 100: settings.language = .ko
        case 101: settings.language = .en
        default: break
        }
        refreshRadioGroup(in: sender.superview, selected: sender, tagRange: 100..<102)
        // Rebuild the entire window with new language
        if let w = window {
            w.title = L10n.tr("settings.windowTitle")
            w.contentView?.subviews.forEach { $0.removeFromSuperview() }
            buildUI(in: w.contentView!)
        }
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
