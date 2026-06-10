import Foundation
import TokenBarCore

// Phase 0 smoke entry point: prove Swift → Rust → tokscale-core works on this
// machine. The menu-bar app shell replaces this in Phase 3.
do {
    let probe = try TBCore.probe()
    print("tokscale-core via Swift FFI → \(probe.messages ?? 0) parsed local messages")
} catch {
    print("FFI probe failed: \(error)")
    exit(1)
}
