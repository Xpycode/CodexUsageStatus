import AppKit
import SwiftUI

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = UsageStore(); private let panel = UsagePanelController(); private var clickAway: Any?
    func applicationDidFinishLaunching(_: Notification) {
        GlobalHotKey.shared.register { [weak self] in self?.toggle() }
        panel.menuProvider = { [weak self] in self?.makeMenu() ?? NSMenu() }
        clickAway = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in Task { @MainActor in self?.panel.hide() } }
        // A Dockless agent otherwise offers no confirmation that it launched.
        // Subsequent use is exclusively through the global hotkey.
        toggle()
    }
    func applicationWillTerminate(_: Notification) { GlobalHotKey.shared.unregister(); if let clickAway { NSEvent.removeMonitor(clickAway) } }
    private func toggle() { if panel.isVisible { panel.hide() } else { panel.show { UsageStatusView(store: store) }; store.refresh() } }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: "Restart Codex Usage Status", action: #selector(restart), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Codex Usage Status", action: #selector(quit), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        return menu
    }

    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func restart() {
        NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: .init()) { _, error in
            guard error == nil else { return }
            DispatchQueue.main.async { NSApp.terminate(nil) }
        }
    }
}
