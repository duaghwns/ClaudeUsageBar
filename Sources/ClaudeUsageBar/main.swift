import AppKit

// Hide from Dock (menu bar only app)
NSApplication.shared.setActivationPolicy(.accessory)

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
