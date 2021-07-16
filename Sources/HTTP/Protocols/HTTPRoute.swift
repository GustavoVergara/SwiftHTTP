public protocol HTTPRoute {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var query: [String: String] { get }
    var body: HTTPBody? { get }
}

public extension HTTPRoute {
    var scheme: String { "https" }
    var headers: [String: String] { [:] }
    var query: [String: String] { [:] }
    var body: HTTPBody? { nil }
}
