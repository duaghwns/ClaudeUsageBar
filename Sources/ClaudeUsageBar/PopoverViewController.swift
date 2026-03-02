import AppKit
import Foundation

// MARK: - Popover Data

struct PopoverData {
    var usage: UsageResponse?
    var planInfo: PlanInfo?
    var profile: ProfileResponse?
    var error: String?
    var version: String?
    var loginMethod: String?
}

// MARK: - Popover Actions Protocol

protocol PopoverActions: AnyObject {
    func popoverDidRequestRefresh()
    func popoverDidRequestQuit()
    func popoverDidRequestSettings()
}

// MARK: - Frosted Glass Background View

class FrostedView: NSView {
    private let vibrancy = NSVisualEffectView()
    private let tintLayer = CALayer()

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        vibrancy.material = .hudWindow
        vibrancy.blendingMode = .behindWindow
        vibrancy.state = .active
        vibrancy.autoresizingMask = [.width, .height]
        vibrancy.frame = bounds
        addSubview(vibrancy)

        wantsLayer = true
        tintLayer.backgroundColor = NSColor(red: 0.10, green: 0.11, blue: 0.28, alpha: 0.55).cgColor
        layer?.addSublayer(tintLayer)
    }

    override func layout() {
        super.layout()
        vibrancy.frame = bounds
        tintLayer.frame = bounds
    }
}

// MARK: - Progress Bar View

class ProgressBarView: NSView {
    var progress: Double = 0 { didSet { needsDisplay = true } }
    var barColor: NSColor = .systemGreen { didSet { needsDisplay = true } }

    private let trackColor = NSColor(white: 1.0, alpha: 0.12)
    private let barHeight: CGFloat = 6

    override func draw(_ dirtyRect: NSRect) {
        let trackRect = NSRect(x: 0, y: (bounds.height - barHeight) / 2,
                               width: bounds.width, height: barHeight)
        let trackPath = NSBezierPath(roundedRect: trackRect, xRadius: barHeight / 2, yRadius: barHeight / 2)
        trackColor.setFill()
        trackPath.fill()

        let fillWidth = max(0, min(bounds.width, bounds.width * CGFloat(progress / 100.0)))
        if fillWidth > 0 {
            let fillRect = NSRect(x: 0, y: (bounds.height - barHeight) / 2,
                                  width: fillWidth, height: barHeight)
            let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: barHeight / 2, yRadius: barHeight / 2)
            barColor.setFill()
            fillPath.fill()
        }
    }
}

// MARK: - Popover View Controller

class PopoverViewController: NSViewController {
    weak var delegate: PopoverActions?

    private let settings = Settings.shared
    private var data = PopoverData()

    private let popoverWidth: CGFloat = 300
    private let contentPadding: CGFloat = 16

    // Colors
    private let textWhite = NSColor.white
    private let textDim = NSColor(white: 1.0, alpha: 0.55)
    private let accentGreen = NSColor(red: 0.30, green: 0.85, blue: 0.45, alpha: 1.0)

    override func loadView() {
        let container = FrostedView(frame: NSRect(x: 0, y: 0, width: popoverWidth, height: 400))
        self.view = container
    }

    func update(with newData: PopoverData) {
        data = newData
        rebuildContent()
    }

    // MARK: - Content Rebuild

    private func rebuildContent() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let innerWidth = popoverWidth - contentPadding * 2

        // Build stack OFF-SCREEN first to measure natural height
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.edgeInsets = NSEdgeInsets(top: contentPadding, left: contentPadding,
                                        bottom: contentPadding, right: contentPadding)

        // Set width for measurement (not yet added to view)
        let widthConstraint = stack.widthAnchor.constraint(equalToConstant: popoverWidth)
        widthConstraint.isActive = true

        // === Build all content ===

        // Header
        addHeader(to: stack, width: innerWidth)
        addSpacer(to: stack, height: 6)

        // Account info
        if let profile = data.profile {
            if let name = profile.account?.displayName ?? profile.account?.fullName {
                let nameLabel = makeLabel(name, size: 13, color: textWhite, weight: .medium)
                stack.addArrangedSubview(nameLabel)
            }
            if let email = profile.account?.email {
                let emailLabel = makeLabel(email, size: 11, color: textDim)
                stack.addArrangedSubview(emailLabel)
            }
            addSpacer(to: stack, height: 2)
        }

        // Plan info
        if let profile = data.profile, let org = profile.organization {
            let tierDisplay = PlanInfo.formatTier(org.rateLimitTier ?? org.organizationType ?? "")
            let planLabel = makeLabel(
                String(format: L10n.tr("plan.label"), tierDisplay),
                size: 11, color: textDim
            )
            stack.addArrangedSubview(planLabel)
        } else if let plan = data.planInfo {
            let planLabel = makeLabel(
                String(format: L10n.tr("plan.label"), plan.displayName),
                size: 11, color: textDim
            )
            stack.addArrangedSubview(planLabel)
        }

