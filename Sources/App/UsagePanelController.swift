import AppKit
import SwiftUI
private final class Host<V: View>: NSHostingView<V> {
    var menuProvider: (() -> NSMenu)?
    override func acceptsFirstMouse(for: NSEvent?) -> Bool { true }
    override func rightMouseDown(with event: NSEvent) {
        guard let menu = menuProvider?() else { return super.rightMouseDown(with: event) }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
}
@MainActor final class UsagePanelController {
    private var panel: NSPanel?; var isVisible: Bool { panel?.isVisible ?? false }
    var menuProvider: (() -> NSMenu)?
    func show<V: View>(@ViewBuilder _ view: () -> V) { let host = Host(rootView: view()); host.menuProvider = menuProvider; let size = host.fittingSize; let p = NSPanel(contentRect: NSRect(origin: .zero, size: size), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false); p.level = .floating; p.isOpaque = false; p.backgroundColor = .clear; p.hasShadow = true; p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]; host.frame = NSRect(origin: .zero, size: size); p.contentView = host; let cursor = NSEvent.mouseLocation; let screen = NSScreen.screens.first { $0.frame.contains(cursor) } ?? NSScreen.main!; let f = screen.visibleFrame; p.setFrameOrigin(NSPoint(x: min(max(cursor.x - size.width / 2, f.minX), f.maxX - size.width), y: min(max(cursor.y + 16, f.minY), f.maxY - size.height))); p.orderFrontRegardless(); panel = p }
    func hide() { panel?.orderOut(nil); panel = nil }
}
