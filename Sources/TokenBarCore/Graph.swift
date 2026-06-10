import Foundation

// Contribution-graph payload (`UsagePayload` in the Tauri frontend's
// src/lib/types.ts). Keys match the Rust serde camelCase serialization exactly.

public struct TokenBreakdown: Decodable, Sendable {
    public let input: Int64
    public let output: Int64
    public let cacheRead: Int64
    public let cacheWrite: Int64
    public let reasoning: Int64
}

public struct ContributionClient: Decodable, Sendable {
    public let client: String
    public let modelId: String
    public let providerId: String
    public let tokens: TokenBreakdown
    public let cost: Double
    public let messages: Int
}

public struct Contribution: Decodable, Sendable {
    public struct Totals: Decodable, Sendable {
        public let tokens: Int64
        public let cost: Double
        public let messages: Int
    }

    public let date: String
    public let totals: Totals
    public let intensity: Int
    public let tokenBreakdown: TokenBreakdown
    public let clients: [ContributionClient]
}

public struct DateRange: Decodable, Sendable {
    public let start: String
    public let end: String
}

public struct YearMeta: Decodable, Sendable {
    public let year: String
    public let totalTokens: Int64
    public let totalCost: Double
    public let range: DateRange
}

public struct UsagePayload: Decodable, Sendable {
    public struct Meta: Decodable, Sendable {
        public let generatedAt: String
        public let version: String
        public let dateRange: DateRange
    }

    public struct Summary: Decodable, Sendable {
        public let totalTokens: Int64
        public let totalCost: Double
        public let totalDays: Int
        public let activeDays: Int
        public let averagePerDay: Double
        public let maxCostInSingleDay: Double
        public let clients: [String]
        public let models: [String]
    }

    public let meta: Meta
    public let summary: Summary
    public let years: [YearMeta]
    public let contributions: [Contribution]
}