        // Login method
        if let login = data.loginMethod {
            let loginLabel = makeLabel(login, size: 11, color: textDim)
            stack.addArrangedSubview(loginLabel)
        }

        // Version + Timezone
        if let version = data.version {
            let tz = TimeZone.current.identifier
            let versionLabel = makeLabel("v\(version) (\(tz))", size: 11, color: textDim)
            stack.addArrangedSubview(versionLabel)
        }

        // Usage sections
        if let usage = data.usage {
            if settings.showFiveHour {
                addSpacer(to: stack, height: 12)
                addUsageSection(
                    to: stack, width: innerWidth,
                    title: L10n.tr("usage.label.fiveHour"),
                    utilization: usage.fiveHour.utilization,
                    resetTime: formatResetTime(usage.fiveHour.resetsAt)
                )
            }

            if settings.showSevenDay {
                addSpacer(to: stack, height: 16)
                addUsageSection(
                    to: stack, width: innerWidth,
                    title: L10n.tr("usage.label.sevenDay"),
                    utilization: usage.sevenDay.utilization,
                    resetTime: formatResetTime(usage.sevenDay.resetsAt)
                )
            }

            if settings.showOpus {
                addSpacer(to: stack, height: 16)
                addUsageSection(
                    to: stack, width: innerWidth,
                    title: L10n.tr("usage.label.opus"),
                    utilization: usage.sevenDayOpus?.utilization ?? 0,
                    resetTime: formatResetTime(usage.sevenDayOpus?.resetsAt)
                )
            }

            if settings.showSonnet {
                addSpacer(to: stack, height: 16)
                addUsageSection(
                    to: stack, width: innerWidth,
                    title: L10n.tr("usage.label.sonnet"),
                    utilization: usage.sevenDaySonnet?.utilization ?? 0,
                    resetTime: formatResetTime(usage.sevenDaySonnet?.resetsAt)
                )
            }
        } else if let error = data.error {
            addSpacer(to: stack, height: 8)
            let errorLabel = makeLabel(error, size: 12, color: NSColor.systemRed)
            errorLabel.preferredMaxLayoutWidth = innerWidth
            errorLabel.lineBreakMode = .byWordWrapping
            stack.addArrangedSubview(errorLabel)
        } else {
            addSpacer(to: stack, height: 8)
            let loadingLabel = makeLabel(L10n.tr("usage.loading"), size: 12, color: textDim)
            stack.addArrangedSubview(loadingLabel)
        }

        // Separator
        addSpacer(to: stack, height: 16)
        addSeparator(to: stack, width: innerWidth)
        addSpacer(to: stack, height: 8)

        // Open at login
        addLoginCheckbox(to: stack)
        addSpacer(to: stack, height: 12)

        // Footer
        addFooter(to: stack, width: innerWidth)

        // === Measure natural size ===
        let fittingHeight = stack.fittingSize.height

        // Remove temporary width constraint
        widthConstraint.isActive = false

        // Set preferred size BEFORE adding to view
        preferredContentSize = NSSize(width: popoverWidth, height: fittingHeight)

        // Add to view and pin to all edges
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Header

