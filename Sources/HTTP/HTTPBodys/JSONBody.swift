import Foundation

public struct JSONBody<T: Encodable>: HTTPBody {
    public var encodable: T
    public var encoder: JSONEncoder
    
    public init(encodable: T, encoder: JSONEncoder = JSONEncoder()) {
        self.encodable = encodable
        self.encoder = encoder
    }
    
    public var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    public func data() throws -> Data {
        try encoder.encode(encodable)
    }
}
