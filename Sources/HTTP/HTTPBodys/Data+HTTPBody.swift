import Foundation

extension Data: HTTPBody {
    public func data() throws -> Data { self }
}