    private func addHeader(to stack: NSStackView, width: CGFloat) {
        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.distribution = .fill
        row.translatesAutoresizingMaskIntoConstraints = false

        let title = makeLabel("Claude Usage", size: 16, color: textWhite, weight: .bold)
        row.addArrangedSubview(title)

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        row.addArrangedSubview(spacer)

        let settingsBtn = makeIconButton("⚙", action: #selector(settingsTapped))
        row.addArrangedSubview(settingsBtn)

        let refreshBtn = makeIconButton("↻", action: #selector(refreshTapped))
        row.addArrangedSubview(refreshBtn)

        stack.addArrangedSubview(row)
        row.widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    // MARK: - Usage Section

    private func addUsageSection(to stack: NSStackView, width: CGFloat,
                                  title: String, utilization: Double, resetTime: String?) {
        let barColor = colorForUtilization(utilization)

        // Row: icon + title + percentage
        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 6
        row.translatesAutoresizingMaskIntoConstraints = false

        let icon = makeStatusIcon(utilization: utilization)
        row.addArrangedSubview(icon)

        let titleLabel = makeLabel(title, size: 13, color: textWhite, weight: .medium)
        row.addArrangedSubview(titleLabel)

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        row.addArrangedSubview(spacer)

        let pctLabel = makeLabel(String(format: "%.0f%%", utilization), size: 13, color: barColor, weight: .semibold)
        row.addArrangedSubview(pctLabel)

        stack.addArrangedSubview(row)
        row.widthAnchor.constraint(equalToConstant: width).isActive = true

        // Progress bar
        addSpacer(to: stack, height: 4)
        let progressBar = ProgressBarView()
        progressBar.progress = utilization
        progressBar.barColor = barColor
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(progressBar)
        NSLayoutConstraint.activate([
            progressBar.widthAnchor.constraint(equalToConstant: width),
            progressBar.heightAnchor.constraint(equalToConstant: 8),
        ])

        // Reset time
        if let resetStr = resetTime {
            addSpacer(to: stack, height: 2)
            let resetLabel = makeLabel(resetStr, size: 11, color: textDim)
            stack.addArrangedSubview(resetLabel)
        }
    }

    // MARK: - Login Checkbox

    private func addLoginCheckbox(to stack: NSStackView) {
        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 6
        row.translatesAutoresizingMaskIntoConstraints = false

        let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(loginToggled(_:)))
        checkbox.state = LaunchAtLogin.isEnabled ? .on : .off
        checkbox.contentTintColor = accentGreen
        row.addArrangedSubview(checkbox)

        let label = makeLabel(L10n.tr("settings.launchAtLogin"), size: 12, color: textWhite)
        row.addArrangedSubview(label)

        stack.addArrangedSubview(row)
    }

    // MARK: - Footer

    private func addFooter(to stack: NSStackView, width: CGFloat) {
        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.translatesAutoresizingMaskIntoConstraints = false

        let refreshKey: String
        switch settings.refreshInterval {
        case .oneMinute: refreshKey = "action.autoRefreshShort.1"
        case .threeMinutes: refreshKey = "action.autoRefreshShort.3"
        case .fiveMinutes: refreshKey = "action.autoRefreshShort.5"
        case .tenMinutes: refreshKey = "action.autoRefreshShort.10"
        }
        let updateLabel = makeLabel(L10n.tr(refreshKey), size: 11, color: textDim)
        row.addArrangedSubview(updateLabel)

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        row.addArrangedSubview(spacer)

        let quitBtn = NSButton(title: L10n.tr("action.quit"), target: self, action: #selector(quitTapped))
        quitBtn.isBordered = false
        quitBtn.contentTintColor = accentGreen
        quitBtn.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        row.addArrangedSubview(quitBtn)

        stack.addArrangedSubview(row)
        row.widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    // MARK: - Helpers

    private func makeLabel(_ text: String, size: CGFloat, color: NSColor,
                           weight: NSFont.Weight = .regular) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.backgroundColor = .clear
        label.isBezeled = false
        label.isEditable = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeIconButton(_ symbol: String, action: Selector) -> NSButton {
        let btn = NSButton(title: symbol, target: self, action: action)
        btn.isBordered = false
        btn.font = NSFont.systemFont(ofSize: 16)
        btn.contentTintColor = NSColor(white: 1.0, alpha: 0.7)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 28).isActive = true
        return btn
    }

    private func makeStatusIcon(utilization: Double) -> NSView {
        let size: CGFloat = 12
        let container = NSView(frame: NSRect(x: 0, y: 0, width: size, height: size))
        container.translatesAutoresizingMaskIntoConstraints = false
        container.wantsLayer = true
        container.layer?.cornerRadius = size / 2
        container.layer?.backgroundColor = colorForUtilization(utilization).cgColor

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: size),
            container.heightAnchor.constraint(equalToConstant: size),
        ])

        return container
    }

    private func colorForUtilization(_ pct: Double) -> NSColor {
        if pct >= 95 { return NSColor.systemRed }
        if pct >= 80 { return NSColor.systemOrange }
        return accentGreen
    }

    private func addSpacer(to stack: NSStackView, height: CGFloat) {
        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        stack.addArrangedSubview(spacer)
    }

    private func addSeparator(to stack: NSStackView, width: CGFloat) {
        let sep = NSView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.wantsLayer = true
        sep.layer?.backgroundColor = NSColor(white: 1.0, alpha: 0.15).cgColor
        NSLayoutConstraint.activate([
            sep.widthAnchor.constraint(equalToConstant: width),
            sep.heightAnchor.constraint(equalToConstant: 1),
        ])
        stack.addArrangedSubview(sep)
    }

    // MARK: - Reset Time Formatting

    private func formatResetTime(_ isoString: String?) -> String? {
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
        guard interval > 0 else { return L10n.tr("usage.resetSoon") }

        let totalMinutes = Int(interval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        let days = hours / 24
        let remainingHours = hours % 24

        if days > 0 {
            if remainingHours > 0 {
                return String(format: L10n.tr("usage.resetPrefixDaysHours"), days, remainingHours)
            }
            return String(format: L10n.tr("usage.resetPrefixDays"), days)
        } else if hours > 0 {
            if minutes > 0 {
                return String(format: L10n.tr("usage.resetPrefixHoursMin"), hours, minutes)
            }
            return String(format: L10n.tr("usage.resetPrefixHours"), hours)
        } else {
            return String(format: L10n.tr("usage.resetPrefixMinutes"), minutes)
        }
    }

    // MARK: - Actions

    @objc private func refreshTapped() {
        delegate?.popoverDidRequestRefresh()
    }

    @objc private func quitTapped() {
        delegate?.popoverDidRequestQuit()
    }

    @objc private func settingsTapped() {
        delegate?.popoverDidRequestSettings()
    }

    @objc private func loginToggled(_ sender: NSButton) {
        LaunchAtLogin.isEnabled = sender.state == .on
    }
}
