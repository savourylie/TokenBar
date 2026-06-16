import AppKit
import SwiftUI

/// Forces the enclosing NSScrollView onto overlay-style scrollers: invisible
/// at rest, a translucent pill while scrolling, and a brief flash when the
/// popover opens so users learn the content scrolls. The system-wide "always
/// show scroll bars" preference would otherwise pin the legacy track — the
/// thick, permanently-visible strip — which is exactly the bug some users hit
/// after a relaunch.
///
/// The earlier version re-asserted only from `DispatchQueue.main.async` (in
/// makeNSView/updateNSView). On some launches that ran before the backing
/// view was in the scroll-view hierarchy, the lookup bailed, and nothing
/// re-asserted — leaving the legacy scroller stuck. This version pins the
/// style from `viewDidMoveToWindow` (fires every popover open, *after* the
/// view is attached, so `enclosingScrollView` is valid), re-pins on every
/// SwiftUI pass, and re-pins when the system preference flips.
struct OverlayScrollerEnforcer: NSViewRepresentable {
    func makeNSView(context: Context) -> EnforcerView { EnforcerView() }

    func updateNSView(_ view: EnforcerView, context: Context) { view.enforce() }

    @MainActor
    final class EnforcerView: NSView {
        private var registeredPrefObserver = false
        private var flashedInWindow = false

        override func viewWillMove(toWindow newWindow: NSWindow?) {
            super.viewWillMove(toWindow: newWindow)
            // Leaving a window arms the one-shot flash for the next appearance.
            if newWindow == nil { flashedInWindow = false }
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            enforce()
        }

        override func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            enforce()
            guard !registeredPrefObserver else { return }
            registeredPrefObserver = true
            // The system flips styles back when the global preference changes;
            // re-assert whenever that happens.
            NotificationCenter.default.addObserver(
                forName: NSScroller.preferredScrollerStyleDidChangeNotification,
                object: nil, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.enforce() }
            }
        }

        /// Pin overlay style on the enclosing scroll view and flash once per
        /// window appearance — idempotent, so every render pass can call it.
        func enforce() {
            guard let scroll = enclosingScrollView else { return }
            scroll.scrollerStyle = .overlay
            scroll.autohidesScrollers = true
            // Flash exactly once per appearance — updateNSView fires on every
            // SwiftUI pass (the 10s rate poll alone re-runs it), and re-flashing
            // kept summoning the scroller back from its fade.
            guard scroll.window != nil, !flashedInWindow else { return }
            flashedInWindow = true
            scroll.flashScrollers()
        }
    }
}
