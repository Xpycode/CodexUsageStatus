import AppKit
import SwiftUI

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = UsageStore(); private let panel = UsagePanelController(); private var clickAway: Any?
    func applicationDidFinishLaunching(_: Notification) {
        GlobalHotKey.shared.register { [weak self] in self?.toggle() }
        clickAway = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in Task { @MainActor in self?.panel.hide() } }
        // A Dockless agent otherwise offers no confirmation that it launched.
        // Subsequent use is exclusively through the global hotkey.
        toggle()
    }
    func applicationWillTerminate(_: Notification) { GlobalHotKey.shared.unregister(); if let clickAway { NSEvent.removeMonitor(clickAway) } }
    private func toggle() { if panel.isVisible { panel.hide() } else { panel.show { UsageStatusView(store: store) }; store.refresh() } }
}
