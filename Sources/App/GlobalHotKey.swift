import Carbon.HIToolbox

@MainActor final class GlobalHotKey {
    static let shared = GlobalHotKey()
    private static var callback: (() -> Void)?
    private static var handlerInstalled = false
    private var reference: EventHotKeyRef?

    func register(_ action: @escaping () -> Void) {
        unregister(); Self.callback = action; installHandlerIfNeeded()
        let id = EventHotKeyID(signature: OSType(0x43555354), id: 1) // "CUST"
        let status = RegisterEventHotKey(UInt32(kVK_ANSI_X), UInt32(cmdKey | optionKey | controlKey), id, GetApplicationEventTarget(), 0, &reference)
        assert(status == noErr, "Could not register the Codex Usage Status hotkey: \(status)")
    }

    func unregister() { if let reference { UnregisterEventHotKey(reference) }; reference = nil; Self.callback = nil }

    private func installHandlerIfNeeded() {
        guard !Self.handlerInstalled else { return }
        var type = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let status = InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in
            Task { @MainActor in GlobalHotKey.callback?() }; return noErr
        }, 1, &type, nil, nil)
        Self.handlerInstalled = status == noErr
        assert(status == noErr, "Could not install the Codex Usage Status hotkey handler: \(status)")
    }
}
