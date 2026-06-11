import Foundation

/// One-shot import of settings from the retired beta identity
/// (com.nyanako.tokenbar.beta, "TokenBar Beta.app"). Runs before anything
/// reads defaults so the first launch of the stable app keeps the user's
/// tray mode, icon style, quota source, chart view, orbit camera, etc.
///
/// Only `tokenbar.*` keys are copied (everything we own is under that
/// prefix), existing values in the stable domain are never overwritten,
/// and a marker key makes the whole thing run at most once. The shared
/// pace-history file lives at data_dir/com.nyanako.tokenbar for both
/// identities, so it needs no migration.
enum BetaMigration {
    private static let markerKey = "tokenbar.migratedFromBeta"
    private static let betaDomain = "com.nyanako.tokenbar.beta"

    static func runIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: markerKey) else { return }
        defaults.set(true, forKey: markerKey)

        guard let beta = UserDefaults(suiteName: betaDomain) else { return }
        var copied = 0
        for (key, value) in beta.dictionaryRepresentation()
        where key.hasPrefix("tokenbar.") && defaults.object(forKey: key) == nil {
            defaults.set(value, forKey: key)
            copied += 1
        }
        if copied > 0 {
            NSLog("TokenBar: imported \(copied) settings from the beta app")
        }
    }
}
