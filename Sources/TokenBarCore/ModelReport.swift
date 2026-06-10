import Foundation

// Per-model report (`ModelReport` in types.ts). Note: the wire key for
// throughput is `msPer1kTokens` (serde camelCase of ms_per_1k_tokens) —
// types.ts declares `msPer1KTokens` but the Rust serialization wins.

public struct ModelReportEntry: Decodable, Sendable {
    public let client: String
    public let model: String
    public let provider: String
    public let input: Int64
    public let output: Int64
    public let cacheRead: Int64
    public let cacheWrite: Int64
    public let reasoning: Int64
    public let total: Int64
    public let messageCount: Int
    public let cost: Double
    public let msPer1kTokens: Double?
}

public struct ModelReport: Decodable, Sendable {
    public let entries: [ModelReportEntry]
    public let totalInput: Int64
    public let totalOutput: Int64
    public let totalCacheRead: Int64
    public let totalCacheWrite: Int64
    public let totalMessages: Int
    public let totalCost: Double
}
