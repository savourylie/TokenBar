# TokenBar

**A native macOS menu-bar monitor for AI coding-agent token usage and quotas — with Liquid Glass.**

TokenBar sits in your menu bar and shows how much you're spending across
Claude Code, Codex CLI, Cursor, Gemini CLI, OpenCode, Copilot CLI and more —
today's tokens, live tokens/min, or how much of your subscription quota is
left. Click it and a glass popover opens with stacked usage charts, an
interactive 3D contribution graph, OAuth quota cards with pace projections,
and per-agent breakdowns. Everything is read from your local session logs;
nothing is uploaded anywhere.

<p align="center">
  <img src="docs/screenshots/popover-dark.png" alt="TokenBar popover (dark) — Liquid Glass over the desktop wallpaper" width="420">
</p>

## Install

```sh
brew install --cask nanako0129/tokenbar/tokenbar
```

In-app updates arrive via Sparkle; future betas ride an opt-in update
channel (Settings → "Receive beta updates") instead of a separate app.
The app is ad-hoc signed (not notarized); the cask clears the quarantine
attribute on install, as disclosed.

Requires an Apple Silicon Mac on macOS 14+. Liquid Glass needs macOS 26;
earlier systems get a vibrancy fallback. Still on macOS 11–13? The final
Tauri build stays available as
[`tokenbar@legacy`](https://github.com/Nanako0129/TokenBar-Tauri).

## Highlights

- **The menu bar is the dashboard.** Show today's tokens or cost, all-time
  totals, live tokens/min, or remaining subscription quota. Quota mode comes
  in three icon styles — signal bars with a waterline, a ring, or a popsicle
  that melts as your 5-hour window drains — with battery-style warning colors.
  Right-click the icon to pick which subscription it tracks.
- **A running cat.** The classic RunCat-style pet paces with your token
  velocity — idle stroll between prompts, full sprint mid-session. Cat or
  parrot, with dark- and light-menu-bar variants.
- **Liquid Glass dashboard.** On macOS 26 the popover renders as clear glass
  cards floating over your wallpaper — the Control Center look. Six lenses
  (Overview / Models / Daily / Hourly / Stats / Agents) plus per-agent tabs,
  with animated transitions and full keyboard control (⌘1–9 tabs, ⌘[ ⌘]
  cycle, ⌘G chart toggle, ⌘, settings).
- **3D contribution graph.** A SceneKit year-at-a-glance token heatmap you can
  orbit and zoom, alongside 30-day stacked bars by model or agent, in tokens
  or dollars.

<p align="center">
  <img src="docs/screenshots/graph-3d.png" alt="3D contribution graph" width="420">
</p>

- **Quota cards with pace.** Codex and Claude OAuth limit windows with
  remaining %, reset times, and a pace readout — whether you're ahead of or
  behind your window, and when you'd run dry at the current burn rate.
- **Live session trace.** Tokens/min per agent while you work, with a
  network-LED activity blinker in the popover header.
- **Stale-data discipline.** A failed refresh never blanks or zeroes a
  display — the last known reading stays up until a fresh one lands.
- **Local-first, no telemetry.** Usage history is parsed from your agents' own
  session logs on disk. Network calls are limited to vendor quota lookups
  (with your existing OAuth credentials), model-price refreshes, and Sparkle
  update checks.

## How it works

Rust owns the data (session parsing, aggregation, pricing, quota fetching) via
the vendored [tokscale-core](https://github.com/junhoyeo/tokscale), exposed to
Swift as a C-ABI staticlib (`crates/tb_core_ffi`). Swift owns everything else:
SwiftUI views, the `NSStatusItem` shell, Sparkle updates.

| Part | Path | Role |
|---|---|---|
| Rust FFI | `crates/tb_core_ffi` | staticlib; JSON-returning C entry points over tokscale-core |
| C shim | `Sources/CTB` | header + modulemap so Swift can import the FFI |
| Core | `Sources/TokenBarCore` | decode JSON into Swift models; pace/stats logic |
| App | `Sources/TokenBar` | menu-bar app (SwiftUI, Liquid Glass / vibrancy fallback) |

## Build from source

Requires Swift 6 and a Rust toolchain. macOS 14+.

```bash
make        # cargo build --release, then swift build
make run    # build + run the smoke binary
```

> **Note:** run `swift build` from the repo root — the linker's `-L
> target/release` path in `Package.swift` is relative.

<details>
<summary>Rewrite progress (Tauri → native)</summary>

| Phase | Scope | Status |
|---|---|---|
| 0 | Repo skeleton: cargo workspace + SwiftPM + CI | ✅ |
| 1 | FFI data layer: 8 JSON entry points over tokscale-core + Swift models | ✅ |
| 2 | SceneKit 3D contribution-graph spike (163 fps, custom orbit rig) | ✅ |
| 3 | Menu-bar shell: NSStatusItem + popover + Liquid Glass/vibrancy | ✅ |
| 4 | Overview lens: usage chart, model breakdown, streaks | ✅ |
| 5 | Remaining lenses: Models / Daily / Hourly / Stats / Agents + tabs | ✅ |
| 6 | Agent limits + pace + live trace + settings | ✅ |
| 7 | 3D contribution graph integration | ✅ |
| 8 | Cat animation, shortcuts, quota icons, tray modes | ✅ |
| 9 | Sparkle updater, signing, packaging, release CI | ✅ (beta live) |
| 10 | Bundle-id switch, migration, v1.0.0 | in progress |

</details>

## Credits

TokenBar began as a fork of [tokcat](https://github.com/handlecusion/tokcat)
by handlecusion, and the spinning-cat idea is theirs — tracing back to the
original [RunCat](https://kyome.io/runcat/) by Takuto Nakamura. Parsing and
pricing come from [tokscale](https://github.com/junhoyeo/tokscale) by Junho
Yeo (MIT). The native menu-bar shell patterns reference
[CodexBar](https://github.com/steipete/CodexBar) by Peter Steinberger (MIT).

Licensed under [MIT](LICENSE).
