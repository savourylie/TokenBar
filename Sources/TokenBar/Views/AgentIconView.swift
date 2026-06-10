import AppKit
import SwiftUI
import TokenBarCore

/// Brand-icon disc for an agent, port of the clients.ts iconRaw/iconType
/// registry (the SVGs ship as bundle resources, rendered via NSImage's
/// native SVG support — the codexbar approach). 'mono' glyphs tint white
/// over the brand-color disc; 'full' icons carry their own design and fill
/// the disc as-is; agents without an icon keep the initial-letter disc.
struct AgentIconView: View {
    let clientId: String
    var size: CGFloat = 14

    private static let monoIds: Set<String> = [
        "claude", "gemini", "opencode", "copilot", "cursor", "amp", "pi",
        "kimi", "qwen", "warp",
    ]
    private static let fullIds: Set<String> = [
        "codex", "droid", "kilocode", "kilo", "synthetic", "codebuff",
        "antigravity", "kiro",
    ]

    @MainActor private static var cache: [String: NSImage] = [:]

    @MainActor private static func image(_ id: String) -> NSImage? {
        if let cached = cache[id] { return cached }
        guard monoIds.contains(id) || fullIds.contains(id),
              let url = Bundle.module.url(
                  forResource: id, withExtension: "svg", subdirectory: "agent-icons"),
              let image = NSImage(contentsOf: url)
        else { return nil }
        cache[id] = image
        return image
    }

    var body: some View {
        let style = ClientRegistry.style(clientId)
        ZStack {
            if Self.fullIds.contains(clientId), let image = Self.image(clientId) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            } else {
                Circle().fill(Color(hex: style.color))
                if Self.monoIds.contains(clientId), let image = Self.image(clientId) {
                    Image(nsImage: image)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.64, height: size * 0.64)
                        .foregroundStyle(.white)
                } else {
                    Text(String(style.displayName.prefix(1)).uppercased())
                        .font(.system(size: size * 0.55, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
    }
}
