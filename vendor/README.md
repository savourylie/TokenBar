# Vendored dependencies

| Crate | Source | Vendored from |
|---|---|---|
| `tokscale-core` | [junhoyeo/tokscale](https://github.com/junhoyeo/tokscale) (`crates/tokscale-core`, MIT) | [Nanako0129/TokenBar](https://github.com/Nanako0129/TokenBar) `vendor/tokscale-core` @ `606cae1` (v0.4.4: backfill missing cache rates from runner-up pricing source) |

> **Sync rule (historical):** the Tauri repo (`Nanako0129/TokenBar-Tauri`,
> archived 2026-06-12) used to be the single upstream-sync point. With it
> archived, this repo now owns the vendored copy; future syncs come straight
> from junhoyeo/tokscale and must re-apply the local patches below.

## Local patches (diverged from upstream)

| Patch | Files | Status upstream |
|---|---|---|
| PR #2 (perf): `HASH_MEMO` + `STORE_MEMO` process-level memos; `LocalParseOptions.modified_after` mtime pruning; `latest_source_mtime_ms()` change probe | `src/message_cache.rs`, `src/lib.rs` | not yet forwarded to junhoyeo/tokscale |
| PR #3 (perf): streaming per-file aggregation replaces materialize-then-aggregate for the graph/model/monthly/hourly reports — `StreamingAggregator` + `SessionizeAccumulator` folded by `scan_messages_streaming` in one cache-aware pass (no full-history `Vec`). Each client lane owns its dedup set (follow-up `0752e35`: prevents cross-client `dedup_key` collisions). | `src/aggregator.rs`, `src/lib.rs`, `src/sessionize.rs`, `tests/streaming_snapshot.rs` | not yet forwarded to junhoyeo/tokscale |
| #6 (fix): the **agents report** now folds over `scan_messages_streaming` too — new `get_agents_report` (mirrors `get_model_report`, `resolve_report_clients` + a single streaming pass into `AgentAccumulator`), so it shares the one deduped/per-client-gated/priced stream as every other report (resolves the issue #6 divergence: agents no longer over-counts copilot/codebuff/kimi/cursor/warp/… duplicate `dedup_key`s, and scans the same client set). `parse_local_unified_messages` survives as public API only (footgun-documented, no in-repo callers). `crates/tb_core_ffi/src/agents_report.rs` is now a thin mapper like `model_report.rs` (no longer byte-identical to the archived Tauri original — accepted). | `src/lib.rs`, `crates/tb_core_ffi/src/agents_report.rs` | not yet forwarded to junhoyeo/tokscale |
| #5 (feat): discover Claude desktop "Cowork" (local-agent-mode) transcripts. `discover_cowork_project_roots()` recurses `~/Library/Application Support/Claude/local-agent-mode-sessions/**/.claude/projects` and feeds the roots into `built_in_extra_scan_paths_for` as `ClientId::Claude`. Returns the per-session `projects` roots only, so the sibling `audit.jsonl` (a mirror of the same `usage` records) is never scanned — scanning it would double-count. | `src/scanner.rs` | not yet forwarded to junhoyeo/tokscale |
