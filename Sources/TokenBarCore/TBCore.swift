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

/// Thin Swift facade over the tb_core_ffi staticlib. All calls are blocking;
/// invoke from a background thread/actor in app code.
public enum TBCore {
    /// Decode a JSON payload returned by a tb_* entry point, then free it.
    static func decode<T: Decodable>(_ raw: UnsafeMutablePointer<CChar>?) throws -> T {
        guard let raw else { throw TBCoreError.nullPointer }
        defer { tb_free(raw) }
        let data = Data(bytes: raw, count: strlen(raw))
        return try JSONDecoder().decode(T.self, from: data)
    }

    public static func probe() throws -> ProbeResult {
        let result: ProbeResult = try decode(tb_probe())
        if !result.ok { throw TBCoreError.bridge(result.err ?? "unknown") }
        return result
    }
}
