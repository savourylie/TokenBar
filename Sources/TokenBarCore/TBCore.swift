import CTB
import Foundation

/// Errors crossing the Rust FFI boundary.
public enum TBCoreError: Error {
    case nullPointer
    case bridge(String)
}

/// Result of the `tb_probe` smoke entry point.
public struct ProbeResult: Decodable {
    public let ok: Bool
    public let messages: Int?
    public let err: String?
}

/// Standard envelope every non-probe entry point returns:
/// `{"ok":true,"data":<payload>}` or `{"ok":false,"err":"..."}`.
struct TBEnvelope<T: Decodable>: Decodable {
    let ok: Bool
    let data: T?
    let err: String?
}

/// Thin Swift facade over the tb_core_ffi staticlib. All calls are blocking;
/// invoke from a background thread/actor in app code. `agentUsage()` is also
/// network-bound.
public enum TBCore {
    /// Decode a JSON payload returned by a tb_* entry point, then free it.
    static func decode<T: Decodable>(_ raw: UnsafeMutablePointer<CChar>?) throws -> T {
        guard let raw else { throw TBCoreError.nullPointer }
        defer { tb_free(raw) }
        let data = Data(bytes: raw, count: strlen(raw))
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Decode an enveloped payload, surfacing `{"ok":false}` as a thrown error.
    static func unwrap<T: Decodable>(_ raw: UnsafeMutablePointer<CChar>?) throws -> T {
        let envelope: TBEnvelope<T> = try decode(raw)
        guard envelope.ok, let data = envelope.data else {
            throw TBCoreError.bridge(envelope.err ?? "unknown")
        }
        return data
    }

    /// Pass an optional year filter across the boundary (nil = all time).
    private static func withYear<R>(
        _ year: String?, _ body: (UnsafePointer<CChar>?) -> R
    ) -> R {
        guard let year else { return body(nil) }
        return year.withCString { body($0) }
    }

    public static func probe() throws -> ProbeResult {
        let result: ProbeResult = try decode(tb_probe())
        if !result.ok { throw TBCoreError.bridge(result.err ?? "unknown") }
        return result
    }

    /// Contribution graph for `year` (nil = all time). Served from a <=30s
    /// cache inside the staticlib when warm.
    public static func graph(year: String? = nil) throws -> UsagePayload {
        try unwrap(withYear(year) { tb_graph($0) })
    }

    /// Contribution graph, always recomputed.
    public static func refreshGraph(year: String? = nil) throws -> UsagePayload {
        try unwrap(withYear(year) { tb_refresh_graph($0) })
    }

    public static func modelReport(year: String? = nil) throws -> ModelReport {
        try unwrap(withYear(year) { tb_model_report($0) })
    }

    public static func hourlyReport(year: String? = nil) throws -> HourlyReport {
        try unwrap(withYear(year) { tb_hourly_report($0) })
    }

    public static func agentsReport(year: String? = nil) throws -> AgentsReport {
        try unwrap(withYear(year) { tb_agents_report($0) })
    }

    /// Live trace buckets over the trailing `windowSecs`.
    public static func usageTrace(windowSecs: Int64) throws -> [TraceBucket] {
        try unwrap(tb_usage_trace(windowSecs))
    }

    /// Live tokens/min estimate (10-minute-window average).
    public static func tokensPerMin() throws -> Double {
        let payload: TokensPerMin = try unwrap(tb_tokens_per_min())
        return payload.tokensPerMin
    }

    /// OAuth quota cards for codex/claude/antigravity/copilot. Network-bound;
    /// per-provider failures are reported in each snapshot's `error`.
    public static func agentUsage() throws -> AgentUsagePayload {
        try unwrap(tb_agent_usage())
    }
}
