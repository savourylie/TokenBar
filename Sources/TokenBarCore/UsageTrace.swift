import Foundation

// Live tail payloads. `TraceBucket` is the one snake_case shape in the
// contract (the Tauri struct has no rename attribute), hence explicit keys.

public struct TraceBucket: Decodable, Sendable {
    public let client: String
    public let agent: String
    public let model: String
    public let tokens: Int64
    public let messages: Int
    public let tokensPerMin: Double

    enum CodingKeys: String, CodingKey {
        case client, agent, model, tokens, messages
        case tokensPerMin = "tokens_per_min"
    }
}

/// Payload of `tb_tokens_per_min`: `{"tokensPerMin": <number>}`.
public struct TokensPerMin: Decodable, Sendable {
    public let tokensPerMin: Double
}
