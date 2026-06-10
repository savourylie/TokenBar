import Foundation

// Entry point. The menu-bar app shell lands next; until then the executable
// still runs the smoke flow directly (CI already invokes it as `--smoke`).
exit(Smoke.run())
