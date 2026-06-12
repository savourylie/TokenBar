import AppKit
import SwiftUI

/// Owns the standalone settings window (gear button, Cmd-comma, `--settings`).
/// One window per app, kept alive across closes so its position persists;
/// `show()` re-fronts it. The popover stays `.transient` and uninvolved —
/// the window carries its own live preview instead of pinning the popover.
@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()

    private var window: NSWindow?

    func show() {
        let window = self.window ?? makeWindow()
        self.window = window
        // Accessory apps are never frontmost; activate or the window opens
        // behind whatever app currently has focus.
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let host = NSHostingController(rootView: SettingsWindowView())
        let window = NSWindow(contentViewController: host)
        window.title = "TokenBar Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
        // The glass backdrop runs under the title bar (the popover look);
        // scroll views inset their content via the safe area.
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.center()
        // Restores any previously saved frame over the centered default.
        window.setFrameAutosaveName("tokenbar.settings")
        return window
    }
}
