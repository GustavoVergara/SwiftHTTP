import Foundation

public protocol HTTPBody {
    var additionalHeaders: [String: String] { get }
    func data() throws -> Data
}

public extension HTTPBody {
    var additionalHeaders: [String: String] { [:] }
}
