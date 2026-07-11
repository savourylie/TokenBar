## Features

- **Reorder and hide client tabs.** Settings has a new "Client tabs (top bar)" section: drag your providers into the order you want and uncheck the ones you don't use. Hiding a client removes it everywhere — the tab bar, every Overview total, the charts, the menu-bar title and live rate, and each lens — as if it never existed, and unhiding restores it instantly. Thanks [@savourylie](https://github.com/savourylie) ([#28](https://github.com/Nanako0129/TokenBar/pull/28), semantics completed in [#36](https://github.com/Nanako0129/TokenBar/pull/36)).
- **Hide the Agent-limits card, globally or per client.** A master "Show Agent limits card" switch plus per-client toggles, independent of tab visibility: a Claude Console account with usage but no OAuth quota can tuck the card away without losing its tab or numbers. Thanks [@yiskang](https://github.com/yiskang) ([#33](https://github.com/Nanako0129/TokenBar/issues/33), [#34](https://github.com/Nanako0129/TokenBar/pull/34)).

## Fixes

- **Dropped the phantom `<synthetic>` row from the Claude model breakdown.** Claude Code stamps locally-fabricated turns (cancelled requests, injected continuations) with a `<synthetic>` model; they carry zero tokens and only showed as an empty placeholder row. Totals are unchanged. Thanks [@starburst3190](https://github.com/starburst3190) ([#30](https://github.com/Nanako0129/TokenBar/pull/30)).
- **Hourly and Agents reports now filter per client in the core engine** instead of approximating in the UI — which also fixes single-client tabs showing whole-bucket totals for hours or agents shared with other clients ([#36](https://github.com/Nanako0129/TokenBar/pull/36)).
- **Token sums saturate instead of overflowing on corrupt data**, and live-trace client ids normalize consistently ([#36](https://github.com/Nanako0129/TokenBar/pull/36)).
