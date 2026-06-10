import Foundation

// Per-(sub-)agent report (`AgentsReport` in types.ts).

public struct AgentReportEntry: Decodable, Sendable {
    public let agent: String
    public let clients: [String]
    public let input: Int64
    public let output: Int64
    public let cacheRead: Int64
    public let cacheWrite: Int64
    public let reasoning: Int64
    public let total: Int64
    public let cost: Double
    public let messages: Int
}

public struct AgentsReport: Decodable, Sendable {
    public let entries: [AgentReportEntry]
    public let totalCost: Double
    public let totalMessages: Int
}
